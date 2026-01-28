-- Add welcome bonus to Timothy Chibinda for testing
-- User ID: 341cc69d-dfc9-4864-a368-b37feb4f74fd
-- Phone: +919253664013

-- Step 1: Check current status
SELECT 
  u.full_name,
  u.total_earnings,
  u.phone_number,
  COUNT(t.id) as bonus_count
FROM public.users u
LEFT JOIN public.transactions t ON u.id = t.user_id 
  AND t.type = 'bonus' 
  AND t.description = 'Welcome Bonus! 🎉'
WHERE u.id = '341cc69d-dfc9-4864-a368-b37feb4f74fd'
GROUP BY u.id, u.full_name, u.total_earnings, u.phone_number;

-- Step 2: Add welcome bonus (only if not already exists)
INSERT INTO public.transactions (user_id, type, amount, status, description, completed_at)
SELECT 
  '341cc69d-dfc9-4864-a368-b37feb4f74fd'::uuid,
  'bonus',
  10.00,
  'completed',
  'Welcome Bonus! 🎉',
  NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM public.transactions
  WHERE user_id = '341cc69d-dfc9-4864-a368-b37feb4f74fd'
    AND type = 'bonus'
    AND description = 'Welcome Bonus! 🎉'
);

-- Step 3: Update user's total_earnings
UPDATE public.users
SET total_earnings = COALESCE(total_earnings, 0) + 10.00
WHERE id = '341cc69d-dfc9-4864-a368-b37feb4f74fd'
  AND (
    SELECT COUNT(*) FROM public.transactions
    WHERE user_id = '341cc69d-dfc9-4864-a368-b37feb4f74fd'
      AND type = 'bonus'
      AND description = 'Welcome Bonus! 🎉'
  ) = 1; -- Only update if exactly 1 bonus exists (the one we just added)

-- Step 4: Verify the result
SELECT 
  u.full_name,
  u.total_earnings,
  u.phone_number,
  t.amount as bonus_amount,
  t.status,
  t.created_at as bonus_date
FROM public.users u
LEFT JOIN public.transactions t ON u.id = t.user_id 
  AND t.type = 'bonus' 
  AND t.description = 'Welcome Bonus! 🎉'
WHERE u.id = '341cc69d-dfc9-4864-a368-b37feb4f74fd';

