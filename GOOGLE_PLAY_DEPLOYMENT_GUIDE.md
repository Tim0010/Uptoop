# 🚀 Google Play Store Deployment Guide - Uptop Careers

## 📋 Pre-Deployment Checklist

### ✅ Required Items
- [ ] Google Play Developer Account ($25 one-time fee)
- [ ] Release keystore (will be generated)
- [ ] App screenshots (2-8 screenshots)
- [ ] Feature graphic (1024 x 500 px)
- [ ] App icon (512 x 512 px)
- [ ] Privacy Policy URL
- [ ] App description and metadata

---

## 🔐 Step 1: Generate Release Keystore

The keystore is already configured but needs to be generated. Run:

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Use these credentials (already configured in `android/key.properties`):**
- **Keystore Password:** `up(#2026)CAREER`
- **Key Password:** `up(#2026)CAREER`
- **Alias:** `upload`

**When prompted, enter:**
- First and Last Name: `Uptop Careers`
- Organizational Unit: `Development`
- Organization: `Uptop Careers`
- City/Locality: `Your City`
- State/Province: `Your State`
- Country Code: `IN` (for India)

⚠️ **IMPORTANT:** Backup this keystore file securely! If you lose it, you cannot update your app on Play Store.

---

## 📦 Step 2: Build Release App Bundle (AAB)

Google Play requires AAB format (not APK) for new apps.

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release AAB
flutter build appbundle --release
```

The AAB will be created at: `build/app/outputs/bundle/release/app-release.aab`

### Alternative: Build Release APK (for testing)
```bash
flutter build apk --release
```

---

## 📱 Step 3: Test Release Build

Before uploading, test the release build:

```bash
# Install release APK on device
adb install build/app/outputs/flutter-apk/app-release.apk

# Or use bundletool to test AAB
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app.apks
bundletool install-apks --apks=app.apks
```

**Test these critical features:**
- [ ] App launches successfully
- [ ] Deep links work (referral links)
- [ ] Login/Signup flow
- [ ] Referral system end-to-end
- [ ] Payment integration
- [ ] All screens load correctly
- [ ] No crashes or errors

---

## 🎨 Step 4: Prepare Play Store Assets

### Required Assets

#### 1. App Icon (512 x 512 px)
- PNG format, 32-bit
- No transparency
- Full bleed (no padding)

#### 2. Feature Graphic (1024 x 500 px)
- PNG or JPEG
- Showcases app's main feature
- Used in Play Store promotions

#### 3. Screenshots (2-8 required)
- Phone: 16:9 or 9:16 aspect ratio
- Minimum dimension: 320px
- Maximum dimension: 3840px
- PNG or JPEG format

**Recommended screenshots:**
1. Home/Dashboard screen
2. Programs listing
3. Referral system/tracker
4. Application journey
5. Rewards/earnings screen
6. Profile screen

#### 4. App Description

**Short Description (80 characters max):**
```
Refer students to top programs & earn rewards. Campus Ambassador platform.
```

**Full Description (4000 characters max):**
```
🎓 Uptop Careers - Campus Ambassador Program

Become a Campus Ambassador and earn rewards by referring students to top educational programs and career opportunities!

✨ KEY FEATURES:

🔗 Smart Referral System
• Generate unique referral links for any program
• Share via WhatsApp, social media, or direct link
• Track every referral in real-time

💰 Earn Rewards
• ₹500 when referred student pays program fee
• ₹20,000 when student completes enrollment
• Transparent reward tracking

📊 Real-Time Tracking
• Monitor application status of all referrals
• See progress from application to enrollment
• Get notified on status updates

🎯 Wide Range of Programs
• Educational courses
• Skill development programs
• Career opportunities
• Internships and placements

📱 Easy to Use
• Simple, intuitive interface
• One-tap sharing
• Automatic link tracking
• Offline support

🔒 Secure & Reliable
• Secure authentication
• Data privacy protected
• Real-time synchronization

WHO CAN USE:
• College students
• Campus ambassadors
• Career counselors
• Anyone passionate about helping students

HOW IT WORKS:
1. Browse available programs
2. Generate your unique referral link
3. Share with friends and students
4. Track applications and earn rewards
5. Get paid when milestones are reached

Join thousands of campus ambassadors earning while helping students find their dream careers!

