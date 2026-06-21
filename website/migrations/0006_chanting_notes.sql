-- Add notes column to chanting_reviews
ALTER TABLE chanting_reviews ADD COLUMN notes TEXT NOT NULL DEFAULT '';
