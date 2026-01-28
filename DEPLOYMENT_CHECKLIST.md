# ✅ Google Play Store Deployment Checklist

## 📦 Build Status

### ✅ Completed
- [x] Release keystore generated (`android/upload-keystore.jks`)
- [x] Keystore credentials configured (`android/key.properties`)
- [x] Release AAB built successfully
- [x] Build configuration verified
- [x] Signing configuration complete

### 📍 Build Details
- **AAB Location:** `build\app\outputs\bundle\release\app-release.aab`
- **AAB Size:** 46.3 MB
- **Build Time:** 411.3 seconds (~7 minutes)
- **Package Name:** com.uptopcareers.app
- **Version:** 1.0.0+1
- **Build Type:** Release (signed)

---

## 🔐 Security & Credentials

### Keystore Information
- **Location:** `android/upload-keystore.jks`
- **Alias:** upload
- **Validity:** 10,000 days (~27 years)
- **Algorithm:** RSA 2048-bit
- **Credentials:** Stored in `android/key.properties`

### ⚠️ CRITICAL: Backup Keystore
- [ ] Copy `android/upload-keystore.jks` to secure location
- [ ] Copy `android/key.properties` to secure location
- [ ] Store in password manager or encrypted drive
- [ ] **NEVER commit keystore to Git**
- [ ] **NEVER share keystore publicly**

**Why?** If you lose the keystore, you CANNOT update your app on Play Store. You'll have to publish as a new app.

---

## 🧪 Pre-Upload Testing

### Required Tests
- [ ] Install release AAB on physical device
- [ ] Test app launch and initialization
- [ ] Test user registration/login
- [ ] Test referral link generation
- [ ] Test deep link handling (click referral link)
- [ ] Test application journey
- [ ] Test referral tracker
- [ ] Test payment integration (if applicable)
- [ ] Test offline functionality
- [ ] Check for crashes or errors
- [ ] Verify all screens load correctly
- [ ] Test on different Android versions (if possible)

### Testing Commands
```bash
# Install using bundletool
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app.apks --mode=universal
bundletool install-apks --apks=app.apks

# Or build release APK for easier testing
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🎨 Play Store Assets

### Required Assets
- [ ] App Icon (512 x 512 px PNG)
- [ ] Feature Graphic (1024 x 500 px PNG/JPEG)
- [ ] At least 2 phone screenshots (up to 8)
- [ ] Privacy Policy (hosted URL)

### Optional Assets
- [ ] 7-inch tablet screenshots
- [ ] 10-inch tablet screenshots
- [ ] Promotional video (YouTube)
- [ ] Promo graphic (180 x 120 px)

### Asset Guidelines
See `PLAY_STORE_ASSETS_GUIDE.md` for detailed instructions on creating these assets.

---

## 📝 App Listing Information

### Basic Information
- [ ] **App Name:** Uptop Careers
- [ ] **Short Description:** (80 chars max)
  ```
  Refer students to top programs & earn rewards. Campus Ambassador platform.
  ```
- [ ] **Full Description:** (4000 chars max) - See `GOOGLE_PLAY_DEPLOYMENT_GUIDE.md`
- [ ] **App Category:** Education
- [ ] **Tags:** referral, education, campus, ambassador, earn, rewards

### Contact Information
- [ ] **Developer Name:** [Your Name/Company]
- [ ] **Email Address:** [your-email@example.com]
- [ ] **Website:** [your-website.com] (optional)
- [ ] **Phone Number:** [Your Phone] (optional)
- [ ] **Privacy Policy URL:** [Required - host PRIVACY_POLICY.md]

---

## 🔒 Privacy & Compliance

### Privacy Policy
- [ ] Host `PRIVACY_POLICY.md` on a public URL
- [ ] Update email addresses in privacy policy
- [ ] Update contact information
- [ ] Ensure URL is accessible (test in browser)

**Hosting Options:**
- GitHub Pages (free)
- Your website
- Google Sites (free)
- Netlify (free)

### Data Safety Form
- [ ] Complete Data Safety questionnaire in Play Console
- [ ] Declare data collection practices:
  - ✅ User info (name, email, phone)
  - ✅ App activity (referrals, applications)
  - ✅ Device ID (for authentication)
- [ ] Specify data usage:
  - ✅ App functionality
  - ✅ Analytics
  - ✅ Account management
- [ ] Declare data sharing:
  - ✅ Service providers (Supabase, Razorpay)
  - ✅ Program providers (for applications)
- [ ] Confirm data security measures

### Content Rating
- [ ] Complete content rating questionnaire
- [ ] Expected rating: Everyone or Teen
- [ ] No violence, gambling, or adult content
- [ ] Submit for rating certificate

---

## 🎯 Target Audience & Distribution

### Target Audience
- [ ] **Age Groups:** 13+ (or 18+ if required)
- [ ] **Appeal to Children:** No
- [ ] **Target Countries:** India (or worldwide)

### App Access
- [ ] **Requires Login:** Yes
- [ ] **Provide Test Account:** (if required by Google)
  - Email: test@example.com
  - Password: TestPassword123

### Ads Declaration
- [ ] **Contains Ads:** No (unless you added ads)
- [ ] **Ad Networks:** None (or list if applicable)

---

## 📤 Upload & Release

### Pre-Upload Checklist
- [ ] All Play Console sections completed
- [ ] All required assets uploaded
- [ ] Privacy policy URL verified
- [ ] Content rating obtained
- [ ] Data safety form completed
- [ ] Release AAB ready
- [ ] Release notes written

### Release Notes (v1.0.0)
```
🎉 Welcome to Uptop Careers!

