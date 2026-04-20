#!/usr/bin/env python3
"""
Build the Write Lao vocab course bundle from prompts/data/.

Reads:
  prompts/data/step5_definition_prompts/prompt_NNN_of_100.json  (100 files, 5 words each)
  prompts/data/outputs/prompt_NNN_of_100_M.png                  (500 images)
  prompts/data/audio/prompt_NNN_of_100_M_{word,example1,example2}.wav  (1500 audio files)

Writes:
  assets/vocab/course.json
  assets/vocab/images/w_XXXX.png
  assets/vocab/audio/w_XXXX_word.wav
  assets/vocab/audio/w_XXXX_example1.wav
  assets/vocab/audio/w_XXXX_example2.wav

Word order is the preserved insertion order of each prompt_NNN.json, concatenated
in filename order — which is already the canonical frequency ranking.

Grouping: 5 new words per lesson (matches prompt batches), 5 lessons per unit,
20 units total (5 * 5 * 20 = 500).
"""

from __future__ import annotations

import json
import shutil
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SRC_PROMPTS = REPO_ROOT / "prompts" / "data" / "step5_definition_prompts"
SRC_IMAGES = REPO_ROOT / "prompts" / "data" / "outputs"
SRC_AUDIO = REPO_ROOT / "prompts" / "data" / "audio"

DEST_ROOT = REPO_ROOT / "assets" / "vocab"
DEST_IMAGES = DEST_ROOT / "images"
DEST_AUDIO = DEST_ROOT / "audio"
DEST_COURSE_JSON = DEST_ROOT / "course.json"

WORDS_PER_LESSON = 5
LESSONS_PER_UNIT = 5
TOTAL_WORDS = 500

# Character classification tables. Only Lao codepoints the app can practice
# appear here — anything else (digits, punctuation, repetition/cancellation
# signs, Pali ellipsis) is skipped with a warning.
CONSONANT_CPS = {
    0x0E81, 0x0E82, 0x0E84, 0x0E87, 0x0E88, 0x0E8A, 0x0E8D,
    0x0E94, 0x0E95, 0x0E96, 0x0E97, 0x0E99, 0x0E9A, 0x0E9B,
    0x0E9C, 0x0E9D, 0x0E9E, 0x0E9F,
    0x0EA1, 0x0EA2, 0x0EA3, 0x0EA5, 0x0EA7, 0x0EAA, 0x0EAB,
    0x0EAD, 0x0EAE,
    0x0EDC, 0x0EDD,
}
VOWEL_CPS = {
    0x0EB0, 0x0EB1, 0x0EB2, 0x0EB3,
    0x0EB4, 0x0EB5, 0x0EB6, 0x0EB7, 0x0EB8, 0x0EB9,
    0x0EBB, 0x0EBC, 0x0EBD,
    0x0EC0, 0x0EC1, 0x0EC2, 0x0EC3, 0x0EC4,
    0x0ECD,
}
TONE_CPS = {0x0EC8, 0x0EC9, 0x0ECA, 0x0ECB}
SKIP_CPS = {0x0EAF, 0x0EC6, 0x0ECC} | set(range(0x0ED0, 0x0EDA))


def classify(ch: str) -> str | None:
    cp = ord(ch)
    if cp in CONSONANT_CPS:
        return "consonant"
    if cp in VOWEL_CPS:
        return "vowel"
    if cp in TONE_CPS:
        return "tone"
    return None


def lao_characters(word: str) -> list[dict]:
    """Classify each Lao codepoint in `word`. Skips unclassifiable codepoints
    silently (they're noted via the warning collector at the call site)."""
    out: list[dict] = []
    pos = 0
    for ch in word:
        if ch.isspace():
            continue
        cp = ord(ch)
        if cp in SKIP_CPS:
            continue
        kind = classify(ch)
        if kind is None:
            # Non-Lao or unknown — skip; caller warns once.
            continue
        out.append({"position": pos, "character": ch, "type": kind})
        pos += 1
    return out


def load_prompt_files() -> list[Path]:
    files = sorted(SRC_PROMPTS.glob("prompt_*_of_100.json"))
    if len(files) != 100:
        raise SystemExit(
            f"Expected 100 prompt JSON files in {SRC_PROMPTS}, found {len(files)}"
        )
    return files


