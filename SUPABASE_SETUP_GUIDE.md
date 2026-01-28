# 🚀 Supabase Setup Guide - Uptop Careers

Complete guide to set up Supabase backend for Uptop Careers app.

---

## 📋 Table of Contents

1. [What is Supabase?](#what-is-supabase)
2. [Quick Setup (10 Minutes)](#quick-setup-10-minutes)
3. [Database Schema](#database-schema)
4. [Configuration](#configuration)
5. [Testing](#testing)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 What is Supabase?

Supabase is an open-source Firebase alternative that provides:
- **PostgreSQL Database** - Powerful relational database
- **Authentication** - Built-in auth with OTP support
- **Real-time** - Live data updates
- **Storage** - File storage
- **Row Level Security** - Secure data access

**Why Supabase for Uptop Careers?**
- ✅ Free tier (50,000 monthly active users)
- ✅ Phone OTP authentication
- ✅ PostgreSQL (powerful queries)
- ✅ Real-time referral tracking
- ✅ Automatic API generation
- ✅ Built-in security

---

## ⚡ Quick Setup (10 Minutes)

### Step 1: Create Supabase Account (2 minutes)

1. Go to https://supabase.com/
2. Click **"Start your project"**
3. Sign up with GitHub (recommended) or email
4. Verify your email

### Step 2: Create New Project (2 minutes)

1. Click **"New Project"**
2. Fill in details:
   - **Name:** `uptop-careers` (or your choice)
   - **Database Password:** Create a strong password (save it!)
   - **Region:** Choose closest to your users (e.g., `ap-south-1` for India)
   - **Pricing Plan:** Free (perfect for development)
3. Click **"Create new project"**
4. Wait 2-3 minutes for setup to complete

### Step 3: Get API Credentials (1 minute)

1. Go to **Settings** → **API** (in left sidebar)
2. Copy these values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (under "Project API keys")

### Step 4: Configure .env File (1 minute)

Open your `.env` file and add:

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

### Step 5: Set Up Database Schema (3 minutes)

1. Go to **SQL Editor** (in left sidebar)
2. Click **"New query"**
3. Copy the entire content from `supabase_schema.sql` file
4. Paste it into the SQL editor
5. Click **"Run"** (or press Ctrl+Enter)
6. You should see "Success. No rows returned"

### Step 6: Test the Integration (1 minute)

```bash
flutter pub get
flutter run
```

That's it! Your app is now connected to Supabase! 🎉

---

## 📊 Database Schema

### Tables Created

#### 1. **users** Table
Stores user profiles and authentication data.

**Key Fields:**
- `id` - UUID (primary key)
- `phone_number` - Unique phone number
- `full_name` - User's full name
- `email` - Unique email address
- `age` - User's age
- `college` - College/University name
- `referral_code` - Unique referral code (auto-generated)
- `referred_by_code` - Code of referrer
- `referred_by_user_id` - ID of referrer
- `level`, `coins`, `total_earnings` - Gamification
- `total_referrals`, `active_referrals` - Statistics
- `is_active`, `is_verified` - Status flags
- `created_at`, `updated_at` - Timestamps

#### 2. **referrals** Table
Tracks all referrals made by users.

**Key Fields:**
- `id` - UUID (primary key)
- `referrer_id` - User who made the referral
- `referred_user_id` - User who was referred
- `referred_name`, `referred_email`, `referred_phone` - Referral details
- `status` - pending, contacted, enrolled, completed, rejected
- `application_stage` - not_started, applied, screening, interview, offer, enrolled
- `reward_amount`, `reward_paid` - Reward tracking
- `created_at`, `updated_at` - Timestamps

#### 3. **user_sessions** Table
Tracks user login sessions.

**Key Fields:**
- `id` - UUID (primary key)
- `user_id` - Reference to users table
- `device_info`, `ip_address`, `user_agent` - Session details
- `created_at`, `expires_at` - Timestamps

### Indexes

Optimized indexes for fast queries:
- Phone number lookup
- Email lookup
- Referral code lookup
- User referrals
- Date-based queries

### Security (Row Level Security)

**Enabled on all tables** with policies:
- Users can view/update their own data
- Users can view others' basic info (for referrals)
- Users can create/view/update their own referrals
- Users can view their own sessions

---

## 🔧 Configuration

### Environment Variables

Required in `.env` file:

```env
# Supabase Configuration
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

### App Integration

The app automatically:
1. Loads environment variables on startup
2. Initializes Supabase client
3. Falls back to offline mode if not configured
4. Saves user data to Supabase during onboarding
5. Syncs referrals to database

---

## 🧪 Testing

### Test User Creation

1. Run the app: `flutter run`
2. Complete OTP verification
3. Fill in onboarding form:
   - Name: Test User
   - Email: test@example.com
   - Age: 20
   - College: Test College
4. Click "Create Account"

### Verify in Supabase

1. Go to **Table Editor** in Supabase
2. Select **users** table
3. You should see your new user with:
   - Phone number
   - Name, email, age, college
   - Auto-generated referral code
   - Timestamps

### Test Referral System

1. Note your referral code from the app
2. Create another account with that referral code
3. Check **users** table - new user should have `referred_by_code`
4. Check **referrals** table - should have a new referral entry

---

## 🔍 Troubleshooting

### "Supabase not initialized"

**Cause:** Missing or invalid credentials

**Solution:**
1. Check `.env` file has correct URL and key
2. Run `flutter pub get`
3. Restart the app

### "Failed to save user profile"

**Cause:** Database schema not set up

**Solution:**
1. Go to SQL Editor in Supabase
2. Run the `supabase_schema.sql` script
3. Check for any errors in the output

### "Row Level Security policy violation"

**Cause:** RLS policies not set up correctly

**Solution:**
1. Re-run the `supabase_schema.sql` script
2. Make sure all policies are created
3. Check Supabase logs for details

### App works but data not in Supabase

**Cause:** App running in offline mode

**Solution:**
1. Check console for "Supabase not configured" message
2. Verify `.env` file has credentials
3. Check Supabase project is active (not paused)

---

## 📚 Additional Resources

- **Supabase Docs:** https://supabase.com/docs
- **Flutter Integration:** https://supabase.com/docs/reference/dart
- **SQL Reference:** https://www.postgresql.org/docs/

---

## 🎉 You're All Set!

Your Uptop Careers app is now powered by Supabase! 🚀

**Next Steps:**
1. Test user registration
2. Test referral system
3. Monitor database in Supabase dashboard
4. Set up backups (in Supabase settings)

**Need Help?** Check the troubleshooting section or Supabase docs.

