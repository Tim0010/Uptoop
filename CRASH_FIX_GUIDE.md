# 🔧 App Crash Fix Guide

## ✅ Fixes Applied

### 1. ProGuard/R8 Configuration
**Problem:** Code minification was breaking reflection-based libraries (Supabase, Razorpay)

**Solution:**
- ✅ Added comprehensive ProGuard rules in `android/app/proguard-rules.pro`
- ✅ Temporarily disabled minification to test (`isMinifyEnabled = false`)
- ✅ Added rules for:
  - Flutter framework
  - Supabase & Ktor
  - Razorpay payment gateway
  - Kotlinx Serialization
  - OkHttp & networking
  - JSON libraries (Gson)
  - All model classes

### 2. Environment Configuration
**Problem:** .env file not included in release builds

**Solution:**
- ✅ Created `lib/config/env_config.dart` with compiled environment variables
- ✅ Updated `SupabaseService` to use fallback config
- ✅ App now works with or without .env file

### 3. Initialization Error Handling
**Problem:** App crashes if Supabase or other services fail to initialize

**Solution:**
- ✅ Added try-catch blocks around all service initialization
- ✅ App continues in offline mode if services fail
- ✅ Better error logging with stack traces
- ✅ Prevents repeated initialization attempts

### 4. Android Permissions
**Problem:** Missing permissions for Android 13+

**Solution:**
- ✅ Added `READ_MEDIA_IMAGES` and `READ_MEDIA_VIDEO` permissions
- ✅ Updated storage permissions with proper SDK version limits
- ✅ Added `requestLegacyExternalStorage` flag

### 5. App Orientation
**Problem:** Potential layout issues with landscape mode

**Solution:**
- ✅ Locked app to portrait mode
- ✅ Prevents rotation-related crashes

---

## 🧪 Testing the Fix

### Step 1: Clean Build
```bash
flutter clean
flutter pub get
```

### Step 2: Build Release APK
```bash
flutter build apk --release
```

### Step 3: Install on Device
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Step 4: Check Logs
```bash
# View crash logs
adb logcat | grep -i "flutter\|crash\|error\|exception"

# Or use Flutter logs
flutter logs
```

### Step 5: Test App Functions
- [ ] App launches successfully
- [ ] No immediate crashes
- [ ] Login/signup works
- [ ] Navigation works
- [ ] Referral system works
- [ ] Deep links work

---

## 🔍 Debugging Crashes

### Get Crash Logs from Device

#### Method 1: Using ADB
```bash
# Clear old logs
adb logcat -c

# Start app and capture logs
adb logcat > crash_log.txt

# Filter for errors
adb logcat *:E > errors.txt
```

#### Method 2: Using Flutter
```bash
flutter logs > flutter_crash.txt
```

#### Method 3: From Play Console
1. Go to Play Console → Quality → Crashes & ANRs
2. View crash reports
3. Download stack traces

### Common Crash Patterns

#### 1. ClassNotFoundException
**Symptom:** `java.lang.ClassNotFoundException: com.example.Class`

**Cause:** ProGuard removed the class

**Fix:** Add to `proguard-rules.pro`:
```
-keep class com.example.Class { *; }
```

#### 2. NoSuchMethodError
**Symptom:** `java.lang.NoSuchMethodError: No method 'methodName'`

**Cause:** ProGuard obfuscated method names

**Fix:** Add to `proguard-rules.pro`:
```
-keepclassmembers class com.example.Class {
    public <methods>;
}
```

#### 3. NullPointerException on Startup
**Symptom:** App crashes immediately on launch

**Cause:** Service initialization failure

**Fix:** Check initialization in `main.dart` - already fixed!

#### 4. MissingPluginException
**Symptom:** `MissingPluginException(No implementation found for method...)`

**Cause:** Plugin not registered or ProGuard removed it

**Fix:** Add to `proguard-rules.pro`:
```
-keep class io.flutter.plugins.** { *; }
```

---

## 📊 Crash Analysis Checklist

### Before Submitting to Play Store
- [ ] Test on multiple devices (different Android versions)
- [ ] Test on Android 11, 12, 13, 14
- [ ] Test with slow internet connection
- [ ] Test in airplane mode (offline)
- [ ] Test all major features
- [ ] Check Play Console pre-launch report
- [ ] Review crash-free rate (should be >99%)

