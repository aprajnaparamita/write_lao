#!/usr/bin/env python3
"""
split_examples.py — Lao example audio splitter using whole-batch MMS_FA alignment.

Pipeline:
  1. torchaudio MMS_FA aligns ALL Lao sentences for a batch in a single pass:
       reference = "* sentence_0 * sentence_1 * ... * sentence_N *"
       Stars absorb Thai spoken labels, pauses, and inter-sentence gaps.
  2. Extract clips at MMS_FA-aligned boundaries.
  3. Validate by duration + RMS energy (no Whisper CER needed).

Optional --verify flag loads faster-whisper and appends CER to the report.

Usage (on vast.ai):
    python split_examples.py \\
        --examples_dir ~/examples \\
        --output_dir   ~/output \\
        --report       ~/split_report.json
"""

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import unicodedata

import numpy as np
import torch
import torchaudio
import uroman as uroman_lib
from jiwer import cer as compute_cer

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

TARGET_SR = 16000
FA_SR     = 16000
PRE_ROLL  = 0.030       # padding before clip start
POST_ROLL = 0.060       # padding after clip end
MIN_DUR   = 0.20        # minimum plausible sentence duration (s)
MAX_DUR   = 8.00        # maximum plausible sentence duration (s)
WIN_PRE   = 5.0         # fallback window: seconds before estimated entry start
WIN_POST  = 5.0         # fallback window: seconds after estimated entry start
RMS_MIN   = 0.005       # clips below this RMS are flagged as silence

DEVICE = 'cuda' if torch.cuda.is_available() else 'cpu'

MMS_FA_URL        = 'https://dl.fbaipublicfiles.com/mms/torchaudio/ctc_alignment_mling_uroman/model.pt'
MMS_FA_CACHE_PATH = os.path.expanduser('~/.cache/torch/hub/checkpoints/model.pt')
WHISPER_HF_REPO   = 'Systran/faster-whisper-large-v3'


# ---------------------------------------------------------------------------
# Audio helpers
# ---------------------------------------------------------------------------

def ffprobe_duration(path):
    r = subprocess.run(
        ['ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_format', path],
        capture_output=True, text=True, check=True,
    )
    return float(json.loads(r.stdout)['format']['duration'])


def load_raw(path, start, end, sr=TARGET_SR):
    """Decode audio slice → float32 PCM in [-32768, 32767]. Returns empty array on error."""
    with tempfile.NamedTemporaryFile(suffix='.raw', delete=False) as f:
        tmp = f.name
    try:
        r = subprocess.run(
            ['ffmpeg', '-y', '-i', path,
             '-ss', f'{max(0.0, start):.6f}', '-to', f'{end:.6f}',
             '-ar', str(sr), '-ac', '1', '-f', 's16le', tmp],
            capture_output=True,
        )
        if r.returncode != 0:
            return np.array([], dtype=np.float32)
        data = open(tmp, 'rb').read()
        return np.frombuffer(data, dtype=np.int16).astype(np.float32)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)


def extract_clip(mp3_path, abs_start, abs_end, out_path):
    """Extract [abs_start − PRE_ROLL, abs_end + POST_ROLL] → 16 kHz mono WAV."""
    start = max(0.0, abs_start - PRE_ROLL)
    end   = abs_end + POST_ROLL
    subprocess.run(
        ['ffmpeg', '-y', '-i', mp3_path,
         '-ss', f'{start:.6f}', '-to', f'{end:.6f}',
         '-ar', str(TARGET_SR), '-ac', '1', '-acodec', 'pcm_s16le', out_path],
        check=True, capture_output=True,
    )


def rms_of_clip(out_path):
    audio = load_raw(out_path, 0.0, 999.0, TARGET_SR)
    if audio.size == 0:
        return 0.0
    return float(np.sqrt(np.mean((audio / 32768.0) ** 2)))


# ---------------------------------------------------------------------------
# Text helpers
# ---------------------------------------------------------------------------

def parse_text_file(path):
    """Return [(word_num, ab, lao_text), ...] in file order."""
    entries = []
    for line in open(path, encoding='utf-8'):
        line = line.strip()
        if not line:
            continue
        m = re.match(r'^(\d+)([ab])\.(.*)$', line)
        if m:
            entries.append((int(m.group(1)), m.group(2), m.group(3)))
    return entries


