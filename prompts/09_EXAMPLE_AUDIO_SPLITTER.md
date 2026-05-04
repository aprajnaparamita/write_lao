# Example Audio Splitter — Precise Forced Alignment + Verification

## Problem

We have 13 TTS batch MP3 files in `prompts/data/examples/` (e.g. `1_54.mp3`,
`136_174.mp3`, …). Each file contains 76–88 Lao example sentences spoken in
order. Before each sentence the TTS speaks a spoken label: "175A", "175B", etc.
We know the exact Lao text for every sentence (from the paired `.txt` files).

We need to extract exactly 1 000 WAV files:

```
assets/vocab/audio/w_NNNN_example1.wav   ← entry NNNNa
assets/vocab/audio/w_NNNN_example2.wav   ← entry NNNNb
```

Format: 16 kHz mono PCM signed-16-bit WAV.

**Why the previous approach failed:**  Whisper word-timestamps lag the true audio
onset by 200–400 ms. Using those timestamps to infer cut points causes the next
entry's spoken label to bleed into the tail of each clip, and sometimes produces
clips that are many seconds too long when no next-entry timestamp is found.

**Required approach:**  
1. Detect each entry's approximate window using Whisper digit-token runs (existing
   code is fine for ±1 s accuracy).  
2. Within that window, run **character-level forced alignment** using the *known
   Lao text* to get precise ±30 ms start/end.  
3. Extract the clip with those exact boundaries.  
4. Verify by re-transcribing the extracted clip and computing **CER** vs the
   expected text.  
5. Produce a JSON report. rsync or tar back to local.

---

## Input Data Format

Each `.txt` file contains one line per sentence:

```
175a.ຂ້ອຍໄປໂຮງຮຽນ
175b.ຂ້ອຍຮຽນພາສາລາວ
176a.ລາວຊ່ວຍຂ້ອຍ
...
```

Pattern: `^(\d+)([ab])\.(.+)$`

The matching MP3 has the same stem, e.g. `175_217.mp3`.

---

## Environment (vast.ai)

Choose an instance with: CUDA GPU (RTX 3090 / A4000 or better), ≥ 24 GB VRAM,
Ubuntu 22.04, CUDA 12.x.

```bash
# One-time setup
pip install faster-whisper torch torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install torchaudio   # for MMS forced alignment
pip install jiwer        # CER computation
pip install numpy scipy  # audio helpers

# Check GPU
python -c "import torch; print(torch.cuda.get_device_name(0))"
```

### Rsync data to instance

```bash
# From local machine — adjust HOST/PORT from vast.ai dashboard
rsync -avz --progress \
  prompts/data/examples/ \
  root@HOST:~/examples/

# After processing, pull results back
rsync -avz --progress \
  root@HOST:~/output/ \
  assets/vocab/audio/

rsync -avz root@HOST:~/split_report.json prompts/data/split_report.json
```

---

## Algorithm

### Overview

```
For each batch file:
  1. parse_text_file(.txt)          → [(word_num, 'a'/'b', lao_text), ...]
  2. whisper_rough_boundaries(mp3)  → rough (start_sec, end_sec) per entry
  3. for each entry:
       window_audio = load_window(mp3, rough_start - 0.5, rough_end + 1.0)
       (fa_start, fa_end) = forced_align(window_audio, lao_text)
       abs_start = rough_start - 0.5 + fa_start
       abs_end   = rough_start - 0.5 + fa_end
       clip = extract(mp3, abs_start, abs_end)
       save_wav(clip, output_path)
       cer = verify(clip, lao_text)
  4. write JSON report
```

### Step 1 — Whisper rough boundaries

Use **faster-whisper** `large-v3` with `device='cuda'`, `compute_type='float16'`,
`word_timestamps=True`. No language setting (auto-detect is fine; the labels
contain Thai-script digits which guide Whisper).

For each file, collect digit-token runs exactly as in the existing
`extract_examples_whisper.py` (`find_label_boundaries`). This gives an
`entry_start` and `entry_end` per entry, accurate to ±1 s.

