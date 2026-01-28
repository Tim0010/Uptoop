-- ============================================================================
-- FIX REFERRAL LINKING ISSUES - Row Level Security (RLS) Policies
-- ============================================================================
-- This script fixes the RLS policies on the referrals table to allow:
-- 1. Users to read referrals by ID (for linking when they sign up)
-- 2. Users to update referrals when linking their account
-- 3. Users to read their own referrals (as referrer or referred user)
-- ============================================================================

-- Step 1: Drop existing policies (if any)
DROP POLICY IF EXISTS "Users can read referrals by ID" ON referrals;
DROP POLICY IF EXISTS "Users can update referrals" ON referrals;
DROP POLICY IF EXISTS "Users can read their own referrals" ON referrals;
DROP POLICY IF EXISTS "Users can create referrals" ON referrals;

-- Step 2: Create new policies

-- Allow authenticated users to read ANY referral by ID
-- This is needed when a referred user signs up and needs to link the referral
CREATE POLICY "Users can read referrals by ID"
ON referrals FOR SELECT
TO authenticated
USING (true);

-- Allow authenticated users to update ANY referral
-- This is needed when linking a referral to a referred user
CREATE POLICY "Users can update referrals"
ON referrals FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Allow authenticated users to create referrals
CREATE POLICY "Users can create referrals"
ON referrals FOR INSERT
TO authenticated
WITH CHECK (true);

-- Step 3: Verify policies were created
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'referrals'
ORDER BY policyname;

-- ============================================================================
-- ALTERNATIVE: More Restrictive Policies (Use if above is too permissive)
-- ============================================================================
-- Uncomment the following if you want more restrictive policies:

/*
-- Drop the permissive policies
DROP POLICY IF EXISTS "Users can read referrals by ID" ON referrals;
DROP POLICY IF EXISTS "Users can update referrals" ON referrals;

-- Allow users to read referrals where they are the referrer OR the referred user
CREATE POLICY "Users can read their own referrals"
ON referrals FOR SELECT
TO authenticated
USING (
  referrer_id = auth.uid() 
  OR referred_user_id = auth.uid()
  OR referred_user_id IS NULL  -- Allow reading unlinked referrals
);

-- Allow users to update referrals where they are being referred
CREATE POLICY "Users can update referrals when linking"
ON referrals FOR UPDATE
TO authenticated
USING (
  referred_user_id IS NULL  -- Can only update unlinked referrals
  OR referred_user_id = auth.uid()  -- Or their own linked referral
)
WITH CHECK (
  referred_user_id = auth.uid()  -- Can only set referred_user_id to themselves
);
*/

-- ============================================================================
-- TEST THE POLICIES
-- ============================================================================
-- Run these queries to test if the policies work:

-- 1. Check if you can read a referral by ID
SELECT * FROM referrals WHERE id = 'YOUR_REFERRAL_ID_HERE' LIMIT 1;

-- 2. Check if you can update a referral
UPDATE referrals 
SET referred_user_id = auth.uid(),
    referred_name = 'Test User'
WHERE id = 'YOUR_REFERRAL_ID_HERE';

-- 3. Verify the update
SELECT * FROM referrals WHERE id = 'YOUR_REFERRAL_ID_HERE';

-- ============================================================================
-- CLEANUP: Remove test data (if needed)
-- ============================================================================
-- Uncomment to remove test referrals:
-- DELETE FROM referrals WHERE referred_name = 'Test User';

