#!/usr/bin/env python3
"""
Step 5: Generate definitions, examples, and image prompts (Multi-locale)
Create 100 prompts with 5 words each for the LLM.
Each word gets definitions, translations, and image prompts.
"""

import json
import os

# Load the final 500 words
with open('final_500.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

words = data['words']
print(f"Loaded {len(words)} words")

# Create output directory
os.makedirs('step5_definition_prompts', exist_ok=True)

# Batch size
BATCH_SIZE = 5
NUM_PROMPTS = (len(words) + BATCH_SIZE - 1) // BATCH_SIZE
print(f"Creating {NUM_PROMPTS} prompts with {BATCH_SIZE} words each")

# All supported locales
SUPPORTED_LOCALES = {
    'de': 'German',
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'hi': 'Hindi',
    'ja': 'Japanese',
    'km': 'Khmer',
    'ko': 'Korean',
    'ne': 'Nepali',
    'pt': 'Portuguese',
    'th': 'Thai',
    'tl': 'Tagalog',
    'ur': 'Urdu',
    'vi': 'Vietnamese',
    'zh': 'Chinese (Simplified)',
    'zh_Hant': 'Chinese (Traditional)',
}

# Locale codes for JSON keys
LOCALE_CODES = list(SUPPORTED_LOCALES.keys())

# Generate locale definitions structure
def get_locale_definitions_template():
    return '\n'.join([f'    "{lc}": "...",' for lc in LOCALE_CODES])

def get_locale_translations_template():
    return '\n'.join([f'      "{lc}": "...",' for lc in LOCALE_CODES])

# Prompt template with multi-locale support and image prompts
DEFINITION_PROMPT = """You are a Lao language expert preparing vocabulary for a language learning app. For each of the 5 Lao words below, provide detailed information in ALL 16 supported locales, plus an image generation prompt.

## Supported Locales:
{locale_list}

## For each word, provide:

### 1. DEFINITIONS (in ALL 16 locales)
```json
"definitions": {{
{locale_defs}
}}
```

### 2. PART OF SPEECH
```json
"part_of_speech": "noun|verb|adjective|particle|classifier|pronoun|conjunction|adverb"
```

### 3. ROMANIZATION (IPA)
```json
"romanization": "..."
```

### 4. TWO EXAMPLE SENTENCES in informal spoken Lao
Each example includes Lao script, romanization, AND translations in ALL 16 locales:
```json
"examples": [
  {{
    "lao_script": "...",
    "romanization": "...",
    "translations": {{
{locale_translations}
    }},
    "out_of_scope_words": ["..."]
  }},
  {{
    "lao_script": "...",
    "romanization": "...",
    "translations": {{
{locale_translations}
    }},
    "out_of_scope_words": ["..."]
  }}
]
```

### 5. IMAGE PROMPT
Write a prompt for an AI image generator (like DALL-E, Midjourney, Stable Diffusion) that creates a clear, simple illustration of the word's meaning.

Guidelines:
- Write in English for best image generation results
- Keep it simple and clear - suitable for language learning
- Include relevant context (e.g., "a smiling woman" not just "woman")
- Use style descriptors: "flat illustration", "simple cartoon", "minimalist design"
- Avoid complex scenes or text in the image
- Maximum 2-3 sentences
```json
"image_prompt": "A simple flat illustration of [concept], suitable for a language learning app, clean white background, colorful, minimalist style"
```

### 6. REGISTER FLAG
```json
"register": "everyday|polite|formal|slang"
```

### 7. CONFIDENCE
```json
"confidence": "high|medium|low"
```

## OUTPUT FORMAT
Return as JSON with the Lao word as the key:
```json
{{
  "WORD": {{
    "definitions": {{
{locale_defs}
    }},
    "part_of_speech": "...",
    "romanization": "...",
    "examples": [...],
    "image_prompt": "...",
    "register": "...",
    "confidence": "..."
  }}
}}
```

## IMPORTANT:
- Write ALL definitions in ALL 16 locales (de, en, es, fr, hi, ja, km, ko, ne, pt, th, tl, ur, vi, zh, zh_Hant)
- Write ALL example sentence translations in ALL 16 locales
- Flag any words in examples that are NOT in our 500-word vocabulary list with "out_of_scope_words": ["WORD"]
- Keep Lao script examples in informal/spoken register
- Use natural, conversational translations appropriate for each language
- Image prompts should be clear, simple, and suitable for educational use

---

Words to define:
"""

# Process in batches of 5
for prompt_num in range(NUM_PROMPTS):
    start_idx = prompt_num * BATCH_SIZE
    end_idx = min(start_idx + BATCH_SIZE, len(words))
    batch_words = words[start_idx:end_idx]
    
    # Build locale list for the prompt header
    locale_list = '\n'.join([f"- `{lc}` ({name})" for lc, name in SUPPORTED_LOCALES.items()])
    
    # Build word list for this prompt
    word_list_text = ""
    for w in batch_words:
        reason = w.get('brief_reason', '')
        category = w.get('category', 'content')
        word_list_text += f"- {w['word']} ({category}) — {reason}\n"
    
    # Fill in template
    full_prompt = DEFINITION_PROMPT.format(
        locale_list=locale_list,
        locale_defs=get_locale_definitions_template(),
        locale_translations=get_locale_translations_template()
    ) + word_list_text
    
    # Save prompt to file
    prompt_filename = f"step5_definition_prompts/prompt_{prompt_num+1:03d}_of_{NUM_PROMPTS}.txt"
    with open(prompt_filename, 'w', encoding='utf-8') as f:
        f.write(full_prompt)

print(f"\nCreated {NUM_PROMPTS} prompts in step5_definition_prompts/")

# Create manifest
manifest = {
    "step": 5,
    "description": "Generate multi-locale definitions, examples, and image prompts for 500 Lao words",
    "supported_locales": SUPPORTED_LOCALES,
    "locale_codes": LOCALE_CODES,
    "total_prompts": NUM_PROMPTS,
    "words_per_prompt": BATCH_SIZE,
    "total_words": len(words),
    "output_format": {
        "definitions": "All 16 locales required",
        "example_translations": "All 16 locales required",
        "image_prompt": "English prompt for AI image generator",
        "out_of_scope_tracking": "flag words not in 500-word list"
    },
    "prompts": []
}

for i in range(NUM_PROMPTS):
    start = i * BATCH_SIZE + 1
    end = min((i + 1) * BATCH_SIZE, len(words))
    manifest["prompts"].append({
        "prompt_number": i + 1,
        "filename": f"prompt_{i+1:03d}_of_{NUM_PROMPTS}.txt",
        "words": [w['word'] for w in words[start-1:end]],
        "word_count": end - start + 1
    })

with open('step5_definition_prompts/manifest.json', 'w', encoding='utf-8') as f:
    json.dump(manifest, f, indent=2, ensure_ascii=False)

print(f"Manifest saved to step5_definition_prompts/manifest.json")

# Show sample
print("\n" + "="*80)
print("SAMPLE PROMPT (prompt_001_of_100.txt):")
print("="*80)
with open('step5_definition_prompts/prompt_001_of_100.txt', 'r') as f:
    print(f.read())
