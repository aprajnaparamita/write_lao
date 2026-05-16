# Word Timing Pipeline Plan

## Goal

Generate a `word_timings.json` asset that maps every audio file in
`assets/vocab/audio/` to microsecond-precision per-word timestamps, plus a
contextual 1–3 word translation in each of the 16 supported languages. This
enables a Flutter UI feature where the app plays an example sentence at
pitch-corrected slow speed and highlights each word (Lao above, translation
below) as it is spoken.

---

## Where Each Step Runs

| Step | Where | Why |
|------|-------|-----|
| Script 1 — Whisper timing extraction | **vast.ai GPU** | GPU-accelerated; ~1500 audio files |
| Script 2 — DeepSeek translations | **vast.ai** (same instance) | CPU/network bound; convenient to keep together |
| Script 3 — Merge | **local Mac** | Trivial JSON merge; no reason to keep instance running |

---

## vast.ai Instance Guide

### What to Rent

Go to [vast.ai](https://vast.ai) → **Search** tab → set these filters:

| Setting | Value | Notes |
|---------|-------|-------|
| GPU | **RTX 3090** or **RTX 4090** | 24GB VRAM; both have faster-whisper large-v3 headroom (needs ~3GB VRAM) |
| VRAM | 24 GB minimum | Ensures model loads without swapping |
| RAM | 16 GB+ | For audio buffers and Python overhead |
| Disk | **30 GB** | OS + CUDA libs + models (~5GB) + audio files (~200MB) + outputs |
| GPU count | 1 | One GPU is plenty for this serial workload |
| CUDA | 12.1 or higher | Required for faster-whisper |
| Reliability | > 95% | Avoids mid-job interruptions |

**Recommended bid:** Use **on-demand** pricing (not spot/interruptible) since the
whisper job runs 15–30 minutes and an interruption means re-running that batch.
Both scripts are resumable (skip if output already exists), so interruptions are
recoverable, but on-demand is still cheaper in wall-clock time.

**Cost estimate:**
- RTX 3090: ~$0.20–0.30/hr on-demand
- Full job (both scripts): ~1 hour total
- Total GPU cost: **~$0.30**

### Docker Image to Select

In the vast.ai instance template, choose:

```
pytorch/pytorch:2.4.1-cuda12.1-cudnn8-devel
```

This is available as a preset in the vast.ai "Image" dropdown. It ships with:
- Python 3.11
- CUDA 12.1 + cuDNN 8
- PyTorch 2.4 pre-installed
- pip ready

If that exact tag isn't listed, use any `pytorch/pytorch` image with
`cuda12.x` and `devel` in the name. The `devel` variant is needed because
faster-whisper's CTranslate2 backend requires CUDA headers.

### Storage Volume

When creating the instance, set **Disk Space** to **30 GB**. vast.ai bills
storage separately at ~$0.01/GB/hr — negligible for this job.

---

## Local Preparation (do this on your Mac before SSHing in)

### 1. Install rsync if not present

```bash
brew install rsync   # likely already installed
```

### 2. Count your audio files

```bash
ls /Volumes/Dara/dev/write_lao/assets/vocab/audio/*.m4a | wc -l
# expect ~1500 files (500 words × 3 audio each)
```

### 3. Create the pipeline script directory

```bash
mkdir -p /Volumes/Dara/dev/write_lao/prompts/data/word_timing_pipeline
```

Write the three scripts (01, 02, 03) into this directory as described in the
Script sections below. They will be uploaded to the instance.

---

## vast.ai Setup (run once after instance starts)

SSH into the instance. vast.ai gives you the SSH command in the instance panel:
```
ssh -p PORT root@IP_ADDRESS
```

### Step A — System packages

```bash
apt-get update -qq
apt-get install -y ffmpeg git htop tmux
```

Verify ffmpeg:
```bash
ffmpeg -version | head -1
# should print: ffmpeg version 6.x or similar
```

### Step B — Python dependencies

```bash
pip install --upgrade pip
pip install faster-whisper openai tqdm numpy
```

Verify faster-whisper + CUDA:
```bash
python3 -c "
from faster_whisper import WhisperModel
import torch
print('CUDA available:', torch.cuda.is_available())
print('GPU:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'none')
m = WhisperModel('tiny', device='cuda', compute_type='float16')
print('faster-whisper OK')
"
```

Expected output:
```
CUDA available: True
GPU: NVIDIA GeForce RTX 3090
faster-whisper OK
```

### Step C — Download the Whisper model (do this before uploading audio)

Pre-download so it doesn't happen mid-batch:

```bash
python3 -c "
from faster_whisper import WhisperModel
print('Downloading large-v3...')
WhisperModel('large-v3', device='cuda', compute_type='float16')
print('Done.')
"
```

This downloads ~3GB from Hugging Face. Takes 1–3 minutes depending on instance
network speed. The model caches to `~/.cache/huggingface/`.

### Step D — Upload files from Mac

Run these on your **local Mac** (not inside SSH):

```bash
# Set your instance details (copy from vast.ai dashboard)
VAST_IP="12.34.56.78"
VAST_PORT="12345"

# Create workspace dirs on instance
ssh -p $VAST_PORT root@$VAST_IP "mkdir -p /workspace/audio /workspace/pipeline /workspace/timings /workspace/translations"

# Upload audio files (~200MB, takes 1-3 min)
rsync -avz --progress \
  -e "ssh -p $VAST_PORT" \
  /Volumes/Dara/dev/write_lao/assets/vocab/audio/ \
  root@$VAST_IP:/workspace/audio/

# Upload course.json
scp -P $VAST_PORT \
  /Volumes/Dara/dev/write_lao/assets/vocab/course.json \
  root@$VAST_IP:/workspace/course.json

# Upload pipeline scripts
rsync -avz \
  -e "ssh -p $VAST_PORT" \
  /Volumes/Dara/dev/write_lao/prompts/data/word_timing_pipeline/ \
  root@$VAST_IP:/workspace/pipeline/
```

Verify upload:
```bash
ssh -p $VAST_PORT root@$VAST_IP "ls /workspace/audio/*.m4a | wc -l"
# should match your local count
```

---

## Script 1 — `01_extract_timings.py`

**On vast.ai at:** `/workspace/pipeline/01_extract_timings.py`

**Purpose:** For each audio file, use faster-whisper with `large-v3` on CUDA to
get per-word timestamps. For example sentences, align Whisper output tokens to
the known `lao_script` reference words (space-separated, already in
`course.json`). For single-word files (`_word`), return the single word with
VAD-snapped start/end.

**Paths on instance:**
- Input audio: `/workspace/audio/*.m4a`
- Input reference: `/workspace/course.json`
- Output: `/workspace/timings/<stem>.json` (~1500 files)

**Algorithm:**

```
Load WhisperModel("large-v3", device="cuda", compute_type="float16")
Load course.json → build ref_map: {stem → {ref_words: [...], lao_script: str}}

for each .m4a in /workspace/audio/ (sorted):
  stem = filename without extension (e.g. "w_0001_example1")
  skip if /workspace/timings/<stem>.json already exists

  convert m4a → 16kHz mono WAV via ffmpeg (tmp file)
  
  segments, _ = model.transcribe(wav,
      word_timestamps=True, language="lo",
      beam_size=5, vad_filter=False)
  whisper_words = [w for seg in segments for w in (seg.words or [])]

  ref = ref_map[stem]
  if stem ends with "_word":
    result = single_word_timing(whisper_words, ref["lao_word"], wav_duration)
  else:
    result = align_to_reference(whisper_words, ref["ref_words"], wav_duration)

  write /workspace/timings/<stem>.json
  delete tmp WAV
```

**Whisper → Reference Word Alignment (`align_to_reference`):**

Lao has no natural spaces so Whisper tokenises by character clusters, not
words. Since `lao_script` already has manually space-separated words (the
ground truth), align Whisper tokens to them character-count-first:

```python
def align_to_reference(whisper_words, ref_words, total_duration_s):
    """
    Greedily consume whisper_words to cover each ref_word by character count.
    Returns list of {lao, start_us, end_us}.
    """
    result = []
    wptr = 0  # pointer into whisper_words
    
    for ref_word in ref_words:
        ref_chars = len(ref_word.replace(" ", ""))
        consumed_chars = 0
        span_start = None
        span_end = None
        
        while wptr < len(whisper_words) and consumed_chars < ref_chars:
            w = whisper_words[wptr]
            tok = w.word.strip()
            if span_start is None:
                span_start = w.start
            span_end = w.end
            consumed_chars += len(tok)
            wptr += 1
        
        if span_start is None:
            # Whisper ran out of tokens — divide remaining duration evenly
            remaining = len(ref_words) - len(result)
            elapsed = result[-1]["end_us"] / 1_000_000 if result else 0
            chunk = (total_duration_s - elapsed) / remaining
            start = elapsed + (len(result) - len([r for r in result if r])) * chunk
            span_start = start
            span_end = start + chunk
        
        result.append({
            "lao": ref_word,
            "start_us": int(round(span_start * 1_000_000)),
            "end_us":   int(round(span_end   * 1_000_000)),
        })
    
    return result
```

**Single-word timing (`single_word_timing`):**

```python
def single_word_timing(whisper_words, lao_word, total_duration_s):
    """For _word files: one entry spanning the voiced portion."""
    if whisper_words:
        start_s = whisper_words[0].start
        end_s   = whisper_words[-1].end
    else:
        # VAD fallback: RMS scan for voice onset
        start_s = rms_voice_onset(wav_path)  # reuse pattern from extract_words_whisper.py
        end_s   = total_duration_s - 0.05
    
    return [{
        "lao":      lao_word,
        "start_us": int(round(start_s * 1_000_000)),
        "end_us":   int(round(end_s   * 1_000_000)),
    }]
```

The `rms_voice_onset` function is a direct copy of `rms_word_start_fallback`
from `extract_words_whisper.py` — searches for first RMS frame above -35dB.

**Output per file:**
```json
{
  "audio_path": "audio/w_0001_example1.m4a",
  "duration_us": 2840000,
  "lao_script": "ຂ້ອຍ ແລະ ເພື່ອນ ໄປ ຕະຫຼາດ",
  "words": [
    {"lao": "ຂ້ອຍ", "start_us": 95000, "end_us": 410000},
    {"lao": "ແລະ",  "start_us": 430000, "end_us": 610000}
  ]
}
```

(`lao_script` only present for example entries, omitted for `_word` entries.)

**Expected runtime:** ~15–25 minutes for all 1500 files on RTX 3090 with large-v3.
Use `tmux` so SSH disconnect doesn't kill it:
```bash
tmux new -s timing
python3 /workspace/pipeline/01_extract_timings.py
# Ctrl+B then D to detach; tmux attach -t timing to reattach
```

**Progress output** (the script should print one line per file):
```
[  1/1500] w_0001_word        0.42s  1 word   ✓
[  2/1500] w_0001_example1    2.84s  5 words  ✓
[  3/1500] w_0001_example2    3.10s  5 words  ✓
...
```

---

## Script 2 — `02_generate_translations.py`

**On vast.ai at:** `/workspace/pipeline/02_generate_translations.py`

**Purpose:** For each word in each timing entry, call DeepSeek to get a
contextual 1–3 word translation in all 16 languages in a single API call.

**Paths on instance:**
- Input timings: `/workspace/timings/<stem>.json`
- Input reference: `/workspace/course.json`
- Output: `/workspace/translations/<stem>.json`

**DeepSeek API:**
- Base URL: `https://api.deepseek.com/v1` (OpenAI-compatible)
- Model: `deepseek-chat` (DeepSeek V3 — fast, cheap, multilingual quality)
  - Use `deepseek-reasoner` (R1) only if spot-checking reveals V3 makes
    systematic errors on a specific language
- API key: `export DEEPSEEK_API_KEY="sk-..."` before running
- Client: `pip install openai` (already OpenAI-compatible, no DeepSeek SDK needed)

**Context lookup per stem:**

Build a lookup from `course.json` so every word call has sentence context:

```python
# For w_0001_example1 → word "ແລະ":
#   context_sentence_lao  = "ຂ້ອຍ ແລະ ເພື່ອນ ໄປ ຕະຫຼາດ"
#   context_translations  = {"en": "My friend and I are going to the market.", ...}
#
# For w_0001_word → word "ແລະ":
#   context_definitions   = {"en": "and (conjunction...)", ...}
#   (use definitions block, no sentence)
```

**System prompt (constant across all calls):**
```
You are a Lao language expert providing ultra-concise contextual word
translations for on-screen subtitles timed to spoken audio. Each translation
must be 1–3 words maximum — the shortest form that accurately conveys the
word's meaning in this specific context. Respond ONLY with a valid JSON object.
No markdown, no explanation, no punctuation in the translations.
```

**User prompt — example sentences:**
```
Lao sentence: {lao_script}

Full sentence translations:
  en: {en_translation}
  th: {th_translation}
  de: {de_translation}
  [... all 16 languages ...]

Target Lao word: {lao_word}

Provide the shortest accurate contextual translation of "{lao_word}" as used
in this sentence, in each language (1–3 words max, no punctuation).

Return ONLY this JSON:
{
  "en": "...", "th": "...", "de": "...", "fr": "...",
  "es": "...", "zh": "...", "zh_Hant": "...", "ja": "...",
  "ko": "...", "vi": "...", "hi": "...", "pt": "...",
  "tl": "...", "km": "...", "ne": "...", "ur": "..."
}
```

**User prompt — word-only files (`_word`):**
```
Lao word: {lao_word}

Word definitions:
  en: {en_definition}
  th: {th_definition}
  [... all 16 languages ...]

Provide a short general translation of "{lao_word}" in each language
(1–3 words max, no punctuation — like a dictionary gloss).

Return ONLY this JSON:
{
  "en": "...", "th": "...", ...
}
```

**Deduplication cache:**

Many words recur across examples. Cache results in memory keyed on
`(lao_word, sentence_lao)` to avoid redundant API calls within the same run.

```python
translation_cache = {}

def get_translation(lao_word, context_key, prompt_fn):
    key = (lao_word, context_key)
    if key in translation_cache:
        return translation_cache[key]
    result = call_deepseek(prompt_fn())
    translation_cache[key] = result
    return result
```

**Error handling:**
- Strip markdown fences from response before JSON parse.
- On `json.JSONDecodeError`: retry up to 3× with backoff (1s, 2s, 4s).
- On 3rd failure: write `{}` for that word's translations, log to
  `/workspace/pipeline/failed_translations.log` for later re-run.

**Parallelism:** Use `ThreadPoolExecutor(max_workers=5)` across stems.
DeepSeek allows ~50 concurrent requests; 5 workers is conservative and safe.

**Resumability:** Skip stems where `/workspace/translations/<stem>.json` exists.

**Rate limiting:** DeepSeek V3 has a 500 RPM limit on the free tier, higher on
paid. With 5 workers and ~0.5s per call you'll run at ~600 RPM — add a
`time.sleep(0.1)` per call as a light throttle if you hit 429 errors.

**Expected runtime:** ~6,000 unique calls × 0.5s average / 5 workers ≈ **10 minutes**.

**Cost estimate:**
- ~6,000 calls × ~400 input tokens × $0.27/million = **~$0.65**
- Output tokens ~150 × $1.10/million = **~$0.99**
- **Total: ~$1.65 for all translations**

Run in tmux:
```bash
export DEEPSEEK_API_KEY="sk-..."
tmux new -s translations
python3 /workspace/pipeline/02_generate_translations.py
```

**Output per file** (same as timings JSON, words now include `translations`):
```json
{
  "audio_path": "audio/w_0001_example1.m4a",
  "duration_us": 2840000,
  "lao_script": "ຂ້ອຍ ແລະ ເພື່ອນ ໄປ ຕະຫຼາດ",
  "words": [
    {
      "lao": "ຂ້ອຍ",
      "start_us": 95000,
      "end_us": 410000,
      "translations": {
        "en": "I", "th": "ฉัน", "de": "ich", "fr": "je",
        "es": "yo", "zh": "我", "zh_Hant": "我", "ja": "私",
        "ko": "저", "vi": "tôi", "hi": "मैं", "pt": "eu",
        "tl": "ako", "km": "ខ្ញុំ", "ne": "म", "ur": "میں"
      }
    }
  ]
}
```

---

## Downloading Results

Run on your **local Mac** after both scripts complete:

```bash
VAST_IP="12.34.56.78"
VAST_PORT="12345"

# Download all translation JSONs (~1500 small files)
rsync -avz --progress \
  -e "ssh -p $VAST_PORT" \
  root@$VAST_IP:/workspace/translations/ \
  /Volumes/Dara/dev/write_lao/prompts/data/word_timing_pipeline/translations/

# Also grab the failed log if any
scp -P $VAST_PORT \
  root@$VAST_IP:/workspace/pipeline/failed_translations.log \
  /Volumes/Dara/dev/write_lao/prompts/data/word_timing_pipeline/ 2>/dev/null || true

# Destroy the instance once confirmed complete
# (do this from the vast.ai dashboard — don't leave it running)
```

---

## Script 3 — `03_merge.py`

**Runs locally on Mac.**

**Purpose:** Merge all per-file `translations/<stem>.json` into the final
`assets/vocab/word_timings.json`.

**Paths:**
- Input: `prompts/data/word_timing_pipeline/translations/*.json`
- Output: `assets/vocab/word_timings.json`

**Logic:**
```python
#!/usr/bin/env python3
from pathlib import Path
from datetime import datetime, timezone
import json

TRANSLATIONS = Path(__file__).parent / "translations"
OUTPUT       = Path(__file__).parent.parent.parent.parent / "assets/vocab/word_timings.json"

entries = {}
for path in sorted(TRANSLATIONS.glob("*.json")):
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    entries[path.stem] = data

output = {
    "version": "1.0.0",
    "generated": datetime.now(timezone.utc).isoformat(),
    "entry_count": len(entries),
    "entries": entries,
}

with open(OUTPUT, "w", encoding="utf-8") as f:
    json.dump(output, f, ensure_ascii=False, separators=(",", ":"))

total_words = sum(len(e.get("words", [])) for e in entries.values())
size_kb = OUTPUT.stat().st_size / 1024
print(f"Wrote {len(entries)} entries / {total_words} words → {OUTPUT}")
print(f"File size: {size_kb:.0f} KB")
```

Run:
```bash
cd /Volumes/Dara/dev/write_lao
python3 prompts/data/word_timing_pipeline/03_merge.py
```

---

## Directory Structure

### On vast.ai instance:
```
/workspace/
├── audio/                    ← uploaded m4a files (~1500)
├── course.json               ← uploaded from assets/vocab/
├── pipeline/
│   ├── 01_extract_timings.py
│   ├── 02_generate_translations.py
│   ├── 03_merge.py           ← not run here, included for reference
│   ├── timings/              ← created by script 1
│   ├── translations/         ← created by script 2
│   └── failed_translations.log
```

### On local Mac (repo):
```
prompts/data/word_timing_pipeline/
├── 01_extract_timings.py
├── 02_generate_translations.py
├── 03_merge.py
├── timings/                  ← optional local copy
└── translations/             ← downloaded from instance

assets/vocab/
└── word_timings.json         ← final output of script 3
```

---

## Complete Run Order

### On vast.ai:
```bash
# 1. Setup (once)
apt-get install -y ffmpeg tmux htop
pip install faster-whisper openai tqdm numpy

# 2. Pre-download Whisper model
python3 -c "from faster_whisper import WhisperModel; WhisperModel('large-v3', device='cuda', compute_type='float16')"

# 3. Run timing extraction
tmux new -s timing
python3 /workspace/pipeline/01_extract_timings.py
# wait ~20min; Ctrl+B D to detach

# 4. Verify timing output
ls /workspace/timings/ | wc -l   # should be ~1500
cat /workspace/timings/w_0001_example1.json | python3 -m json.tool

# 5. Run translation generation
export DEEPSEEK_API_KEY="sk-..."
tmux new -s trans
python3 /workspace/pipeline/02_generate_translations.py
# wait ~10min
```

### On local Mac:
```bash
# 6. Download results
rsync -avz -e "ssh -p PORT" root@IP:/workspace/translations/ \
  /Volumes/Dara/dev/write_lao/prompts/data/word_timing_pipeline/translations/

# 7. Merge
python3 /Volumes/Dara/dev/write_lao/prompts/data/word_timing_pipeline/03_merge.py

# 8. Validate
python3 /Volumes/Dara/dev/write_lao/prompts/data/word_timing_pipeline/validate.py

# 9. Destroy vast.ai instance from dashboard
```

---

## Validation Script — `validate.py`

```bash
# Run locally after 03_merge.py
python3 /Volumes/Dara/dev/write_lao/prompts/data/word_timing_pipeline/validate.py
```

```python
#!/usr/bin/env python3
import json
from pathlib import Path

OUTPUT = Path(__file__).parent.parent.parent.parent / "assets/vocab/word_timings.json"
LANGS  = {"en","th","de","fr","es","zh","zh_Hant","ja","ko","vi","hi","pt","tl","km","ne","ur"}

with open(OUTPUT, encoding="utf-8") as f:
    d = json.load(f)

entries = d["entries"]
word_entries = [k for k in entries if k.endswith("_word")]
ex1_entries  = [k for k in entries if k.endswith("_example1")]
ex2_entries  = [k for k in entries if k.endswith("_example2")]

print(f"Total entries : {len(entries)}")
print(f"  _word       : {len(word_entries)}")
print(f"  _example1   : {len(ex1_entries)}")
print(f"  _example2   : {len(ex2_entries)}")
print(f"File size     : {OUTPUT.stat().st_size / 1024:.0f} KB")

# Check for missing/empty translations
missing_langs, empty_words, bad_timing = [], [], []
for key, entry in entries.items():
    for w in entry.get("words", []):
        t = w.get("translations", {})
        missing = LANGS - set(t.keys())
        if missing:
            missing_langs.append((key, w["lao"], missing))
        if not w.get("lao"):
            empty_words.append(key)
        if w.get("start_us", 0) >= w.get("end_us", 0):
            bad_timing.append((key, w["lao"], w.get("start_us"), w.get("end_us")))

print(f"\nIssues:")
print(f"  Missing lang codes : {len(missing_langs)}")
print(f"  Empty lao fields   : {len(empty_words)}")
print(f"  Bad timing (s>=e)  : {len(bad_timing)}")

if missing_langs[:3]:
    print("\nSample missing langs:")
    for item in missing_langs[:3]:
        print(f"  {item}")
if bad_timing[:3]:
    print("\nSample bad timings:")
    for item in bad_timing[:3]:
        print(f"  {item}")

# Sample output
print("\nSample w_0001_example1:")
sample = entries.get("w_0001_example1", {})
for w in sample.get("words", []):
    print(f"  {w['lao']:15s}  {w['start_us']:>8}µs – {w['end_us']:>8}µs  en='{w['translations'].get('en','?')}'")
```

---

## Existing Code to Reuse

These functions exist in `prompts/data/extract_words_whisper.py` and
`prompts/data/extract_examples_whisper.py`. Copy them into the new scripts
rather than importing (to keep the vast.ai scripts self-contained):

| Function | Source file | Use in |
|----------|------------|--------|
| `load_raw(path, start, end, sr)` | `extract_words_whisper.py:67` | Script 1 — load WAV slice |
| `trim_trailing_silence(audio, sr)` | `extract_words_whisper.py:103` | Script 1 — clip silence |
| `rms_word_start_fallback(audio, sr)` | `extract_words_whisper.py:82` | Script 1 — VAD fallback for `_word` |
| `ffprobe_duration(path)` | `extract_words_whisper.py:31` | Script 1 — get total duration |
| `save_wav(audio, sr, path)` | `extract_words_whisper.py:114` | Script 1 — if any WAV output needed |
| `energy_snap(path, t, window)` | `extract_examples_whisper.py:66` | Script 1 — snap boundaries to silence |

---

## Output Schema (final `word_timings.json`)

```json
{
  "version": "1.0.0",
  "generated": "2026-05-08T12:00:00Z",
  "entry_count": 1500,
  "entries": {
    "w_0001_word": {
      "audio_path": "audio/w_0001_word.m4a",
      "duration_us": 420000,
      "words": [
        {
          "lao": "ແລະ",
          "start_us": 48000,
          "end_us": 390000,
          "translations": {
            "en": "and", "th": "และ", "de": "und", "fr": "et",
            "es": "y", "zh": "和", "zh_Hant": "和", "ja": "そして",
            "ko": "그리고", "vi": "và", "hi": "और", "pt": "e",
            "tl": "at", "km": "និង", "ne": "र", "ur": "اور"
          }
        }
      ]
    },
    "w_0001_example1": {
      "audio_path": "audio/w_0001_example1.m4a",
      "duration_us": 2840000,
      "lao_script": "ຂ້ອຍ ແລະ ເພື່ອນ ໄປ ຕະຫຼາດ",
      "words": [
        {
          "lao": "ຂ້ອຍ",
          "start_us": 95000,
          "end_us": 410000,
          "translations": {
            "en": "I", "th": "ฉัน", "de": "ich", "fr": "je",
            "es": "yo", "zh": "我", "zh_Hant": "我", "ja": "私",
            "ko": "저", "vi": "tôi", "hi": "मैं", "pt": "eu",
            "tl": "ako", "km": "ខ្ញុំ", "ne": "म", "ur": "میں"
          }
        },
        {
          "lao": "ແລະ",
          "start_us": 430000,
          "end_us": 610000,
          "translations": {
            "en": "and", "th": "และ", "de": "und", "fr": "et",
            "es": "y", "zh": "和", "zh_Hant": "和", "ja": "そして",
            "ko": "그리고", "vi": "và", "hi": "और", "pt": "e",
            "tl": "at", "km": "និង", "ne": "र", "ur": "اور"
          }
        }
      ]
    }
  }
}
```

**Rules:**
- All times: integer microseconds (seconds × 1,000,000, rounded).
- `start_us`/`end_us` are relative to start of that individual audio file.
- `lao_script` only present for `_example1` and `_example2` entries.
- All 16 language codes present in every `translations` object.
- File written compact (no indent) to minimise bundle size.

---

## Flutter UI Notes (for future implementation)

**Playback mechanics:**
- `just_audio` package: `player.setSpeed(0.4)` + `player.setPitch(2.5)` →
  2.5× slowdown at natural pitch. Android uses SonicProcessor; iOS uses
  AVAudioEngine — both support independent speed/pitch natively.
- Stream `player.positionStream` → microseconds → binary-search `words` array
  for current word index. Use `ValueNotifier<int>` for index to avoid full
  widget rebuild.

**UI layout:**
```
┌─────────────────────────────────────────────┐
│  ຂ້ອຍ   ແລະ   ເພື່ອນ   ໄປ   ຕະຫຼາດ           │  ← all words visible, active highlighted
│   I    and   friend   go   market           │  ← localized translation, active highlighted
└─────────────────────────────────────────────┘
             [◀]  [▶ Play]  [▶▶]
               Speed: [0.5×] [1×]
```

- Entry key to load: `${wordId}_example1` or `${wordId}_example2`
- Language to show: user's selected locale from app settings
