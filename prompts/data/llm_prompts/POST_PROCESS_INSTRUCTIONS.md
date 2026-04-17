# Step 3 POST PROCESS: Instructions

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