Download now and start referring!
```

---

## 🏪 Step 5: Create Play Console Listing

### A. Create Google Play Developer Account
1. Go to https://play.google.com/console
2. Pay $25 one-time registration fee
3. Complete account setup

### B. Create New App
1. Click "Create app"
2. Fill in details:
   - **App name:** Uptop Careers
   - **Default language:** English (United States)
   - **App or game:** App
   - **Free or paid:** Free
3. Accept declarations

### C. Set Up App Details

#### Store Listing
- **App name:** Uptop Careers
- **Short description:** (Use above)
- **Full description:** (Use above)
- **App icon:** Upload 512x512 icon
- **Feature graphic:** Upload 1024x500 graphic
- **Screenshots:** Upload 2-8 screenshots
- **App category:** Education
- **Contact email:** your-email@example.com
- **Privacy policy URL:** (Required - create one)

#### Content Rating
1. Fill out questionnaire
2. Likely rating: Everyone or Teen
3. Submit for rating

#### App Access
- Specify if app requires login
- Provide test credentials if needed

#### Ads
- Declare if app contains ads: No (unless you added ads)

#### Target Audience
- Age groups: 13+ (or as appropriate)
- Appeal to children: No

#### Data Safety
- Declare data collection practices
- Privacy policy required
- Data types: User info, App activity, Device ID

---

## 📤 Step 6: Upload and Release

### A. Upload App Bundle
1. Go to "Production" → "Create new release"
2. Upload `app-release.aab`
3. Add release notes:

```
Initial release of Uptop Careers!

Features:
• Smart referral system with unique links
• Real-time referral tracking
• Earn rewards on successful referrals
• Wide range of educational programs
• Secure authentication and data sync
• Offline support

Start referring and earning today!
```

### B. Review and Rollout
1. Review all sections (must be complete)
2. Set rollout percentage (start with 20% for testing)
3. Click "Start rollout to Production"

### C. Review Process
- Google reviews app (1-7 days typically)
- You'll receive email updates
- May request changes or clarifications

---

## 🔄 Step 7: Post-Launch

### Monitor Performance
- Check crash reports daily
- Monitor user reviews
- Track download metrics
- Respond to user feedback

### Future Updates
```bash
# Update version in pubspec.yaml
version: 1.0.1+2  # Format: version+buildNumber

# Build new AAB
flutter build appbundle --release

# Upload to Play Console
# Create new release with changelog
```

---

## 📝 Important Configuration Details

### Current App Configuration
- **Package Name:** com.uptopcareers.app
- **Version:** 1.0.0+1
- **Min SDK:** Flutter default
- **Target SDK:** Flutter default
- **Permissions:** Internet, Storage, Network State

### Deep Link Configuration
- **Domain:** uptop.careers
- **Path:** /ref/*
- **Scheme:** https, http, uptopcareers

⚠️ **Note:** Ensure domain `uptop.careers` is owned and configured for App Links verification

---

## 🆘 Troubleshooting

### Build Fails
```bash
flutter clean
flutter pub get
flutter build appbundle --release --verbose
```

### Keystore Issues
- Ensure `android/upload-keystore.jks` exists
- Verify `android/key.properties` has correct credentials
- Check file paths are correct

### Upload Rejected
- Check package name is unique
- Ensure all required assets uploaded
- Complete all Play Console sections
- Verify privacy policy URL is accessible

---

## 📞 Support Resources

- **Flutter Deployment:** https://docs.flutter.dev/deployment/android
- **Play Console Help:** https://support.google.com/googleplay/android-developer
- **App Signing:** https://developer.android.com/studio/publish/app-signing

---

## ✅ Final Checklist

Before submitting:
- [ ] Keystore generated and backed up
- [ ] Release AAB built successfully
- [ ] Release build tested on device
- [ ] All screenshots prepared
- [ ] Feature graphic created
- [ ] App icon ready (512x512)
- [ ] Privacy policy URL live
- [ ] App description written
- [ ] Content rating completed
- [ ] Data safety form filled
- [ ] Test credentials provided (if needed)
- [ ] Release notes written
- [ ] All Play Console sections complete

---

🎉 **Ready to deploy!** Follow the steps above to publish Uptop Careers to Google Play Store.

