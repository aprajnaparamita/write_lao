# Example Audio Splitter

Extracts 1 000 Lao example sentence WAV files from 13 TTS batch MP3s using
forced alignment (torchaudio MMS_FA) for precise boundaries, then verifies
each clip by re-transcription.

---

## Step 1 — Rent a vast.ai instance

- GPU: RTX 3090, A4000, or better (≥ 16 GB VRAM)
- OS image: pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime (or similar)
- Note the SSH host and port from the vast.ai dashboard

---

## Step 2 — Upload this folder and the audio data

```bash
# From the write_lao repo root on your Mac:
# Replace HOST and PORT with the values from your vast.ai dashboard.

# Upload this splitter folder
rsync -avz -e "ssh -p PORT" prompts/data/splitter/ root@HOST:~/splitter/

# Upload the batch MP3 + TXT files  (~500 MB total)
rsync -avz -e "ssh -p PORT" prompts/data/examples/ root@HOST:~/examples/
```

---

## Step 3 — Set up the instance

```bash
ssh -p PORT root@HOST
cd ~/splitter
bash setup.sh
```

Expected output ends with:
```
MMS_FA langs  : 1162 total, lao=True, tha=True
MMS_FA vocab  : 64 labels
Setup complete
```

---

## Step 4 — Run the splitter

```bash
python3 ~/splitter/split_examples.py \
    --examples_dir ~/examples \
    --output_dir   ~/output \
    --report       ~/split_report.json
```

Progress is printed per-entry with CER. The report is written incrementally
so a crash won't lose completed work. Expected runtime: ~30–45 min on A4000.

Per-line output format:
```
  [ 175a] ຂ້ອຍໄປໂຮງຮຽນ         1.74–2.98s  dur=1.24  CER=0.04  mms_fa
  [ 175b] ຂ້ອຍຮຽນພາສາລາວ        6.21–7.59s  dur=1.38  CER=0.06  mms_fa
```

---

## Step 5 — Download results

```bash
# On the vast.ai instance — pack everything up:
tar -czf ~/example_audio.tar.gz ~/output ~/split_report.json

# On your Mac — download:
scp -P PORT root@HOST:~/example_audio.tar.gz /tmp/

# Unpack WAVs into the right place:
cd /Volumes/Dara/dev/write_lao
tar -xzf /tmp/example_audio.tar.gz \
    --strip-components=2 \
    -C assets/vocab/audio \
    'root/output/'
cp /tmp/split_report.json prompts/data/split_report.json
```

---

## Step 6 — Audit locally

```bash
cd /Volumes/Dara/dev/write_lao
python3 prompts/data/splitter/audit_results.py \
    --report  prompts/data/split_report.json \
    --wav_dir assets/vocab/audio
```

Target: ≥ 970 PASS, 0 missing files, 0 duration outliers.

---

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--examples_dir` | `~/examples` | Folder with `.txt` + `.mp3` pairs |
| `--output_dir` | `~/output` | Where to write WAV files |
| `--report` | `~/split_report.json` | JSON report path |
| `--device` | `cuda` | `cuda` or `cpu` |
| `--skip_verify` | off | Skip per-clip re-transcription (faster, no CER) |

---

## How it works

1. **Whisper large-v3** transcribes each batch MP3 with word timestamps to
   find the spoken label (e.g. "175A") that precedes each sentence — gives
   a rough ±1 s window around each entry.

2. **MMS_FA** (Meta Massively Multilingual Speech forced aligner, supports
   1 162 languages including Lao) aligns the *known Lao text* to the audio
   within that window. The `*` (star) token absorbs the spoken label so only
   the sentence portion is aligned → precise ±30 ms boundaries.

3. **Whisper large-v3** (language=`lo`) re-transcribes each extracted clip
   and computes CER vs the expected text. PASS < 0.20, WARN < 0.40, FAIL ≥ 0.40.

4. Falls back to Whisper rough boundaries if MMS_FA alignment fails or
   produces an implausible duration.