def romanize_lao(text, uromanizer):
    nfc = unicodedata.normalize('NFC', text)
    return uromanizer.romanize_string(nfc, lcode='lao').lower().strip()


def clean_for_fa(romanized, valid_chars):
    """Keep only MMS_FA vocab chars (a-z + space + '*'); collapse spaces."""
    out = ''.join(c if c in valid_chars else ' ' for c in romanized)
    return ' '.join(out.split())


# ---------------------------------------------------------------------------
# MMS_FA model loading
# ---------------------------------------------------------------------------

def _ensure_mms_fa_downloaded():
    dest = MMS_FA_CACHE_PATH
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    if os.path.exists(dest):
        try:
            import zipfile
            with zipfile.ZipFile(dest) as zf:
                zf.testzip()
            print(f'  MMS_FA checkpoint cached at {dest}')
            return
        except Exception:
            print('  Cached checkpoint corrupt — re-downloading…')
            os.remove(dest)
    print(f'  Downloading MMS_FA checkpoint (~1.2 GB) with resume support…')
    result = subprocess.run(
        ['wget', '--continue', '--show-progress', '-O', dest, MMS_FA_URL])
    if result.returncode != 0:
        raise RuntimeError(f'wget failed (exit {result.returncode}). Re-run to resume.')


def build_fa_model():
    """Load MMS_FA + uroman. Returns (model, tokenizer, aligner, valid_chars, uromanizer, sr)."""
    print(f'Loading MMS_FA on {DEVICE}…')
    _ensure_mms_fa_downloaded()
    bundle    = torchaudio.pipelines.MMS_FA
    model     = bundle.get_model(with_star=True).to(DEVICE)
    tokenizer = bundle.get_tokenizer()
    aligner   = bundle.get_aligner()
    try:
        labels = bundle.get_labels(star=None)
    except TypeError:
        labels = bundle.get_labels()
    valid_chars = set(''.join(labels))
    print(f'  MMS_FA vocab: {len(labels)} labels (a-z + special)')
    print('Loading uroman romaniser…')
    uromanizer = uroman_lib.Uroman()
    test = uromanizer.romanize_string(
        unicodedata.normalize('NFC', 'ຂ້ອຍໄປໂຮງຮຽນ'), lcode='lao').lower().strip()
    print(f'  romanize test: "ຂ້ອຍໄປໂຮງຮຽນ" → "{test}"')
    return model, tokenizer, aligner, valid_chars, uromanizer, bundle.sample_rate


# ---------------------------------------------------------------------------
# Tokenizer helper (shared by alignment functions)
# ---------------------------------------------------------------------------

def _tok(s, tokenizer):
    """Convert romanized string to flat MMS_FA token ID list."""
    s_norm = re.sub(r'[^a-z*]', '', s)
    if not s_norm:
        return []
    raw = tokenizer(s_norm)
    return [t for ids in raw for t in (ids if hasattr(ids, '__iter__') else [ids])]


# ---------------------------------------------------------------------------
# Whole-batch MMS_FA alignment
# ---------------------------------------------------------------------------

