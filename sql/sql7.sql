-- SQL 7: Add missing address column and refresh schema cache

-- 1. Add address column to the talents table if it doesn't already exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema='public' AND table_name='talents' AND column_name='address') THEN
        ALTER TABLE public.talents ADD COLUMN address TEXT;
    END IF;
END $$;

-- 2. Force PostgREST (Supabase API) to reload its schema cache
-- This prevents the "Could not find the 'address' column... in the schema cache" error
NOTIFY pgrst, 'reload schema';