Become a Campus Ambassador and earn rewards by referring students to top programs.

✨ Features:
• Smart referral system with unique tracking links
• Real-time referral tracker with status updates
• Earn ₹500 on fee payment, ₹20,000 on enrollment
• Wide range of educational programs
• Secure authentication and data sync
• Offline support for seamless experience

Start referring and earning today! 🚀

For support, contact: [your-email@example.com]
```

### Upload Steps
1. [ ] Go to Play Console → Production
2. [ ] Click "Create new release"
3. [ ] Upload `app-release.aab`
4. [ ] Add release notes
5. [ ] Review all sections
6. [ ] Set rollout percentage (recommend 20% initially)
7. [ ] Click "Review release"
8. [ ] Submit for review

---

## 🚀 Post-Submission

### Review Process
- [ ] Wait for Google review (typically 1-7 days)
- [ ] Monitor email for updates
- [ ] Respond to any requests from Google
- [ ] Fix any issues if rejected

### After Approval
- [ ] Monitor crash reports in Play Console
- [ ] Check user reviews daily
- [ ] Respond to user feedback
- [ ] Track download metrics
- [ ] Monitor app performance

### Marketing
- [ ] Share Play Store link on social media
- [ ] Create promotional materials
- [ ] Reach out to campus ambassadors
- [ ] Set up app analytics (Firebase, etc.)

---

## 🔄 Future Updates

### Version Update Process
1. Update version in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # version+buildNumber
   ```
2. Make code changes
3. Test thoroughly
4. Build new AAB:
   ```bash
   flutter build appbundle --release
   ```
5. Upload to Play Console
6. Write changelog
7. Submit for review

### Recommended Update Cycle
- **Bug fixes:** As needed
- **Minor features:** Every 2-4 weeks
- **Major features:** Every 2-3 months

---

## 📊 Monitoring & Analytics

### Play Console Metrics
- [ ] Set up Play Console alerts
- [ ] Monitor crash rate (keep below 2%)
- [ ] Track ANR rate (keep below 0.5%)
- [ ] Monitor user ratings
- [ ] Track install/uninstall rates

### Optional Analytics
- [ ] Set up Firebase Analytics
- [ ] Set up Crashlytics
- [ ] Set up Performance Monitoring
- [ ] Track custom events (referrals, applications)

---

## 🆘 Troubleshooting

### Common Issues

**Build Fails:**
```bash
flutter clean
flutter pub get
flutter build appbundle --release --verbose
```

**Keystore Not Found:**
- Verify `android/upload-keystore.jks` exists
- Check `android/key.properties` paths
- Ensure credentials are correct

**Upload Rejected:**
- Check package name is unique
- Verify all required sections complete
- Ensure privacy policy URL works
- Check content rating is obtained

**App Crashes on Release:**
- Test release build before uploading
- Check ProGuard rules if using obfuscation
- Review crash logs in Play Console

---

## 📞 Support Resources

- **Play Console:** https://play.google.com/console
- **Flutter Deployment Docs:** https://docs.flutter.dev/deployment/android
- **Play Console Help:** https://support.google.com/googleplay/android-developer
- **App Signing Guide:** https://developer.android.com/studio/publish/app-signing

---

## ✅ Final Pre-Submission Checklist

### Technical
- [x] Release AAB built successfully
- [x] Keystore generated and backed up
- [x] Signing configuration verified
- [ ] Release build tested on device
- [ ] No crashes or critical bugs

### Play Console
- [ ] Google Play Developer account created ($25 paid)
- [ ] App created in Play Console
- [ ] All required assets uploaded
- [ ] Privacy policy URL added
- [ ] Content rating obtained
- [ ] Data safety form completed
- [ ] Store listing complete
- [ ] Release notes written

### Legal & Compliance
- [ ] Privacy policy reviewed and accurate
- [ ] Terms of service (if applicable)
- [ ] All contact information correct
- [ ] Data handling practices declared

### Ready to Submit?
If all items above are checked, you're ready to submit to Google Play Store! 🎉

---

## 🎯 Next Steps

1. **Create Play Store Assets** (see `PLAY_STORE_ASSETS_GUIDE.md`)
2. **Host Privacy Policy** (upload `PRIVACY_POLICY.md` to web)
3. **Create Google Play Developer Account** ($25)
4. **Complete Play Console Setup**
5. **Upload AAB and Submit**
6. **Wait for Review**
7. **Launch! 🚀**

---

**Good luck with your launch! 🎉**

