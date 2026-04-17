#!/usr/bin/env python3
"""
Merge all LLM batch responses and produce final 500-word vocabulary list.
Steps:
1. Load all batch responses (both sets)
2. Extract top 30 non-formal words per batch
3. Add function words
4. Merge with existing filtered words
5. Re-rank by corpus frequency
6. Truncate to 500
"""

import json
import os
import re

# Load validated words for frequency data
with open('validated_words_extended.json', 'r', encoding='utf-8') as f:
    extended_data = json.load(f)
word_freq = {w['word']: {'frequency_rank': w['frequency_rank'], 'frequency_count': w['frequency_count']} for w in extended_data['words']}
print(f"Loaded frequency data for {len(word_freq)} words")

# Also load original validated words
with open('validated_words.json', 'r', encoding='utf-8') as f:
    original_data = json.load(f)
original_word_freq = {w['word']: {'frequency_rank': w['frequency_rank'], 'frequency_count': w['frequency_count']} for w in original_data['words']}
word_freq.update(original_word_freq)
print(f"Total words with frequency data: {len(word_freq)}")

def load_batch_response(filepath):
    """Load and parse a batch response JSON file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return data
    except json.JSONDecodeError as e:
        print(f"  Warning: Could not parse {filepath}: {e}")
        return []

def load_function_word_response(filepath):
    """Load function word extraction response."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return data
    except (json.JSONDecodeError, FileNotFoundError) as e:
        print(f"  Warning: Could not load {filepath}: {e}")
        return []

# Collect all words with their data
all_words = {}
word_sources = {}  # Track where each word came from

# Load existing llm_filtered.json (original 266 words)
existing_filtered_path = 'llm_prompts/llm_filtered.json'
if os.path.exists(existing_filtered_path):
    with open(existing_filtered_path, 'r', encoding='utf-8') as f:
        existing = json.load(f)
    print(f"\nLoaded existing filtered list: {existing.get('total_count', 0)} words")
    for w in existing.get('content_words', []):
        all_words[w['word']] = w
        word_sources[w['word']] = 'existing_content'
    for w in existing.get('function_words', []):
        # Function words have different format
        all_words[w['word']] = {
            'word': w['word'],
            'rank': 0,
            'category': 'function',
            'brief_reason': w.get('why_essential', ''),
            'type': w.get('type', 'function'),
            'in_filtered': True
        }
        word_sources[w['word']] = 'existing_function'

print(f"Words from existing filtered: {len(all_words)}")

# Process Batch 1 responses (13 batches)
print("\nProcessing Batch 1 responses (13 batches)...")
batch1_dir = 'llm_prompts'
batch1_count = 0
for i in range(1, 14):
    filepath = f'{batch1_dir}/batch_{i:02d}_of_13.txt.json'
    if os.path.exists(filepath):
        data = load_batch_response(filepath)
        # Handle both list and dict formats
        if isinstance(data, dict):
            words = data if isinstance(data, list) else data.get('words', data.get('results', []))
        else:
            words = data
        # Keep top 30, non-formal
        kept = 0
        for w in words:
            if isinstance(w, dict) and w.get('category') != 'formal':
                if w['word'] not in all_words:
                    freq_data = word_freq.get(w['word'], {'frequency_rank': 9999, 'frequency_count': 0})
                    all_words[w['word']] = {
                        'word': w['word'],
                        'rank': w.get('rank', 0),
                        'category': w.get('category', 'content'),
                        'brief_reason': w.get('brief_reason', ''),
                        'frequency_rank': freq_data['frequency_rank'],
                        'frequency_count': freq_data['frequency_count'],
                        'in_filtered': True
                    }
                    word_sources[w['word']] = f'batch1_{i}'
                    kept += 1
        batch1_count += kept

print(f"  Batch 1: Added {batch1_count} words (total: {len(all_words)})")

