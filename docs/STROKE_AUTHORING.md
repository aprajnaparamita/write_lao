# Stroke Authoring Guide

## Overview

Each Lao character needs hand-authored stroke data defining the center-line path of each stroke in the correct writing order. This guide explains the full workflow.

## Prerequisites

- Inkscape 1.0+ (free, cross-platform SVG editor)
- Noto Lao font installed (for reference glyph rendering)
- Dart SDK (to run the SVG-to-JSON converter)

## Step 1: SVG Files

SVG templates are located in `lao_svgs/` directory. Each SVG has:
- A reference layer with the character rendered semi-transparently
- A strokes layer where you draw your center-line strokes
- Metadata attributes (codepoint, name, etc.)

## Step 2: Draw Strokes in Inkscape

1. Open the SVG in Inkscape
2. In the Layers panel, LOCK the `reference` layer
3. Select the `strokes` layer as active
4. Draw each stroke as a separate path using the Bezier tool (B)
   - Draw ONE path per stroke
   - Draw strokes IN WRITING ORDER
   - Use thin strokes (8px width, no fill)

### What Makes a Good Stroke Path

- **Clean curves:** Use smooth Bezier curves
- **Center-line:** The path follows the CENTER of the stroke
- **Correct direction:** Start where the pen/finger starts writing
- **Minimal nodes:** 4-8 nodes per stroke

## Step 3: Convert to JSON

```bash
dart run tool/svg_to_json.dart lao_svgs/01_01_ko_U0E81.svg -o assets/stroke_data/
```

## Step 4: Test in the App

1. Copy the JSON to `assets/stroke_data/`
2. Run the app
3. Practice the character
4. Verify matching works correctly

## Stroke Order Reference

General Lao stroke order rules:
1. Top to bottom
2. Left to right
3. Loops/circles drawn first (typically clockwise)
4. Horizontal strokes before vertical strokes

## File Naming Convention

- SVG: `{phase}_{order}_{name}_{codepoint}.svg`
- JSON: `{codepoint}.json` (e.g., `U+0E81.json`)

## Quality Checklist

- [ ] Correct number of strokes
- [ ] Correct stroke order
- [ ] Correct stroke direction
- [ ] Clean, smooth paths
- [ ] Paths in the `strokes` layer
- [ ] JSON converts without errors
- [ ] Matching works in the app
