#!/usr/bin/env python3
"""
Step 3 POST PROCESS: Generate function-word extraction prompt
Run a parallel pass for function words (particles, classifiers, pronouns, etc.)
"""

import json
import os

# Load validated words
with open('validated_words.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

words = data['words']
print(f"Total validated words: {len(words)}")

# Function word prompt template from word_list.md
FUNCTION_WORD_PROMPT = """From the following Lao words, identify particles, classifiers, pronouns, question words, and conjunctions that a beginner learner MUST know to form basic sentences.

Return up to 50 such words as JSON:
```json
[
  {{"word": "...", "type": "particle|classifier|pronoun|question_word|conjunction", "why_essential": "..."}},
  ...
]
```

If a word is essential, include it. If not, you may omit it. Focus on grammatical function words that are indispensable for basic communication.

Full list of validated Lao words:
"""

# Create directory if needed
os.makedirs('llm_prompts', exist_ok=True)

# Build word list for the full validated set
word_list_text = ""
for w in words:
    dict_flag = "✓" if w['in_dictionary'] else "⚠"
    word_list_text += f"- {w['word']} (rank: {w['frequency_rank']}, count: {w['frequency_count']}) [{dict_flag}]\n"

# Create full prompt
full_prompt = FUNCTION_WORD_PROMPT + word_list_text

# Save function word prompt
function_word_filename = "llm_prompts/function_word_extraction.txt"
with open(function_word_filename, 'w', encoding='utf-8') as f:
    f.write(full_prompt)

print(f"Function word prompt saved to {function_word_filename}")
print(f"Contains {len(words)} words for analysis")

# Also create a post-processing instructions file
POST_PROCESS_INSTRUCTIONS = """# Step 3 POST PROCESS: Instructions

## Overview
After receiving LLM responses from all 13 batch prompts (batch_01_of_13.txt through batch_13_of_13.txt), follow these steps:

## Step 3.1: Extract Top 30 from Each Batch
For each batch response:
1. Keep the top 30 ranked words (rank 1-30)
2. Discard words marked as `formal` category regardless of rank
3. Combine all survivors from all batches

Expected: ~420-480 survivors across all batches

## Step 3.2: Function Word Parallel Pass
Run the function word extraction prompt (function_word_extraction.txt) on the full validated list.

The LLM will identify essential particles, classifiers, pronouns, question words, and conjunctions that:
- May rank low on "usefulness" in conversation
- Are grammatically indispensable for forming basic sentences
- Include words like: ແມ່ນ (negation), ບໍ່ (not), ໄหํ (question), ໃน (classifier), etc.

Expected: Up to 50 function words

## Step 3.3: Merge Results
Combine the two lists:
- Content words: top 30 from each batch, no formal words
- Function words: up to 50 essential function words

This is a UNION (not intersection) - add function words even if they weren't in the top 30.

## Output
Save combined list as `llm_filtered.json` with format:
```json
{
  "content_words": [...],
  "function_words": [...],
  "total_count": ...
}
```

Each entry should have:
- word
- rank (from original batch ranking)
- category
- brief_reason
- frequency_rank (from Leipzig corpus)
- frequency_count (from Leipzig corpus)
"""

with open('llm_prompts/POST_PROCESS_INSTRUCTIONS.md', 'w', encoding='utf-8') as f:
    f.write(POST_PROCESS_INSTRUCTIONS)

print(f"\nPost-processing instructions saved to llm_prompts/POST_PROCESS_INSTRUCTIONS.md")

# Create a summary file
summary = {
    "pipeline_stage": "Step 3: POST PROCESS",
    "total_llm_prompts": 14,  # 13 batch + 1 function word
    "prompts": {
        "batch_prompts": {
            "count": 13,
            "pattern": "batch_XX_of_13.txt",
            "purpose": "Rank words 1-50 by conversational usefulness, assign category"
        },
        "function_word_prompt": {
            "filename": "function_word_extraction.txt",
            "purpose": "Identify essential function words (particles, classifiers, pronouns)"
        }
    },
    "post_processing": {
        "keep_top_n_per_batch": 30,
        "discard_formal": True,
        "max_function_words": 50
    },
    "expected_output": {
        "survivors_from_batches": "~420-480 words",
        "function_words": "up to 50 words",
        "total_after_merge": "~470-530 words"
    }
}

with open('llm_prompts/summary.json', 'w', encoding='utf-8') as f:
    json.dump(summary, f, indent=2)

print(f"Summary saved to llm_prompts/summary.json")

# List all generated files
print("\n" + "="*60)
print("FILES GENERATED:")
print("="*60)
for f in sorted(os.listdir('llm_prompts')):
    size = os.path.getsize(f'llm_prompts/{f}')
    print(f"  {f} ({size} bytes)")