Use the existing `find_label_boundaries` code unchanged. Its output is good
enough to define a ±1.5 s window for forced alignment.

### Step 2 — Forced alignment with torchaudio MMS

`torchaudio.pipelines.MMS_FA` is a CTC model trained on 1 000+ languages
including Lao (`'lao'`). It aligns a known text string to audio at the character
level, returning frame-level start/end for every character.

```python
import torch, torchaudio
from torchaudio.pipelines import MMS_FA

bundle = MMS_FA
fa_model = bundle.get_model(with_star=False).to('cuda')
tokenizer = bundle.get_tokenizer()
aligner   = bundle.get_aligner()
SAMPLE_RATE = bundle.sample_rate   # 16 000 Hz

@torch.inference_mode()
def forced_align_window(audio_float32_16k, text):
    """
    audio_float32_16k: 1-D numpy float32 at 16 kHz, range [-32768, 32767].
    text: Lao string, e.g. 'ຂ້ອຍໄປໂຮງຮຽນ'

    Returns (start_sec, end_sec) of text within audio, or None on failure.
    """
    # Normalise to [-1, 1] float32 tensor
    wav = torch.from_numpy(audio_float32_16k / 32768.0).unsqueeze(0).to('cuda')

    # MMS_FA requires 16 kHz input
    emission, _ = fa_model(wav)           # (1, T_frames, vocab)

    try:
        tokens = tokenizer(text)
    except Exception:
        return None                        # text contains chars outside vocab

    # Forced alignment
    token_spans = aligner(emission[0], tokens)

    # frames → seconds
    n_frames = emission.shape[1]
    n_samples = audio_float32_16k.shape[0]
    ratio = n_samples / n_frames / SAMPLE_RATE   # seconds per frame

    start_sec = token_spans[0][0].start * ratio
    end_sec   = token_spans[-1][-1].end   * ratio
    return start_sec, end_sec
```

**Character filtering:** MMS_FA has a fixed vocabulary. Strip or replace any
characters not in `bundle.get_labels()` before calling `tokenizer()`. A safe
pre-process:

```python
VALID = set(bundle.get_labels())

def clean_for_fa(text):
    # Keep only chars that MMS_FA knows; collapse runs of spaces
    out = ''.join(c if c in VALID else ' ' for c in text)
    return ' '.join(out.split())
```

If `clean_for_fa` removes more than 30% of characters, skip forced alignment
and fall back to the Whisper rough boundaries (log the entry).

### Step 3 — Extract clip

```python
def extract_clip(mp3_path, abs_start, abs_end, out_wav_path):
    """
    abs_start, abs_end in seconds (relative to mp3 start).
    Writes 16 kHz mono signed-16-bit WAV.
    Adds 30 ms pre-roll and 60 ms post-roll to the forced-align boundaries
    so the clip doesn't clip the first/last phoneme.
    """
    start = max(0.0, abs_start - 0.03)
    end   = abs_end + 0.06

    subprocess.run([
        'ffmpeg', '-y', '-i', mp3_path,
        '-ss', f'{start:.6f}', '-to', f'{end:.6f}',
        '-ar', '16000', '-ac', '1',
        '-acodec', 'pcm_s16le', out_wav_path,
    ], check=True, capture_output=True)
```

### Step 4 — Verify

Re-transcribe each extracted WAV using faster-whisper with `language='lo'` and
compare to the expected Lao text.

```python
from jiwer import cer as compute_cer
import unicodedata

def normalise_lao(text):
    # NFC normalise, remove spaces (Lao script has no spaces between words)
    return unicodedata.normalize('NFC', text).replace(' ', '')

def verify_clip(whisper_model, wav_path, expected_text):
    segs, _ = whisper_model.transcribe(wav_path, language='lo', word_timestamps=False)
    transcript = ''.join(s.text for s in segs).strip()
    hyp = normalise_lao(transcript)
    ref = normalise_lao(expected_text)
    if not ref:
        return 0.0, transcript
    return compute_cer(ref, hyp), transcript
```

