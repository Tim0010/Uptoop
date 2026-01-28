-- Manual script to add welcome bonus to an existing user for testing
-- This is useful for testing the welcome bonus feature with existing accounts

-- INSTRUCTIONS:
-- 1. Replace 'YOUR_USER_ID' with the actual user ID (e.g., '341cc69d-dfc9-4864-a368-b37feb4f74fd')
-- 2. Run this script in Supabase SQL Editor
-- 3. Refresh the app to see the bonus in the wallet

-- Step 1: Check if user already has a welcome bonus
-- Uncomment to check:
-- SELECT * FROM public.transactions 
-- WHERE user_id = 'YOUR_USER_ID' 
--   AND type = 'bonus' 
--   AND description = 'Welcome Bonus! 🎉';

-- Step 2: Add welcome bonus transaction (if not already exists)
INSERT INTO public.transactions (user_id, type, amount, status, description, completed_at)
SELECT 
  'YOUR_USER_ID'::uuid,
  'bonus',
  10.00,
  'completed',
  'Welcome Bonus! 🎉',
  NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM public.transactions
  WHERE user_id = 'YOUR_USER_ID'
    AND type = 'bonus'
    AND description = 'Welcome Bonus! 🎉'
);

-- Step 3: Update user's total_earnings
UPDATE public.users
SET total_earnings = total_earnings + 10.00
WHERE id = 'YOUR_USER_ID'
  AND NOT EXISTS (
    SELECT 1 FROM public.transactions
    WHERE user_id = 'YOUR_USER_ID'
      AND type = 'bonus'
      AND description = 'Welcome Bonus! 🎉'
      AND created_at < NOW() - INTERVAL '1 second'
  );

-- Step 4: Verify the bonus was added
-- Uncomment to verify:
-- SELECT 
--   u.full_name,
--   u.total_earnings,
--   t.amount as bonus_amount,
--   t.created_at as bonus_date
-- FROM public.users u
-- LEFT JOIN public.transactions t ON u.id = t.user_id 
--   AND t.type = 'bonus' 
--   AND t.description = 'Welcome Bonus! 🎉'
-- WHERE u.id = 'YOUR_USER_ID';

-- EXAMPLE FOR TIMOTHY CHIBINDA:
-- Replace 'YOUR_USER_ID' with '341cc69d-dfc9-4864-a368-b37feb4f74fd'

