# Application Data Sync Verification Guide

## Overview
This guide helps you verify that application data is being properly saved to the Supabase database at each stage of the application journey.

---

## ✅ What Gets Saved to Database

### 1. **Application Creation** (Stage: `invited`)
When a user clicks "Start Application", the following is saved:
- `user_id` - UUID of the user
- `program_id` - UUID of the program
- `referral_id` - UUID of the referral (if applicable)
- `status` - 'draft'
- `stage` - 'invited'
- `progress` - 0
- `documents_submitted` - false
- `application_fee_paid` - false
- `enrollment_confirmed` - false

**Database Table:** `applications`

---

### 2. **Personal Information Saved** (Stage: `personal_info_submitted`)
When user clicks "Save & Continue" on Personal Info section:
- `full_name` - Candidate's full name
- `father_name` - Father's name
- `mother_name` - Mother's name
- `gender` - Gender (male/female/other)
- `date_of_birth` - Date of birth
- `aadhar_number` - 12-digit Aadhaar number (if provided)
- `stage` - 'personal_info_submitted'
- `progress` - 30%
- `personal_info_submitted_at` - Timestamp (auto-set by trigger)

**Stage History:** Automatically updated by PostgreSQL trigger

---

### 3. **Academic Information Saved** (Stage: `academic_info_submitted`)
When user clicks "Save & Continue" on Academic Info section:
- `address_line1` - Address
- `city` - City
- `state` - State
- `country` - Country
- `pincode` - PIN code
- `stage` - 'academic_info_submitted'
- `progress` - 50%
- `academic_info_submitted_at` - Timestamp (auto-set by trigger)

---

### 4. **Documents Submitted** (Stage: `documents_submitted`)
When user uploads and saves documents:
- `photo_url` - Profile picture URL
- `id_proof_url` - Photo ID URL
- `qualification_certificate_url` - 10th marksheet URL
- `documents_submitted` - true
- `stage` - 'documents_submitted'
- `progress` - 70%
- `documents_submitted_at` - Timestamp (auto-set by trigger)

---

### 5. **Application Fee Paid** (Stage: `application_fee_paid`)
When user completes payment:
- `application_fee_paid` - true
- `payment_transaction_id` - Transaction ID
- `payment_date` - Payment timestamp
- `stage` - 'application_fee_paid'
- `progress` - 85%
- `application_fee_paid_at` - Timestamp (auto-set by trigger)

---

### 6. **Application Submitted** (Stage: `application_submitted`)
When user submits final application:
- `status` - 'submitted'
- `stage` - 'application_submitted'
- `progress` - 100%
- `submitted_at` - Submission timestamp
- `application_submitted_at` - Timestamp (auto-set by trigger)

---

## 🔍 How to Verify Data is Being Saved

### Step 1: Enable Debug Logging
The app now has enhanced logging. Watch the console for these messages:

```
💾 Saving application data:
   ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   Full Name: John Doe
   Email: john@example.com
   Phone: +919876543210
   Father Name: Father Name
   Mother Name: Mother Name
   Gender: male
   DOB: 2000-01-01
   Address: 123 Main St
   City: Mumbai
   State: Maharashtra
   Documents Submitted: false
   Fee Paid: false
   Stage: personal_info_submitted
   Progress: 30%

✅ Application successfully synced to Supabase database
```

### Step 2: Check Supabase Dashboard
1. Go to your Supabase project dashboard
2. Navigate to **Table Editor** → **applications**
3. Find the application by `user_id` or `id`
4. Verify all fields are populated correctly

### Step 3: Check Stage History
In Supabase, check the `stage_history` JSONB column:
```json
[
  {
    "stage": "personal_info_submitted",
    "timestamp": "2026-01-21T10:30:00Z",
    "previous_stage": "invited"
  },
  {
    "stage": "academic_info_submitted",
    "timestamp": "2026-01-21T10:35:00Z",
    "previous_stage": "personal_info_submitted"
  }
]
```

### Step 4: Verify Referral Sync
If the application is linked to a referral, check the `referrals` table:
- `application_stage` should match the application's `stage`
- `status` should be updated based on progress
- `updated_at` should reflect the latest change

---

## 🧪 Testing Checklist

- [ ] Create new application → Check `applications` table has new row
- [ ] Save personal info → Verify `full_name`, `father_name`, `mother_name`, `gender`, `date_of_birth` are saved
- [ ] Save academic info → Verify `address_line1`, `city`, `state`, `country`, `pincode` are saved
- [ ] Upload documents → Verify `photo_url`, `id_proof_url`, `qualification_certificate_url` are saved
- [ ] Check stage progression → Verify `stage` column updates correctly
- [ ] Check stage history → Verify `stage_history` JSONB array is populated
- [ ] Check referral sync → Verify `referrals.application_stage` matches `applications.stage`
- [ ] Check timestamps → Verify `personal_info_submitted_at`, `academic_info_submitted_at`, etc. are set

---

## 🐛 Troubleshooting

### Issue: Data not saving to Supabase
**Check:**
1. Supabase is configured (check `.env` file)
2. User is authenticated
3. Application ID is a valid UUID
4. Check console for error messages

### Issue: Stage not updating
**Check:**
1. `calculateCurrentStage()` method is being called
2. Stage is being set in `copyWith(stage: calculatedStage)`
3. `getApplicationStageString()` returns correct database value

### Issue: Referral not syncing
**Check:**
1. Application has `referralId` set
2. `ApplicationReferralSyncService.syncApplicationToReferral()` is being called
3. Referral exists in database
4. RLS policies allow update

---

## 📊 Database Schema Reference

### Applications Table Key Columns
- `id` (UUID) - Primary key
- `user_id` (UUID) - Foreign key to users
- `program_id` (UUID) - Foreign key to programs
- `referral_id` (UUID) - Foreign key to referrals (nullable)
- `status` (TEXT) - draft, in_progress, submitted, accepted, rejected
- `stage` (TEXT) - invited, application_started, personal_info_submitted, etc.
- `stage_history` (JSONB) - Array of stage transitions
- `progress` (INT) - 0-100%

### Automatic Triggers
1. **update_application_stage_history** - Adds entry to `stage_history` when `stage` changes
2. **set_updated_at** - Updates `updated_at` timestamp on any change

