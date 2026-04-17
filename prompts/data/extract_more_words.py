#!/usr/bin/env python3
"""
Extract more words from Leipzig corpus for additional LLM processing.
We need ~1500+ validated words to hopefully get 500+ after LLM filtering.
"""

import json
import re
from laonlp.corpus import lao_words

# Load LaoNLP dictionary
lao_dict = set(lao_words())
print(f"LaoNLP dictionary loaded: {len(lao_dict)} words")

# Load corpus words file
corpus_file = 'lao_community_2021/lao_community_2021-words.txt'
raw_words = []
with open(corpus_file, 'r', encoding='utf-8') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        parts = line.split('\t')
        if len(parts) >= 3:
            rank = int(parts[0])
            word = parts[1]
            count = int(parts[2])
            raw_words.append((rank, word, count))

print(f"Total words in corpus: {len(raw_words)}")

# Define Lao Unicode range
LAO_RANGE = re.compile(r'^[\u0E80-\u0EFF]+$')
MIN_LENGTH = 2

def is_valid_lao_word(word):
    """Check if word is valid Lao (not numeric, punctuation, etc.)"""
    if not LAO_RANGE.match(word):
        return False
    if len(word) < MIN_LENGTH:
        return False
    return True

# Filter and validate - take top 3000
TARGET_COUNT = 3000
validated = []

for rank, word, count in raw_words:
    if not is_valid_lao_word(word):
        continue
    
    in_dict = word in lao_dict
    entry = {
        "word": word,
        "frequency_rank": rank,
        "frequency_count": count,
        "in_dictionary": in_dict
    }
    validated.append(entry)
    
    if len(validated) >= TARGET_COUNT:
        break

print(f"\nExtracted {len(validated)} validated words")

# Keep top 200 not-in-dict words for manual review (as per spec)
not_in_dict = [w for w in validated if not w['in_dictionary']]
in_dict = [w for w in validated if w['in_dictionary']]
top_not_in_dict = sorted(not_in_dict, key=lambda x: x["frequency_rank"])[:200]

valid_words = in_dict + top_not_in_dict
valid_words.sort(key=lambda x: x["frequency_rank"])

print(f"Final: {len(valid_words)} words ({len(in_dict)} in dict, {len(top_not_in_dict)} not in dict flagged)")

# Save extended validated set
output = {
    "metadata": {
        "source": "Leipzig Corpora Collection - Lao 2021",
        "corpus_total": len(raw_words),
        "total_extracted": TARGET_COUNT,
        "final_validated": len(valid_words),
        "step": "Step 2 (extended): Clean and validate"
    },
    "words": valid_words
}

with open('validated_words_extended.json', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print(f"\nExtended validated words saved to validated_words_extended.json")

# Show some stats
print("\nWord count ranges:")
print(f"  Rank 1-1000: {sum(1 for w in valid_words if w['frequency_rank'] <= 1000)} words")
print(f"  Rank 1001-2000: {sum(1 for w in valid_words if 1000 < w['frequency_rank'] <= 2000)} words")
print(f"  Rank 2001-3000: {sum(1 for w in valid_words if 2000 < w['frequency_rank'] <= 3000)} words")
