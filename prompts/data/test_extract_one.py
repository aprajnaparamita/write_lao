#!/usr/bin/env python3
"""
Test script - extract only the Lao text portion for the first batch file.
Focuses on finding actual speech boundaries instead of using fixed offsets.
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


def ffprobe_duration(path):
    r = subprocess.run(
        ['ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_format', path],
        capture_output=True, text=True, check=True,
    )
    return float(json.loads(r.stdout)['format']['duration'])


def load_raw(path, start, end, sr=TARGET_SR):
    with tempfile.NamedTemporaryFile(suffix='.raw', delete=False) as f:
        tmp = f.name
    try:
        subprocess.run(
            ['ffmpeg', '-y', '-i', path,
             '-ss', str(max(0, start)), '-to', str(end),
             '-ar', str(sr), '-ac', '1', '-f', 's16le', tmp],
            capture_output=True, check=True,
        )
        return np.frombuffer(open(tmp, 'rb').read(), dtype=np.int16).astype(np.float32)
    finally:
        os.unlink(tmp)


def find_speech_onset(audio, sr, search_start=0.0, max_duration=0.5):
    """
    Find the exact start of speech by scanning for energy above silence threshold.
    Returns time in seconds from the start of the audio segment.
    """
    threshold = 500  # RMS threshold for speech detection
    win_s = int(0.010 * sr)  # 10ms window
    hop_s = int(0.005 * sr)  # 5ms hop
    
    # Scan for first frame above threshold
    for i in range(0, len(audio) - win_s, hop_s):
        rms = np.sqrt(np.mean(audio[i:i + win_s] ** 2))
        if rms > threshold:
            # Found onset - return time
            onset_time = i / sr
            if onset_time <= max_duration:
                return onset_time
            return 0.0
    return 0.0


def find_speech_offset(audio, sr, search_end=None):
    """
    Find the exact end of speech by scanning backwards for last energy above silence.
    Returns time in seconds from the start of the audio segment.
    """
    if search_end is None:
        search_end = len(audio) / sr
    
    threshold = 500
    win_s = int(0.010 * sr)
    hop_s = int(0.005 * sr)
    
    # Scan backwards from the end
    for i in range(len(audio) - win_s, 0, -hop_s):
        rms = np.sqrt(np.mean(audio[i:i + win_s] ** 2))
        if rms > threshold:
            # Found offset - return time (with small buffer)
            offset_time = i / sr
            return min(offset_time + 0.020, len(audio) / sr)  # 20ms buffer
    return 0.0


def trim_silence(audio, sr):
    """Trim leading and trailing silence from audio."""
    # Trim leading
    threshold = 500
    win_s = int(0.010 * sr)
    hop_s = int(0.005 * sr)
    
    start_idx = 0
    for i in range(0, len(audio) - win_s, hop_s):
        rms = np.sqrt(np.mean(audio[i:i + win_s] ** 2))
        if rms > threshold:
            start_idx = max(0, i - hop_s)
            break
    
    # Trim trailing
    end_idx = len(audio)
    for i in range(len(audio) - win_s, start_idx, -hop_s):
        rms = np.sqrt(np.mean(audio[i:i + win_s] ** 2))
        if rms > threshold:
            end_idx = min(len(audio), i + win_s + hop_s)
            break
    
    return audio[start_idx:end_idx]


def save_wav(audio_float32, sr, out_path):
    pcm = np.clip(audio_float32, -32768, 32767).astype(np.int16)
    proc = subprocess.Popen(
        ['ffmpeg', '-y',
         '-f', 's16le', '-ar', str(sr), '-ac', '1', '-i', 'pipe:0',
         '-acodec', 'pcm_s16le', out_path],
        stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    proc.communicate(input=pcm.tobytes())


def transcribe(model, path):
    segs, _ = model.transcribe(
        path, language='lo', word_timestamps=True, beam_size=5, vad_filter=False,
    )
    segs = list(segs)
    words = [w for s in segs for w in (s.words or [])]
    return segs, words


def is_digit_token(tok):
    return bool(re.fullmatch(r'[\s\d]+', tok.strip()))


def parse_text_file(path):
    """Parse examples text file."""
    entries = []
    for line in open(path, encoding='utf-8'):
        line = line.strip()
        if not line:
            continue
        m = re.match(r'^(\d+)([ab])\.(.*)$', line)
        if m:
            entries.append((int(m.group(1)), m.group(2), m.group(3)))
    return entries


def analyze_batch(model, txt_path, mp3_path, limit=5):
    """Analyze and extract examples, showing debug info for first `limit` entries."""
    entries = parse_text_file(txt_path)
    if not entries:
        print(f'No entries parsed from {txt_path}')
        return

    entries = entries[:limit]  # Only process first few for testing
    
    print(f'\nTranscribing {os.path.basename(mp3_path)}...')
    segs, words = transcribe(model, mp3_path)
    
    if not words:
        print('ERROR: no word tokens returned')
        return

    print(f'\nTotal words: {len(words)}')
    print(f'File duration: {words[-1].end:.3f}s')
    
    # Find digit runs
    digit_runs = []
    i = 0
    while i < len(words):
        tok = words[i].word.strip()
        if is_digit_token(tok):
            run_start = words[i].start
            run_end = words[i].end
            num_str = tok
            j = i + 1
            while j < len(words) and is_digit_token(words[j].word.strip()):
                run_end = words[j].end
                num_str += words[j].word.strip()
                j += 1
            try:
                number = int(num_str)
            except ValueError:
                number = None
            next_tok = words[j] if j < len(words) else None
            digit_runs.append({
                'number': number,
                'run_start': run_start,
                'run_end': run_end,
                'next_tok': next_tok.word if next_tok else None,
                'next_start': next_tok.start if next_tok else None,
            })
            i = j
        else:
            i += 1
    
    print(f'\nDigit runs found: {len(digit_runs)}')
    for dr in digit_runs[:15]:
        print(f"  {dr['number']:4d}: {dr['run_start']:.3f}s - {dr['run_end']:.3f}s | next: '{dr['next_tok']}' @ {dr['next_start']:.3f}s")
    
    # For each entry, find the Lao text boundaries
    print(f'\n{"="*60}')
    print('Analyzing sentence boundaries:')
    print(f'{"="*60}\n')
    
    for entry_idx, (word_num, ab, text) in enumerate(entries):
        print(f'[{word_num}{ab}] "{text[:40]}..."')
        
        # Find this entry's digit run
        entry_drs = [dr for dr in digit_runs if dr['number'] == word_num]
        if not entry_drs:
            print(f'  ERROR: No digit run found for {word_num}{ab}')
            continue
        
        # Use first matching run for 'a', second for 'b'
        dr = entry_drs[0] if ab == 'a' else (entry_drs[1] if len(entry_drs) > 1 else entry_drs[0])
        
        label_start = dr['run_start']
        label_end = dr['run_end']
        
        # Find what comes after the label
        next_word = dr['next_tok']
        next_start = dr['next_start']
        
        print(f'  Label: {label_start:.3f}s - {label_end:.3f}s')
        print(f'  Next word: "{next_word}" @ {next_start:.3f}s')
        
        # Find Lao text start: first non-label, non-silence token after label
        lao_text_start = None
        for w in words:
            if w.start > label_end + 0.1 and w.start > label_start:
                # Skip if this is the next number label
                if is_digit_token(w.word.strip()):
                    continue
                # Skip 'ว่า' and related particles
                if w.word.strip() in ('ว', '่', 'า', 'ว่', 'ว่า', '່'):
                    continue
                lao_text_start = w.start
                print(f'  Lao text starts: "{w.word.strip()}" @ {w.start:.3f}s')
                break
        
        if lao_text_start is None:
            print(f'  ERROR: Could not find Lao text start')
            continue
        
        # Find the boundary where Lao text ends
        # Lao text ends BEFORE the next label starts (so we don't include it)
        next_entry_idx = entry_idx + 1
        lao_text_end = None
        
        if next_entry_idx < len(entries):
            next_word_num, next_ab, _ = entries[next_entry_idx]
            
            # Find all digit runs for the next entry
            next_drs = [dr for dr in digit_runs if dr['number'] == next_word_num]
            
            if next_drs:
                # Each word_num has 2 runs (a and b), find the right one
                if len(next_drs) == 1:
                    next_label_start = next_drs[0]['run_start']
                elif next_ab == 'a':
                    next_label_start = next_drs[0]['run_start']
                else:
                    next_label_start = next_drs[1]['run_start']
                
                # End just BEFORE the next label starts (to exclude it)
                lao_text_end = next_label_start - 0.05
                print(f'  Lao text ends @ {lao_text_end:.3f}s (before {next_word_num}{next_ab} @ {next_label_start:.3f}s)')
            else:
                lao_text_end = label_end + 4.0
                print(f'  Lao text ends @ {lao_text_end:.3f}s (estimated)')
        else:
            # Last entry - estimate 4 seconds
            lao_text_end = lao_text_start + 4.0
            print(f'  Lao text ends @ {lao_text_end:.3f}s (last entry)')
        
        # Safety check
        if lao_text_end <= lao_text_start:
            print(f'  WARNING: lao_text_end ({lao_text_end:.3f}) <= lao_text_start ({lao_text_start:.3f})')
            print(f'  Using label_end + 4.0 as fallback')
            lao_text_end = label_end + 4.0
        
        # Extract audio and find exact boundaries using energy
        print(f'  Extracting: {lao_text_start:.3f}s - {lao_text_end:.3f}s')
        
        raw_audio = load_raw(mp3_path, lao_text_start, lao_text_end)
        if len(raw_audio) < 100:
            print(f'  ERROR: Audio too short')
            continue
        
        # Use Whisper word timestamps directly for exact boundaries
        # Find first and last Lao words (not digits) in this segment
        
        first_word = None
        last_word = None
        for w in words:
            if w.start >= lao_text_start and w.start < lao_text_end:
                stripped = w.word.strip()
                if stripped and not is_digit_token(stripped):
                    if first_word is None:
                        first_word = w
                    last_word = w
            elif w.start >= lao_text_end:
                break
        
        if first_word:
            exact_start = first_word.start
        else:
            exact_start = lao_text_start + onset
        
        if last_word:
            # End right after the last Lao word (no buffer - speech stops immediately)
            exact_end = last_word.end + 0.02
        else:
            exact_end = lao_text_end
        
        print(f'  Exact boundaries: {exact_start:.3f}s - {exact_end:.3f}s')
        print(f'  Duration: {(exact_end - exact_start):.3f}s')
        
        # Extract with trim
        audio = load_raw(mp3_path, exact_start, exact_end)
        audio = trim_silence(audio, TARGET_SR)
        
        if len(audio) < 100:
            print(f'  WARNING: Still too short after trim')
            continue
        
        final_dur = len(audio) / TARGET_SR
        print(f'  FINAL: {exact_start:.3f}s - {exact_end:.3f}s, dur={final_dur:.3f}s')
        
        # Save
        example_num = 1 if ab == 'a' else 2
        out_path = os.path.join(OUT_DIR, f'w_{word_num:04d}_example{example_num}.wav')
        save_wav(audio, TARGET_SR, out_path)
        print(f'  → Saved to {os.path.basename(out_path)}')
        print()


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    
    print('Loading Whisper medium model...')
    model = WhisperModel('medium', device='cpu', compute_type='int8')
    
    # Find first txt file
    txt_files = sorted(f for f in os.listdir(EXAMPLES_DIR) if f.endswith('.txt'))
    if not txt_files:
        print('No text files found')
        return
    
    txt_name = txt_files[0]
    txt_path = os.path.join(EXAMPLES_DIR, txt_name)
    mp3_path = txt_path.replace('.txt', '.mp3')
    
    if not os.path.exists(mp3_path):
        print(f'MP3 not found: {mp3_path}')
        return
    
    print(f'Processing: {txt_name}')
    analyze_batch(model, txt_path, mp3_path, limit=5)


if __name__ == '__main__':
    main()
