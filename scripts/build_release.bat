@echo off
echo ========================================
echo Uptop Careers - Release Build Script
echo ========================================
echo.

REM Change to project root if we're in scripts directory
if exist "build_release.bat" (
    cd ..
)

REM Check if key.properties exists
if not exist "android\key.properties" (
    echo ERROR: android\key.properties not found!
    echo.
    echo Please create it from android\key.properties.template
    echo and fill in your keystore credentials.
    echo.
    pause
    exit /b 1
)

REM Check if keystore exists
if not exist "upload-keystore.jks" (
    echo ERROR: upload-keystore.jks not found!
    echo.
    echo Please run scripts\generate_keystore.bat first
    echo to create your keystore.
    echo.
    pause
    exit /b 1
)

echo All prerequisites found!
echo.
echo Starting build process...
echo.

REM Clean previous builds
echo [1/4] Cleaning previous builds...
call flutter clean
if errorlevel 1 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b 1
)

REM Get dependencies
echo.
echo [2/4] Getting dependencies...
call flutter pub get
if errorlevel 1 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)

REM Build App Bundle (AAB)
echo.
echo [3/4] Building App Bundle (AAB)...
call flutter build appbundle --release
if errorlevel 1 (
    echo ERROR: App Bundle build failed!
    pause
    exit /b 1
)

REM Build APK (for testing)
echo.
echo [4/4] Building APK (for testing)...
call flutter build apk --release
if errorlevel 1 (
    echo ERROR: APK build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo.
echo Output files:
echo - App Bundle (for Play Store): build\app\outputs\bundle\release\app-release.aab
echo - APK (for testing): build\app\outputs\flutter-apk\app-release.apk
echo.
echo NEXT STEPS:
echo 1. Test the APK on a real device
echo 2. Upload the AAB to Google Play Console
echo 3. Complete the Play Store listing
echo 4. Submit for review
echo.
echo See docs\PLAY_STORE_RELEASE_GUIDE.md for detailed instructions.
echo.
pause

