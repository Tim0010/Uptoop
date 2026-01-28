# User Name Display Fix

## Problem
After signing in, the main screen was showing "Hey User!" instead of "Hey Timothy!" (the actual user's name).

## Root Cause
The issue was in `lib/services/user_data_service.dart` in the `getCurrentUserProfile()` method.

### What Was Happening:

1. User signs in with phone number ✅
2. System creates anonymous Supabase user (ID: `8c8237b6-c255-4821-8997-288c97e5dafd`) ✅
3. System finds existing profile by phone (ID: `bc189084-b9ab-4df4-9a37-7df03efd5bb1`) ✅
4. System updates `userId` in SharedPreferences to the actual user ID ✅
5. **BUT** when loading user data, `getCurrentUserProfile()` was using the **anonymous user ID** instead of the **actual user ID** ❌
6. No profile found for anonymous ID → Falls back to local storage → Shows "User" as default name ❌

### The Bug:

<augment_code_snippet path="lib/services/user_data_service.dart" mode="EXCERPT">
````dart
// BEFORE (Broken)
if (SupabaseService.isConfigured && SupabaseService.isAuthenticated) {
  final userId = SupabaseService.currentUser?.id;  // ❌ This is the anonymous ID!
  if (userId != null) {
    return await SupabaseService.getUserProfile(userId);
  }
}
````
</augment_code_snippet>

## Solution

Changed the method to:
1. **First** get the actual user ID from SharedPreferences
2. **Then** use that ID to query Supabase
3. Fall back to local storage if needed

### The Fix:

<augment_code_snippet path="lib/services/user_data_service.dart" mode="EXCERPT">
````dart
// AFTER (Fixed)
// Get userId from SharedPreferences (this is the actual user ID)
final prefs = await SharedPreferences.getInstance();
final userId = prefs.getString('userId');

if (userId == null) return null;

// Try Supabase using the actual user ID
if (SupabaseService.isConfigured && SupabaseService.isAuthenticated) {
  final profile = await SupabaseService.getUserProfile(userId);
  if (profile != null) return profile;
}
````
</augment_code_snippet>

## How It Works Now

### For Existing Users:
1. User enters phone and verifies OTP ✅
2. System finds existing profile by phone ✅
3. System updates `userId` in SharedPreferences to actual user ID ✅
4. System calls `loadUserData()` ✅
5. `getCurrentUserProfile()` reads actual user ID from SharedPreferences ✅
6. Queries Supabase with actual user ID ✅
7. Finds profile and returns it ✅
8. Main screen shows "Hey Timothy!" ✅

### For New Users:
1. User enters phone and verifies OTP ✅
2. No existing profile found ✅
3. User completes onboarding ✅
4. Profile saved to Supabase with new user ID ✅
5. `userId` saved to SharedPreferences ✅
6. Main screen shows correct name ✅

## Testing

After this fix, you should see:

```
🔍 Loading user profile for ID: bc189084-b9ab-4df4-9a37-7df03efd5bb1
📡 Supabase configured: true
🔐 Supabase authenticated: true
✅ Loaded profile from Supabase: Timothy
```

And the main screen should display:
```
Hey, Timothy! 👋
```

## Files Changed

1. **`lib/services/user_data_service.dart`**
   - Fixed `getCurrentUserProfile()` to use actual user ID from SharedPreferences
   - Added comprehensive debug logging

## Related Fixes

This fix works together with the previous sign-in fix:
1. **RLS Policy Fix** - Allows phone number lookup
2. **Sign-in Flow Fix** - Updates user ID when existing user signs in
3. **User Data Loading Fix** - Uses correct user ID to load profile ✅

## Summary

The issue was a mismatch between:
- **Anonymous Supabase Auth ID** (temporary, created during OTP verification)
- **Actual User Profile ID** (permanent, stored in database)

The fix ensures we always use the **actual user profile ID** from SharedPreferences when loading user data, not the temporary anonymous auth ID.

