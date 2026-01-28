-- Migration: Add policy to allow users to receive welcome bonus
-- This allows the system to insert bonus transactions for new users

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Transactions insert welcome bonus" ON public.transactions;

-- Create policy to allow inserting welcome bonus for authenticated users
-- This allows the client to insert a bonus transaction for themselves during onboarding
CREATE POLICY "Transactions insert welcome bonus" ON public.transactions
  FOR INSERT WITH CHECK (
    auth.uid() = user_id AND type = 'bonus' AND status = 'completed'
  );

-- Note: This policy allows users to insert their own bonus transactions
-- In production, you may want to use a server-side function or Edge Function
-- to prevent abuse. For now, we trust the client-side logic.

