#!/usr/bin/env python3
"""
Extract each word from the LLM response files into individual JSON files.
Creates one file per word named: prompt_XXX_of_100_Y.json
where XXX = prompt number, Y = word index (1-5)
"""

import json
import os
import re

# Setup directories
INPUT_DIR = 'step5_definition_prompts'
OUTPUT_DIR = 'step5_individual_words'

# Create output directory
os.makedirs(OUTPUT_DIR, exist_ok=True)
print(f"Output directory: {OUTPUT_DIR}")

# Find all response JSON files (exclude manifest.json)
response_files = []
for f in os.listdir(INPUT_DIR):
    if f.startswith('prompt_') and f.endswith('.json') and f != 'manifest.json':
        response_files.append(f)

response_files.sort()
print(f"Found {len(response_files)} response files")

# Track statistics
total_words = 0
processed_files = 0
skipped = 0

for filename in response_files:
    filepath = os.path.join(INPUT_DIR, filename)
    
    # Extract prompt number from filename (e.g., "prompt_001_of_100.json" -> 1)
    match = re.search(r'prompt_(\d+)_of_100', filename)
    if not match:
        print(f"  Skipping: {filename} (could not extract prompt number)")
        skipped += 1
        continue
    
    prompt_num = int(match.group(1))
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"  Skipping: {filename} (JSON parse error: {e})")
        skipped += 1
        continue
    
    # Process each word in the response
    words_in_file = list(data.keys())
    
    for word_index, lao_word in enumerate(words_in_file, start=1):
        word_data = data[lao_word]
        
        # Create individual word entry
        entry = {
            "lao_word": lao_word,
            "definitions": word_data.get("definitions", {}),
            "definition_en": word_data.get("definitions", {}).get("en", ""),
            "romanization": word_data.get("romanization", ""),
            "lao_examples": [
                {
                    "lao_script": ex.get("lao_script", ""),
                    "romanization": ex.get("romanization", ""),
                    "translation_en": ex.get("translations", {}).get("en", "")
                }
                for ex in word_data.get("examples", [])
            ],
            "image_prompt": word_data.get("image_prompt", "")
        }
        
        # Generate output filename: prompt_001_of_100_1.json
        output_filename = f"prompt_{prompt_num:03d}_of_100_{word_index}.json"
        output_path = os.path.join(OUTPUT_DIR, output_filename)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(entry, f, ensure_ascii=False, indent=2)
        
        total_words += 1
    
    processed_files += 1

print(f"\n{'='*60}")
print("EXTRACTION COMPLETE")
print('='*60)
print(f"Files processed: {processed_files}")
print(f"Files skipped: {skipped}")
print(f"Total words extracted: {total_words}")
print(f"Output directory: {OUTPUT_DIR}")

# List some output files
print("\nSample output files:")
sample_files = sorted(os.listdir(OUTPUT_DIR))[:10]
for f in sample_files:
    print(f"  {f}")