### If Crashes Persist

1. **Disable Minification Completely**
   - Already done in `build.gradle.kts`
   - Test if crashes stop

2. **Check Specific Library Issues**
   - Supabase: Check initialization logs
   - Razorpay: Verify API keys
   - Deep Links: Test link handling

3. **Add More Logging**
   ```dart
   try {
     // risky code
   } catch (e, stackTrace) {
     debugPrint('Error: $e');
     debugPrint('Stack: $stackTrace');
   }
   ```

4. **Use Firebase Crashlytics**
   - Add crashlytics for better crash reporting
   - Get detailed stack traces

---

## 🚀 Next Steps

### Option 1: Test Without Minification (Recommended First)
The current build has minification **disabled**. This will:
- ✅ Prevent ProGuard-related crashes
- ✅ Make debugging easier
- ✅ Increase APK size (~10-20MB larger)
- ❌ Slightly slower app performance

**Action:** Build and test now!

### Option 2: Re-enable Minification (After Testing)
Once app works without minification:
1. Set `isMinifyEnabled = true` in `build.gradle.kts`
2. Set `isShrinkResources = true`
3. Build and test again
4. If crashes return, add more ProGuard rules

---

## 📝 Build Commands

### Clean Build (Recommended)
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Build AAB for Play Store
```bash
flutter build appbundle --release
```

### Install and Test
```bash
# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Or install AAB (requires bundletool)
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app.apks --mode=universal
bundletool install-apks --apks=app.apks
```

### View Logs While Testing
```bash
# Terminal 1: Install and run app
adb install build/app/outputs/flutter-apk/app-release.apk
adb shell am start -n com.uptopcareers.app/.MainActivity

# Terminal 2: Watch logs
adb logcat | grep -E "flutter|AndroidRuntime|FATAL"
```

---

## ✅ What Was Changed

### Files Modified
1. ✅ `android/app/proguard-rules.pro` - Comprehensive ProGuard rules
2. ✅ `android/app/build.gradle.kts` - Disabled minification
3. ✅ `lib/config/env_config.dart` - NEW: Compiled environment config
4. ✅ `lib/services/supabase_service.dart` - Better error handling
5. ✅ `lib/main.dart` - Improved initialization
6. ✅ `android/app/src/main/AndroidManifest.xml` - Updated permissions

### No Changes Needed
- ❌ Don't modify `pubspec.yaml`
- ❌ Don't change package name
- ❌ Don't update dependencies yet

---

## 🎯 Expected Results

After rebuilding with these fixes:
- ✅ App should launch without crashes
- ✅ All features should work
- ✅ Offline mode should work
- ✅ Deep links should work
- ✅ Payments should work

---

## 🆘 If Still Crashing

### Get Detailed Crash Report
```bash
# Get full crash log
adb logcat -d > full_crash_log.txt

# Get only errors
adb logcat -d *:E > errors_only.txt

# Get Flutter-specific logs
adb logcat -d | grep -i flutter > flutter_log.txt
```

### Share These Files
1. `full_crash_log.txt`
2. `errors_only.txt`
3. Screenshot of crash (if visible)
4. Device info (Android version, manufacturer)

---

## 📱 Test Devices Recommended

### Minimum Testing
- Android 11 (API 30)
- Android 12 (API 31)
- Android 13 (API 33)
- Android 14 (API 34)

### Recommended Devices
- Samsung Galaxy (One UI)
- Google Pixel (Stock Android)
- Xiaomi/Redmi (MIUI)
- OnePlus (OxygenOS)

---

## 🔄 Re-enabling Minification Later

When ready to optimize app size:

1. **Edit `android/app/build.gradle.kts`:**
   ```kotlin
   isMinifyEnabled = true
   isShrinkResources = true
   ```

2. **Build and test:**
   ```bash
   flutter build apk --release
   ```

3. **If crashes return:**
   - Check crash logs
   - Identify missing ProGuard rules
   - Add rules to `proguard-rules.pro`
   - Rebuild and test

---

**Ready to rebuild and test! 🚀**

