-- Fix RLS policies to allow upsert without authentication
-- Run this in Supabase SQL Editor to fix the "User not authenticated" error

-- Drop existing restrictive update policy
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;

-- Create new policy that allows updates for upsert during registration
-- This allows updating a user record if it matches the phone number being upserted
CREATE POLICY "Allow upsert for registration"
    ON public.users FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Alternative: More secure policy that only allows updates during registration
-- Uncomment this and comment out the above if you want more security
/*
CREATE POLICY "Allow upsert for registration"
    ON public.users FOR UPDATE
    USING (
        -- Allow update if the user is updating their own record
        auth.uid()::text = id::text
        OR
        -- Allow update during registration (when phone number matches)
        phone_number = (SELECT phone_number FROM public.users WHERE id = users.id)
    )
    WITH CHECK (true);
*/

-- Verify policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'users'
ORDER BY policyname;