@torch.inference_mode()
def align_full_batch(fa_model, tokenizer, aligner, audio_float32, entries,
                     uromanizer, valid_chars, sr=FA_SR):
    """
    Align all N entries against the full batch audio in a single MMS_FA pass.

    Token structure passed to the aligner:
      [* ,  sent_0 ,  * ,  sent_1 ,  * ,  …  ,  sent_N-1 ,  *]
    group indices:
       0      1       2      3       4               2N-1    2N

    Star tokens absorb Thai spoken labels, pauses, and inter-entry gaps.
    Returns (timestamps, romanized_list) where timestamps[i] = (start_s, end_s) | None.
    """
    n = len(entries)

    # Build romanized texts first (needed regardless of alignment outcome).
    romanized_list = []
    for _, _, text in entries:
        romanized_list.append(romanize_lao(text, uromanizer))

    if audio_float32.size == 0:
        return [None] * n, romanized_list

    tok_star = _tok('*', tokenizer)

    # Build token groups: [star, sent0, star, sent1, star, ..., sentN-1, star]
    tok_groups = [tok_star]
    for roman in romanized_list:
        clean = clean_for_fa(roman, valid_chars)
        toks  = _tok(clean, tokenizer) or tok_star[:]   # fallback: star as placeholder
        tok_groups.append(toks)
        tok_groups.append(tok_star)

    total_tokens = sum(len(g) for g in tok_groups)
    print(f'  [batch_align] audio={audio_float32.size/sr:.1f}s  entries={n}  '
          f'groups={len(tok_groups)}  tokens={total_tokens}', flush=True)

    try:
        wav      = torch.from_numpy(audio_float32 / 32768.0).unsqueeze(0).to(DEVICE)
        emission, _ = fa_model(wav)
        em       = emission[0]
        n_frames = em.shape[0]
        spf      = audio_float32.shape[0] / n_frames / sr   # seconds per frame
        print(f'  [batch_align] frames={n_frames}  spf={spf*1000:.1f}ms', flush=True)

        spans = aligner(em, tok_groups)

        results = []
        for i in range(n):
            g_idx = 1 + i * 2          # sentence i is at group index 1, 3, 5, …
            if g_idx < len(spans) and spans[g_idx]:
                s   = spans[g_idx][0].start * spf
                e   = spans[g_idx][-1].end  * spf
                dur = e - s
                results.append((s, e) if MIN_DUR <= dur <= MAX_DUR else None)
            else:
                results.append(None)

        n_ok = sum(1 for r in results if r is not None)
        print(f'  [batch_align] aligned {n_ok}/{n} entries OK', flush=True)
        return results, romanized_list

    except Exception as exc:
        print(f'  [batch_align] EXCEPTION: {exc}', flush=True)
        return [None] * n, romanized_list


# ---------------------------------------------------------------------------
# Per-entry windowed MMS_FA (fallback for entries the batch pass misses)
# ---------------------------------------------------------------------------

@torch.inference_mode()
def forced_align_window(fa_model, tokenizer, aligner, audio_float32, romanized_text,
                        sr=FA_SR):
    """Align a single entry within a narrow audio window. Returns (start_s, end_s) or None."""
    if audio_float32.size == 0:
        return None

    wav = torch.from_numpy(audio_float32 / 32768.0).unsqueeze(0).to(DEVICE)
    try:
        emission, _ = fa_model(wav)
        em = emission[0]
        if em.shape[0] == 0:
            return None
        spf = audio_float32.shape[0] / em.shape[0] / sr

        tok_star = _tok('*', tokenizer)
        tok_text = _tok(romanized_text, tokenizer)

        # Attempt 1: star absorbs label, then sentence
        # Attempt 2: sentence only (no star)
        for groups, sent_idx in [([tok_star, tok_text], 1), ([tok_text], 0)]:
            try:
                spans = aligner(em, groups)
                if spans and len(spans) > sent_idx and spans[sent_idx]:
                    s = spans[sent_idx][0].start * spf
                    e = spans[sent_idx][-1].end  * spf
                    if MIN_DUR <= (e - s) <= MAX_DUR:
                        return s, e
            except Exception:
                continue
    except Exception:
        pass
    return None


# ---------------------------------------------------------------------------
# Optional Whisper verification
# ---------------------------------------------------------------------------

def _ensure_whisper_downloaded():
    from huggingface_hub import snapshot_download
    print('  Verifying faster-whisper large-v3 cache…')
    local_dir = snapshot_download(repo_id=WHISPER_HF_REPO, resume_download=True)
    print(f'  Whisper model ready at {local_dir}')
    return local_dir


def _script_lcode(text):
    thai = sum(1 for c in text if '฀' <= c <= '๿')
    lao  = sum(1 for c in text if '຀' <= c <= '໿')
    return 'tha' if thai >= lao else 'lao'


def verify_clip(whisper_model, wav_path, expected_text, uromanizer):
    """Re-transcribe clip and compute romanized CER vs expected Lao text."""
    try:
        segs, info = whisper_model.transcribe(
            wav_path, language='lo', word_timestamps=False, beam_size=5, vad_filter=False)
        transcript = ''.join(s.text for s in segs).strip()
        detected   = info.language
    except Exception as exc:
        return 1.0, f'[error: {exc}]', 'err'

    if not transcript:
        return 1.0, '', detected

    lcode_hyp = _script_lcode(transcript)

    def _roman(text, lcode):
        try:
            r = uromanizer.romanize_string(unicodedata.normalize('NFC', text), lcode=lcode)
            return re.sub(r'[^a-z]', '', r.lower())
        except Exception:
            return re.sub(r'[^a-z]', '', text.lower())

    ref_r = _roman(expected_text, 'lao')
    hyp_r = _roman(transcript, lcode_hyp)
    if not ref_r:
        return 0.0, transcript, detected
    try:
        c = compute_cer(ref_r, hyp_r) if hyp_r else 1.0
    except Exception:
        c = 1.0
    return c, transcript, detected


