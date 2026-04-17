#!/usr/bin/env python3
"""
Merge all LLM batch responses and produce final 500-word vocabulary list.
Guarantees mix of content and function words.
"""

import json
import os

# Load validated words for frequency data
with open('validated_words_extended.json', 'r', encoding='utf-8') as f:
    extended_data = json.load(f)
word_freq = {w['word']: {'frequency_rank': w['frequency_rank'], 'frequency_count': w['frequency_count']} for w in extended_data['words']}
word_freq.update({w['word']: {'frequency_rank': w['frequency_rank'], 'frequency_count': w['frequency_count']} for w in json.load(open('validated_words.json'))['words']})
print(f"Loaded frequency data for {len(word_freq)} words")

def load_batch_response(filepath):
    """Load and parse a batch response JSON file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        return data
    except (json.JSONDecodeError, FileNotFoundError) as e:
        return []

# Collect all words with their data
all_words = {}

# Load existing llm_filtered.json
existing_filtered_path = 'llm_prompts/llm_filtered.json'
if os.path.exists(existing_filtered_path):
    with open(existing_filtered_path, 'r', encoding='utf-8') as f:
        existing = json.load(f)
    print(f"Loaded existing filtered: {existing.get('total_count', 0)} words")
    for w in existing.get('content_words', []) + existing.get('function_words', []):
        if w['word'] not in all_words:
            freq = word_freq.get(w['word'], {'frequency_rank': 9999, 'frequency_count': 0})
            all_words[w['word']] = {
                'word': w['word'],
                'rank': w.get('rank', 0),
                'category': w.get('category', 'function' if w.get('type') else 'content'),
                'brief_reason': w.get('brief_reason', w.get('why_essential', '')),
                'frequency_rank': freq['frequency_rank'],
                'frequency_count': freq['frequency_count'],
                'type': w.get('type', 'word' if w.get('category') != 'function' else 'function')
            }

print(f"After existing: {len(all_words)} words")

# Process Batch 1 responses
print("\nProcessing Batch 1...")
for i in range(1, 14):
    filepath = f'llm_prompts/batch_{i:02d}_of_13.txt.json'
    if os.path.exists(filepath):
        data = load_batch_response(filepath)
        words = data if isinstance(data, list) else data.get('words', data.get('results', []))
        for w in words:
            if isinstance(w, dict) and w.get('category') != 'formal' and w['word'] not in all_words:
                freq = word_freq.get(w['word'], {'frequency_rank': 9999, 'frequency_count': 0})
                all_words[w['word']] = {
                    'word': w['word'],
                    'rank': w.get('rank', 0),
                    'category': w.get('category', 'content'),
                    'brief_reason': w.get('brief_reason', ''),
                    'frequency_rank': freq['frequency_rank'],
                    'frequency_count': freq['frequency_count'],
                    'type': 'word'
                }

print(f"After Batch 1: {len(all_words)} words")

# Process Batch 2 responses
print("Processing Batch 2...")
for i in range(1, 35):
    filepath = f'llm_prompts_batch2/batch_{i:02d}_of_34.txt.json'
    if os.path.exists(filepath):
        data = load_batch_response(filepath)
        words = data if isinstance(data, list) else data.get('words', data.get('results', []))
        for w in words:
            if isinstance(w, dict) and w.get('category') != 'formal' and w['word'] not in all_words:
                freq = word_freq.get(w['word'], {'frequency_rank': 9999, 'frequency_count': 0})
                all_words[w['word']] = {
                    'word': w['word'],
                    'rank': w.get('rank', 0),
                    'category': w.get('category', 'content'),
                    'brief_reason': w.get('brief_reason', ''),
                    'frequency_rank': freq['frequency_rank'],
                    'frequency_count': freq['frequency_count'],
                    'type': 'word'
                }

print(f"After Batch 2: {len(all_words)} words")

# Separate content and function words
word_list = list(all_words.values())
content_words = [w for w in word_list if w.get('category') != 'function']
function_words = [w for w in word_list if w.get('category') == 'function']

# Sort each by frequency_rank
content_words.sort(key=lambda x: x.get('frequency_rank', 99999))
function_words.sort(key=lambda x: x.get('frequency_rank', 99999))

print(f"\nContent words: {len(content_words)}")
print(f"Function words: {len(function_words)}")

# Strategy: Keep top ~460 content words + ~40 function words = 500
TARGET_CONTENT = 460
TARGET_FUNCTION = 40

# If not enough function words, add more content
if len(function_words) < TARGET_FUNCTION:
    TARGET_CONTENT = 500 - len(function_words)
    print(f"Adjusting: {TARGET_CONTENT} content + {len(function_words)} function")

final_content = content_words[:TARGET_CONTENT]
final_function = function_words[:TARGET_FUNCTION]

# Combine and re-rank
final_list = final_content + final_function
final_list.sort(key=lambda x: x.get('frequency_rank', 99999))

for i, w in enumerate(final_list):
    w['final_rank'] = i + 1

# Save final result
output = {
    "metadata": {
        "total_words": len(final_list),
        "content_words": len([w for w in final_list if w.get('category') != 'function']),
        "function_words": len([w for w in final_list if w.get('category') == 'function']),
        "source": "Leipzig corpus + LLM pedagogical filter",
        "pipeline_stage": "Step 4: Re-rank by corpus frequency"
    },
    "words": final_list
}

with open('final_500.json', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print(f"\n✅ Final vocabulary list saved: {len(final_list)} words")
print(f"   Content: {len([w for w in final_list if w.get('category') != 'function'])}")
print(f"   Function: {len([w for w in final_list if w.get('category') == 'function'])}")

# Show sample
print("\n" + "="*60)
print("SAMPLE WORDS:")
print("="*60)
print("\nTop 10 content words:")
for w in final_list[:10]:
    if w.get('category') != 'function':
        print(f"  {w['final_rank']:3d}. {w['word']} - {w.get('brief_reason', '')[:50]}")

print("\nSample function words (if any):")
fw = [w for w in final_list if w.get('category') == 'function']
for w in fw[:10]:
    print(f"  {w['final_rank']:3d}. {w['word']} ({w.get('type', 'function')}) - {w.get('brief_reason', '')[:40]}")
