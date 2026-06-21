-- Pali chanting book OCR review table
-- Stores per-page reviews from human reviewers.
-- Each (reviewer_name, page_id) pair is unique — re-submitting overwrites.

CREATE TABLE IF NOT EXISTS chanting_reviews (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  reviewer_name     TEXT    NOT NULL,
  page_id           TEXT    NOT NULL,
  page_title        TEXT,
  status            TEXT    NOT NULL CHECK(status IN ('ok', 'problem')),
  flagged_runs      TEXT    NOT NULL DEFAULT '[]',   -- JSON array of run indices
  flagged_run_texts TEXT    NOT NULL DEFAULT '[]',   -- JSON array of run text snippets
  reviewed_at       TEXT    NOT NULL DEFAULT (datetime('now')),
  UNIQUE(reviewer_name, page_id) ON CONFLICT REPLACE
);

CREATE INDEX IF NOT EXISTS idx_chanting_reviews_page   ON chanting_reviews(page_id);
CREATE INDEX IF NOT EXISTS idx_chanting_reviews_reviewer ON chanting_reviews(reviewer_name);
