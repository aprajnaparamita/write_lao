-- Migration: Create tester_submissions table
-- Run this to set up the database for video submissions

CREATE TABLE IF NOT EXISTS tester_submissions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  filename TEXT NOT NULL,
  section TEXT NOT NULL,
  device_model TEXT NOT NULL,
  os_version TEXT NOT NULL,
  app_version TEXT NOT NULL,
  tester_name TEXT NOT NULL,
  uploaded_at TEXT NOT NULL
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_tester_device ON tester_submissions(device_model, os_version);
CREATE INDEX IF NOT EXISTS idx_tester_section ON tester_submissions(section);
CREATE INDEX IF NOT EXISTS idx_tester_uploaded ON tester_submissions(uploaded_at DESC);
