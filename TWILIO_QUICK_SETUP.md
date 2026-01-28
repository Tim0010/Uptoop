# ⚡ Twilio Quick Setup - 5 Minutes

## 🎯 Quick Start (Recommended: Twilio Verify API)

### Step 1: Get Twilio Credentials (2 minutes)

1. Go to https://console.twilio.com/
2. Copy these 3 values:
   - **Account SID** (starts with AC...)
   - **Auth Token** (click to reveal)
   - **Verify Service SID** (create at https://console.twilio.com/us1/develop/verify/services)

### Step 2: Configure .env File (1 minute)

Open `.env` file and paste your credentials:

```env
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_VERIFY_SERVICE_SID=VAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Step 3: Run the App (1 minute)

```bash
flutter pub get
flutter run
```

### Step 4: Test (1 minute)

1. Enter your phone number (with country code: +919876543210)
2. Click "Send OTP"
3. Check your phone for SMS
4. Enter OTP
5. Done! 🎉

---

## 🔧 Alternative: Regular SMS Method

### Step 1: Get Twilio Credentials

1. Go to https://console.twilio.com/
2. Copy:
   - **Account SID**
   - **Auth Token**
3. Get a phone number:
   - Go to Phone Numbers → Buy a number
   - Choose one with SMS capability
   - Copy the number (e.g., +1234567890)

### Step 2: Configure .env File

```env
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+1234567890
```

### Step 3: Switch to SMS Mode

Open `lib/providers/auth_provider.dart` and change:

```dart
bool _useTwilioVerify = false; // Change true to false
```

### Step 4: Run and Test

```bash
flutter pub get
flutter run
```

---

## 🧪 Testing Without Twilio (Development Mode)

Don't want to set up Twilio yet? No problem!

1. **Leave .env empty** (or don't fill in credentials)
2. **Run the app:**
   ```bash
   flutter run
   ```
3. **Check console for OTP:**
   ```
   🔐 [DEV MODE] OTP sent to +919876543210: 123456
   ```
4. **Enter the OTP from console**

---

## 📋 Checklist

### For Twilio Verify API:
- [ ] Created Twilio account
- [ ] Got Account SID
- [ ] Got Auth Token
- [ ] Created Verify Service
- [ ] Got Verify Service SID
- [ ] Updated .env file
- [ ] Ran `flutter pub get`
- [ ] Tested with real phone number

### For Regular SMS:
- [ ] Created Twilio account
- [ ] Got Account SID
- [ ] Got Auth Token
- [ ] Bought Twilio phone number
- [ ] Updated .env file
- [ ] Changed `_useTwilioVerify` to `false`
- [ ] Ran `flutter pub get`
- [ ] Tested with real phone number

---

## ⚠️ Important Notes

### Trial Account Limitations:
- Can only send to verified phone numbers
- Add your test numbers at: https://console.twilio.com/us1/develop/phone-numbers/manage/verified

### Phone Number Format:
- Always use E.164 format: `+[country code][number]`
- India: `+919876543210`
- US: `+11234567890`

### Free Credits:
- New accounts get $15 free credit
- ~500 SMS in India
- ~1000 SMS in US
- Perfect for testing!

---

## 🆘 Quick Troubleshooting

### "Twilio not configured"
→ Check .env file has credentials

### "Invalid phone number"
→ Use format: +919876543210

### "Unverified number" (Trial account)
→ Verify number at: https://console.twilio.com/us1/develop/phone-numbers/manage/verified

### SMS not received
→ Check Twilio console logs: https://console.twilio.com/us1/monitor/logs/sms

### .env not loading
→ Run `flutter pub get` and restart app

---

## 📚 Full Documentation

For detailed information, see:
- `TWILIO_INTEGRATION_GUIDE.md` - Complete integration guide
- `OTP_ONBOARDING_IMPLEMENTATION.md` - OTP system documentation

---

## 🎉 That's It!

You're ready to send real OTPs! 🚀

**Need help?** Check the full guide or Twilio docs.

