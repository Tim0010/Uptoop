# 🔧 Enable Anonymous Authentication in Supabase

## ⚠️ Current Error

```
❌ Error signing in anonymously: AuthApiException(message: Anonymous sign-ins are disabled, statusCode: 422, code: anonymous_provider_disabled)
```

## ✅ Solution: Enable Anonymous Auth

### Step 1: Go to Supabase Dashboard

1. Open https://app.supabase.com/
2. Select your project
3. Go to **Authentication** (left sidebar)
4. Click **Providers**

### Step 2: Enable Anonymous Sign-In

1. Scroll down to **"Anonymous Sign-In"**
2. Toggle it **ON** (enable it)
3. Click **"Save"**

### Step 3: Restart Your App

```bash
# Press 'q' to quit
flutter run
```

### Step 4: Test Registration

The anonymous auth error should be gone! ✅

---

## 🎯 What This Does

**Anonymous authentication** allows users to:
- Create a Supabase session without email/password
- Save data to the database
- Later link their account to phone/email

**Perfect for:**
- Phone OTP flows (like yours!)
- Guest users
- Progressive onboarding

---

## 🔐 Security

**Is this secure?**

✅ **Yes!** Because:
1. Users still verify phone via OTP
2. RLS policies protect data access
3. Anonymous users are linked to phone numbers
4. Can't access other users' data

---

**After enabling, restart the app and try registration again!**

