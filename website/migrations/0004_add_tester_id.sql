-- Migration: Add tester_id to tester_submissions
-- Enables deterministic grouping by tester identity across devices/browsers

ALTER TABLE tester_submissions ADD COLUMN tester_id TEXT;

CREATE INDEX IF NOT EXISTS idx_tester_id ON tester_submissions(tester_id);
