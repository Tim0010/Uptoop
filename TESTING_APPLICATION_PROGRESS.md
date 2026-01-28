# 🧪 Testing Application Progress - Step by Step

## ✅ Test Scenario 1: Progress Updates on Each Step

### Steps:
1. **Open the app** - Navigate to Refer screen
2. **Click a program card** - Any program from the grid
3. **Click "Start Application"** - Opens Application Journey Screen
4. **Fill Personal Information:**
   - Full Name: "John Doe"
   - Email: "john@example.com"
   - Phone: "9876543210"
5. **Observe Progress Bar:**
   - Should show **20%** (1 of 5 steps complete)
6. **Click "Continue"** - Move to Documents step
7. **Check Documents:**
   - Mark "Government ID uploaded" ✓
   - Mark "Latest marksheet uploaded" ✓
8. **Observe Progress Bar:**
   - Should show **40%** (2 of 5 steps complete)
9. **Click "Continue"** - Move to Enrollment step
10. **Confirm Enrollment:**
    - Mark "I confirm I want to enroll" ✓
11. **Observe Progress Bar:**
    - Should show **60%** (3 of 5 steps complete)
12. **Click "Continue"** - Move to Payment step
13. **Pay Application Fee:**
    - Click "Pay ₹500 (mock)"
    - Wait 2 seconds for mock payment
14. **Observe Progress Bar:**
    - Should show **80%** (4 of 5 steps complete)
15. **Click "Continue"** - Move to Enrollment Fee step
16. **Pay Enrollment Fee:**
    - Click "Pay Enrollment Fee (mock)"
    - Wait 2 seconds for mock payment
17. **Observe Progress Bar:**
    - Should show **100%** (5 of 5 steps complete)
18. **Click "Submit Application"** - Submit the application
19. **Verify Completion:**
    - Should see "Great job!" message
    - Status should be "Submitted"

## ✅ Test Scenario 2: Resume Application

### Steps:
1. **Complete Test Scenario 1** - Get to 100% progress
2. **Close the application** - Click "Close" button
3. **Go back to Refer screen** - Navigate back
4. **Click the same program card** - Same program as before
5. **Observe Popup:**
   - Button should say "Continue Application" (not "Start Application")
6. **Click "Continue Application"** - Resume the application
7. **Verify Data Loaded:**
   - All previous data should be loaded
   - Progress should show **100%**
8. **Verify Status:**
   - Application status should be "Submitted"

## ✅ Test Scenario 3: Multiple Applications

### Steps:
1. **Start Application 1:**
   - Click program card A
   - Fill in personal info (20%)
   - Click "Continue"
   - Click "Back" to go back
2. **Start Application 2:**
   - Click program card B
   - Fill in personal info (20%)
   - Click "Continue"
   - Fill in documents (40%)
   - Click "Back" to go back
3. **Resume Application 1:**
   - Click program card A
   - Should show "Continue Application"
   - Progress should be 20%
   - Data should be loaded
4. **Resume Application 2:**
   - Click program card B
   - Should show "Continue Application"
   - Progress should be 40%
   - Data should be loaded

## ✅ Test Scenario 4: Data Persistence

### Steps:
1. **Start Application:**
   - Click program card
   - Fill in personal info
   - Progress shows 20%
2. **Close the app** - Completely close the browser/app
3. **Reopen the app** - Start the app again
4. **Go to Refer screen** - Navigate to Refer
5. **Click same program card** - Same program as before
6. **Verify:**
   - Button should say "Continue Application"
   - Progress should still be 20%
   - Data should be loaded

## ✅ Test Scenario 5: Progress Bar Visual

### Expected Behavior:
- Progress bar should be **smooth** and **continuous**
- Progress percentage should **match** the number of completed steps
- Progress bar should **fill from left to right**
- Color should be **blue** (AppTheme.primaryBlue)

### Visual Checkpoints:
- 0% - Empty bar (no steps complete)
- 20% - 1/5 filled (personal info complete)
- 40% - 2/5 filled (documents complete)
- 60% - 3/5 filled (enrollment complete)
- 80% - 4/5 filled (app fee complete)
- 100% - Full bar (all steps complete)

## 🐛 Troubleshooting

### Issue: Progress bar not updating
**Solution:**
1. Check browser console for errors
2. Verify ApplicationProvider is in MultiProvider
3. Check that _refreshApplicationData() is being called
4. Clear browser cache and reload

### Issue: Data not persisting
**Solution:**
1. Check SharedPreferences is working
2. Verify _saveApplications() is being called
3. Check browser storage settings
4. Try clearing app data and restarting

### Issue: Progress shows wrong percentage
**Solution:**
1. Check progressPercentage calculation in Application model
2. Verify all 5 steps are being counted
3. Check that _application is being refreshed
4. Verify setState() is being called

## ✅ Checklist

- [ ] Progress bar updates on each step
- [ ] Progress percentage is correct (20%, 40%, 60%, 80%, 100%)
- [ ] Data persists when closing and reopening app
- [ ] Multiple applications can be tracked
- [ ] Resume functionality works
- [ ] Progress bar visual is smooth
- [ ] No errors in console
- [ ] Application can be submitted
- [ ] Status changes to "Submitted"

## 📊 Expected Results

| Step | Progress | Status |
|------|----------|--------|
| Personal Info | 20% | Draft |
| Documents | 40% | Draft |
| Enrollment | 60% | Draft |
| App Fee | 80% | Draft |
| Enrollment Fee | 100% | Draft |
| Submit | 100% | Submitted |

---

**Last Updated:** December 2024
**Version:** 1.0

