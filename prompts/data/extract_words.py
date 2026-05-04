#!/usr/bin/env python3
"""
Extract individual word audio from TTS batch files.

Input:  prompts/data/word_list_with_numbers/1-100.mp3 … 401-500.mp3
Output: assets/vocab/audio/w_NNNN_word.wav  (16kHz mono PCM)

Each batch file contains: silence / "number" / short-pause / "word" / silence / ...
Strategy:
  1. Split on long silences (>0.4s) → one entry per word
  2. Within each entry, find the lowest-RMS point in the plausible
     number-duration window → that's where the word starts
  3. Trim trailing silence and export as 16kHz mono WAV
"""

import os
import re
import json
import subprocess
import tempfile

import numpy as np

# ── Paths ────────────────────────────────────────────────────────────────────
SCRIPT_DIR   = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT    = os.path.join(SCRIPT_DIR, '..', '..')
BATCH_DIR    = os.path.join(SCRIPT_DIR, 'word_list_with_numbers')
WORD_LIST    = os.path.join(SCRIPT_DIR, 'word_list_with_numbers.txt')
OUT_DIR      = os.path.join(REPO_ROOT, 'assets', 'vocab', 'audio')
TARGET_SR    = 16000

# ── Helpers ──────────────────────────────────────────────────────────────────

def ffprobe_duration(path):
    r = subprocess.run(
        ['ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_format', path],
        capture_output=True, text=True, check=True,
    )
    return float(json.loads(r.stdout)['format']['duration'])


def detect_silences(path, noise_db=-35, min_dur=0.4):
    """Return list of (start, end, duration) for silences ≥ min_dur."""
    r = subprocess.run(
        ['ffmpeg', '-i', path, '-af',
         f'silencedetect=noise={noise_db}dB:d={min_dur}', '-f', 'null', '-'],
        capture_output=True, text=True,
    )
    starts = [float(x) for x in re.findall(r'silence_start: ([\d.]+)', r.stderr)]
    ends   = [float(x) for x in re.findall(r'silence_end: ([\d.]+)',   r.stderr)]
    durs   = [float(x) for x in re.findall(r'silence_duration: ([\d.]+)', r.stderr)]
    return list(zip(starts, ends, durs))


def entry_segments(path):
    """Split a batch file into one segment per word entry."""
    silences = detect_silences(path)
    dur = ffprobe_duration(path)
    segs, prev = [], 0.0
    for s, e, d in silences:
        if s > prev + 0.05:          # speech before this long silence
            segs.append((prev, s))
        prev = e
    if prev < dur - 0.1:
        segs.append((prev, dur))
    return segs


def load_raw(path, start, end, sr=TARGET_SR):
    """Extract audio segment as float32 numpy array via ffmpeg."""
    with tempfile.NamedTemporaryFile(suffix='.raw', delete=False) as f:
        tmp = f.name
    try:
        subprocess.run(
            ['ffmpeg', '-y', '-i', path,
             '-ss', str(start), '-to', str(end),
             '-ar', str(sr), '-ac', '1', '-f', 's16le', tmp],
            capture_output=True, check=True,
        )
        return np.frombuffer(open(tmp, 'rb').read(), dtype=np.int16).astype(np.float32)
    finally:
        os.unlink(tmp)


def find_word_start(audio, sr, num_dur_hint):
    """
    Find the sample offset where the word begins by looking for the
    lowest-energy point inside a plausible window after the number ends.
    Returns offset in seconds.
    """
    win = int(0.020 * sr)   # 20 ms RMS window
    hop = int(0.005 * sr)   # 5 ms hop
    rms = np.array([
        np.sqrt(np.mean(audio[i:i + win] ** 2))
        for i in range(0, len(audio) - win, hop)
    ])
    total = len(audio) / sr
    # Search between 80% of the hint and 65% of segment duration (max 0.9s)
    s_sec = max(0.10, num_dur_hint * 0.80)
    e_sec = min(total * 0.65, 0.90)
    fs = int(s_sec / (hop / sr))
    fe = min(int(e_sec / (hop / sr)), len(rms) - 1)
    if fs >= fe:
        return s_sec
    min_frame = fs + int(np.argmin(rms[fs:fe]))
    # Back off 20 ms so we don't clip the word attack
    return max(0.0, min_frame * hop / sr - 0.020)


