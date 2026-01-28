@echo off
echo ========================================
echo Setting up App Signing
echo ========================================
echo.

REM Move keystore to project root
if exist "upload-keystore.jks" (
    echo Moving keystore to project root...
    move upload-keystore.jks ..
    echo Keystore moved successfully!
) else if exist "..\upload-keystore.jks" (
    echo Keystore already in project root.
) else (
    echo ERROR: Keystore not found!
    echo Please run generate_keystore.bat first.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Creating key.properties file
echo ========================================
echo.
echo Please enter your keystore password (the one you just created):
set /p STORE_PASSWORD=Keystore Password: 

echo.
echo Please enter your key password (usually same as keystore password):
set /p KEY_PASSWORD=Key Password: 

echo.
echo Creating android\key.properties...

(
echo storePassword=%STORE_PASSWORD%
echo keyPassword=%KEY_PASSWORD%
echo keyAlias=upload
echo storeFile=../upload-keystore.jks
) > ..\android\key.properties

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Files created:
echo - upload-keystore.jks (in project root)
echo - android\key.properties
echo.
echo IMPORTANT: Backup these files securely!
echo.
echo Next step: Run build_release.bat
echo.
pause

