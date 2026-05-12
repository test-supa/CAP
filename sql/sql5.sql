-- ============================================================
-- SQL5: STRATEGIC SOCIAL & PAYMENT COLUMNS
-- Adds mandatory tracking for social and region-specific payment connections.
-- ============================================================

-- 1. Add Social & Payment columns to talents
ALTER TABLE talents ADD COLUMN IF NOT EXISTS "socialConnections" JSONB DEFAULT '[]';
ALTER TABLE talents ADD COLUMN IF NOT EXISTS "paymentMethods" JSONB DEFAULT '[]';

-- 2. Add verification flags for easier querying
ALTER TABLE talents ADD COLUMN IF NOT EXISTS "hasSocialVerified" BOOLEAN DEFAULT FALSE;
ALTER TABLE talents ADD COLUMN IF NOT EXISTS "hasPaymentVerified" BOOLEAN DEFAULT FALSE;

-- 3. Ensure 'primaryRole' from SQL4 is also here just in case
ALTER TABLE talents ADD COLUMN IF NOT EXISTS "primaryRole" TEXT;