# ---------------------------------------------------------------------------
# Per-batch processing
# ---------------------------------------------------------------------------

def process_batch(fa_model, tokenizer, aligner, valid_chars, uromanizer,
                  whisper_model, txt_path, mp3_path, out_dir):
    entries = parse_text_file(txt_path)
    if not entries:
        print(f'  No entries in {txt_path}')
        return []

    print(f'\n── {os.path.basename(txt_path)} ({len(entries)} entries) ──')
    total_dur = ffprobe_duration(mp3_path)
    print(f'  Duration: {total_dur:.1f}s  avg spacing: {total_dur/len(entries):.1f}s/entry')

    # ── Step 1: load full audio and run whole-batch MMS_FA ──
    full_audio = load_raw(mp3_path, 0.0, total_dur, FA_SR)

    timestamps, romanized_list = align_full_batch(
        fa_model, tokenizer, aligner, full_audio, entries, uromanizer, valid_chars)

    fa_methods = ['mms_fa_batch' if t is not None else '' for t in timestamps]

    # ── Step 2: windowed fallback for entries the batch pass missed ──
    n_missing = sum(1 for t in timestamps if t is None)
    if n_missing:
        print(f'  Windowed fallback for {n_missing} entries…')
        spacing = total_dur / len(entries)
        for i, (ts, (_, _, text)) in enumerate(zip(timestamps, entries)):
            if ts is not None:
                continue
            est     = i * spacing
            win_s   = max(0.0, est - WIN_PRE)
            win_e   = min(total_dur, est + WIN_POST)
            window  = load_raw(mp3_path, win_s, win_e, FA_SR)
            clean   = clean_for_fa(romanized_list[i], valid_chars)
            if clean:
                result = forced_align_window(fa_model, tokenizer, aligner, window, clean)
                if result:
                    rel_s, rel_e = result
                    timestamps[i] = (win_s + rel_s, win_s + rel_e)
                    fa_methods[i] = 'mms_fa_window'

    # ── Step 3: uniform-spacing last resort ──
    spacing = total_dur / len(entries)
    for i, ts in enumerate(timestamps):
        if ts is None:
            est = i * spacing + 0.5   # skip approximate label duration
            timestamps[i] = (est, est + 2.0)
            fa_methods[i] = 'uniform_fallback'

    # ── Step 4: extract clips and validate ──
    os.makedirs(out_dir, exist_ok=True)
    report = []
    n_pass = n_warn = n_fail = 0

    for i, (word_num, ab, text) in enumerate(entries):
        example_num = 1 if ab == 'a' else 2
        out_path    = os.path.join(out_dir, f'w_{word_num:04d}_example{example_num}.wav')

        abs_start, abs_end = timestamps[i]
        fa_method          = fa_methods[i]
        dur                = abs_end - abs_start

        try:
            extract_clip(mp3_path, abs_start, abs_end, out_path)
        except subprocess.CalledProcessError:
            print(f'  [{word_num:4d}{ab}] FAIL — ffmpeg error')
            n_fail += 1
            continue

        rms = rms_of_clip(out_path)

        # Status: duration + energy check; no Whisper CER needed
        if not (MIN_DUR <= dur <= MAX_DUR):
            status = 'FAIL'
        elif rms < RMS_MIN:
            status = 'FAIL'   # silence / near-silence
        elif fa_method == 'uniform_fallback':
            status = 'WARN'   # boundary uncertain
        else:
            status = 'PASS'

        # Optional Whisper re-transcription for CER
        clip_cer, transcript, det_lang = None, '', ''
        if whisper_model is not None:
            clip_cer, transcript, det_lang = verify_clip(
                whisper_model, out_path, text, uromanizer)
            cer_tag = f'  CER={clip_cer:.2f}[{det_lang}]'
        else:
            cer_tag = ''

        flag = f'  *** {status} ***' if status != 'PASS' else ''
        print(f'  [{word_num:4d}{ab}] {text[:20]:20s}  '
              f'{abs_start:.2f}–{abs_end:.2f}s  dur={dur:.2f}  '
              f'rms={rms:.3f}  {fa_method}{cer_tag}{flag}', flush=True)

        if status == 'PASS':   n_pass += 1
        elif status == 'WARN': n_warn += 1
        else:                  n_fail += 1

        report.append({
            'word_num':  word_num,
            'ab':        ab,
            'expected':  text,
            'romanized': romanized_list[i],
            'out_path':  os.path.basename(out_path),
            'abs_start': round(abs_start, 3),
            'abs_end':   round(abs_end, 3),
            'dur':       round(dur, 3),
            'fa_method': fa_method,
            'rms':       round(rms, 4),
            'cer':       round(clip_cer, 3) if clip_cer is not None else None,
            'transcript': transcript,
            'det_lang':  det_lang,
            'status':    status,
        })

    print(f'  → PASS={n_pass}  WARN={n_warn}  FAIL={n_fail}')
    return report


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    global DEVICE
    parser = argparse.ArgumentParser(
        description='Split Lao example audio via whole-batch MMS_FA forced alignment')
    parser.add_argument('--examples_dir', default=os.path.expanduser('~/examples'))
    parser.add_argument('--output_dir',   default=os.path.expanduser('~/output'))
    parser.add_argument('--report',       default=os.path.expanduser('~/split_report.json'))
    parser.add_argument('--device',       default=DEVICE, choices=['cuda', 'cpu'])
    parser.add_argument('--verify',       action='store_true',
                        help='Run faster-whisper re-transcription for CER scores (optional)')
    args = parser.parse_args()
    DEVICE = args.device

    if not os.path.isdir(args.examples_dir):
        sys.exit(f'ERROR: examples_dir not found: {args.examples_dir}')

    txt_files = sorted(f for f in os.listdir(args.examples_dir) if f.endswith('.txt'))
    if not txt_files:
        sys.exit(f'ERROR: no .txt files in {args.examples_dir}')

    print(f'Batches  : {len(txt_files)}')
    print(f'Output   : {args.output_dir}')
    print(f'Device   : {DEVICE}')
    os.makedirs(args.output_dir, exist_ok=True)

    fa_model, tokenizer, aligner, valid_chars, uromanizer, _ = build_fa_model()

    whisper_model = None
    if args.verify:
        from faster_whisper import WhisperModel
        compute       = 'float16' if DEVICE == 'cuda' else 'int8'
        whisper_local = _ensure_whisper_downloaded()
        whisper_model = WhisperModel(whisper_local, device=DEVICE, compute_type=compute)

    all_report = []
    for txt_name in txt_files:
        txt_path = os.path.join(args.examples_dir, txt_name)
        mp3_path = txt_path.replace('.txt', '.mp3')
        if not os.path.exists(mp3_path):
            print(f'WARNING: no MP3 for {txt_name}, skipping')
            continue

        batch_report = process_batch(
            fa_model, tokenizer, aligner, valid_chars, uromanizer,
            whisper_model, txt_path, mp3_path, args.output_dir,
        )
        all_report.extend(batch_report)

        with open(args.report, 'w', encoding='utf-8') as f:
            json.dump(all_report, f, ensure_ascii=False, indent=2)

    total  = len(all_report)
    passed = sum(1 for e in all_report if e['status'] == 'PASS')
    warned = sum(1 for e in all_report if e['status'] == 'WARN')
    failed = sum(1 for e in all_report if e['status'] == 'FAIL')
    by_method = {}
    for e in all_report:
        by_method[e['fa_method']] = by_method.get(e['fa_method'], 0) + 1

    print(f'\n{"─"*60}')
    print(f'Done.  {total} clips written to {args.output_dir}')
    print(f'  PASS             : {passed}')
    print(f'  WARN             : {warned}')
    print(f'  FAIL             : {failed}')
    for method, count in sorted(by_method.items()):
        print(f'  {method:20s}: {count}')
    print(f'  Report           : {args.report}')

    if failed:
        print('\nFAIL entries:')
        for e in all_report:
            if e['status'] == 'FAIL':
                print(f"  w_{e['word_num']:04d}{e['ab']}  dur={e['dur']:.2f}  "
                      f"rms={e['rms']:.4f}  {e['fa_method']}  {e['expected'][:30]!r}")


if __name__ == '__main__':
    main()
