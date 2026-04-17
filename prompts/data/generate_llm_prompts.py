#!/usr/bin/env python3
"""
Step 3: Generate LLM batch prompts for pedagogical filtering
Process validated words in batches of 50
"""

import json
import os

# Load validated words
with open('validated_words.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

words = data['words']
print(f"Total validated words: {len(words)}")

# Create output directory for prompts
os.makedirs('llm_prompts', exist_ok=True)

# Batch size
BATCH_SIZE = 50
num_batches = (len(words) + BATCH_SIZE - 1) // BATCH_SIZE
print(f"Will create {num_batches} batches of {BATCH_SIZE} words each")

# Base prompt template from word_list.md
BASE_PROMPT = """You are a Lao language teacher preparing vocabulary for a beginner-to-intermediate learner focused on **informal spoken conversation**. Below are 50 Lao words drawn from a written-text corpus.

Some of these words are genuinely common in daily spoken Lao. Others are frequent in the corpus because they appear heavily in formal writing, news, or Pali/Sanskrit loanwords that nobody uses in conversation.

**Rank these 50 words from 1 (most useful for a conversational learner) to 50 (least useful).** Do not omit any words — rank all 50.

For each word, also assign a category:
- `content` (nouns, verbs, adjectives, adverbs)
- `function` (particles, classifiers, pronouns, conjunctions)
- `formal` (Pali/Sanskrit loanwords, bureaucratic vocabulary rarely used in speech)

Write output as JSON with the same filename with .json appended in this format:
```json
[
  {{"word": "...", "rank": 1, "category": "content", "brief_reason": "..."}},
  ...
]
```

Words to rank:
"""

# Process in batches
for batch_num in range(num_batches):
    start_idx = batch_num * BATCH_SIZE
    end_idx = min(start_idx + BATCH_SIZE, len(words))
    batch_words = words[start_idx:end_idx]
    
    # Build word list for this batch
    word_list_text = ""
    for i, w in enumerate(batch_words):
        dict_flag = "✓" if w['in_dictionary'] else "⚠"  # ⚠ = needs review
        word_list_text += f"{i+1}. {w['word']} (frequency rank: {w['frequency_rank']}, count: {w['frequency_count']}) [{dict_flag}]\n"
    
    # Create full prompt
    full_prompt = BASE_PROMPT + word_list_text
    
    # Save prompt to file
    prompt_filename = f"llm_prompts/batch_{batch_num+1:02d}_of_{num_batches}.txt"
    with open(prompt_filename, 'w', encoding='utf-8') as f:
        f.write(full_prompt)
    
    print(f"  Created: {prompt_filename} ({len(batch_words)} words)")

# Create a manifest of all batch files
manifest = {
    "total_batches": num_batches,
    "batch_size": BATCH_SIZE,
    "total_words": len(words),
    "batches": []
}

for batch_num in range(num_batches):
    manifest["batches"].append({
        "batch_number": batch_num + 1,
        "filename": f"batch_{batch_num+1:02d}_of_{num_batches}.txt",
        "word_count": BATCH_SIZE if batch_num < num_batches - 1 else len(words) % BATCH_SIZE or BATCH_SIZE,
        "start_index": batch_num * BATCH_SIZE + 1,
        "end_index": min((batch_num + 1) * BATCH_SIZE, len(words))
    })

with open('llm_prompts/manifest.json', 'w', encoding='utf-8') as f:
    json.dump(manifest, f, indent=2)

print(f"\nManifest saved to llm_prompts/manifest.json")
print(f"All prompts saved to llm_prompts/ directory")
