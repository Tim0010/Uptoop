# Application & Referral Tracker Integration

## 🎯 Overview

This document explains how the Application Journey system is integrated with the Referral Tracker to automatically sync application progress with referral status in real-time.

## 🔗 How It Works

### Architecture

```
User fills Application Journey
         ↓
ApplicationProvider.updateApplication()
         ↓
ApplicationReferralSyncService.syncApplicationToReferral()
         ↓
UserDataService.updateReferralStatus()
         ↓
SupabaseService updates database
         ↓
ReferralTracker displays updated status
```

### Status Mapping

The system automatically maps application progress to referral statuses:

| Application Stage | Referral Status | Description |
|------------------|-----------------|-------------|
| Application created | `invited` | Friend was invited |
| Personal info saved | `application_started` | Application in progress |
| Documents submitted | `documents` | Documents uploaded |
| Application fee paid | `fee_paid` | Fee payment completed |
| Enrollment confirmed | `enrolled` | Student enrolled |

## 📁 Files Modified

### 1. Application Model (`lib/models/application.dart`)
- ✅ Added `referralId` field to link applications with referrals
- ✅ Added `getReferralStatus()` method to get current referral status

### 2. Application Provider (`lib/providers/application_provider.dart`)
- ✅ Updated `createApplication()` to accept optional `referralId`
- ✅ Updated `updateApplication()` to auto-sync with referral tracker
- ✅ Syncs only when significant progress is made

### 3. Application Journey Screen (`lib/screens/application_journey_screen.dart`)
- ✅ Updated to accept optional `referralId` parameter
- ✅ Passes `referralId` when creating new applications

### 4. Application Referral Sync Service (`lib/services/application_referral_sync_service.dart`)
- ✅ New service to handle syncing logic
- ✅ Maps application stages to referral statuses
- ✅ Calculates reward amounts
- ✅ Provides reward messages

## 🚀 Usage

### Creating an Application with Referral Link

```dart
final application = await appProvider.createApplication(
  programId: 'prog_123',
  userId: 'user_456',
  referralId: 'ref_789', // Link to referral
);
```

### Automatic Syncing

When you update an application, it automatically syncs with the referral:

```dart
// Update application
final updatedApp = application.copyWith(
  documentsSubmitted: true,
);

// This automatically syncs with referral tracker
await appProvider.updateApplication(updatedApp);
```

### Manual Syncing

You can also manually sync if needed:

```dart
final success = await ApplicationReferralSyncService.syncApplicationToReferral(
  application,
);
```

## 📊 Status Flow Example

1. **User starts application**
   - Referral status: `invited`
   - Reward: ₹0

2. **User fills personal info**
   - Referral status: `application_started`
   - Reward: ₹0

3. **User submits documents**
   - Referral status: `documents`
   - Reward: ₹0

4. **User pays application fee**
   - Referral status: `fee_paid`
   - Reward: ₹500 💰

5. **User confirms enrollment**
   - Referral status: `enrolled`
   - Reward: ₹20,000 💰💰💰

## 🎨 UI Integration

### ReferralTracker Widget

The `ReferralTracker` widget automatically displays the correct status based on the referral's current status:

```dart
ReferralTracker(
  friendName: 'John Doe',
  programName: 'MBA - Harvard University',
  currentStatus: 'documents', // Automatically updated
  earning: 500.0,
)
```

### Progress Steps

The tracker shows 5 steps:
1. **Invited** - Friend invited
2. **Applied** - Application started
3. **Docs** - Documents submitted
4. **Enrolled** - Fee paid
5. **Done!** - Enrollment confirmed

## 🔄 Real-time Updates

### How Updates Work

1. User saves a section in Application Journey
2. `ApplicationProvider.updateApplication()` is called
3. Service checks if status changed using `shouldSyncToReferral()`
4. If changed, syncs to database in background
5. ReferralTracker reads updated status from database
6. UI updates automatically

### Performance Optimization

- ✅ Syncs only when significant progress is made
- ✅ Runs in background (non-blocking)
- ✅ Handles errors gracefully
- ✅ Logs all sync operations for debugging

## 🧪 Testing

### Test Scenarios

1. **Create application with referral**
   - Verify referral status is `invited`

2. **Fill personal info**
   - Verify referral status updates to `application_started`

3. **Submit documents**
   - Verify referral status updates to `documents`

4. **Pay application fee**
   - Verify referral status updates to `fee_paid`
   - Verify reward is ₹500

5. **Confirm enrollment**
   - Verify referral status updates to `enrolled`
   - Verify reward is ₹20,000

## 📝 Next Steps

To complete the integration:

1. **Update Program Details Popup** to pass referralId when navigating to Application Journey
2. **Add referral creation** when user shares a program
3. **Link shared referrals** to applications when friend signs up
4. **Test end-to-end flow** from sharing to enrollment

## 🐛 Debugging

Enable debug logs to see sync operations:

```dart
// In ApplicationReferralSyncService
debugPrint('🔄 Syncing application ${application.id} to referral ${application.referralId}');
debugPrint('   Status: $status, Stage: $applicationStage, Completed: $isCompleted');
```

Look for these log messages:
- ✅ `Referral status synced successfully`
- ❌ `Failed to sync referral status`
- ⚠️ `No referral ID linked to this application`

## 💡 Tips

- Always pass `referralId` when creating applications from referral links
- The system handles all syncing automatically
- Check logs if status doesn't update
- Referral status updates are non-blocking and won't affect user experience

