#!/usr/bin/env python3
"""
Extract individual example sentence audio from TTS batch files using Whisper.

Each batch file contains lines like "1a.ຂ້ອຍແລະ..." spoken as:
  [label: "one A"] [sentence in Lao] [~1s silence] [label: "one B"] [sentence] ...

Strategy:
  1. Transcribe each MP3 with faster-whisper (word timestamps)
  2. Find digit-token runs → reconstruct label number from concatenated tokens
  3. Match runs to text entries by number (number-aware, handles mid-file gaps)
  4. After digits: 'ว...' token = "B" label (~0.45s) else = "A" label (short/absent)
  5. Sentence runs from label_end → next label_start
  6. Entries 1–9 at file start: fall back to Whisper segment boundaries
  7. Any remaining missing entries: interpolate between known neighbours

Output: assets/vocab/audio/w_NNNN_example1.wav  and  w_NNNN_example2.wav
        (16kHz mono PCM WAV, matching existing audio assets)
"""

import os
import re
import json
import subprocess
import tempfile

import numpy as np
from faster_whisper import WhisperModel

# ── Paths ─────────────────────────────────────────────────────────────────────
SCRIPT_DIR  = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT   = os.path.join(SCRIPT_DIR, '..', '..')
EXAMPLES_DIR = os.path.join(SCRIPT_DIR, 'examples')
OUT_DIR     = os.path.join(REPO_ROOT, 'assets', 'vocab', 'audio')
TARGET_SR   = 16000

# ── Audio helpers ─────────────────────────────────────────────────────────────

def ffprobe_duration(path):
    r = subprocess.run(
        ['ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_format', path],
        capture_output=True, text=True, check=True,
    )
    return float(json.loads(r.stdout)['format']['duration'])


def load_raw(path, start, end, sr=TARGET_SR):
    """Load audio slice as float32 numpy array. Returns empty array on error."""
    with tempfile.NamedTemporaryFile(suffix='.raw', delete=False) as f:
        tmp = f.name
    try:
        result = subprocess.run(
            ['ffmpeg', '-y', '-i', path,
             '-ss', str(max(0, start)), '-to', str(end),
             '-ar', str(sr), '-ac', '1', '-f', 's16le', tmp],
            capture_output=True,
        )
        if result.returncode != 0:
            return np.array([], dtype=np.float32)
        return np.frombuffer(open(tmp, 'rb').read(), dtype=np.int16).astype(np.float32)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)


def energy_snap(path, target_t, sr=TARGET_SR, window=0.25, pre_roll=0.02):
    """
    Return the time within [target_t ± window] that has minimum RMS energy
    (i.e. the quietest point — ideal cut location).
    """
    start = max(0, target_t - window)
    end   = target_t + window
    audio = load_raw(path, start, end, sr)
    win_s = int(0.020 * sr)
    hop_s = int(0.005 * sr)
    if len(audio) < win_s:
        return target_t
    rms = np.array([
        np.sqrt(np.mean(audio[i:i + win_s] ** 2))
        for i in range(0, len(audio) - win_s, hop_s)
    ])
    min_frame = int(np.argmin(rms))
    snap_offset = min_frame * hop_s / sr
    return max(0.0, start + snap_offset - pre_roll)


def trim_trailing_silence(audio, sr, noise_db=-40):
    threshold = 10 ** (noise_db / 20.0) * 32768
    win = int(0.020 * sr)
    end = len(audio)
    while end > win:
        if np.sqrt(np.mean(audio[end - win:end] ** 2)) > threshold:
            break
        end -= win
    return audio[:min(len(audio), end + int(0.050 * sr))]


