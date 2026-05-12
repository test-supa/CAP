-- SQL 9: Comprehensive fix for all Onboarding formData columns
-- This ensures the Supabase schema matches the React frontend exactly.

-- 1. Identity & Profile
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "fullName" TEXT;
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "phone" TEXT;
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "address" TEXT;
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "country" TEXT;
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "profilePictureUrl" TEXT;

-- 2. Experience & Role
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "yearsOfExperience" TEXT;
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "primaryRole" TEXT;
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "hoursPerWeek" INTEGER DEFAULT 40;
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "availableStartDate" TEXT;

-- 3. JSONB Collections (camelCase to match React state)
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "skills" JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "socialConnections" JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "freelancePlatforms" JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "paymentMethods" JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "verifiedTools" JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "portfolios" JSONB DEFAULT '[]'::jsonb;

-- 4. Force Supabase API to reload the schema cache
NOTIFY pgrst, 'reload schema';
