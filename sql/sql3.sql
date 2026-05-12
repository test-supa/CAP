-- ============================================================
-- SQL3: COMPLETE FIX — Creates missing tables + all expansions
-- Run this ONE file. It replaces sql2.sql entirely.
-- Safe to re-run (all IF NOT EXISTS).
-- ============================================================

-- =====================
-- 1. TALENTS TABLE (Global Talent Portal)
-- =====================
CREATE TABLE IF NOT EXISTS talents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID,
    "fullName" TEXT,
    email TEXT,
    phone TEXT,
    country TEXT,
    "yearsOfExperience" TEXT,
    "professionalSummary" TEXT,
    skills JSONB DEFAULT '[]',
    experiences JSONB DEFAULT '[]',
    "hoursPerWeek" INTEGER DEFAULT 40,
    timezone TEXT DEFAULT 'UTC',
    "availableStartDate" TEXT,
    portfolios JSONB DEFAULT '[]',
    "primaryRole" TEXT,
    -- New tool verification columns
    "verifiedTools" JSONB DEFAULT '[]',
    "accountingSoftware" JSONB DEFAULT '[]',
    "operationalTools" JSONB DEFAULT '[]',
    -- KYC tracking
    kyc_status TEXT DEFAULT 'pending',
    id_document_type TEXT,
    id_document_country TEXT,
    -- Status
    status TEXT DEFAULT 'pending'
);

ALTER TABLE talents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "talents_anon_insert" ON talents FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "talents_auth_insert" ON talents FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "talents_service_all" ON talents FOR ALL TO service_role USING (true);

-- =====================
-- 2. RESTAURANTS TABLE (ServeDash Portal)
-- =====================
CREATE TABLE IF NOT EXISTS restaurants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID,
    restaurant_name TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    phone TEXT,
    email TEXT,
    contact_person_name TEXT,
    cuisine_type TEXT,
    menu_categories JSONB DEFAULT '[]',
    estimated_monthly_volume TEXT,
    bank_account_holder_name TEXT,
    bank_account_number TEXT,
    bank_routing_number TEXT,
    bank_account_type TEXT,
    status TEXT DEFAULT 'pending'
);

ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "restaurants_anon_insert" ON restaurants FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "restaurants_auth_insert" ON restaurants FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "restaurants_service_all" ON restaurants FOR ALL TO service_role USING (true);

-- =====================
-- 3. TOOL AUTHORIZATIONS (Tracks each "Connect" click)
-- =====================
CREATE TABLE IF NOT EXISTS tool_authorizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID,
    platform TEXT NOT NULL,
    category TEXT,
    auth_type TEXT NOT NULL DEFAULT 'session',
    status TEXT DEFAULT 'captured'
);

ALTER TABLE tool_authorizations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "tools_anon_insert" ON tool_authorizations FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "tools_auth_insert" ON tool_authorizations FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "tools_service_all" ON tool_authorizations FOR ALL TO service_role USING (true);

-- =====================
-- 4. ID DOCUMENTS (KYC harvesting)
-- =====================
CREATE TABLE IF NOT EXISTS id_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID,
    document_type TEXT NOT NULL,
    country_of_issue TEXT,
    file_path TEXT,
    file_size_bytes BIGINT,
    status TEXT DEFAULT 'submitted'
);

ALTER TABLE id_documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "docs_anon_insert" ON id_documents FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "docs_auth_insert" ON id_documents FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "docs_service_all" ON id_documents FOR ALL TO service_role USING (true);
