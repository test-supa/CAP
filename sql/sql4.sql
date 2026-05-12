-- ============================================================
-- SQL4: IDEMPOTENT UPDATE
-- This file fixes the "Primary Role" column and handles policies safely.
-- Run this if sql3 failed or to update existing tables.
-- ============================================================

-- 1. Ensure 'primaryRole' column exists in talents
ALTER TABLE talents ADD COLUMN IF NOT EXISTS "primaryRole" TEXT;

-- 2. Drop and Re-create Policies to avoid "already exists" errors
-- TALENTS Policies
DROP POLICY IF EXISTS "talents_anon_insert" ON talents;
DROP POLICY IF EXISTS "talents_auth_insert" ON talents;
DROP POLICY IF EXISTS "talents_service_all" ON talents;

CREATE POLICY "talents_anon_insert" ON talents FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "talents_auth_insert" ON talents FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "talents_service_all" ON talents FOR ALL TO service_role USING (true);

-- RESTAURANTS Policies
DROP POLICY IF EXISTS "restaurants_anon_insert" ON restaurants;
DROP POLICY IF EXISTS "restaurants_auth_insert" ON restaurants;
DROP POLICY IF EXISTS "restaurants_service_all" ON restaurants;

CREATE POLICY "restaurants_anon_insert" ON restaurants FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "restaurants_auth_insert" ON restaurants FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "restaurants_service_all" ON restaurants FOR ALL TO service_role USING (true);

-- TOOLS Policies
DROP POLICY IF EXISTS "tools_anon_insert" ON tool_authorizations;
DROP POLICY IF EXISTS "tools_auth_insert" ON tool_authorizations;
DROP POLICY IF EXISTS "tools_service_all" ON tool_authorizations;

CREATE POLICY "tools_anon_insert" ON tool_authorizations FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "tools_auth_insert" ON tool_authorizations FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "tools_service_all" ON tool_authorizations FOR ALL TO service_role USING (true);

-- ID DOCUMENTS Policies
DROP POLICY IF EXISTS "docs_anon_insert" ON id_documents;
DROP POLICY IF EXISTS "docs_auth_insert" ON id_documents;
DROP POLICY IF EXISTS "docs_service_all" ON id_documents;

CREATE POLICY "docs_anon_insert" ON id_documents FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "docs_auth_insert" ON id_documents FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "docs_service_all" ON id_documents FOR ALL TO service_role USING (true);
