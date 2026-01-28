# 🚀 Temporary Login System - Quick Access Guide

**Date:** 2026-01-18  
**Feature:** OTP-based temporary login without signup

---

## 📋 Overview

The **Temporary Login System** allows users to access the app instantly with just their phone number and OTP verification - **no signup required**! This is perfect for:

- 🔗 Users clicking referral links who want quick access
- 👀 Users who want to browse programs before committing
- ⚡ Reducing friction in the onboarding process
- 📈 Increasing conversion rates from referral links

---

## ✨ Key Features

### 1. **Quick Access Flow**
- User enters phone number
- Receives OTP via SMS
- Verifies OTP
- **Instantly accesses the app** - no name, email, or other details required!

### 2. **Guest Profile Creation**
- Automatically creates a minimal "guest" profile in Supabase
- Stores only: phone number, temporary referral code, referrer info (if applicable)
- Marked with `is_guest: true` flag in database
- Can be upgraded to full account later

### 3. **Seamless Upgrade Path**
- Guest users can complete their profile anytime
- Profile completion unlocks full features (referrals, earnings, etc.)
- No data loss - all activity is preserved

---

## 🔄 User Flow

### **Temporary Access Flow:**

```
1. User clicks referral link
   ↓
2. Welcome Screen shows "Quick Access with OTP" button
   ↓
3. User enters phone number
   ↓
4. OTP sent via Twilio
   ↓
5. User enters OTP
   ↓
6. Guest profile created automatically
   ↓
7. User lands on Main Screen (can browse programs, start applications)
   ↓
8. [Optional] User completes profile later to unlock full features
```

### **Full Signup Flow (Still Available):**

```
1. User clicks "Create Full Account"
   ↓
2. Phone verification (OTP)
   ↓
3. Onboarding screen (name, email, age, college)
   ↓
4. Full profile created
   ↓
5. Main Screen with all features unlocked
```

---

## 🛠️ Technical Implementation

### **Files Modified:**

| File | Changes |
|------|---------|
| `lib/screens/welcome_screen.dart` | Added "Quick Access with OTP" button |
| `lib/screens/otp_auth_screen.dart` | Added `isTemporaryAccess` parameter and guest flow |
| `lib/providers/auth_provider.dart` | Added `createOrGetGuestProfile()` method |
| `lib/services/supabase_service.dart` | Added `createGuestProfile()` method |

---

### **Database Schema:**

**Guest Profile Structure:**
```json
{
  "id": "uuid",
  "phone_number": "+919876543210",
  "full_name": "Guest User",
  "email": "",
  "age": 0,
  "college": "",
  "referral_code": "GST1234",
  "referred_by_code": "ABC5678",
  "referred_by_user_id": "uuid",
  "is_phone_verified": true,
  "is_guest": true,
  "last_login_at": "2026-01-18T10:30:00Z"
}
```

**Note:** You may need to add the `is_guest` column to your `users` table:

```sql
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS is_guest BOOLEAN DEFAULT FALSE;
```

---

### **SharedPreferences Flags:**

When a user logs in via temporary access:

```dart
await prefs.setBool('isAuthenticated', true);
await prefs.setBool('isTemporaryUser', true); // NEW FLAG
await prefs.setString('userId', userId);
await prefs.setBool('keyProfileCompleted', false); // Not completed yet
```

---

## 🎯 How to Use

### **For Users:**

1. **Quick Access:**
   - Click "Quick Access with OTP" on welcome screen
   - Enter phone number
   - Enter OTP
   - Start using the app immediately!

2. **Upgrade to Full Account:**
   - Go to Profile tab
   - Click "Complete Profile"
   - Fill in name, email, age, college
   - Unlock full features (referrals, earnings tracking)

### **For Developers:**

**Check if user is temporary:**
```dart
final prefs = await SharedPreferences.getInstance();
final isTemporary = prefs.getBool('isTemporaryUser') ?? false;

if (isTemporary) {
  // Show "Complete Profile" banner
  // Limit certain features
}
```

**Upgrade guest to full account:**
```dart
// When user completes profile
await authProvider.saveUserProfile(
  fullName: fullName,
  email: email,
  age: age,
  college: college,
);

// Update flags
await prefs.setBool('isTemporaryUser', false);
await prefs.setBool('keyProfileCompleted', true);

// Update database
await SupabaseService.updateUserProfile(userId, {
  'full_name': fullName,
  'email': email,
  'age': age,
  'college': college,
  'is_guest': false,
});
```

---

## 🔐 Security Considerations

1. **Phone Verification:** All users (guest or full) must verify their phone via OTP
2. **One Profile Per Phone:** Duplicate phone numbers are prevented
3. **Referral Tracking:** Guest users can still be tracked for referral rewards
4. **Data Integrity:** Guest profiles can be upgraded without data loss

---

## 📊 Benefits

### **For Users:**
- ⚡ **Instant access** - no lengthy signup forms
- 🎯 **Try before commit** - explore programs first
- 🔄 **Flexible** - upgrade to full account anytime

### **For Business:**
- 📈 **Higher conversion** - reduced friction = more signups
- 🔗 **Better referral performance** - easier for referred users to join
- 💰 **Increased engagement** - users start exploring immediately

---

## 🚀 Next Steps

1. **Add "Complete Profile" Banner:** Show a persistent banner for temporary users
2. **Feature Gating:** Limit certain features (e.g., creating referrals) to full accounts
3. **Analytics:** Track conversion rate from guest → full account
4. **Reminders:** Send notifications encouraging profile completion

---

## ✅ Testing Checklist

- [ ] Test temporary login flow end-to-end
- [ ] Verify guest profile creation in Supabase
- [ ] Test referral link → temporary access flow
- [ ] Test profile upgrade from guest → full account
- [ ] Verify OTP delivery via Twilio
- [ ] Test offline mode (local-only guest profiles)
- [ ] Verify `isTemporaryUser` flag is set correctly

---

**Status:** ✅ **READY FOR TESTING**