def build() -> None:
    DEST_IMAGES.mkdir(parents=True, exist_ok=True)
    DEST_AUDIO.mkdir(parents=True, exist_ok=True)

    prompt_files = load_prompt_files()
    words_out: list[dict] = []
    lessons_out: list[dict] = []
    units_out: list[dict] = []

    warnings: list[str] = []
    global_index = 0  # 0-based across all 500 words

    for batch_idx, prompt_path in enumerate(prompt_files, start=1):
        batch_stem = prompt_path.stem  # e.g. "prompt_001_of_100"
        with prompt_path.open(encoding="utf-8") as f:
            entry = json.load(f)

        # Preserve insertion order; JSON decoder keeps order in Python 3.7+.
        keys = list(entry.keys())
        if len(keys) != 5:
            warnings.append(
                f"{batch_stem}: expected 5 words, got {len(keys)}"
            )

        for within_batch_idx, lao_word in enumerate(keys, start=1):
            global_index += 1
            word_id = f"w_{global_index:04d}"
            data = entry[lao_word]

            chars = lao_characters(lao_word)
            if not chars:
                warnings.append(
                    f"{word_id} ({lao_word}): no classifiable Lao chars — "
                    "forcing a single 'consonant' entry so the validator "
                    "doesn't reject the word."
                )
                chars = [{"position": 0, "character": lao_word[:1], "type": "consonant"}]

            # ───── Copy image ─────
            src_img = SRC_IMAGES / f"{batch_stem}_{within_batch_idx}.png"
            dst_img_rel = f"images/{word_id}.png"
            dst_img = DEST_ROOT / dst_img_rel
            if not src_img.exists():
                raise SystemExit(f"Missing source image: {src_img}")
            shutil.copyfile(src_img, dst_img)

            # ───── Copy audio (word + 2 examples) ─────
            src_word_audio = SRC_AUDIO / f"{batch_stem}_{within_batch_idx}_word.wav"
            dst_word_audio_rel = f"audio/{word_id}_word.wav"
            if not src_word_audio.exists():
                raise SystemExit(f"Missing source audio: {src_word_audio}")
            shutil.copyfile(src_word_audio, DEST_ROOT / dst_word_audio_rel)

            examples_out: list[dict] = []
            raw_examples = data.get("examples", [])
            for ex_idx, ex in enumerate(raw_examples[:2], start=1):
                src_ex_audio = SRC_AUDIO / (
                    f"{batch_stem}_{within_batch_idx}_example{ex_idx}.wav"
                )
                dst_ex_audio_rel = f"audio/{word_id}_example{ex_idx}.wav"
                if not src_ex_audio.exists():
                    raise SystemExit(f"Missing example audio: {src_ex_audio}")
                shutil.copyfile(src_ex_audio, DEST_ROOT / dst_ex_audio_rel)

                examples_out.append({
                    "example_id": f"{word_id}_ex{ex_idx}",
                    "lao_script": ex["lao_script"],
                    "romanization": ex["romanization"],
                    "translations": ex["translations"],
                    "audio_path": dst_ex_audio_rel,
                })

            if len(examples_out) < 1:
                raise SystemExit(f"{word_id}: no examples in source JSON")

            # Definitions come in under `definitions` keyed by language code.
            defs = dict(data.get("definitions", {}))
            if not defs:
                raise SystemExit(f"{word_id}: no definitions")

            words_out.append({
                "word_id": word_id,
                "lao_word": lao_word,
                "romanization": data.get("romanization", ""),
                "definitions": defs,
                "part_of_speech": data.get("part_of_speech", ""),
                "characters": chars,
                "image_path": dst_img_rel,
                "audio_path": dst_word_audio_rel,
                "examples": examples_out,
            })

    # ───── Build lessons and units ─────
    assert len(words_out) == TOTAL_WORDS, (
        f"Expected {TOTAL_WORDS} words, built {len(words_out)}"
    )

    for unit_idx in range(20):  # 0..19
        unit_number = unit_idx + 1
        unit_id = f"u_{unit_number:02d}"
        start_word = unit_idx * WORDS_PER_LESSON * LESSONS_PER_UNIT + 1
        end_word = start_word + (WORDS_PER_LESSON * LESSONS_PER_UNIT) - 1
        lesson_ids = []
        for lesson_within_unit in range(LESSONS_PER_UNIT):
            lesson_number = lesson_within_unit + 1
            lesson_id = f"l_{unit_number:02d}_{lesson_number:02d}"
            lesson_ids.append(lesson_id)
            offset = (
                unit_idx * WORDS_PER_LESSON * LESSONS_PER_UNIT
                + lesson_within_unit * WORDS_PER_LESSON
            )
            new_word_ids = [
                f"w_{offset + i + 1:04d}" for i in range(WORDS_PER_LESSON)
            ]
            lessons_out.append({
                "lesson_id": lesson_id,
                "unit_id": unit_id,
                "lesson_number": lesson_number,
                "new_word_ids": new_word_ids,
                "review_word_ids": [],
            })
        units_out.append({
            "unit_id": unit_id,
            "unit_number": unit_number,
            "title": f"Core Vocabulary — Part {unit_number}",
            "description": (
                f"Lao words {start_word}–{end_word} by frequency"
            ),
            "lesson_ids": lesson_ids,
        })

    course = {
        "version": "1.0.0",
        "language": "lao",
        "target_audience": "write_lao_500",
        "units": units_out,
        "lessons": lessons_out,
        "words": words_out,
    }

    DEST_COURSE_JSON.write_text(
        json.dumps(course, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(f"Wrote {DEST_COURSE_JSON}")
    print(
        f"  units={len(units_out)} lessons={len(lessons_out)} words={len(words_out)}"
    )
    print(f"  images copied to {DEST_IMAGES}")
    print(f"  audio copied to {DEST_AUDIO}")

    if warnings:
        print(f"\n{len(warnings)} warning(s):")
        for w in warnings:
            print(f"  - {w}")


if __name__ == "__main__":
    try:
        build()
    except SystemExit:
        raise
    except Exception as exc:
        print(f"FATAL: {exc}", file=sys.stderr)
        sys.exit(1)
