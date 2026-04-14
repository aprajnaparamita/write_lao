#!/usr/bin/env python3
"""
Generate pronunciation audio for all Lao characters using ElevenLabs TTS.

Usage:
    python3 tool/generate_audio.py                    # generate missing only
    python3 tool/generate_audio.py --force             # regenerate all
    python3 tool/generate_audio.py --voice VOICE_ID    # use specific voice
    python3 tool/generate_audio.py --dry-run           # preview without generating

Reads ELEVENLABS_API_KEY from .env file or environment.
Outputs MP3 files to assets/audio/pronunciation/{codepoint}.mp3
"""

import json
import os
import sys
import time
import argparse
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
CHAR_JSON = PROJECT_ROOT / "assets" / "lao_characters.json"
OUTPUT_DIR = PROJECT_ROOT / "assets" / "audio" / "pronunciation"
ENV_FILE = PROJECT_ROOT / ".env"

ELEVENLABS_URL = "https://api.elevenlabs.io/v1/text-to-speech"
MODEL_ID = "eleven_turbo_v2_5"
DEFAULT_VOICE = "EXAVITQu4vr4xnSDxMaL"  # Sarah - clear female voice


def load_env():
    """Load .env file into os.environ."""
    if ENV_FILE.exists():
        for line in ENV_FILE.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, val = line.split("=", 1)
                os.environ.setdefault(key.strip(), val.strip())


def get_api_key():
    load_env()
    key = os.environ.get("ELEVENLABS_API_KEY")
    if not key:
        print("ERROR: ELEVENLABS_API_KEY not found in .env or environment")
        sys.exit(1)
    return key


def load_characters():
    """Load character data and return list of (codepoint, text_to_speak) tuples."""
    data = json.loads(CHAR_JSON.read_text(encoding="utf-8"))
    characters = []

    for c in data["consonants"]:
        # Speak the full letter name: "ກໍ ໄກ່"
        characters.append((c["codepoint"], c["letterName"], c.get("acrophonicalMeaning", "")))

    for v in data["vowels"]:
        # Speak the vowel name: "ສະຫຼະ ອິ"
        characters.append((v["codepoint"], v["vowelName"], ""))

    for t in data["toneMarks"]:
        # Speak the tone mark name: "ໄມ້ເອກ"
        characters.append((t["codepoint"], t["toneName"], ""))

    for n in data["numerals"]:
        # Speak the Lao number name: "ສູນ"
        characters.append((n["codepoint"], n["laoName"], ""))

    for l in data["ligatures"]:
        # Speak the ligature name: "ຫໍ ນໍ"
        characters.append((l["codepoint"], l["letterName"], ""))

    for s in data["specialCharacters"]:
        # Speak the special character name: "ໄປຍານ້ອຍ"
        characters.append((s["codepoint"], s["name"], ""))

    return characters


def synthesize(api_key, voice_id, text):
    """Call ElevenLabs TTS and return MP3 bytes."""
    import urllib.request

    url = f"{ELEVENLABS_URL}/{voice_id}"
    payload = json.dumps({
        "text": text,
        "model_id": MODEL_ID,
        "voice_settings": {
            "stability": 0.6,
            "similarity_boost": 0.75,
            "style": 0.0,
            "use_speaker_boost": True,
        },
    }).encode("utf-8")

    req = urllib.request.Request(
        url,
        data=payload,
        headers={
            "xi-api-key": api_key,
            "Content-Type": "application/json",
            "Accept": "audio/mpeg",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req) as resp:
            return resp.read()
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        print(f"  API error {e.code}: {body[:200]}")
        return None


def main():
    parser = argparse.ArgumentParser(description="Generate Lao pronunciation audio")
    parser.add_argument("--force", action="store_true", help="Regenerate all files")
    parser.add_argument("--voice", default=DEFAULT_VOICE, help=f"ElevenLabs voice ID (default: {DEFAULT_VOICE})")
    parser.add_argument("--dry-run", action="store_true", help="Preview only, don't generate")
    args = parser.parse_args()

    api_key = get_api_key()
    characters = load_characters()
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Generating pronunciation audio for {len(characters)} characters")
    print(f"Voice: {args.voice}")
    print(f"Output: {OUTPUT_DIR}")
    print(f"Mode: {'force (overwrite all)' if args.force else 'skip existing'}")
    print()

    generated = 0
    skipped = 0
    errors = 0

    for codepoint, text, meaning in characters:
        out_file = OUTPUT_DIR / f"{codepoint}.mp3"
        label = f"{codepoint}  {text}"
        if meaning:
            label += f"  ({meaning})"

        if out_file.exists() and not args.force:
            print(f"  SKIP  {label}")
            skipped += 1
            continue

        if args.dry_run:
            print(f"  WOULD  {label}")
            generated += 1
            continue

        print(f"  GEN   {label} ...", end="", flush=True)
        audio = synthesize(api_key, args.voice, text)

        if audio:
            out_file.write_bytes(audio)
            size_kb = len(audio) / 1024
            print(f" {size_kb:.1f}KB")
            generated += 1
        else:
            print(" FAILED")
            errors += 1

        # Rate limit: ElevenLabs allows ~10 req/s on most plans
        time.sleep(0.15)

    print()
    print(f"Done. {generated} generated, {skipped} skipped, {errors} errors.")


if __name__ == "__main__":
    main()
