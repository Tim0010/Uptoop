-- Uptop Careers Database Schema
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.users (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Authentication
    phone_number TEXT UNIQUE NOT NULL,
    auth_provider TEXT DEFAULT 'phone', -- 'phone', 'google', 'facebook', etc.
    
    -- Basic Information (from onboarding)
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    age INTEGER CHECK (age >= 13 AND age <= 100),
    college TEXT NOT NULL,
    
    -- Profile Information
    avatar_url TEXT,
    bio TEXT,
    interests TEXT[], -- Array of interests
    
    -- Referral System
    referral_code TEXT UNIQUE NOT NULL,
    referred_by_code TEXT, -- Code of the person who referred this user
    referred_by_user_id UUID REFERENCES public.users(id),
    
    -- Gamification
    level INTEGER DEFAULT 1,
    coins INTEGER DEFAULT 0,
    total_earnings DECIMAL(10, 2) DEFAULT 0.00,
    pending_earnings DECIMAL(10, 2) DEFAULT 0.00,
    monthly_earnings DECIMAL(10, 2) DEFAULT 0.00,
    
    -- Statistics
    total_referrals INTEGER DEFAULT 0,
    active_referrals INTEGER DEFAULT 0,
    successful_referrals INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    is_email_verified BOOLEAN DEFAULT false,
    is_phone_verified BOOLEAN DEFAULT true, -- True after OTP verification
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Indexes for performance
    CONSTRAINT users_phone_number_key UNIQUE (phone_number),
    CONSTRAINT users_email_key UNIQUE (email),
    CONSTRAINT users_referral_code_key UNIQUE (referral_code)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users(phone_number);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_referral_code ON public.users(referral_code);
CREATE INDEX IF NOT EXISTS idx_users_referred_by ON public.users(referred_by_user_id);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON public.users(created_at);

-- ============================================
-- REFERRALS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Referrer (the person who made the referral)
    referrer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    
    -- Referred User (the person who was referred)
    referred_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    
    -- Referral Information
    referred_name TEXT NOT NULL,
    referred_email TEXT,
    referred_phone TEXT,
    referred_college TEXT,
    
    -- Status
    status TEXT DEFAULT 'pending', -- 'pending', 'contacted', 'enrolled', 'completed', 'rejected'
    application_stage TEXT DEFAULT 'not_started', -- 'not_started', 'applied', 'screening', 'interview', 'offer', 'enrolled'
    
    -- Tracking
    is_active BOOLEAN DEFAULT true,
    is_completed BOOLEAN DEFAULT false,
    
    -- Rewards
    reward_amount DECIMAL(10, 2) DEFAULT 0.00,
    reward_paid BOOLEAN DEFAULT false,
    reward_paid_at TIMESTAMP WITH TIME ZONE,
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Notes
    notes TEXT
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON public.referrals(referrer_id);
CREATE INDEX IF NOT EXISTS idx_referrals_referred_user ON public.referrals(referred_user_id);
CREATE INDEX IF NOT EXISTS idx_referrals_status ON public.referrals(status);
CREATE INDEX IF NOT EXISTS idx_referrals_created_at ON public.referrals(created_at);

-- ============================================
-- USER SESSIONS TABLE (for tracking logins)
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    
    -- Session Info
    device_info TEXT,
    ip_address TEXT,
    user_agent TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_sessions_user ON public.user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_created_at ON public.user_sessions(created_at);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for users table
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for referrals table
DROP TRIGGER IF EXISTS update_referrals_updated_at ON public.referrals;
CREATE TRIGGER update_referrals_updated_at
    BEFORE UPDATE ON public.referrals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;

-- Users table policies
-- Users can read their own data
CREATE POLICY "Users can view own profile"
    ON public.users FOR SELECT
    USING (auth.uid()::text = id::text);

-- Users can update their own data
CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE
    USING (auth.uid()::text = id::text);

-- Anyone can insert (for registration)
CREATE POLICY "Anyone can create user"
    ON public.users FOR INSERT
    WITH CHECK (true);

-- Users can view other users' basic info (for referrals)
CREATE POLICY "Users can view others basic info"
    ON public.users FOR SELECT
    USING (true);

-- Referrals table policies
-- Users can view their own referrals
CREATE POLICY "Users can view own referrals"
    ON public.referrals FOR SELECT
    USING (auth.uid()::text = referrer_id::text);

-- Users can create referrals
CREATE POLICY "Users can create referrals"
    ON public.referrals FOR INSERT
    WITH CHECK (auth.uid()::text = referrer_id::text);

-- Users can update their own referrals
CREATE POLICY "Users can update own referrals"
    ON public.referrals FOR UPDATE
    USING (auth.uid()::text = referrer_id::text);

-- Sessions table policies
-- Users can view their own sessions
CREATE POLICY "Users can view own sessions"
    ON public.user_sessions FOR SELECT
    USING (auth.uid()::text = user_id::text);

-- Users can create sessions
CREATE POLICY "Users can create sessions"
    ON public.user_sessions FOR INSERT
    WITH CHECK (auth.uid()::text = user_id::text);

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Function to generate unique referral code
CREATE OR REPLACE FUNCTION generate_referral_code(user_name TEXT)
RETURNS TEXT AS $$
DECLARE
    code TEXT;
    prefix TEXT;
    suffix TEXT;
    exists BOOLEAN;
BEGIN
    -- Get first 3 letters of name (uppercase)
    prefix := UPPER(SUBSTRING(REGEXP_REPLACE(user_name, '[^a-zA-Z]', '', 'g'), 1, 3));

    -- If prefix is less than 3 chars, pad with 'X'
    WHILE LENGTH(prefix) < 3 LOOP
        prefix := prefix || 'X';
    END LOOP;

    -- Generate random 4-digit suffix
    LOOP
        suffix := LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
        code := prefix || suffix;

        -- Check if code already exists
        SELECT EXISTS(SELECT 1 FROM public.users WHERE referral_code = code) INTO exists;

        EXIT WHEN NOT exists;
    END LOOP;

    RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Function to update referral statistics
CREATE OR REPLACE FUNCTION update_referral_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Update referrer's statistics
    IF TG_OP = 'INSERT' THEN
        UPDATE public.users
        SET total_referrals = total_referrals + 1,
            active_referrals = active_referrals + 1
        WHERE id = NEW.referrer_id;
    ELSIF TG_OP = 'UPDATE' THEN
        -- If referral is completed
        IF NEW.is_completed = true AND OLD.is_completed = false THEN
            UPDATE public.users
            SET successful_referrals = successful_referrals + 1,
                active_referrals = active_referrals - 1
            WHERE id = NEW.referrer_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update referral stats
DROP TRIGGER IF EXISTS update_referral_stats_trigger ON public.referrals;
CREATE TRIGGER update_referral_stats_trigger
    AFTER INSERT OR UPDATE ON public.referrals
    FOR EACH ROW
    EXECUTE FUNCTION update_referral_stats();

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- Uncomment to insert sample data
/*
INSERT INTO public.users (phone_number, full_name, email, age, college, referral_code)
VALUES
    ('+919876543210', 'John Kumar', 'john@example.com', 20, 'MIT', 'JOH1234'),
    ('+919876543211', 'Jane Sharma', 'jane@example.com', 21, 'Stanford', 'JAN5678');
*/

