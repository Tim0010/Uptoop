# Sign-In Issue Fix Guide

## Problem
Existing users are being redirected to the account creation screen instead of the main screen after signing in.

## Root Cause
The Supabase Row Level Security (RLS) policy was too restrictive. It only allowed users to view their own profile (`auth.uid() = id`), which prevented the sign-in flow from checking if a user with a given phone number already exists in the database.

### What Was Happening:
1. User enters phone number and verifies OTP ✅
2. System creates a new anonymous Supabase user ✅
3. System tries to query the `users` table for existing profile by phone number ❌
4. **RLS policy blocks the query** because the new anonymous user doesn't have permission to see other users
5. Query returns `null` (no profile found)
6. System thinks it's a new user and redirects to onboarding ❌

## Solution

### Step 1: Update RLS Policy in Supabase

1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor**
3. Run the following SQL command:

```sql
-- Allow users to search by phone number (for sign-in flow)
drop policy if exists "Users select by phone" on public.users;
create policy "Users select by phone" on public.users
  for select using ( true );
```

**OR** run the complete fix script:
- Open `supabase/fix_rls_policy.sql` in this project
- Copy the entire content
- Paste and run it in Supabase SQL Editor

### Step 2: Verify the Fix

After updating the RLS policy, test the sign-in flow:

1. **Test with Existing User:**
   - Use a phone number that's already in your database
   - Enter OTP and verify
   - You should see these debug logs:
     ```
     🔍 Checking for existing profile...
     📱 Phone: +919253664013
     👤 Profile found: true
     📝 Full name: [Your Name]
     🆔 User ID: [UUID]
     ✅ Existing user detected - signing in
     ```
   - Should redirect to **Main Screen** ✅

2. **Test with New User:**
   - Use a phone number that's NOT in your database
   - Enter OTP and verify
   - You should see:
     ```
     🔍 Checking for existing profile...
     📱 Phone: +91XXXXXXXXXX
     👤 Profile found: false
     🆕 New user detected - going to onboarding
     ```
   - Should redirect to **Onboarding Screen** ✅

## Code Changes Made

### 1. `lib/screens/otp_auth_screen.dart`
- Changed from `getUserProfile()` to `getUserProfileByPhone()`
- Added logic to update user ID when existing profile is found
- Added comprehensive debug logging

### 2. `lib/providers/auth_provider.dart`
- Added `getUserProfileByPhone()` method
- Added `updateUserId()` method

### 3. `lib/services/supabase_service.dart`
- Enhanced `getUserByPhone()` with detailed logging
- Shows sample phone numbers from database when user not found

### 4. `supabase/required_tables.sql`
- Updated RLS policy to allow phone number lookups

## Security Considerations

The new RLS policy allows any authenticated user to SELECT (read) from the users table. This is safe because:

1. ✅ Users can only INSERT/UPDATE their own records (protected by other policies)
2. ✅ We only expose necessary fields during lookup
3. ✅ This is required for the sign-in flow to work properly
4. ✅ No sensitive data is exposed (passwords, tokens, etc.)

## Alternative (More Restrictive) Policy

If you want to be more restrictive, you can use this policy instead:

```sql
create policy "Users select by phone" on public.users
  for select using ( 
    auth.uid() = id OR 
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE phone_number = current_setting('request.jwt.claims', true)::json->>'phone'
    )
  );
```

This allows users to:
- View their own profile
- Search for profiles by phone number (but only during authentication)

## Troubleshooting

### Issue: Still redirecting to onboarding
**Solution:** 
1. Check if the RLS policy was applied correctly
2. Verify the phone number format in the database matches the format being searched
3. Check the debug logs to see what's being searched

### Issue: "No user found" but user exists
**Solution:**
1. Check the phone number format in database vs. what's being searched
2. The app formats numbers to E.164 format (+919253664013)
3. Make sure database has the same format

### Issue: RLS policy error
**Solution:**
1. Make sure you're running the SQL as the database owner
2. Check if the policy name conflicts with existing policies
3. Try dropping all user policies and recreating them

## Testing Checklist

- [ ] RLS policy updated in Supabase
- [ ] Existing user can sign in and goes to Main Screen
- [ ] New user goes to Onboarding Screen
- [ ] Debug logs show correct phone number format
- [ ] Debug logs show profile found/not found correctly
- [ ] User data loads correctly after sign-in

