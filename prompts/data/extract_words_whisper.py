#!/usr/bin/env python3
"""
Extract individual word audio from TTS batch files using Whisper word timestamps.

For each batch file:
  1. Silence-detection splits it into 100 entry segments (very reliable)
  2. faster-whisper transcribes the whole file with word-level timestamps
  3. For each entry, the numeric token's END time = where the Lao word starts
  4. Fall back to RMS-energy minimum when no numeric token aligns

Output: assets/vocab/audio/w_NNNN_word.wav  (16kHz mono PCM)
"""

import os
import re
import json
import subprocess
import tempfile

import numpy as np
from faster_whisper import WhisperModel

# ── Paths ─────────────────────────────────────────────────────────────────────
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT  = os.path.join(SCRIPT_DIR, '..', '..')
BATCH_DIR  = os.path.join(SCRIPT_DIR, 'word_list_with_numbers')
WORD_LIST  = os.path.join(SCRIPT_DIR, 'word_list_with_numbers.txt')
OUT_DIR    = os.path.join(REPO_ROOT, 'assets', 'vocab', 'audio')
TARGET_SR  = 16000

# ── Audio helpers ─────────────────────────────────────────────────────────────

def ffprobe_duration(path):
    r = subprocess.run(
        ['ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_format', path],
        capture_output=True, text=True, check=True,
    )
    return float(json.loads(r.stdout)['format']['duration'])


def detect_long_silences(path, noise_db=-35, min_dur=0.4):
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
    """Return list of (start, end) for each word entry in the batch file."""
    silences = detect_long_silences(path)
    dur = ffprobe_duration(path)
    segs, prev = [], 0.0
    for s, e, d in silences:
        if s > prev + 0.05:
            segs.append((prev, s))
        prev = e
    if prev < dur - 0.1:
        segs.append((prev, dur))
    return segs


def load_raw(path, start, end, sr=TARGET_SR):
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


def rms_word_start_fallback(audio, sr):
    """
    Fallback: find lowest-RMS point in plausible number-duration window.
    Searches from 0.15s to 65% of segment duration (max 0.9s).
    """
    win = int(0.020 * sr)
    hop = int(0.005 * sr)
    rms = np.array([
        np.sqrt(np.mean(audio[i:i + win] ** 2))
        for i in range(0, len(audio) - win, hop)
    ])
    total = len(audio) / sr
    s_sec = 0.15
    e_sec = min(total * 0.65, 0.90)
    fs = int(s_sec / (hop / sr))
    fe = min(int(e_sec / (hop / sr)), len(rms) - 1)
    if fs >= fe:
        return s_sec
    return max(0.0, (fs + int(np.argmin(rms[fs:fe]))) * hop / sr - 0.020)


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

def is_numeric_token(text):
    """True if token is a number (digits only, possibly with spaces/commas)."""
    return bool(re.fullmatch(r'[\s\d,\.]+', text))


def transcribe_batch(model, path):
    """
    Transcribe a batch file and return all word tokens as list of
    (start_sec, end_sec, text) sorted by start time.
    """
    segs, _ = model.transcribe(
        path,
        word_timestamps=True,
        beam_size=5,
        vad_filter=False,   # keep all audio including silence regions
    )
    tokens = []
    for seg in segs:
        for w in (seg.words or []):
            tokens.append((w.start, w.end, w.word))
    return tokens


def find_word_offset(seg_start, seg_end, all_tokens):
    """
    Given an entry's absolute time range and all Whisper tokens for the file,
    return the word start offset (seconds from seg_start).

    Strategy: find the numeric token whose start falls inside
    [seg_start - 0.6, seg_end].  The word starts at that token's end.
    If none found, return None (triggers fallback).
    """
    # Collect tokens that could belong to this entry
    # The number token for entry N typically starts shortly after seg_start
    # (Whisper sometimes places it a bit before due to silence)
    candidates = [
        (s, e, t) for s, e, t in all_tokens
        if seg_start - 0.6 <= s <= seg_end and is_numeric_token(t)
    ]
    if not candidates:
        return None

    # Use the numeric token that starts closest to seg_start
    candidates.sort(key=lambda x: abs(x[0] - seg_start))
    _, num_end, _ = candidates[0]

    # Convert to entry-relative offset
    offset = num_end - seg_start
    # Sanity: must be within (0.05, 90% of entry)
    entry_dur = seg_end - seg_start
    if not (0.05 < offset < entry_dur * 0.90):
        return None
    return offset


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    with open(WORD_LIST) as f:
        raw_lines = f.read().splitlines()
    words = []
    for line in raw_lines:
        if '"' in line:
            words.append(line.split('"')[1])
        else:
            words.append(re.sub(r'^\d+\.\s*', '', line).strip())

    print('Loading Whisper medium model…')
    model = WhisperModel('medium', device='cpu', compute_type='int8')

    batch_files = [
        ('1-100.mp3',   1,   100),
        ('101-200.mp3', 101, 200),
        ('201-300.mp3', 201, 300),
        ('301-400.mp3', 301, 400),
        ('401-500.mp3', 401, 500),
    ]

    total_whisper = 0
    total_fallback = 0

    for fname, first, last in batch_files:
        path = os.path.join(BATCH_DIR, fname)
        print(f'\n── {fname} (words {first}–{last}) ──')

        # Step 1: entry boundaries via silence detection
        segs = entry_segments(path)
        expected = last - first + 1
        if len(segs) != expected:
            print(f'  WARNING: expected {expected} segments, got {len(segs)}')

        # Step 2: transcribe whole file once
        print(f'  Transcribing with Whisper…')
        tokens = transcribe_batch(model, path)
        print(f'  Got {len(tokens)} tokens')

        for i, (seg_s, seg_e) in enumerate(segs):
            word_num = first + i
            if word_num > len(words):
                break

            word_text = words[word_num - 1]
            out_path  = os.path.join(OUT_DIR, f'w_{word_num:04d}_word.wav')

            # Step 3: find word offset using Whisper token
            offset = find_word_offset(seg_s, seg_e, tokens)
            method = 'whisper'

            if offset is None:
                # Step 4: fallback to RMS energy minimum
                audio = load_raw(path, seg_s, seg_e)
                offset = rms_word_start_fallback(audio, TARGET_SR)
                method = 'fallback'

            # Step 5: extract + trim + save
            audio = load_raw(path, seg_s + offset, seg_e)
            audio = trim_trailing_silence(audio, TARGET_SR)

            if len(audio) < int(0.05 * TARGET_SR):
                print(f'  [{word_num:4d}] WARNING too short after cut ({len(audio)/TARGET_SR:.3f}s) — {word_text}')
                audio = load_raw(path, seg_s + 0.10, seg_e)
                audio = trim_trailing_silence(audio, TARGET_SR)
                method += '(rescue)'

            save_wav(audio, TARGET_SR, out_path)

            dur = len(audio) / TARGET_SR
            flag = '⚠' if method.startswith('fallback') else ' '
            print(f'  {flag}[{word_num:4d}] {word_text:15s}  offset={offset:.3f}s  dur={dur:.3f}s  [{method}]')

            if method.startswith('whisper'):
                total_whisper += 1
            else:
                total_fallback += 1

    print(f'\nDone.')
    print(f'  Whisper-aligned : {total_whisper}')
    print(f'  Fallback (RMS)  : {total_fallback}')
    print(f'  Output dir      : {os.path.abspath(OUT_DIR)}')


if __name__ == '__main__':
    main()
