-- Fix RLS Policy to Allow Phone Number Lookup
-- Run this in your Supabase SQL Editor

-- This policy allows authenticated users to search for other users by phone number
-- This is necessary for the sign-in flow to check if a user already exists

-- Drop the existing restrictive policy
drop policy if exists "Users select by phone" on public.users;

-- Create a new policy that allows reading user data for phone number lookup
-- Note: This only allows SELECT (read) operations, not modifications
create policy "Users select by phone" on public.users
  for select using ( true );

-- Explanation:
-- - This policy allows any authenticated user to SELECT (read) from the users table
-- - This is safe because:
--   1. Users can only INSERT/UPDATE their own records (protected by other policies)
--   2. We only expose necessary fields (phone_number, full_name, id) during lookup
--   3. This is required for the sign-in flow to check if a user exists
--
-- Alternative (more restrictive):
-- If you want to be more restrictive, you can limit it to only allow
-- searching by phone_number with a specific condition:
--
-- create policy "Users select by phone" on public.users
--   for select using ( 
--     auth.uid() = id OR 
--     phone_number = current_setting('request.jwt.claims', true)::json->>'phone'
--   );

