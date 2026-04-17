# Batch 2: Additional LLM Prompts for 500-Word Target

## Summary

You processed the initial 13 batches and got **271 words**. To reach **500 words**, we've generated **34 new batch prompts** from the extended word list.

## Files to Process

### New Batch Prompts (34 files)
Location: `prompts/data/llm_prompts_batch2/`

| Files | Words | Range |
|-------|-------|-------|
| batch_01_of_34.txt - batch_34_of_34.txt | 1674 words | Rank 1000-3000 |

### Function Word Prompts (2 files)
- `llm_prompts/function_word_extraction.txt` (already have)
- `llm_prompts_batch2/function_word_extraction.txt` (new, for ranks 1000-3000)

## Math for 500-Word Target

| Source | Words | Expected Survivors (30%) |
|--------|-------|--------------------------|
| Batch 1 (already processed) | 632 | ~190 (already have 271) |
| Batch 2 (new) | 1674 | ~500 |
| Function words | ~100 | ~50 |
| **Total** | **2306** | **~740** |

Even at a conservative 20% survival rate, Batch 2 should yield ~335 additional words, bringing your total to ~600+.

## Processing Instructions

1. Process all 34 new batch prompts (batch_01_of_34.txt through batch_34_of_34.txt)
2. Process the new function_word_extraction.txt for Batch 2
3. After all LLM responses collected, run POST PROCESS to:
   - Keep top 30 per batch
   - Remove formal words
   - Add function words
   - Combine with original 271 words
   - Re-rank by corpus frequency
   - Truncate to 500

## Combined Manifest

See `combined_llm_manifest.json` for complete list of all 47 batches.
