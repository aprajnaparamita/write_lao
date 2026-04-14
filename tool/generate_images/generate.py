#!/usr/bin/env python3
"""
Generate acrophonical illustrations for Lao consonants using FLUX.1-schnell.

Designed for Tesla P40 (24GB VRAM, Pascal arch, no bf16).

Usage:
    python generate.py                    # generate missing only
    python generate.py --force            # regenerate all
    python generate.py --only U+0E81      # single character
    python generate.py --size 768         # custom resolution
    python generate.py --low-vram         # CPU offload if OOM
    python generate.py --seed 42          # reproducible output
"""

import argparse
import json
import time
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
PROMPTS_FILE = SCRIPT_DIR / "prompts.json"
OUTPUT_DIR = PROJECT_ROOT / "assets" / "images" / "acrophonical"

MODEL_ID = "black-forest-labs/FLUX.1-schnell"


def load_prompts():
    data = json.loads(PROMPTS_FILE.read_text(encoding="utf-8"))
    style = data["style"]
    characters = data["characters"]
    return style, characters


def build_prompt(style, character):
    return f"{style['prefix']} {character['prompt_subject']}, {style['suffix']}"


def main():
    parser = argparse.ArgumentParser(description="Generate Lao acrophonical illustrations")
    parser.add_argument("--force", action="store_true", help="Regenerate all images")
    parser.add_argument("--only", type=str, help="Generate only this codepoint (e.g. U+0E81)")
    parser.add_argument("--size", type=int, default=512, help="Image size in pixels (default: 512)")
    parser.add_argument("--seed", type=int, default=2563, help="Random seed for reproducibility (default: 2563, Thai year of Lao independence)")
    parser.add_argument("--steps", type=int, default=4, help="Inference steps (default: 4 for schnell)")
    parser.add_argument("--sequential", action="store_true", help="Use sequential CPU offload (slower but even less VRAM)")
    parser.add_argument("--guidance", type=float, default=0.0, help="Guidance scale (default: 0.0 for schnell)")
    parser.add_argument("--dry-run", action="store_true", help="Print prompts without generating")
    args = parser.parse_args()

    style, characters = load_prompts()

    if args.only:
        characters = [c for c in characters if c["codepoint"] == args.only]
        if not characters:
            print(f"ERROR: No character found for {args.only}")
            sys.exit(1)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Dry run: just print prompts
    if args.dry_run:
        for char in characters:
            prompt = build_prompt(style, char)
            out_file = OUTPUT_DIR / f"{char['codepoint']}.png"
            exists = "EXISTS" if out_file.exists() else "MISSING"
            print(f"\n[{char['codepoint']}] {char['char']} — {char['meaning']} [{exists}]")
            print(f"  {prompt}")
        print(f"\n{len(characters)} prompts total")
        return

    # Import heavy deps only when actually generating
    print("Loading model...")
    import torch
    from diffusers import FluxPipeline

    # P40 doesn't support bf16 — use fp16
    dtype = torch.float16

    # FLUX.1 is ~24GB in fp16 — too large to fit entirely on a 24GB P40.
    # Always use CPU offloading: keeps components on CPU, moves them to GPU
    # one at a time during inference. Slower but fits in memory.
    pipe = FluxPipeline.from_pretrained(
        MODEL_ID,
        torch_dtype=dtype,
    )
    if args.sequential:
        print("Enabling sequential CPU offload (minimum VRAM mode)...")
        pipe.enable_sequential_cpu_offload()
    else:
        print("Enabling model CPU offload (required for 24GB GPU)...")
        pipe.enable_model_cpu_offload()

    # Keep VAE in fp16 to match pipeline dtype (avoids type mismatch with CPU offload).
    # Use upcast_vae workaround: decode latents in fp32 by temporarily upcasting.
    pipe.vae.config.force_upcast = False

    print(f"Model loaded. Generating {len(characters)} images at {args.size}x{args.size}")
    print(f"Seed: {args.seed}, Steps: {args.steps}")
    print()

    generated = 0
    skipped = 0

    for i, char in enumerate(characters):
        out_file = OUTPUT_DIR / f"{char['codepoint']}.png"

        if out_file.exists() and not args.force:
            print(f"  SKIP  [{char['codepoint']}] {char['char']} {char['meaning']}")
            skipped += 1
            continue

        prompt = build_prompt(style, char)
        print(f"  [{i+1}/{len(characters)}] {char['codepoint']} {char['char']} — {char['meaning']}...", end="", flush=True)

        t0 = time.time()
        generator = torch.Generator("cuda").manual_seed(args.seed)

        image = pipe(
            prompt=prompt,
            height=args.size,
            width=args.size,
            num_inference_steps=args.steps,
            guidance_scale=args.guidance,
            generator=generator,
        ).images[0]

        image.save(out_file)
        elapsed = time.time() - t0
        print(f" {elapsed:.1f}s")
        generated += 1

    print()
    print(f"Done. {generated} generated, {skipped} skipped.")
    print(f"Output: {OUTPUT_DIR}/")


if __name__ == "__main__":
    main()
