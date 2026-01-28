-- Fix: Allow NULL IDs and auto-generate them
-- This fixes the error: "null value in column "id" of relation "users" violates not-null constraint"

-- Option 1: Make ID nullable and auto-generate if not provided
ALTER TABLE public.users 
ALTER COLUMN id SET DEFAULT uuid_generate_v4();

-- Option 2: Drop NOT NULL constraint (if needed)
-- Uncomment if Option 1 doesn't work
-- ALTER TABLE public.users ALTER COLUMN id DROP NOT NULL;

-- Verify the change
SELECT column_name, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'users' AND column_name = 'id';

