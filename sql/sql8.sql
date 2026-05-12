-- SQL 8: Fix 'freelance Platforms' column error and refresh schema cache

-- The React code is trying to insert into a column named "freelancePlatforms" (camelCase)
-- However, PostgreSQL folds unquoted column names to lowercase.
-- If the column was created as "freelancePlatforms" (quoted), it must be referenced exactly.
-- To ensure compatibility with the React `formData` object, we make sure the exact camelCase column exists.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema='public' AND table_name='talents' AND column_name='freelancePlatforms') THEN
        ALTER TABLE public.talents ADD COLUMN "freelancePlatforms" JSONB DEFAULT '[]'::jsonb;
    END IF;
END $$;

-- Also ensure "paymentMethods" exists since formData has it
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema='public' AND table_name='talents' AND column_name='paymentMethods') THEN
        ALTER TABLE public.talents ADD COLUMN "paymentMethods" JSONB DEFAULT '[]'::jsonb;
    END IF;
END $$;

-- Force PostgREST (Supabase API) to reload its schema cache
NOTIFY pgrst, 'reload schema';