CER thresholds:
- `< 0.20`  → PASS
- `0.20 – 0.40` → WARN (probably fine, flag for spot-check)
- `> 0.40`  → FAIL (likely wrong segment; save anyway but log prominently)

### Step 5 — JSON report

Write `~/split_report.json`:

```json
[
  {
    "word_num": 175,
    "ab": "a",
    "expected": "ຂ້ອຍໄປໂຮງຮຽນ",
    "out_path": "w_0175_example1.wav",
    "abs_start": 1.743,
    "abs_end": 2.981,
    "dur": 1.268,
    "fa_method": "mms_fa",
    "cer": 0.04,
    "transcript": "ຂ້ອຍໄປໂຮງຮຽນ",
    "status": "PASS"
  },
  ...
]
```

`fa_method` is one of `"mms_fa"` (forced align succeeded) or `"whisper_rough"`
(fell back to Whisper bounds).

---

## Complete Script Structure

```
split_examples.py
├── Imports + path constants
├── load_raw(path, start, end, sr=16000) → np.float32
├── parse_text_file(path) → [(num, ab, text), ...]
├── whisper_rough_boundaries(model, mp3, entries) → dict[(num,ab)→(start,end)]
│     (copy find_label_boundaries from extract_examples_whisper.py)
├── forced_align_window(audio, text) → (start_sec, end_sec) | None
├── clean_for_fa(text) → str
├── extract_clip(mp3, abs_start, abs_end, out_path)
├── verify_clip(whisper_model, wav_path, expected) → (cer, transcript)
├── process_batch(fa_model, tokenizer, aligner,
│                whisper_model, txt_path, mp3_path, out_dir) → [report_entries]
└── main()
     ├── Load MMS_FA model (cuda)
     ├── Load faster-whisper large-v3 (cuda, float16)
     ├── Discover *.txt in examples/
     ├── For each batch: process_batch(...)
     ├── Write split_report.json
     └── Print summary (total PASS / WARN / FAIL / fallback)
```

---

## process_batch Detail

```python
def process_batch(fa_model, tokenizer, aligner, whisper_model,
                  txt_path, mp3_path, out_dir):
    entries = parse_text_file(txt_path)
    print(f'\n── {os.path.basename(txt_path)} ({len(entries)} entries) ──')

    # 1. Rough boundaries via Whisper
    segs, words = transcribe(whisper_model, mp3_path)   # existing helper
    rough = find_label_boundaries(words, segs, entries) # existing helper

    total_dur = ffprobe_duration(mp3_path)
    report = []

    for word_num, ab, text in entries:
        example_num = 1 if ab == 'a' else 2
        out_path = os.path.join(out_dir, f'w_{word_num:04d}_example{example_num}.wav')

        b = rough.get((word_num, ab))
        if b is None:
            print(f'  [{word_num}{ab}] SKIP — no rough boundary')
            continue

        # 2. Define window: rough entry_start − 0.5 s to rough entry_start + 6 s
        #    (cap at next entry start if known)
        win_start = max(0.0, b.entry_start - 0.5)
        win_end   = min(total_dur, b.entry_start + 6.0)

        window_audio = load_raw(mp3_path, win_start, win_end)  # float32 pcm

        # 3. Forced alignment on window
        fa_method = 'mms_fa'
        fa_result = None
        clean_text = clean_for_fa(text)
        removed = len(text) - len(clean_text.replace(' ', ''))
        if removed / max(len(text), 1) < 0.3:
            fa_result = forced_align_window(fa_model, tokenizer, aligner,
                                            window_audio, clean_text)

        if fa_result is None:
            # Fallback: use Whisper sentence_start and cap at entry_start + 5s
            fa_method = 'whisper_rough'
            rel_start = b.sentence_start - win_start
            rel_end   = min(b.entry_end - win_start, rel_start + 5.0)
            fa_result = (max(0.0, rel_start), rel_end)

        rel_start, rel_end = fa_result
        abs_start = win_start + rel_start
        abs_end   = win_start + rel_end

        # Sanity: duration must be 0.2 – 8.0 s
        dur = abs_end - abs_start
        if dur < 0.2 or dur > 8.0:
            print(f'  [{word_num}{ab}] SKIP — implausible duration {dur:.2f}s '
                  f'({fa_method})')
            continue

        # 4. Extract
        extract_clip(mp3_path, abs_start, abs_end, out_path)

        # 5. Verify
        clip_cer, transcript = verify_clip(whisper_model, out_path, text)
        status = 'PASS' if clip_cer < 0.20 else ('WARN' if clip_cer < 0.40 else 'FAIL')

        print(f'  [{word_num:4d}{ab}] {text[:22]:22s}  '
              f'{abs_start:.2f}-{abs_end:.2f}s  '
              f'CER={clip_cer:.2f}  {status}  ({fa_method})')

        report.append({
            'word_num': word_num, 'ab': ab, 'expected': text,
            'out_path': os.path.basename(out_path),
            'abs_start': round(abs_start, 3),
            'abs_end': round(abs_end, 3),
            'dur': round(dur, 3),
            'fa_method': fa_method,
            'cer': round(clip_cer, 3),
            'transcript': transcript,
            'status': status,
        })

    return report
```

