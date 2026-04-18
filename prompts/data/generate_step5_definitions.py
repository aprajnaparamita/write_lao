#!/usr/bin/env python3
"""
Step 5: Run each prompt_XXX_of_100.txt through the Anthropic API and save
the JSON response as prompt_XXX_of_100.json.

Uses prompt caching on the shared instruction template (everything before
the "Words to define:" section) so that repeat prompts reuse the cache
and input cost is reduced dramatically.

Requirements:
  pip install anthropic
  export ANTHROPIC_API_KEY=sk-ant-...

Usage:
  python generate_step5_definitions.py                 # process all missing
  python generate_step5_definitions.py --start 8 --end 100
  python generate_step5_definitions.py --model claude-opus-4-7
  python generate_step5_definitions.py --concurrency 5
  python generate_step5_definitions.py --overwrite     # redo even if .json exists
"""

from __future__ import annotations

import argparse
import concurrent.futures as cf
import json
import os
import re
import sys
import time
from pathlib import Path

try:
    from anthropic import Anthropic
except ImportError:
    sys.exit("Missing dependency: pip install anthropic")


PROMPTS_DIR = Path(__file__).parent / "step5_definition_prompts"
MANIFEST = PROMPTS_DIR / "manifest.json"

# Split each prompt into (cacheable template, per-prompt words block) so the
# template is sent as a cache breakpoint and hits cache on every subsequent call.
WORDS_MARKER = "Words to define:"


def split_prompt(text: str) -> tuple[str, str]:
    idx = text.find(WORDS_MARKER)
    if idx == -1:
        return text, ""
    return text[:idx], text[idx:]


def extract_json(response_text: str) -> dict:
    """Pull the first top-level JSON object from the model's reply."""
    # Prefer a fenced ```json block if present
    fenced = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", response_text, re.DOTALL)
    candidate = fenced.group(1) if fenced else None
    if candidate is None:
        start = response_text.find("{")
        end = response_text.rfind("}")
        if start == -1 or end == -1 or end <= start:
            raise ValueError("No JSON object found in response")
        candidate = response_text[start : end + 1]
    return json.loads(candidate)


def process_one(
    client: Anthropic,
    prompt_path: Path,
    out_path: Path,
    model: str,
    max_tokens: int,
    overwrite: bool,
) -> tuple[Path, str]:
    if out_path.exists() and not overwrite:
        return out_path, "skipped"

    prompt_text = prompt_path.read_text(encoding="utf-8")
    template, words_block = split_prompt(prompt_text)

    last_err: Exception | None = None
    for attempt in range(6):
        try:
            resp = client.messages.create(
                model=model,
                max_tokens=max_tokens,
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "text",
                                "text": template,
                                "cache_control": {"type": "ephemeral"},
                            },
                            {"type": "text", "text": words_block},
                        ],
                    }
                ],
            )
            reply = "".join(
                b.text for b in resp.content if getattr(b, "type", None) == "text"
            )
            data = extract_json(reply)
            out_path.write_text(
                json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8"
            )
            return out_path, "ok"
        except Exception as e:  # noqa: BLE001
            last_err = e
            msg = str(e)
            if "rate_limit" in msg or "429" in msg:
                time.sleep(30 + 15 * attempt)
            else:
                time.sleep(2 ** attempt)
    return out_path, f"error: {last_err}"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--start", type=int, default=1)
    ap.add_argument("--end", type=int, default=100)
    ap.add_argument(
        "--model",
        default="claude-sonnet-4-6",
        help="Anthropic model id (default claude-sonnet-4-6 for cost; use claude-opus-4-7 for max quality)",
    )
    ap.add_argument("--max-tokens", type=int, default=16000)
    ap.add_argument("--concurrency", type=int, default=4)
    ap.add_argument("--overwrite", action="store_true")
    args = ap.parse_args()

    if not os.environ.get("ANTHROPIC_API_KEY"):
        sys.exit("Set ANTHROPIC_API_KEY before running.")

    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    total = manifest["total_prompts"]

    jobs: list[tuple[Path, Path]] = []
    for entry in manifest["prompts"]:
        n = entry["prompt_number"]
        if not (args.start <= n <= args.end):
            continue
        prompt_path = PROMPTS_DIR / entry["filename"]
        out_path = prompt_path.with_suffix(".json")
        jobs.append((prompt_path, out_path))

    client = Anthropic(max_retries=8)
    print(f"Processing {len(jobs)} prompts with {args.model} (concurrency={args.concurrency})")
    done = 0
    with cf.ThreadPoolExecutor(max_workers=args.concurrency) as pool:
        futures = [
            pool.submit(
                process_one,
                client,
                p,
                o,
                args.model,
                args.max_tokens,
                args.overwrite,
            )
            for p, o in jobs
        ]
        for fut in cf.as_completed(futures):
            out_path, status = fut.result()
            done += 1
            print(f"[{done}/{len(jobs)}] {out_path.name}: {status}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