def trim_trailing_silence(audio, sr, noise_db=-40):
    """Return audio with trailing silence removed."""
    threshold = 10 ** (noise_db / 20.0) * 32768
    win = int(0.020 * sr)
    # Walk backwards in 20 ms chunks until we find signal
    end = len(audio)
    while end > win:
        chunk = audio[end - win:end]
        if np.sqrt(np.mean(chunk ** 2)) > threshold:
            break
        end -= win
    # Add 50 ms tail
    end = min(len(audio), end + int(0.050 * sr))
    return audio[:end]


def save_wav(audio_float32, sr, out_path):
    """Write float32 array as 16-bit PCM WAV via ffmpeg pipe."""
    pcm = np.clip(audio_float32, -32768, 32767).astype(np.int16)
    proc = subprocess.Popen(
        ['ffmpeg', '-y',
         '-f', 's16le', '-ar', str(sr), '-ac', '1', '-i', 'pipe:0',
         '-acodec', 'pcm_s16le', out_path],
        stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    proc.communicate(input=pcm.tobytes())


# ── Number-duration hints ─────────────────────────────────────────────────────

def num_hint(n):
    """Estimated spoken duration of the number n in English (seconds)."""
    if n < 10:
        return 0.22        # "one" … "nine"
    elif n < 20:
        return 0.38        # "ten" … "nineteen"
    elif n < 100:
        return 0.48        # "twenty-one" etc.
    elif n % 100 == 0:
        return 0.55        # "one hundred", "two hundred" …
    else:
        return 0.70        # "one hundred one" … "four hundred ninety-nine"


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    # Read word list
    with open(WORD_LIST) as f:
        raw_lines = f.read().splitlines()
    # Each line: `N. "word"`  or  `N. word`
    words = []
    for line in raw_lines:
        if '"' in line:
            words.append(line.split('"')[1])
        else:
            words.append(re.sub(r'^\d+\.\s*', '', line).strip())

    batch_files = [
        ('1-100.mp3',   1,   100),
        ('101-200.mp3', 101, 200),
        ('201-300.mp3', 201, 300),
        ('301-400.mp3', 301, 400),
        ('401-500.mp3', 401, 500),
    ]

    total_written = 0

    for fname, first, last in batch_files:
        path = os.path.join(BATCH_DIR, fname)
        print(f'\n── {fname} (words {first}–{last}) ──')
        segs = entry_segments(path)
        expected = last - first + 1
        if len(segs) != expected:
            print(f'  WARNING: expected {expected} segments, got {len(segs)}')

        for i, (seg_s, seg_e) in enumerate(segs):
            word_num = first + i
            if word_num > len(words):
                break

            out_path = os.path.join(OUT_DIR, f'w_{word_num:04d}_word.wav')
            word_text = words[word_num - 1]

            audio = load_raw(path, seg_s, seg_e)
            hint  = num_hint(word_num)
            ws    = find_word_start(audio, TARGET_SR, hint)

            word_samples = int(ws * TARGET_SR)
            word_audio   = audio[word_samples:]
            word_audio   = trim_trailing_silence(word_audio, TARGET_SR)

            if len(word_audio) < int(0.05 * TARGET_SR):
                print(f'  [{word_num:4d}] WARNING: word too short ({len(word_audio)/TARGET_SR:.3f}s) — {word_text}')
                # Fall back to full segment minus first 100ms
                word_audio = audio[int(0.10 * TARGET_SR):]
                word_audio = trim_trailing_silence(word_audio, TARGET_SR)

            save_wav(word_audio, TARGET_SR, out_path)
            dur = len(word_audio) / TARGET_SR
            print(f'  [{word_num:4d}] {word_text:15s}  offset={ws:.3f}s  dur={dur:.3f}s  → {os.path.basename(out_path)}')
            total_written += 1

    print(f'\nDone. Wrote {total_written} files to {OUT_DIR}/')


if __name__ == '__main__':
    main()