def save_wav(audio_float32, sr, out_path):
    pcm = np.clip(audio_float32, -32768, 32767).astype(np.int16)
    proc = subprocess.Popen(
        ['ffmpeg', '-y',
         '-f', 's16le', '-ar', str(sr), '-ac', '1', '-i', 'pipe:0',
         '-acodec', 'pcm_s16le', out_path],
        stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    proc.communicate(input=pcm.tobytes())


# ── Whisper helpers ────────────────────────────────────────────────────────────

def transcribe(model, path):
    """Return (segments, words) for the whole file."""
    segs, _ = model.transcribe(
        path, word_timestamps=True, beam_size=5, vad_filter=False,
    )
    segs = list(segs)
    words = [w for s in segs for w in (s.words or [])]
    return segs, words


def is_digit_token(tok):
    return bool(re.fullmatch(r'[\s\d]+', tok))


def find_label_boundaries(words, segs, entries):
    """
    Return dict mapping (word_num, ab) → LabelBoundary, one per entry.

    LabelBoundary has:
      .entry_start  : time audio for this entry begins (≈ label start)
      .sentence_start: time the Lao sentence begins (after label)
      .entry_end    : time this entry's audio ends (= next label start)

    Uses Arabic digit tokens to locate labels. For entries whose numbers
    Whisper renders as Thai words (typically 1–9 at the start of a file),
    falls back to Whisper segment boundaries.
    """
    class LB:
        def __init__(self, entry_start, sentence_start, entry_end):
            self.entry_start    = entry_start
            self.sentence_start = sentence_start
            self.entry_end      = entry_end

    total_dur = words[-1].end if words else segs[-1].end if segs else 0
    first_entry_num = entries[0][0] if entries else 1

    # ── Step 1: collect digit runs with reconstructed word numbers ───────────
    # A "run" = consecutive digit tokens (e.g. '13'+'6' = 136).
    # We also note the next token to detect B-labels ('ว่า').
    digit_runs = []  # list of (number, run_start, run_end, next_tok)
    i = 0
    while i < len(words):
        if is_digit_token(words[i].word):
            run_start = words[i].start
            run_end   = words[i].end
            num_str   = words[i].word.strip()
            j = i + 1
            while j < len(words) and is_digit_token(words[j].word):
                run_end = words[j].end
                num_str += words[j].word.strip()
                j += 1
            try:
                number = int(num_str) if num_str else None
            except ValueError:
                number = None
            next_tok = words[j] if j < len(words) else None
            digit_runs.append((number, run_start, run_end, next_tok))
            i = j
        else:
            i += 1

    # ── Step 2: build sentence_start for each digit run ──────────────────────
    def run_to_label_time(run_start, run_end, nxt):
        if nxt and nxt.word.lstrip().startswith('ว'):
            b_end = nxt.end
            nxt_idx = words.index(nxt) if nxt in words else -1
            if nxt_idx >= 0:
                k = nxt_idx
                while k < len(words) and words[k].word.lstrip() in ('ว', '่', 'า', 'ว่', 'ว่า'):
                    b_end = words[k].end
                    k += 1
            return (run_start, b_end + 0.05)
        else:
            return (run_start, run_end + 0.28)

    # Group runs by number: each word_num should appear twice (a and b)
    from collections import defaultdict
    runs_by_num = defaultdict(list)
    for number, run_start, run_end, nxt in digit_runs:
        if number is not None:
            lt = run_to_label_time(run_start, run_end, nxt)
            runs_by_num[number].append(lt)

    # ── Step 3: assemble label_times list matching entry order ───────────────
    # For each entry (word_num, ab), fetch the matching run by number.
    # If the number was heard as Thai words (1–9, file starts near 1), fall
    # back to Whisper segment boundaries for those entries.
    seg_starts = [s.start for s in segs]
    seg_idx = 0  # pointer into seg_starts for Thai-word fallback

    label_times_keyed = {}  # (word_num, ab) → (entry_start, raw_sentence_start)
    for word_num, ab, _text in entries:
        # For files starting near word 1, single-digit labels (1–9) are often
        # rendered as Thai words by Whisper; also their digit tokens can match
        # spuriously at late timestamps. Always use segment fallback for them.
        use_fallback = first_entry_num <= 9 and word_num <= 9
        if not use_fallback and word_num in runs_by_num and runs_by_num[word_num]:
            lt = runs_by_num[word_num].pop(0)
            label_times_keyed[(word_num, ab)] = lt
        elif first_entry_num <= 9 and word_num <= 9:
            # Thai-word fallback for numbers 1–9 at start of batch
            if seg_idx < len(seg_starts):
                es = seg_starts[seg_idx]
                label_times_keyed[(word_num, ab)] = (es, es + 0.80)
                seg_idx += 1
            # else: leave missing, will be interpolated below

    # ── Step 4: fill in missing entries by interpolating neighbours ──────────
    # Build an ordered list aligned to entries
    ordered = []   # (entry_start, raw_sentence_start) or None
    for word_num, ab, _text in entries:
        ordered.append(label_times_keyed.get((word_num, ab)))

    # Forward/backward interpolation for gaps
    # Uses position-aware fraction so entries spread evenly between neighbours.
    known = [(i, t) for i, t in enumerate(ordered) if t is not None]
    if known:
        for gap_i in range(len(ordered)):
            if ordered[gap_i] is not None:
                continue
            prev_pair = next(((i, t) for i, t in reversed(known) if i < gap_i), None)
            nxt_pair  = next(((i, t) for i, t in known if i > gap_i), None)
            if prev_pair and nxt_pair:
                prev_i, prev_t = prev_pair
                nxt_i,  nxt_t  = nxt_pair
                frac = (gap_i - prev_i) / (nxt_i - prev_i)
                es = prev_t[0] + frac * (nxt_t[0] - prev_t[0])
            elif prev_pair:
                prev_i, prev_t = prev_pair
                es = prev_t[0] + (gap_i - prev_i) * 4.0   # space out by ~4s each
                if es >= total_dur - 1.0:
                    ordered[gap_i] = None  # beyond file end — leave unresolved
                    continue
            elif nxt_pair:
                nxt_i, nxt_t = nxt_pair
                es = max(0.0, nxt_t[0] - (nxt_i - gap_i) * 4.0)
            else:
                es = gap_i * 4.0
            ordered[gap_i] = (es, es + 0.80)

    # ── Step 5: build LabelBoundary objects ──────────────────────────────────
    result = {}
    for idx, (word_num, ab, _text) in enumerate(entries):
        lt = ordered[idx]
        if lt is None:
            continue
        entry_start, raw_sent = lt
        # entry_end = next entry's start − 0.08s
        next_lt = next(
            (ordered[j] for j in range(idx + 1, len(ordered)) if ordered[j] is not None),
            None,
        )
        entry_end = (next_lt[0] - 0.08) if next_lt else total_dur
        result[(word_num, ab)] = LB(entry_start, raw_sent, entry_end)

    return result


# ── Text file parsing ──────────────────────────────────────────────────────────

def parse_text_file(path):
    """
    Parse examples text file.
    Returns list of (word_num, 'a'/'b', lao_text) in file order.
    """
    entries = []
    for line in open(path, encoding='utf-8'):
        line = line.strip()
        if not line:
            continue
        # format: "123a.lao text" or "1b.lao text"
        m = re.match(r'^(\d+)([ab])\.(.*)$', line)
        if m:
            entries.append((int(m.group(1)), m.group(2), m.group(3)))
    return entries


# ── Main ──────────────────────────────────────────────────────────────────────

def process_batch(model, txt_path, mp3_path):
    entries = parse_text_file(txt_path)
    if not entries:
        print(f'  No entries parsed from {txt_path}')
        return 0, 0

    print(f'  Transcribing {os.path.basename(mp3_path)} ({len(entries)} entries)…')
    segs, words = transcribe(model, mp3_path)
    if not words:
        print(f'  ERROR: no word tokens returned')
        return 0, 0

    bounds = find_label_boundaries(words, segs, entries)

    written = fallback = 0
    for i, (word_num, ab, text) in enumerate(entries):
        example_num = 1 if ab == 'a' else 2
        out_path = os.path.join(OUT_DIR, f'w_{word_num:04d}_example{example_num}.wav')

        b = bounds.get((word_num, ab))
        if b is None:
            print(f'  [{word_num}{ab}] SKIP — no boundary found')
            continue

        if b.entry_end <= b.entry_start + 0.20:
            print(f'  [{word_num}{ab}] SKIP — inverted boundary ({b.entry_start:.3f}→{b.entry_end:.3f})')
            continue

        # Snap sentence start to nearest energy minimum
        snapped = energy_snap(mp3_path, b.sentence_start, window=0.20)
        # Sanity: must be after entry start and before entry end
        if snapped < b.entry_start + 0.10:
            snapped = b.entry_start + 0.10
        if snapped >= b.entry_end - 0.10:
            snapped = b.entry_start + 0.20
        # Final guard: clamp to valid range
        snapped = min(snapped, b.entry_end - 0.15)
        if snapped <= 0:
            print(f'  [{word_num}{ab}] SKIP — could not compute valid start')
            continue

        # Snap end boundary into the silence gap just before the next label.
        # Cap at snapped + 7s so a bad b.entry_end (e.g. total_dur) can't bleed
        # the whole file in.
        MAX_SENT = 7.0
        end_cap = min(b.entry_end, snapped + MAX_SENT)
        end_target = end_cap - 0.6
        end_snapped = energy_snap(mp3_path, end_target, window=0.4) if end_target > snapped + 0.2 else end_cap
        end_snapped = max(end_snapped, snapped + 0.3)
        end_snapped = min(end_snapped, end_cap)
        audio = load_raw(mp3_path, snapped, end_snapped)
        audio = trim_trailing_silence(audio, TARGET_SR)

        if len(audio) < int(0.08 * TARGET_SR):
            print(f'  [{word_num}{ab}] WARNING: too short ({len(audio)/TARGET_SR:.3f}s) — using fallback offset')
            fallback_end = min(b.entry_start + 4.0, max(b.entry_end, b.entry_start + 1.0))
            audio = load_raw(mp3_path, b.entry_start + 0.50, fallback_end)
            audio = trim_trailing_silence(audio, TARGET_SR)
            fallback += 1
        else:
            written += 1

        save_wav(audio, TARGET_SR, out_path)
        dur = len(audio) / TARGET_SR
        print(f'  [{word_num:4d}{ab}] {text[:25]:25s}  sent_start={snapped:.3f}s  dur={dur:.3f}s  → {os.path.basename(out_path)}')

    return written, fallback


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    # Discover batch files from the examples directory
    txt_files = sorted(
        f for f in os.listdir(EXAMPLES_DIR) if f.endswith('.txt')
    )

    print('Loading Whisper medium model…')
    model = WhisperModel('medium', device='cpu', compute_type='int8')

    total_ok = total_fb = 0
    for txt_name in txt_files:
        txt_path = os.path.join(EXAMPLES_DIR, txt_name)
        mp3_path = txt_path.replace('.txt', '.mp3')
        if not os.path.exists(mp3_path):
            print(f'WARNING: no MP3 for {txt_name}, skipping')
            continue
        print(f'\n── {txt_name} ──')
        ok, fb = process_batch(model, txt_path, mp3_path)
        total_ok += ok
        total_fb += fb

    print(f'\nDone.')
    print(f'  Written (clean)  : {total_ok}')
    print(f'  Fallback rescues : {total_fb}')
    print(f'  Output dir       : {os.path.abspath(OUT_DIR)}')


if __name__ == '__main__':
    main()