# Process Batch 2 responses (34 batches)
print("\nProcessing Batch 2 responses (34 batches)...")
batch2_dir = 'llm_prompts_batch2'
batch2_count = 0
for i in range(1, 35):
    filepath = f'{batch2_dir}/batch_{i:02d}_of_34.txt.json'
    if os.path.exists(filepath):
        data = load_batch_response(filepath)
        # Handle both list and dict formats
        if isinstance(data, dict):
            words = data if isinstance(data, list) else data.get('words', data.get('results', []))
        else:
            words = data
        # Keep top 30, non-formal
        kept = 0
        for w in words:
            if isinstance(w, dict) and w.get('category') != 'formal':
                if w['word'] not in all_words:
                    freq_data = word_freq.get(w['word'], {'frequency_rank': 9999, 'frequency_count': 0})
                    all_words[w['word']] = {
                        'word': w['word'],
                        'rank': w.get('rank', 0),
                        'category': w.get('category', 'content'),
                        'brief_reason': w.get('brief_reason', ''),
                        'frequency_rank': freq_data['frequency_rank'],
                        'frequency_count': freq_data['frequency_count'],
                        'in_filtered': True
                    }
                    word_sources[w['word']] = f'batch2_{i}'
                    kept += 1
        batch2_count += kept

print(f"  Batch 2: Added {batch2_count} words (total: {len(all_words)})")

# Process function word responses
print("\nProcessing function word responses...")
function_word_count = 0
for fw_path in ['llm_prompts/function_word_extraction.txt.json', 'llm_prompts_batch2/function_word_extraction.txt.json']:
    if os.path.exists(fw_path):
        fw_data = load_function_word_response(fw_path)
        if isinstance(fw_data, dict):
            fw_words = fw_data if isinstance(fw_data, list) else fw_data.get('function_words', fw_data.get('words', []))
        else:
            fw_words = fw_data
        for fw in fw_words:
            if isinstance(fw, dict) and fw['word'] not in all_words:
                freq_data = word_freq.get(fw['word'], {'frequency_rank': 9999, 'frequency_count': 0})
                all_words[fw['word']] = {
                    'word': fw['word'],
                    'rank': 0,
                    'category': 'function',
                    'brief_reason': fw.get('why_essential', ''),
                    'type': fw.get('type', 'function'),
                    'frequency_rank': freq_data['frequency_rank'],
                    'frequency_count': freq_data['frequency_count'],
                    'in_filtered': True
                }
                word_sources[fw['word']] = 'function_word'
                function_word_count += 1

print(f"  Function words added: {function_word_count}")

# Convert to list and sort by frequency
print(f"\nTotal words collected: {len(all_words)}")

word_list = list(all_words.values())

# Sort by frequency_rank (ascending = most frequent first)
word_list.sort(key=lambda x: x.get('frequency_rank', 99999))

# Separate content and function words
content_words = [w for w in word_list if w.get('category') != 'function']
function_words = [w for w in word_list if w.get('category') == 'function']

print(f"Content words: {len(content_words)}")
print(f"Function words: {len(function_words)}")

# Re-rank content words by frequency (1 = most frequent)
for i, w in enumerate(content_words):
    w['final_rank'] = i + 1

# Re-rank function words by frequency
for i, w in enumerate(function_words):
    w['final_rank'] = len(content_words) + i + 1

# Combine
final_list = content_words + function_words

# Truncate to 500
if len(final_list) > 500:
    final_list = final_list[:500]
    print(f"\nTruncated to 500 words")

# Save final result
output = {
    "metadata": {
        "total_words": len(final_list),
        "content_words": len([w for w in final_list if w.get('category') != 'function']),
        "function_words": len([w for w in final_list if w.get('category') == 'function']),
        "source_batches_processed": "13 (batch1) + 34 (batch2)",
        "pipeline_stage": "Step 4: Re-rank by corpus frequency"
    },
    "words": final_list
}

with open('final_500.json', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print(f"\nFinal vocabulary list saved to final_500.json")
print(f"Total words: {len(final_list)}")

# Show top 30 words
print("\n" + "="*60)
print("TOP 30 WORDS (by corpus frequency):")
print("="*60)
for w in final_list[:30]:
    print(f"  {w['final_rank']:3d}. {w['word']} (freq: {w['frequency_rank']}, {w['category']}) - {w.get('brief_reason', '')[:40]}")
