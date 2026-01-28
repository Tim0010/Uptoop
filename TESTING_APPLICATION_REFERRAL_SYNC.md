# Testing Application & Referral Sync

## 🧪 Test Plan

### Prerequisites
- Supabase configured and running
- User logged in
- At least one program available

## Test Scenarios

### Scenario 1: Create Application with Referral Link

**Steps:**
1. Create a referral in the database
2. Navigate to a program
3. Start application with referralId
4. Check database for referral status

**Expected Result:**
- Application created with `referralId` field populated
- Referral status updated to `invited`
- No errors in console

**Code to Test:**
```dart
final appProvider = context.read<ApplicationProvider>();
final app = await appProvider.createApplication(
  programId: 'test_program_id',
  userId: 'test_user_id',
  referralId: 'test_referral_id',
);

print('Application created: ${app.id}');
print('Linked to referral: ${app.referralId}');
```

---

### Scenario 2: Update Personal Information

**Steps:**
1. Create application with referralId
2. Fill personal information (name, father's name, etc.)
3. Save personal info section
4. Check referral status in database

**Expected Result:**
- Application updated with personal info
- Referral status changed from `invited` to `application_started`
- Console shows: `✅ Referral status synced successfully`

**Code to Test:**
```dart
final updatedApp = app.copyWith(
  fullName: 'John Doe',
  fatherName: 'Father Name',
  motherName: 'Mother Name',
);

await appProvider.updateApplication(updatedApp);
// Check logs for sync message
```

---

### Scenario 3: Submit Documents

**Steps:**
1. Continue from Scenario 2
2. Upload required documents
3. Mark documents as submitted
4. Check referral status

**Expected Result:**
- Application updated with `documentsSubmitted: true`
- Referral status changed to `documents`
- Console shows sync success message

**Code to Test:**
```dart
final updatedApp = app.copyWith(
  documentsSubmitted: true,
  profilePictureUrl: 'path/to/profile.jpg',
  marksheet10thUrl: 'path/to/10th.pdf',
);

await appProvider.updateApplication(updatedApp);
```

---

### Scenario 4: Pay Application Fee

**Steps:**
1. Continue from Scenario 3
2. Complete payment process
3. Mark application fee as paid
4. Check referral status and reward

**Expected Result:**
- Application updated with `applicationFeePaid: true`
- Referral status changed to `fee_paid`
- Referral reward updated to ₹500
- Console shows sync success message

**Code to Test:**
```dart
final updatedApp = app.copyWith(
  applicationFeePaid: true,
);

await appProvider.updateApplication(updatedApp);

// Check reward
final reward = ApplicationReferralSyncService.getRewardAmount(updatedApp);
print('Reward: ₹$reward'); // Should be 500
```

---

### Scenario 5: Confirm Enrollment

**Steps:**
1. Continue from Scenario 4
2. Confirm enrollment
3. Check referral status and final reward

**Expected Result:**
- Application updated with `enrollmentConfirmed: true`
- Referral status changed to `enrolled`
- Referral reward updated to ₹20,000
- Referral marked as completed
- Console shows sync success message

**Code to Test:**
```dart
final updatedApp = app.copyWith(
  enrollmentConfirmed: true,
);

await appProvider.updateApplication(updatedApp);

// Check reward
final reward = ApplicationReferralSyncService.getRewardAmount(updatedApp);
print('Reward: ₹$reward'); // Should be 20000
```

---

### Scenario 6: Application Without Referral

**Steps:**
1. Create application without referralId
2. Update application
3. Check console logs

**Expected Result:**
- Application created successfully
- No sync attempts made
- Console shows: `⚠️ No referral ID linked to this application`

**Code to Test:**
```dart
final app = await appProvider.createApplication(
  programId: 'test_program_id',
  userId: 'test_user_id',
  // No referralId
);

final updatedApp = app.copyWith(fullName: 'Test User');
await appProvider.updateApplication(updatedApp);
// Should not attempt to sync
```

---

## 🔍 Verification Checklist

### Database Checks

After each scenario, verify in Supabase:

```sql
-- Check referral status
SELECT id, status, application_stage, reward_amount, is_completed
FROM referrals
WHERE id = 'test_referral_id';

-- Check application
SELECT id, referral_id, full_name, documents_submitted, 
       application_fee_paid, enrollment_confirmed
FROM applications
WHERE id = 'test_application_id';
```

### Console Log Checks

Look for these messages:

✅ Success messages:
- `🔄 Syncing application {id} to referral {referralId}`
- `   Status: {status}, Stage: {stage}, Completed: {bool}`
- `✅ Referral status synced successfully`

⚠️ Warning messages:
- `⚠️ No referral ID linked to this application`
- `⚠️ Failed to sync referral: {error}`

❌ Error messages:
- `❌ Error syncing application to referral: {error}`
- `❌ Failed to sync referral status`

---

## 🎯 Manual Testing Steps

### Step-by-Step UI Test

1. **Setup**
   - Login to the app
   - Navigate to Refer screen
   - Select a program

2. **Create Referral**
   - Share program link
   - Note the referral ID created

3. **Start Application**
   - Open program details
   - Click "Start Application"
   - Verify application journey opens

4. **Fill Personal Info**
   - Enter all required fields
   - Click "Save & Continue"
   - Check Referrals tab - status should be "Application in progress"

5. **Upload Documents**
   - Upload all required documents
   - Click "Save & Continue"
   - Check Referrals tab - status should be "Documents submitted"

6. **Pay Fee**
   - Complete payment
   - Check Referrals tab - status should be "Fee paid"
   - Verify earning shows ₹500

7. **Confirm Enrollment**
   - Accept terms and conditions
   - Confirm enrollment
   - Check Referrals tab - status should be "Enrolled - You earned!"
   - Verify earning shows ₹20,000

---

## 📊 Expected Results Summary

| Stage | Referral Status | Reward | Application Field |
|-------|----------------|--------|-------------------|
| Created | `invited` | ₹0 | `referralId` set |
| Personal Info | `application_started` | ₹0 | `fullName` filled |
| Documents | `documents` | ₹0 | `documentsSubmitted: true` |
| Fee Paid | `fee_paid` | ₹500 | `applicationFeePaid: true` |
| Enrolled | `enrolled` | ₹20,000 | `enrollmentConfirmed: true` |

---

## 🐛 Common Issues

### Issue 1: Status Not Updating
**Cause:** Supabase not configured
**Solution:** Check `SupabaseService.isConfigured`

### Issue 2: Sync Errors
**Cause:** Invalid referralId
**Solution:** Verify referral exists in database

### Issue 3: No Logs Appearing
**Cause:** Debug mode not enabled
**Solution:** Run app in debug mode

---

## ✅ Success Criteria

All tests pass if:
- ✅ Applications can be created with referralId
- ✅ Referral status updates automatically
- ✅ Rewards are calculated correctly
- ✅ No errors in console
- ✅ UI reflects correct status
- ✅ Database shows correct data

