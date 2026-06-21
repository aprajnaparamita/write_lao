# Pali Chanting OCR Review — Deployment Guide

The review app lives at `https://writelao.xyz/chanting`.
It lets human reviewers mark each of the 136 scanned pages as OK or "has problem",
and flag specific OCR text runs that are wrong. Results are saved to D1 and can
be exported as JSON for LLM-assisted correction.

---

## One-time setup

### 1. Run the D1 migration

```bash
cd /Users/dara/dev/write_lao/website
wrangler d1 execute writelao-db \
  --file=migrations/0005_create_chanting_reviews.sql \
  --remote
```

### 2. Upload data to R2

The app reads three things from R2 under the `chanting/` prefix:
- `chanting/manifest.json` — page list and metadata
- `chanting/orig/*.jpg`   — original page thumbnails (one per page)
- `chanting/ocr/*.json`   — OCR JSON for each page (runs, bboxes, text)

The source files live in:
```
/Volumes/Dara/original scans/out/build_dots/web/orig/     ← thumbnails
/Volumes/Dara/original scans/out/build_dots/ocr_json/     ← OCR JSONs
/Volumes/Dara/original scans/out/build_dots/web/manifest.json
```

Upload the manifest:
```bash
wrangler r2 object put writelao-course-data/chanting/manifest.json \
  --file="/Volumes/Dara/original scans/out/build_dots/web/manifest.json"
```

Upload all thumbnails (bulk — takes a few minutes for 136 files):
```bash
for f in "/Volumes/Dara/original scans/out/build_dots/web/orig"/*.jpg; do
  echo "Uploading $(basename $f)..."
  wrangler r2 object put "writelao-course-data/chanting/orig/$(basename $f)" --file="$f"
done
```

Upload all OCR JSONs:
```bash
for f in "/Volumes/Dara/original scans/out/build_dots/ocr_json"/*.json; do
  echo "Uploading $(basename $f)..."
  wrangler r2 object put "writelao-course-data/chanting/ocr/$(basename $f)" --file="$f"
done
```

> **Tip:** If you re-run the OCR pipeline on vast.ai and get new results, just
> re-run the OCR JSON upload loop above — existing files are overwritten.

### 3. Deploy the worker

```bash
cd /Users/dara/dev/write_lao/website
wrangler deploy
```

---

## After OCR re-runs

When you run the pipeline on vast.ai and copy back new `results.tar.bz2`:

```bash
cd "/Volumes/Dara/original scans/out"

# Extract (overwrites ocr_json/, web/orig/, web/ viewer files)
tar -xjf results.tar.bz2

# Strip any remaining markdown/HTML from OCR output (usually done on vast.ai already)
python3 build_dots/strip_markdown.py

# Refine bboxes with Tesseract (split-only was already done on vast.ai;
# this also runs Tesseract to get pixel-accurate per-line y-coordinates).
# Requires Tesseract + lao language pack: brew install tesseract tesseract-lang
python3 build_dots/refine_bboxes.py \
  --ocr build_dots/ocr_json \
  --src "/Volumes/Dara/original scans/out"

# Re-upload OCR JSONs to R2
for f in build_dots/ocr_json/*.json; do
  wrangler r2 object put "writelao-course-data/chanting/ocr/$(basename $f)" \
    --file="$f" \
    --cwd /Users/dara/dev/write_lao/website
done

# Re-upload thumbnails if they changed
for f in build_dots/web/orig/*.jpg; do
  wrangler r2 object put "writelao-course-data/chanting/orig/$(basename $f)" \
    --file="$f" \
    --cwd /Users/dara/dev/write_lao/website
done

# Re-upload manifest if page list changed
wrangler r2 object put writelao-course-data/chanting/manifest.json \
  --file="build_dots/web/manifest.json" \
  --cwd /Users/dara/dev/write_lao/website
```

---

## Pulling reviews for LLM correction

All reviews are stored in D1. Export them via the API:

```bash
# All reviews
curl https://writelao.xyz/api/chanting/reviews | jq . > reviews_all.json

# Only problem pages
curl "https://writelao.xyz/api/chanting/reviews?status=problem" | jq . > reviews_problems.json

# One specific reviewer
curl "https://writelao.xyz/api/chanting/reviews?reviewer=Daisy" | jq . > reviews_daisy.json
```

Each review record looks like:
```json
{
  "id": 12,
  "reviewer_name": "Daisy",
  "page_id": "IMG_20260617_172414_1",
  "page_title": "46. ຂໍ້ຄິດໄຫວ້ພນະ",
  "status": "problem",
  "flagged_runs": [2, 5],
  "flagged_run_texts": ["ທ່ານທັງຫຼາຍ ທີ່ທ່ານໄດ້ທຸກ", "ສັພເພສັຕຕາ"],
  "reviewed_at": "2026-06-20 22:00:00"
}
```

Feed `flagged_run_texts` to the LLM along with the original image to ask for
corrected text. The `flagged_runs` indices let you update exactly those entries
in the OCR JSON.

---

## Local dev server (for testing the viewer, not the review app)

```bash
cd "/Volumes/Dara/original scans/out"
python3 build_dots/serve.py   # serves on http://127.0.0.1:8888
```

## Local dev server (for the review app / writelao worker)

```bash
cd /Users/dara/dev/write_lao/website
npx wrangler dev
# opens on http://localhost:8787/chanting
# Note: /chanting/data/* reads from R2 — data must already be uploaded
```
