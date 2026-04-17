#!/usr/bin/env python3
"""
Step 2: Clean and validate Lao words against LaoNLP dictionary
"""

import json
import re
from laonlp.corpus import lao_words

# Load LaoNLP dictionary
lao_dict = set(lao_words())
print(f"LaoNLP dictionary loaded: {len(lao_dict)} words")

# Load raw Leipzig words
raw_words = []
with open('raw_leipzig_top1000.txt', 'r', encoding='utf-8') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        parts = line.split('\t')
        if len(parts) == 2:
            word = parts[0]
            count = int(parts[1])
            raw_words.append((word, count))

print(f"Loaded {len(raw_words)} raw words from Leipzig corpus")

# Define Lao Unicode range
LAO_RANGE = re.compile(r'^[\u0E80-\u0EFF]+$')
# Need at least 2 Lao characters
MIN_LENGTH = 2

def is_valid_lao_word(word):
    """Check if word is valid Lao (not numeric, punctuation, etc.)"""
    # Must contain at least one Lao character
    if not LAO_RANGE.match(word):
        return False
    # Must be at least 2 characters
    if len(word) < MIN_LENGTH:
        return False
    return True

# Filter and validate
validated = []
not_in_dict = []

for i, (word, count) in enumerate(raw_words):
    if not is_valid_lao_word(word):
        continue  # Skip invalid entries
    
    # Check if in dictionary
    in_dict = word in lao_dict
    
    # Track frequency rank (1-indexed)
    frequency_rank = i + 1
    
    entry = {
        "word": word,
        "frequency_rank": frequency_rank,
        "frequency_count": count,
        "in_dictionary": in_dict
    }
    
    validated.append(entry)
    
    if not in_dict:
        not_in_dict.append(entry)

print(f"\nAfter filtering: {len(validated)} words")
print(f"Words NOT in dictionary: {len(not_in_dict)}")

# Keep top 200 not-in-dict words for manual review (as per spec)
# But in the final output, only keep in-dict or top 200 not-in-dict
top_not_in_dict = sorted(not_in_dict, key=lambda x: x["frequency_rank"])[:200]
valid_words = [w for w in validated if w["in_dictionary"]] + top_not_in_dict

# Re-sort by frequency rank
valid_words.sort(key=lambda x: x["frequency_rank"])

print(f"\nFinal validated words: {len(valid_words)}")
print(f"  - In dictionary: {sum(1 for w in valid_words if w['in_dictionary'])}")
print(f"  - Not in dict (top 200): {sum(1 for w in valid_words if not w['in_dictionary'])}")

# Output JSON
output = {
    "metadata": {
        "source": "Leipzig Corpora Collection - Lao 2021",
        "total_raw_words": len(raw_words),
        "after_filtering": len(validated),
        "final_validated": len(valid_words),
        "step": "Step 2: Clean and validate"
    },
    "words": valid_words,
    "not_in_dictionary_top200": top_not_in_dict  # For manual review
}

with open('validated_words.json', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print(f"\nOutput saved to validated_words.json")

# Show first 20 entries
print("\nFirst 20 validated words:")
for w in valid_words[:20]:
    dict_flag = "✓" if w["in_dictionary"] else "✗"
    print(f"  {w['frequency_rank']:4d}. {w['word']} (count: {w['frequency_count']:5d}) [{dict_flag}]")
