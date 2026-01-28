@echo off
echo ========================================
echo Uptop Careers - Keystore Generator
echo ========================================
echo.
echo This script will generate a keystore for signing your Android app.
echo.
echo IMPORTANT: Save the passwords you enter securely!
echo If you lose them, you won't be able to update your app on Play Store.
echo.
pause

echo.
echo Generating keystore...
echo.

keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

echo.
echo ========================================
echo Keystore generated successfully!
echo ========================================
echo.
echo File location: upload-keystore.jks
echo.
echo NEXT STEPS:
echo 1. Create android/key.properties file with your passwords
echo 2. BACKUP the keystore file securely
echo 3. NEVER commit the keystore to git
echo.
echo Example key.properties content:
echo storePassword=YOUR_KEYSTORE_PASSWORD
echo keyPassword=YOUR_KEY_PASSWORD
echo keyAlias=upload
echo storeFile=../upload-keystore.jks
echo.
pause

