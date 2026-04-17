#!/usr/bin/env python3
"""
Create combined manifest for all LLM prompts (batch 1 + batch 2)
"""

import json
import os

# Load both manifests
with open('llm_prompts/manifest.json', 'r') as f:
    batch1 = json.load(f)
with open('llm_prompts_batch2/manifest.json', 'r') as f:
    batch2 = json.load(f)

# Create combined manifest
combined = {
    "pipeline_stage": "Step 3: LLM Pedagogical Filter",
    "total_batches": batch1['total_batches'] + batch2['total_batches'],
    "total_words_to_process": batch1['total_words'] + batch2['total_words_to_process'],
    "already_processed": {
        "batches": batch1['total_batches'],
        "words": batch1['total_words']
    },
    "new_batches": {
        "batches": batch2['total_batches'],
        "words": batch2['total_words_to_process']
    },
    "batches": [],
    "function_word_prompts": [
        "llm_prompts/function_word_extraction.txt",
        "llm_prompts_batch2/function_word_extraction.txt"
    ]
}

# Add batch 1 entries
for b in batch1['batches']:
    combined['batches'].append({
        **b,
        'filepath': f"llm_prompts/{b['filename']}",
        'status': 'already_processed'
    })

# Add batch 2 entries
for b in batch2['batches']:
    combined['batches'].append({
        **b,
        'filepath': f"llm_prompts_batch2/{b['filename']}",
        'status': 'pending'
    })

with open('combined_llm_manifest.json', 'w') as f:
    json.dump(combined, f, indent=2)

print("Combined manifest created: combined_llm_manifest.json")
print(f"\nTotal LLM prompts to process: {combined['total_batches']} batches")
print(f"  - Already processed: {batch1['total_batches']} batches ({batch1['total_words']} words)")
print(f"  - Pending: {batch2['total_batches']} batches ({batch2['total_words_to_process']} words)")
