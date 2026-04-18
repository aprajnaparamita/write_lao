# Task: Build a 500-word Lao vocabulary list for a language learning app

You are helping build a curated list of 500 essential Lao words for a beginner/intermediate language learning app. The final output should be a ranked, annotated word list suitable for teaching informal conversational Lao.

## Pipeline overview

1. Source raw frequency data from Leipzig Corpora Collection (Lao corpus)
2. Clean and validate against a Lao dictionary (LaoNLP)
3. Use an LLM to filter for pedagogical usefulness in batches
4. Re-rank survivors by original corpus frequency
5. Generate definitions and example sentences
6. Flag everything for native speaker review

---

## Step 1: Source the raw frequency data

- Download the Lao corpus from the Leipzig Corpora Collection: https://wortschatz.uni-leipzig.de/en/download/Lao
- Use the largest available corpus size (e.g., `lao_web` or `lao_newscrawl`, 1M sentences if available)
- Extract the top 1000 words by raw frequency from the `*-words.txt` file
- Preserve frequency counts alongside each word — we need these for final ranking

## Step 2: Clean and validate

Filter the raw 1000 to remove junk before sending anything to an LLM:

- Drop entries that are purely numeric, punctuation, Latin characters, or emoji
- Drop entries shorter than 2 Lao characters (likely tokenizer fragments)
- Validate each remaining word against the LaoNLP dictionary (`laonlp.corpus.lao_words()` or the dictionary module)
- Drop entries not found in the dictionary UNLESS they appear in the top 200 by frequency (very common words may be missing from dictionaries; flag these for manual review instead of dropping)
- Expected survivors: ~700–800 validated words

Output of this step: `validated_words.json` with `{word, ipa, frequency_rank, frequency_count, in_dictionary}`

## Step 3: LLM pedagogical filter

Process the validated list in batches of 50 words. For each batch, write out a  prompt to be fed to an LLM.

> You are a Lao language teacher preparing vocabulary for a beginner-to-intermediate learner focused on **informal spoken conversation**. Below are 50 Lao words drawn from a written-text corpus.
>
> Some of these words are genuinely common in daily spoken Lao. Others are frequent in the corpus because they appear heavily in formal writing, news, or Pali/Sanskrit loanwords that nobody uses in conversation.
>
> **Rank these 50 words from 1 (most useful for a conversational learner) to 50 (least useful).** Do not omit any words — rank all 50.
>
> For each word, also assign a category: `content` (nouns, verbs, adjectives, adverbs), `function` (particles, classifiers, pronouns, conjunctions), or `formal` (Pali/Sanskrit loanwords, bureaucratic vocabulary rarely used in speech).
>
> Write output as JSON with the same filename with .json appended in this format: `[{word, ipa, rank, category, brief_reason}, ...]`
>
> Words to rank:
> [insert batch of 50 here]

## Step 3: POST PROCESS

From each batch, keep the top 30 ranked words. This gives you roughly 420–480 survivors across all batches. Discard words marked `formal` regardless of rank.

**Run a second parallel pass** specifically for function words. Many essential particles and classifiers rank low on "usefulness" but are grammatically indispensable. Use this prompt on the full validated list:

> From the following Lao words, identify particles, classifiers, pronouns, question words, and conjunctions that a beginner learner MUST know to form basic sentences. Return up to 50 such words as JSON: `[{word, type, why_essential}, ...]`

Merge this function-word set into your survivor list (union, not intersection).

## Step 4: Re-rank by corpus frequency

- Take the combined survivor list
- Re-sort by the original Leipzig frequency count (descending)
- Truncate to exactly 500 words
- If under 500, pull additional entries from the next-highest-frequency validated words

## Step 5: Generate definitions and examples

For each of the 500 words, write a propmt out for the LLM (in small batches of 5):

> For the Lao word `[WORD]`, provide:
>
> 1. **Primary English definition** (one short phrase, conversational register)
> 2. **Part of speech** (noun, verb, adjective, classifier, particle, etc.)
> 3. **Romanization** (using a consistent system, e.g., BGN/PCGN or IPA — specify which)
> 4. **Two example sentences in informal spoken Lao**, each with:
>    - Lao script
>    - IPA romanization
>    - English translation
>    - A note if the example uses any word NOT in our 500-word list (flag it)
> 5. **Register/usage flag**: `everyday` / `polite` / `formal` / `slang`
> 6. **Confidence**: `high` / `medium` / `low` — your confidence that the Lao script, romanization, and examples are accurate
>
> Return as JSON.

## Step 6: Consistency and error checks (automated)

Before handing to human reviewers, run these automated checks:

- Example sentences actually contain the target word
- No duplicate words in the final list
- All 500 entries have all required fields
- Flag any entry where LLM confidence is `low`

Output a review-ready CSV or JSON with a `needs_review` boolean column.

## Step 7: Native speaker review (NOT automated)

The output of step 6 is NOT a finished product. A native Lao speaker (ideally a teacher) must review:

- All `low` confidence entries
- A random 10% sample of `high`/`medium` entries
- All function words and particles (these are where subtle errors do the most damage)
- All example sentences for naturalness

Budget for this explicitly. Do not ship without it.

---

## Deliverables

- `raw_leipzig_top1000.txt` — step 1 output
- `validated_words.json` — step 2 output
- `llm_filtered.json` — step 3 output (with rankings and categories)
- `final_500.json` — step 4 output (ranked by frequency)
- `annotated_500.json` — step 5 output (with definitions and examples)
- `review_ready.csv` — step 6 output, ready for native speaker
- `final_500_reviewed.csv` — after step 7, THIS is what goes in the app

## Known limitations to document

- Leipzig corpus is web/newspaper-biased toward written register — even with LLM filtering, the list skews slightly more formal than pure spoken Lao
- LLM definitions and examples for Lao (a low-resource language) have an estimated 5–15% error rate; native review is mandatory
- Word segmentation in Lao is ambiguous; some "words" in the final list may be compound-parts or fragments that a native speaker should merge or split
- This list represents standard Lao (Vientiane dialect, roughly); regional variants are not covered
