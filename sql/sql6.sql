-- ============================================================
-- SQL6: FINAL DATA HARVESTING COLUMNS
-- Adds missing PII and specialized platform tracking.
-- ============================================================

-- 1. PII Expansion (Section 1)
ALTER TABLE talents ADD COLUMN IF NOT EXISTS "address" TEXT;
ALTER TABLE talents ADD COLUMN IF NOT EXISTS "profilePictureUrl" TEXT;

-- 2. Freelance Platform Tracking (Section 3)
ALTER TABLE talents ADD COLUMN IF NOT EXISTS "freelancePlatforms" JSONB DEFAULT '[]';

-- 3. Detailed Payment Capture (Section 4)
-- We store the full JSON from the dynamic payment section here
-- Including the new crypto dropdown data.
ALTER TABLE talents ADD COLUMN IF NOT EXISTS "payoutDetails" JSONB DEFAULT '{}';
