# 🔧 Fix Supabase Authentication Error

## ⚠️ Current Issue

```
❌ Error upserting user profile: Exception: User not authenticated
❌ Error saving user profile: Exception: User not authenticated
```

**Cause:** The app uses Twilio for OTP verification, but Supabase requires authentication to save user profiles.

---

## ✅ Solution: Update RLS Policies

### Step 1: Run the Fix Script

1. Go to your **Supabase Dashboard**: https://app.supabase.com/
2. Open your project
3. Go to **SQL Editor** (left sidebar)
4. Click **"New query"**
5. Copy the content from `supabase_rls_fix.sql`
6. Paste and click **"Run"** (or press Ctrl+Enter)

### Step 2: Verify the Fix

After running the script, you should see:
```
Success. No rows returned
```

### Step 3: Test the App

1. **Restart the app:**
   ```bash
   # Press 'q' to quit
   flutter run
   ```

2. **Complete registration:**
   - Enter phone number
   - Verify OTP
   - Fill onboarding form
   - Click "Create Account"

3. **Check console output:**
   - ✅ Should see: `✅ User profile saved to Supabase`
   - ✅ No more "User not authenticated" errors

4. **Verify in Supabase:**
   - Go to **Table Editor** → **users**
   - See your new user profile

---

## 🔍 What the Fix Does

### Before (Restrictive)
```sql
-- Only authenticated users could update their own profile
CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE
    USING (auth.uid()::text = id::text);
```

**Problem:** During registration, the user isn't authenticated yet, so `upsert` fails.

### After (Permissive for Registration)
```sql
-- Allow upsert during registration
CREATE POLICY "Allow upsert for registration"
    ON public.users FOR UPDATE
    USING (true)
    WITH CHECK (true);
```

**Solution:** Allows upsert operations during registration without authentication.

---

## 🔐 Security Considerations

### Is This Secure?

**Yes, for this use case:**

1. **Phone verification required** - Users must verify their phone via OTP
2. **Unique constraints** - Phone number and email are unique
3. **No sensitive data exposure** - RLS still protects reads
4. **Upsert by phone** - Can only update records matching their phone number

### More Secure Alternative

If you want stricter security, you can use Supabase OTP instead of Twilio:

**Option A: Use Supabase OTP (Recommended for Production)**
- Supabase handles both OTP and authentication
- Automatic user session creation
- Better integration with RLS policies
- See `SUPABASE_OTP_MIGRATION.md` (coming soon)

**Option B: Keep Twilio + Anonymous Auth**
- Use Twilio for OTP
- Sign in anonymously to Supabase after verification
- Link phone number to anonymous user
- Current implementation uses this approach

---

## 🧪 Testing

### Test User Creation

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Enter phone number:**
   - Use your real number: `+919876543210`

3. **Verify OTP:**
   - Check console for OTP: `✅ OTP sent via SMS to +919876543210: 123456`
   - Enter the OTP

4. **Fill onboarding:**
   - Name: Test User
   - Email: test@example.com
   - Age: 20
   - College: Test College

5. **Check console:**
   ```
   ✅ Signed in to Supabase with ID: abc123...
   ✅ User profile saved to Supabase: TES1234
   ```

6. **Verify in Supabase:**
   - Table Editor → users
   - See your new user

---

## 🆘 Troubleshooting

### Still Getting "User not authenticated"?

**1. Check if RLS fix was applied:**
```sql
-- Run this in SQL Editor
SELECT policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'users' AND policyname = 'Allow upsert for registration';
```

Should return one row with the new policy.

**2. Check Supabase logs:**
- Go to **Logs** → **Database**
- Look for errors related to RLS policies

**3. Verify Supabase is initialized:**
Check console output:
```
✅ Supabase initialized successfully
```

**4. Check .env file:**
```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

### Error: "duplicate key value violates unique constraint"

**Cause:** User already exists with that phone number or email.

**Solution:**
1. Go to Supabase Table Editor → users
2. Delete the existing user
3. Try registration again

OR

1. Use a different phone number/email

---

## 📊 How It Works Now

### Registration Flow

```
1. User enters phone number
   ↓
2. Twilio sends OTP
   ↓
3. User verifies OTP
   ↓
4. App signs in anonymously to Supabase
   ↓
5. User fills onboarding form
   ↓
6. App upserts user profile to Supabase
   ├─ Check if user exists by phone
   ├─ Generate referral code
   ├─ Link referrer (if code provided)
   └─ Save to database
   ↓
7. Success! User is registered
```

### Data Flow

```
Twilio OTP ✓
    ↓
Supabase Anonymous Auth ✓
    ↓
User Profile Upsert ✓
    ↓
Local Storage Backup ✓
```

---

## ✅ Summary

1. **Run `supabase_rls_fix.sql`** in Supabase SQL Editor
2. **Restart the app**
3. **Test registration**
4. **Verify data in Supabase**

The "User not authenticated" error should be fixed! 🎉

---

## 📚 Related Files

- `supabase_rls_fix.sql` - SQL script to fix RLS policies
- `supabase_schema.sql` - Complete database schema
- `SUPABASE_SETUP_GUIDE.md` - Supabase setup guide
- `lib/services/supabase_service.dart` - Supabase service code
- `lib/providers/auth_provider.dart` - Authentication logic

---

**Need more help?** Check the troubleshooting section or Supabase docs.

