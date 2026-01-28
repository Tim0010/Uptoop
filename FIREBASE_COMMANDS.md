# 🔥 Firebase Setup - Quick Commands

## 📦 Installation Commands

### Install Firebase CLI
```bash
npm install -g firebase-tools
```

### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Verify Installation
```bash
firebase --version
flutterfire --version
```

## 🔐 Firebase Login

```bash
# Login to Firebase
firebase login

# Check current user
firebase login:list

# Logout
firebase logout
```

## ⚙️ FlutterFire Configuration

### Automatic Configuration (Recommended)
```bash
# Configure Firebase for your Flutter project
flutterfire configure

# This will:
# 1. Show list of your Firebase projects
# 2. Let you select or create a project
# 3. Select platforms (Android, iOS, Web)
# 4. Generate lib/firebase_options.dart
# 5. Download config files
```

### Reconfigure
```bash
# Reconfigure if you need to change settings
flutterfire configure --force
```

## 📱 Flutter Commands

### Get Dependencies
```bash
flutter pub get
```

### Clean Build
```bash
flutter clean
flutter pub get
```

### Run App
```bash
# Run on connected device
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

## 🍎 iOS Commands

### Install Pods
```bash
cd ios
pod install
cd ..
```

### Update Pods
```bash
cd ios
pod update
cd ..
```

### Clean Pods
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Open in Xcode
```bash
open ios/Runner.xcworkspace
```

## 🤖 Android Commands

### Get SHA-1 Certificate (for Google Sign-In)
```bash
cd android
./gradlew signingReport
cd ..
```

### Clean Android Build
```bash
cd android
./gradlew clean
cd ..
```

### Build APK
```bash
flutter build apk
```

### Build App Bundle
```bash
flutter build appbundle
```

## 🔍 Debugging Commands

### Check Flutter Doctor
```bash
flutter doctor
flutter doctor -v
```

### Check Dependencies
```bash
flutter pub deps
```

### Analyze Code
```bash
flutter analyze
```

### Check for Updates
```bash
flutter upgrade
```

## 🔥 Firebase Project Commands

### List Projects
```bash
firebase projects:list
```

### Use Specific Project
```bash
firebase use <project-id>
```

### Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Deploy Storage Rules
```bash
firebase deploy --only storage
```

## 🧪 Testing Commands

### Run Tests
```bash
flutter test
```

### Run Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## 📊 Build Commands

### Build for Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### Build for iOS
```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

## 🔧 Troubleshooting Commands

### Clear Flutter Cache
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### Reset iOS Pods
```bash
cd ios
rm -rf Pods Podfile.lock .symlinks
pod cache clean --all
pod install
cd ..
```

### Reset Android Gradle
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Fix Permission Issues (macOS/Linux)
```bash
sudo gem install cocoapods
sudo chown -R $(whoami) ~/.pub-cache
```

## 📝 Quick Setup Script

Save this as `setup_firebase.sh`:

```bash
#!/bin/bash

echo "🔥 Setting up Firebase for Flutter..."

# Install dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Configure Firebase
echo "⚙️ Configuring Firebase..."
flutterfire configure

# Install iOS pods
echo "🍎 Installing iOS pods..."
cd ios
pod install
cd ..

# Clean and rebuild
echo "🧹 Cleaning project..."
flutter clean
flutter pub get

echo "✅ Firebase setup complete!"
echo "📱 Run 'flutter run' to test your app"
```

Make executable:
```bash
chmod +x setup_firebase.sh
./setup_firebase.sh
```

## 🚀 Quick Start (Copy & Paste)

```bash
# 1. Install tools
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# 2. Login to Firebase
firebase login

# 3. Configure project
flutterfire configure

# 4. Get dependencies
flutter pub get

# 5. Install iOS pods
cd ios && pod install && cd ..

# 6. Run app
flutter run
```

## 📞 Help Commands

```bash
# Flutter help
flutter --help
flutter run --help

# Firebase help
firebase --help
firebase deploy --help

# FlutterFire help
flutterfire --help
flutterfire configure --help
```

---

**Pro Tip**: Save these commands in a text file for quick reference! 💡

