#!/usr/bin/env python3
"""
Split a single pronunciation MP3 into per-character files.

The input MP3 should contain all character names spoken in sequence,
separated by a delimiter word (e.g. "0") that creates silence gaps.

This script detects silence gaps using ffmpeg, splits the audio, and
names each segment using the manifest from generate_pronunciation_text.

Usage:
    python3 tool/split_audio.py INPUT.mp3
    python3 tool/split_audio.py INPUT.mp3 --min-silence 0.3 --threshold -30
    python3 tool/split_audio.py INPUT.mp3 --dry-run

Requires: ffmpeg (brew install ffmpeg)
"""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
MANIFEST = PROJECT_ROOT / "tool" / "pronunciation_manifest.tsv"
OUTPUT_DIR = PROJECT_ROOT / "assets" / "audio" / "pronunciation"


def load_manifest():
    """Load the ordered list of (index, codepoint, name) from manifest."""
    entries = []
    for line in MANIFEST.read_text(encoding="utf-8").splitlines():
        parts = line.strip().split("\t")
        if len(parts) >= 2:
            entries.append((int(parts[0]), parts[1], parts[2] if len(parts) > 2 else ""))
    return entries


def detect_silences(input_file, min_silence=0.4, threshold=-30):
    """Use ffmpeg silencedetect to find silence periods."""
    cmd = [
        "ffmpeg", "-i", str(input_file),
        "-af", f"silencedetect=noise={threshold}dB:d={min_silence}",
        "-f", "null", "-"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    stderr = result.stderr

    # Parse silence_start and silence_end from ffmpeg output
    starts = [float(m) for m in re.findall(r"silence_start: ([\d.]+)", stderr)]
    ends = [float(m) for m in re.findall(r"silence_end: ([\d.]+)", stderr)]

    # Pair them up
    silences = list(zip(starts, ends))
    return silences


def get_duration(input_file):
    """Get total duration of audio file."""
    cmd = ["ffprobe", "-v", "quiet", "-show_entries", "format=duration",
           "-of", "default=noprint_wrappers=1:nokey=1", str(input_file)]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return float(result.stdout.strip())


def split_segment(input_file, start, end, output_file):
    """Extract a segment from the input file."""
    cmd = [
        "ffmpeg", "-y", "-i", str(input_file),
        "-ss", f"{start:.3f}", "-to", f"{end:.3f}",
        "-c:a", "libmp3lame", "-q:a", "4",
        str(output_file)
    ]
    subprocess.run(cmd, capture_output=True, check=True)


def main():
    parser = argparse.ArgumentParser(description="Split pronunciation audio into per-character files")
    parser.add_argument("input", help="Input MP3 file with all pronunciations")
    parser.add_argument("--min-silence", type=float, default=0.4,
                        help="Minimum silence duration to detect as gap (seconds, default: 0.4)")
    parser.add_argument("--threshold", type=int, default=-30,
                        help="Silence threshold in dB (default: -30)")
    parser.add_argument("--dry-run", action="store_true", help="Show splits without writing files")
    parser.add_argument("--padding", type=float, default=0.05,
                        help="Seconds of padding to keep around each segment (default: 0.05)")
    args = parser.parse_args()

    input_file = Path(args.input)
    if not input_file.exists():
        print(f"ERROR: {input_file} not found")
        sys.exit(1)

    entries = load_manifest()
    print(f"Manifest: {len(entries)} characters")

    duration = get_duration(input_file)
    print(f"Audio: {duration:.1f}s")

    print(f"Detecting silences (min={args.min_silence}s, threshold={args.threshold}dB)...")
    silences = detect_silences(input_file, args.min_silence, args.threshold)
    print(f"Found {len(silences)} silence gaps")

    # Build segment boundaries: speech regions between silences
    segments = []
    # First segment: from start to first silence
    if silences:
        seg_start = 0.0
        for sil_start, sil_end in silences:
            seg_end = sil_start
            if seg_end - seg_start > 0.05:  # ignore tiny segments
                segments.append((seg_start, seg_end))
            seg_start = sil_end
        # Last segment: from last silence end to file end
        if seg_start < duration:
            segments.append((seg_start, duration))
    else:
        segments.append((0.0, duration))

    print(f"Found {len(segments)} speech segments")
    print()

    expected = len(entries)
    if len(segments) != expected:
        print(f"WARNING: Expected {expected} segments but found {len(segments)}.")
        print(f"Try adjusting --min-silence (currently {args.min_silence}) or --threshold (currently {args.threshold}).")
        print()
        if len(segments) > expected:
            print("Too many segments — try increasing --min-silence or lowering --threshold.")
        else:
            print("Too few segments — try decreasing --min-silence or raising --threshold.")
        print()
        # Show segments for debugging
        for i, (s, e) in enumerate(segments):
            label = entries[i][2] if i < len(entries) else "???"
            print(f"  [{i:2d}] {s:6.2f}s – {e:6.2f}s  ({e-s:.2f}s)  {label}")
        print()
        resp = input(f"Continue with {min(len(segments), expected)} segments? [y/N] ")
        if resp.lower() != "y":
            sys.exit(0)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    count = min(len(segments), len(entries))

    for i in range(count):
        seg_start, seg_end = segments[i]
        _, codepoint, name = entries[i]
        out_file = OUTPUT_DIR / f"{codepoint}.mp3"

        # Apply padding
        padded_start = max(0, seg_start - args.padding)
        padded_end = min(duration, seg_end + args.padding)

        if args.dry_run:
            print(f"  [{i:2d}] {padded_start:6.2f}s – {padded_end:6.2f}s → {out_file.name}  {name}")
        else:
            split_segment(input_file, padded_start, padded_end, out_file)
            size_kb = out_file.stat().st_size / 1024
            print(f"  [{i:2d}] {padded_start:6.2f}s – {padded_end:6.2f}s → {out_file.name}  ({size_kb:.1f}KB)  {name}")

    print()
    print(f"Done. {count} files {'would be' if args.dry_run else ''} written to {OUTPUT_DIR}/")


if __name__ == "__main__":
    main()
