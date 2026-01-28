# 🔍 Referral Linking Debug Guide

## Current Issue

The referral is created successfully, but when the referred user signs up, the referral is not being linked. The `referred_user_id` remains `null`.

**Example:**
```json
{
  "id": "6d9b62ba-1861-40c9-a4ce-7c24e198a58a",
  "referrer_id": "c5bca7bd-51ef-44d3-88b0-5eb79c4a63c7",
  "referred_user_id": null,  // ❌ Should be Ackim's ID
  "referred_name": "Invited Friend",  // ❌ Should be "Ackim Mulenga"
  "referred_email": null,  // ❌ Should be Ackim's email
  "referred_phone": null,  // ❌ Should be Ackim's phone
  "referred_college": null  // ❌ Should be Ackim's college
}
```

---

## Possible Root Causes

### 1. **Row Level Security (RLS) Policy Issue**

The Supabase RLS policies might be preventing the app from reading the referral record.

**Check in Supabase Dashboard:**
1. Go to **Authentication** → **Policies**
2. Find the `referrals` table
3. Check if there's a SELECT policy that allows reading referrals by `id`

**Expected Policy:**
```sql
-- Allow users to read referrals by ID (for linking)
CREATE POLICY "Users can read referrals by ID"
ON referrals FOR SELECT
USING (true);  -- Or: auth.uid() IS NOT NULL

-- Allow users to update referrals they're referred to
CREATE POLICY "Users can update their own referrals"
ON referrals FOR UPDATE
USING (referred_user_id = auth.uid() OR id IN (
  SELECT id FROM referrals WHERE id = id
));
```

### 2. **Timing Issue - Referral Not Yet in Database**

The referral might not be committed to the database yet when the referred user clicks the link.

**Solution:** Add a small delay or retry logic when checking for referral existence.

### 3. **Deep Link Not Capturing Referral ID**

The deep link might not be properly capturing the `referralId` parameter.

**Check Logs:**
- Look for: `✅ Referral link detected:`
- Should show: `Referral ID: xxx-xxx-xxx`

### 4. **User ID Not Available When Linking**

The `_userId` might be `null` when `_linkPendingReferral()` is called.

**Check Logs:**
- Look for: `🔍 Checking for pending referral...`
- Should show: `User ID: xxx-xxx-xxx` (not null)

---

## Debug Steps

### Step 1: Check RLS Policies

Run this SQL in Supabase SQL Editor:

```sql
-- Check existing policies on referrals table
SELECT * FROM pg_policies WHERE tablename = 'referrals';

-- If no SELECT policy exists, create one
CREATE POLICY "Allow reading referrals by ID" ON referrals
FOR SELECT USING (true);

-- If no UPDATE policy exists, create one
CREATE POLICY "Allow updating referrals" ON referrals
FOR UPDATE USING (true);
```

### Step 2: Test Referral Linking Manually

Run this SQL to manually link a referral:

```sql
-- Update the referral with Ackim's information
UPDATE referrals
SET 
  referred_user_id = 'ACKIM_USER_ID_HERE',
  referred_name = 'Ackim Mulenga',
  referred_email = 'ackim@example.com',
  referred_phone = '+919239654874',
  referred_college = 'University Name'
WHERE id = '6d9b62ba-1861-40c9-a4ce-7c24e198a58a';

-- Verify the update
SELECT * FROM referrals WHERE id = '6d9b62ba-1861-40c9-a4ce-7c24e198a58a';
```

### Step 3: Check Logs for Complete Flow

**Peter's side (referrer):**
```
✅ Referral created: Invited Friend
✅ Referral created in Supabase with ID: 6d9b62ba-1861-40c9-a4ce-7c24e198a58a
🔗 Generated referral link: https://uptop.careers/ref/PET3547?referralId=6d9b62ba-1861-40c9-a4ce-7c24e198a58a&programId=xxx
```

**Ackim's side (referred user):**
```
✅ Referral link detected:
   Referral ID: 6d9b62ba-1861-40c9-a4ce-7c24e198a58a
   Program ID: xxx
🔍 Checking for pending referral...
   Pending Referral ID: 6d9b62ba-1861-40c9-a4ce-7c24e198a58a
   User ID: ACKIM_USER_ID
   User Name: Ackim Mulenga
🔗 Linking referral 6d9b62ba-1861-40c9-a4ce-7c24e198a58a to user ACKIM_USER_ID
🔍 Checking if referral exists: 6d9b62ba-1861-40c9-a4ce-7c24e198a58a
✅ Referral found: 6d9b62ba-1861-40c9-a4ce-7c24e198a58a
   Referrer: PETER_USER_ID
   Current referred_user_id: null
✅ Referral linked to user: ACKIM_USER_ID
```

### Step 4: Fresh Test with Enhanced Logging

1. **Delete both users from database**
2. **Restart both apps**
3. **Peter creates account and shares link**
4. **Ackim clicks link and signs up**
5. **Check logs for the complete flow above**
6. **Check database to verify `referred_user_id` is populated**

---

## Expected vs Actual

| Field | Expected | Actual | Status |
|-------|----------|--------|--------|
| `referred_user_id` | Ackim's UUID | `null` | ❌ |
| `referred_name` | "Ackim Mulenga" | "Invited Friend" | ❌ |
| `referred_email` | Ackim's email | `null` | ❌ |
| `referred_phone` | "+919239654874" | `null` | ❌ |
| `referred_college` | Ackim's college | `null` | ❌ |

---

## Next Actions

1. ✅ **Check RLS policies** in Supabase
2. ✅ **Run fresh test** with enhanced logging
3. ✅ **Share complete logs** from both Peter and Ackim
4. ✅ **Verify referral exists** in database before linking attempt