---

## Sending Results Back

From the vast.ai instance:

```bash
# Tar the 1000 WAVs + report
cd ~/
tar -czf example_audio.tar.gz output/ split_report.json

# Option A — rsync direct (works if SSH port is open)
rsync -avz --progress root@HOST:~/example_audio.tar.gz \
  /Volumes/Dara/dev/write_lao/prompts/data/

# Option B — scp
scp -P PORT root@HOST:~/example_audio.tar.gz .

# On local, unpack WAVs into place
cd /Volumes/Dara/dev/write_lao
tar -xzf prompts/data/example_audio.tar.gz \
  --strip-components=1 -C assets/vocab/audio/ 'output/*.wav'
cp prompts/data/output/split_report.json prompts/data/split_report.json
```

---

## Quality Checklist After Transfer

Run locally to audit results:

```python
# prompts/data/audit_results.py
import json, os, subprocess

report = json.load(open('prompts/data/split_report.json'))
out_dir = 'assets/vocab/audio'

fail = [e for e in report if e['status'] == 'FAIL']
warn = [e for e in report if e['status'] == 'WARN']
missing = []
for e in report:
    if not os.path.exists(os.path.join(out_dir, e['out_path'])):
        missing.append(e['out_path'])

print(f"Total:   {len(report)}")
print(f"PASS:    {sum(1 for e in report if e['status']=='PASS')}")
print(f"WARN:    {len(warn)}")
print(f"FAIL:    {len(fail)}")
print(f"Missing: {len(missing)}")
print()
if fail:
    print("FAIL entries:")
    for e in fail[:20]:
        print(f"  w_{e['word_num']:04d}{e['ab']}  CER={e['cer']:.2f}  "
              f"got: {e['transcript'][:40]!r}")
```

Acceptable outcome: ≥ 970 PASS, 0 entries > 8 s or < 0.25 s.

---

## Notes for the Implementer

- **MMS_FA vocabulary for Lao:** Run `print(bundle.get_labels())` to see what
  characters are supported. Lao vowel marks and tone marks may be separate
  codepoints — NFC normalise the text before passing to `clean_for_fa`.

- **Batching:** MMS_FA runs one clip at a time is fine on GPU (each window is
  ~5 s). No need to batch.

- **Whisper large-v3 memory:** ~3 GB VRAM. MMS_FA: ~300 MB. Should fit on any
  24 GB card simultaneously.

- **If MMS_FA language 'lao' is unsupported:** Fall back to `'tha'` (Thai) —
  the two scripts are closely related and the model will still align reasonably
  well. Set `bundle = torchaudio.pipelines.MMS_FA` then check
  `'lao' in bundle.get_languages()`.

- **The `.txt` files have an off-by-one in their filenames** (e.g. `175_217.txt`
  actually contains entries through word 218a). The script should parse the
  `.txt` file content directly — do not rely on the filename range.

- **Total runtime estimate:** ~30–40 min on an A4000 for all 13 batches
  (transcription dominates; FA is fast).
