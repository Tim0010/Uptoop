# Troubleshooting: Application Data Not Saving to Database

## 🔍 Issue Analysis

Based on the logs, I can see:

### ✅ What's Working:
1. **Application IS being created in Supabase**
   - Log shows: `✅ Application created in Supabase with ID: 6c0078fd-4460-4072-8827-a47c2ecb5022`
   - This means the initial creation is successful

2. **Update request IS being sent**
   - Log shows: `🔄 Updating application in Supabase: 6c0078fd-4460-4072-8827-a47c2ecb5022`
   - Log shows: `📤 Sending update to Supabase...`

### ❌ Potential Issues:

1. **Network Connectivity Problem**
   - Log shows: `❌ Error getting user profile: ClientException with SocketException: Failed host lookup: 'hndxhixadfhrgfrkshjy.supabase.co'`
   - This suggests intermittent network issues or incorrect Supabase URL

2. **Update Completion Not Logged**
   - We see "📤 Sending update to Supabase..." but NOT "✅ Application updated in Supabase"
   - This could mean the update is failing silently

3. **setState During Build Error**
   - Fixed in latest code update
   - Was causing UI issues but shouldn't prevent database saves

---

## 🛠️ Step-by-Step Troubleshooting

### Step 1: Verify Supabase Configuration

1. **Check your `.env` file:**
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

2. **Verify the URL is correct:**
   - Go to your Supabase project dashboard
   - Settings → API
   - Copy the **Project URL** (should NOT contain typos like 'hndxhixadfhrgfrkshjy')

3. **Hot restart the app** after fixing .env:
   ```
   Press 'R' in the terminal (capital R for full restart)
   ```

---

### Step 2: Check Supabase Dashboard

1. **Go to Supabase Dashboard** → **Table Editor** → **applications**

2. **Look for the application ID from logs:**
   - ID: `6c0078fd-4460-4072-8827-a47c2ecb5022`
   - If you see this row, the creation worked!

3. **Check the row data:**
   - `stage` column - should show 'invited' or 'application_started'
   - `full_name`, `father_name`, `mother_name` - check if these are populated after you save
   - `stage_history` - should be a JSONB array

4. **If the row exists but fields are NULL:**
   - The creation worked but updates are failing
   - Continue to Step 3

5. **If the row doesn't exist at all:**
   - Check if you're looking at the right Supabase project
   - Check if RLS (Row Level Security) policies are blocking inserts
   - Continue to Step 4

---

### Step 3: Test Update Manually

1. **Fill in the personal information form**
2. **Click "Save & Continue"**
3. **Watch the console logs carefully:**

   **Expected logs:**
   ```
   💾 Saving application data:
      ID: 6c0078fd-4460-4072-8827-a47c2ecb5022
      Full Name: [your name]
      Father Name: [father name]
      Mother Name: [mother name]
      ...
      Stage: personal_info_submitted
      Progress: 30%
   
   🔄 Updating application in Supabase: 6c0078fd-4460-4072-8827-a47c2ecb5022
      Stage: personal_info_submitted
      Progress: 30%
   
   📤 Sending update to Supabase...
   
   ✅ Application updated in Supabase: 6c0078fd-4460-4072-8827-a47c2ecb5022
      Response: [...]
   ```

4. **If you see "❌ Error updating application":**
   - Copy the full error message
   - Check if it's a network error, permission error, or validation error

5. **Immediately check Supabase dashboard:**
   - Refresh the applications table
   - Check if the `full_name`, `father_name`, `mother_name` fields are populated
   - Check if `stage` changed to 'personal_info_submitted'

---

### Step 4: Check RLS Policies

Row Level Security (RLS) policies might be blocking updates.

1. **Go to Supabase Dashboard** → **Authentication** → **Policies**

2. **Check `applications` table policies:**

   **Required policies:**
   ```sql
   -- Allow users to insert their own applications
   CREATE POLICY "Users can insert own applications"
   ON applications FOR INSERT
   WITH CHECK (auth.uid() = user_id);

   -- Allow users to update their own applications
   CREATE POLICY "Users can update own applications"
   ON applications FOR UPDATE
   USING (auth.uid() = user_id);

   -- Allow users to select their own applications
   CREATE POLICY "Users can view own applications"
   ON applications FOR SELECT
   USING (auth.uid() = user_id);
   ```

3. **If policies are missing or incorrect:**
   - Go to **SQL Editor**
   - Run the policy creation SQL above
   - Test again

---

### Step 5: Check Database Schema

1. **Verify the `applications` table has all required columns:**
   - `id` (uuid)
   - `user_id` (uuid)
   - `program_id` (uuid)
   - `referral_id` (uuid, nullable)
   - `stage` (text) ← **Important for granular tracking**
   - `stage_history` (jsonb) ← **Important for history**
   - `full_name` (text)
   - `father_name` (text)
   - `mother_name` (text)
   - `gender` (text)
   - `date_of_birth` (date)
   - `address_line1` (text)
   - `city` (text)
   - `state` (text)
   - ... and all other fields

2. **If `stage` or `stage_history` columns are missing:**
   - Run the migration: `supabase/migrations/add_granular_stage_tracking.sql`
   - Or manually add them in SQL Editor

---

### Step 6: Enable Detailed Logging

The app already has detailed logging. To see ALL logs:

1. **Clear the terminal:** Press 'c'
2. **Fill the form and save**
3. **Copy ALL the logs** from the terminal
4. **Share the logs** so I can identify the exact issue

---

## 🎯 Quick Diagnostic Checklist

- [ ] Supabase URL in `.env` is correct (no typos)
- [ ] Hot restarted app after fixing `.env` (Press 'R')
- [ ] Application row exists in Supabase `applications` table
- [ ] RLS policies allow INSERT and UPDATE for authenticated users
- [ ] `stage` and `stage_history` columns exist in `applications` table
- [ ] Console shows "✅ Application updated in Supabase" after saving
- [ ] Supabase dashboard shows updated data after refreshing

---

## 🆘 If Still Not Working

**Share the following information:**

1. **Console logs** from creating application to saving first section
2. **Screenshot** of Supabase applications table (showing the row or empty table)
3. **Screenshot** of RLS policies for applications table
4. **Confirmation** that `.env` file has correct Supabase URL

This will help me pinpoint the exact issue!

