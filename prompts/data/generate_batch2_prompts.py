#!/usr/bin/env python3
"""
Generate additional LLM batch prompts for extended word list.
Skip words already processed in the first round.
"""

import json
import os

# Load original validated words (already processed)
with open('validated_words.json', 'r', encoding='utf-8') as f:
    original_data = json.load(f)
original_words = {w['word'] for w in original_data['words']}
print(f"Original processed words: {len(original_words)}")

# Load extended validated words
with open('validated_words_extended.json', 'r', encoding='utf-8') as f:
    extended_data = json.load(f)
extended_words = extended_data['words']
print(f"Extended validated words: {len(extended_words)}")

# Find words not yet processed
unprocessed = [w for w in extended_words if w['word'] not in original_words]
print(f"New words to process: {len(unprocessed)}")

# Create directory for new prompts
os.makedirs('llm_prompts_batch2', exist_ok=True)

# Base prompt template
BASE_PROMPT = """You are a Lao language teacher preparing vocabulary for a beginner-to-intermediate learner focused on **informal spoken conversation**. Below are 50 Lao words drawn from a written-text corpus.

Some of these words are genuinely common in daily spoken Lao. Others are frequent in the corpus because they appear heavily in formal writing, news, or Pali/Sanskrit loanwords that nobody uses in conversation.

**Rank these 50 words from 1 (most useful for a conversational learner) to 50 (least useful).** Do not omit any words — rank all 50.

For each word, also assign a category:
- `content` (nouns, verbs, adjectives, adverbs)
- `function` (particles, classifiers, pronouns, conjunctions)
- `formal` (Pali/Sanskrit loanwords, bureaucratic vocabulary rarely used in speech)

Write output as JSON in this format:
```json
[
  {{"word": "...", "rank": 1, "category": "content", "brief_reason": "..."}},
  ...
]
```

Words to rank:
"""

# Batch size
BATCH_SIZE = 50
num_batches = (len(unprocessed) + BATCH_SIZE - 1) // BATCH_SIZE
print(f"\nWill create {num_batches} batches of {BATCH_SIZE} words each")

# Process in batches
for batch_num in range(num_batches):
    start_idx = batch_num * BATCH_SIZE
    end_idx = min(start_idx + BATCH_SIZE, len(unprocessed))
    batch_words = unprocessed[start_idx:end_idx]
    
    # Build word list for this batch
    word_list_text = ""
    for i, w in enumerate(batch_words):
        dict_flag = "✓" if w['in_dictionary'] else "⚠"
        word_list_text += f"{i+1}. {w['word']} (frequency rank: {w['frequency_rank']}, count: {w['frequency_count']}) [{dict_flag}]\n"
    
    # Create full prompt
    full_prompt = BASE_PROMPT + word_list_text
    
    # Save prompt to file
    prompt_filename = f"llm_prompts_batch2/batch_{batch_num+1:02d}_of_{num_batches}.txt"
    with open(prompt_filename, 'w', encoding='utf-8') as f:
        f.write(full_prompt)

print(f"\nBatch prompts saved to llm_prompts_batch2/")

# Also create a function word prompt for the new words
FUNCTION_WORD_PROMPT = """From the following Lao words, identify particles, classifiers, pronouns, question words, and conjunctions that a beginner learner MUST know to form basic sentences.

Return up to 50 such words as JSON:
```json
[
  {{"word": "...", "type": "particle|classifier|pronoun|question_word|conjunction", "why_essential": "..."}},
  ...
]
```

Focus on grammatical function words indispensable for basic communication.

Full list of validated Lao words:
"""

word_list_text = ""
for w in unprocessed:
    dict_flag = "✓" if w['in_dictionary'] else "⚠"
    word_list_text += f"- {w['word']} (rank: {w['frequency_rank']}, count: {w['frequency_count']}) [{dict_flag}]\n"

full_prompt = FUNCTION_WORD_PROMPT + word_list_text

with open('llm_prompts_batch2/function_word_extraction.txt', 'w', encoding='utf-8') as f:
    f.write(full_prompt)

print(f"Function word prompt saved to llm_prompts_batch2/function_word_extraction.txt")

# Create manifest
manifest = {
    "total_batches": num_batches,
    "batch_size": BATCH_SIZE,
    "total_words_to_process": len(unprocessed),
    "batches": []
}

for batch_num in range(num_batches):
    start = batch_num * BATCH_SIZE
    end = min((batch_num + 1) * BATCH_SIZE, len(unprocessed))
    manifest["batches"].append({
        "batch_number": batch_num + 1,
        "filename": f"batch_{batch_num+1:02d}_of_{num_batches}.txt",
        "word_count": end - start,
        "start_index": start + 1,
        "end_index": end
    })

with open('llm_prompts_batch2/manifest.json', 'w', encoding='utf-8') as f:
    json.dump(manifest, f, indent=2)

print(f"\nManifest saved to llm_prompts_batch2/manifest.json")

# Summary
print("\n" + "="*60)
print("BATCH 2 SUMMARY:")
print("="*60)
print(f"  Original words processed: {len(original_words)}")
print(f"  New words to process: {len(unprocessed)}")
print(f"  New batch prompts: {num_batches}")
print(f"  Total words available for LLM filtering: {len(original_words) + len(unprocessed)}")
print(f"\nExpected survivors after filtering:")
print(f"  If ~50% survive: ~{int((len(original_words) + len(unprocessed)) * 0.5)} words")
print(f"  If 40% survive: ~{int((len(original_words) + len(unprocessed)) * 0.4)} words")
print(f"  If 30% survive: ~{int((len(original_words) + len(unprocessed)) * 0.3)} words")
