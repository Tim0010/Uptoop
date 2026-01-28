# 🔥 Firebase Integration Checklist

## ✅ Pre-Integration (Already Done)

- [x] Added Firebase dependencies to `pubspec.yaml`
- [x] Updated Android build configuration
- [x] Created iOS Podfile
- [x] Created Firebase options template
- [x] Set minimum SDK to 21 for Android
- [x] Set iOS deployment target to 13.0

## 📱 Step 1: Firebase Console Setup

### Create Firebase Project
- [ ] Go to [Firebase Console](https://console.firebase.google.com/)
- [ ] Click "Add project" or select existing project
- [ ] Enter project name: `uptop-careers` (or your preferred name)
- [ ] Enable Google Analytics (optional)
- [ ] Click "Create project"

### Register Android App
- [ ] In Firebase Console, click "Add app" → Android icon
- [ ] **Android package name**: `com.example.uptop_careers`
- [ ] **App nickname**: `Uptop Careers Android`
- [ ] **Debug signing certificate SHA-1**: (Optional, get from below command)
  ```bash
  cd android
  ./gradlew signingReport
  ```
- [ ] Click "Register app"
- [ ] Download `google-services.json`
- [ ] Place file in `android/app/` directory
- [ ] Click "Next" → "Continue to console"

### Register iOS App
- [ ] In Firebase Console, click "Add app" → iOS icon
- [ ] **iOS bundle ID**: `com.example.uptop_careers`
  - Find in `ios/Runner.xcodeproj/project.pbxproj` (search for PRODUCT_BUNDLE_IDENTIFIER)
- [ ] **App nickname**: `Uptop Careers iOS`
- [ ] **App Store ID**: Leave blank for now
- [ ] Click "Register app"
- [ ] Download `GoogleService-Info.plist`
- [ ] Add to iOS project:
  ```bash
  # Open Xcode
  open ios/Runner.xcworkspace
  
  # Then drag GoogleService-Info.plist into Runner folder
  # Make sure "Copy items if needed" is checked
  # Select Runner target
  ```
- [ ] Click "Next" → "Continue to console"

## 🛠️ Step 2: Install Dependencies

```bash
# Get Flutter packages
flutter pub get

# Install iOS pods
cd ios
pod install
cd ..
```

- [ ] Run `flutter pub get`
- [ ] Run `cd ios && pod install && cd ..`
- [ ] Verify no errors in terminal

## 🔧 Step 3: Configure Firebase (Automatic Method)

### Install Firebase CLI
```bash
npm install -g firebase-tools
```

### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Login to Firebase
```bash
firebase login
```

### Configure FlutterFire
```bash
flutterfire configure
```

This will:
- [ ] Automatically detect your Flutter project
- [ ] Show list of Firebase projects
- [ ] Select platforms (Android, iOS)
- [ ] Generate `lib/firebase_options.dart` with correct configuration
- [ ] Download config files if not already present

## 📝 Step 4: Update main.dart

- [ ] Open `lib/main.dart`
- [ ] Add Firebase initialization (see example below)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

## 🔐 Step 5: Enable Firebase Services

### Firestore Database
- [ ] Go to Firebase Console → Firestore Database
- [ ] Click "Create database"
- [ ] Select "Start in test mode" (for development)
- [ ] Choose location (closest to your users)
- [ ] Click "Enable"

### Authentication
- [ ] Go to Firebase Console → Authentication
- [ ] Click "Get started"
- [ ] Enable sign-in methods:
  - [ ] Email/Password
  - [ ] Phone (if needed)
  - [ ] Google (if needed)

### Storage
- [ ] Go to Firebase Console → Storage
- [ ] Click "Get started"
- [ ] Start in test mode
- [ ] Choose location
- [ ] Click "Done"

### Cloud Messaging (Optional)
- [ ] Go to Firebase Console → Cloud Messaging
- [ ] Note down Server Key for push notifications

## ✅ Step 6: Test Firebase Connection

Create a test file `lib/test_firebase.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirebaseConnection() async {
  try {
    // Test Firestore
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('test').doc('test').set({
      'message': 'Firebase is working!',
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    print('✅ Firebase connected successfully!');
  } catch (e) {
    print('❌ Firebase error: $e');
  }
}
```

- [ ] Run the app: `flutter run`
- [ ] Check console for "✅ Firebase connected successfully!"
- [ ] Check Firestore in Firebase Console for test document

## 🚨 Troubleshooting

### Android Issues

**Error: "Default FirebaseApp is not initialized"**
- [ ] Verify `google-services.json` is in `android/app/`
- [ ] Check `com.google.gms.google-services` plugin is added
- [ ] Run `flutter clean && flutter pub get`

**Error: "Minimum SDK version"**
- [ ] Verify `minSdk = 21` in `android/app/build.gradle.kts`

**Error: "Duplicate class found"**
- [ ] Add `multiDexEnabled = true` in `android/app/build.gradle.kts`

### iOS Issues

**Error: "GoogleService-Info.plist not found"**
- [ ] Open Xcode: `open ios/Runner.xcworkspace`
- [ ] Verify `GoogleService-Info.plist` is in Runner folder
- [ ] Check file is added to Runner target

**Error: "Pod install failed"**
- [ ] Update CocoaPods: `sudo gem install cocoapods`
- [ ] Clean pods: `cd ios && rm -rf Pods Podfile.lock && pod install`

**Error: "Deployment target too low"**
- [ ] Verify `platform :ios, '13.0'` in `ios/Podfile`

## 📊 Verification Checklist

- [ ] App builds successfully on Android
- [ ] App builds successfully on iOS
- [ ] Firebase initializes without errors
- [ ] Can write to Firestore
- [ ] Can read from Firestore
- [ ] Authentication works (if enabled)
- [ ] Storage works (if enabled)

## 🎯 Next Steps After Firebase Setup

1. **Migrate Payment System to Firestore**
   - Replace SharedPreferences with Firestore
   - Real-time payment updates
   - Better admin dashboard

2. **Add Firebase Authentication**
   - Replace current auth with Firebase Auth
   - Phone authentication
   - Email/password authentication

3. **Add Cloud Storage**
   - Store user documents
   - Store payment receipts
   - Profile pictures

4. **Add Push Notifications**
   - Payment verification alerts
   - Offer acceptance notifications
   - Application status updates

## 📞 Support Resources

- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firebase Console](https://console.firebase.google.com)

---

**Current Status**: Ready for Firebase integration! Follow the checklist above. ✅

