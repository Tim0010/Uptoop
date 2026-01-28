# 🚀 Uptop Careers - Play Store Release

## ✅ What's Been Done

Your app has been prepared for Play Store release! Here's what's configured:

### Configuration Updates
- ✅ Application ID changed to `com.uptopcareers.app`
- ✅ App name set to "Uptop Careers"
- ✅ Release signing configuration added
- ✅ ProGuard rules created for code optimization
- ✅ Android permissions configured
- ✅ Backup rules configured
- ✅ `.gitignore` updated to protect sensitive files

### Documentation Created
- ✅ `docs/PLAY_STORE_RELEASE_GUIDE.md` - Complete step-by-step guide
- ✅ `docs/PLAY_STORE_LISTING.md` - Store listing content and metadata
- ✅ `docs/RELEASE_CHECKLIST.md` - Comprehensive checklist
- ✅ `scripts/generate_keystore.bat` - Keystore generation script
- ✅ `scripts/build_release.bat` - Automated build script

## 🎯 Next Steps (In Order)

### Step 1: Generate Keystore (CRITICAL!)

Run the keystore generation script:

```bash
cd scripts
generate_keystore.bat
```

**IMPORTANT:** 
- Save the passwords securely!
- Backup the `upload-keystore.jks` file!
- If you lose these, you CANNOT update your app!

### Step 2: Create key.properties

1. Copy `android/key.properties.template` to `android/key.properties`
2. Fill in your keystore passwords:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

### Step 3: Update Environment Variables

Make sure your `.env` file has production values:

```env
SUPABASE_URL=your_production_supabase_url
SUPABASE_ANON_KEY=your_production_anon_key
RAZORPAY_KEY_ID=your_production_razorpay_key
# ... other production credentials
```

### Step 4: Build Release

Run the build script:

```bash
cd scripts
build_release.bat
```

Or manually:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
flutter build apk --release
```

### Step 5: Test the APK

1. Install the APK on a real device:
   - File: `build/app/outputs/flutter-apk/app-release.apk`
2. Test all features thoroughly
3. Verify no crashes or bugs

### Step 6: Prepare Play Store Assets

Create the following graphics:

1. **App Icon** (512x512 PNG)
   - Export from your existing icon

2. **Feature Graphic** (1024x500 PNG)
   - Create promotional banner

3. **Screenshots** (1080x1920 pixels, minimum 2)
   - Welcome screen
   - Programs listing
   - Application journey
   - Referral tracking
   - Wallet
   - Profile

### Step 7: Create Play Console Account

1. Go to https://play.google.com/console
2. Pay $25 one-time registration fee
3. Complete developer profile
4. Set up payment and tax information

### Step 8: Prepare Legal Documents

Create and publish:

1. **Privacy Policy**
   - Host at: `https://www.uptopcareers.com/privacy-policy`
   - Must be publicly accessible

2. **Terms of Service**
   - Host at: `https://www.uptopcareers.com/terms`

### Step 9: Upload to Play Console

1. Create new app in Play Console
2. Complete all required sections:
   - App details
   - Store listing
   - Content rating
   - Data safety
   - Pricing & distribution
3. Upload `build/app/outputs/bundle/release/app-release.aab`
4. Add release notes
5. Submit for review

### Step 10: Monitor & Launch

1. Wait for review (1-7 days)
2. Respond to any review questions
3. Once approved, app goes live!
4. Monitor crash reports and reviews

## 📚 Documentation

- **Complete Guide:** `docs/PLAY_STORE_RELEASE_GUIDE.md`
- **Checklist:** `docs/RELEASE_CHECKLIST.md`
- **Store Listing:** `docs/PLAY_STORE_LISTING.md`

## ⚠️ Important Warnings

### 🔴 NEVER COMMIT THESE FILES:
- `upload-keystore.jks`
- `android/key.properties`
- `.env` (with production credentials)

### 🔴 BACKUP THESE FILES:
- `upload-keystore.jks` (CRITICAL!)
- Keystore passwords
- Production `.env` file

### 🔴 BEFORE BUILDING:
- Test thoroughly on real devices
- Remove all debug code
- Use production API credentials
- Verify all features work

## 🆘 Need Help?

1. Check `docs/PLAY_STORE_RELEASE_GUIDE.md` for detailed instructions
2. Review `docs/RELEASE_CHECKLIST.md` for step-by-step checklist
3. Visit Play Console Help: https://support.google.com/googleplay/android-developer
4. Flutter deployment docs: https://docs.flutter.dev/deployment/android

## 📞 Support

- **Email:** support@uptopcareers.com
- **Play Console:** https://play.google.com/console
- **Flutter Docs:** https://docs.flutter.dev

---

**Ready to publish? Follow the steps above in order!** 🚀

Good luck with your Play Store launch!

