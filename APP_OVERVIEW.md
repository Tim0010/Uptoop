# 📱 Uptop Careers - App Overview

**Version**: 1.0.0  
**Platform**: Android (Flutter)  
**Package**: com.uptopcareers.app  
**Last Updated**: January 10, 2026

---

## 🎯 What is Uptop Careers?

Uptop Careers is a **referral-based education platform** that allows users to earn money by referring students to university programs. Users can browse educational programs, refer friends, track their earnings, and participate in gamified challenges.

---

## 🌟 Key Features

### 1. **User Authentication**
- 📱 Phone number-based OTP authentication
- 🔐 Secure login with Supabase backend
- 👤 User profile management
- 🎁 Welcome bonus for new users (₹100)
- 🔗 Referral code system for inviting friends

### 2. **Program Browsing & Referrals**
- 🎓 Browse university programs (MBA, BBA, etc.)
- 📊 View program details (duration, mode, fees)
- 💰 See earning potential for each referral
- 📤 Share programs with friends
- 🔗 Generate unique referral links
- 📋 Track referral status and progress

### 3. **Application Journey**
- 📝 Multi-step application process
- 👨‍👩‍👧 Personal information collection
- 🎓 Academic information
- 📄 Document upload system
- 💳 Application fee payment (Razorpay integration)
- ✅ Terms & conditions acceptance
- 💾 Auto-save progress (works offline)

### 4. **Wallet & Earnings**
- 💰 Track total earnings
- 📊 View transaction history
- 💸 Withdraw to UPI (minimum ₹500)
- 🎁 Bonus tracking
- 📈 Earnings breakdown by referral stage

### 5. **Games & Missions**
- 🎮 Daily challenges and missions
- 🏆 Earn bonus coins by completing tasks
- 📊 Progress tracking
- 🎯 Achievement system
- ⏰ Time-limited challenges

### 6. **Leaderboard**
- 🏅 Weekly, monthly, and all-time rankings
- 👑 Top earners showcase
- 📊 Compare your performance
- 🎖️ Rank badges and recognition

### 7. **Profile Management**
- 👤 View and edit profile
- 📱 QR code for referral sharing
- 📊 Statistics dashboard
- 🔗 Referral code management
- 🚪 Sign out option

---

## 🏗️ Technical Architecture

### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider pattern
- **UI**: Material Design 3
- **Navigation**: Custom navigation with bottom tabs

### Backend
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth (Phone OTP)
- **Storage**: SharedPreferences (local) + Supabase (cloud)
- **Real-time**: Supabase real-time subscriptions

### Integrations
- **Payment Gateway**: Razorpay (UPI, Cards, Net Banking, Wallets)
- **File Picker**: Document upload functionality
- **QR Code**: QR code generation for referrals
- **Deep Linking**: App links for referral tracking
- **Share**: Native share functionality

### Offline Support
- ✅ Local data caching with SharedPreferences
- ✅ Offline queue for pending operations
- ✅ Auto-sync when connection restored
- ✅ Works without Supabase configuration

---

## 📊 Data Models

### User
- ID, Name, Email, Phone
- Referral code
- Total earnings, withdrawable balance
- Profile completion status
- Created date

### Program
- University name, Program name
- Duration, Mode (Online/Offline)
- Earning potential
- Logo/Image

### Application
- User ID, Program ID
- Personal & academic information
- Document submission status
- Payment status
- Application stage

### Referral
- Referrer ID, Referee ID
- Program ID
- Status (Applied, Enrolled, Completed)
- Earning amount
- Created date

### Transaction
- User ID, Type (Earning/Withdrawal/Bonus)
- Amount, Status
- Payment details
- Timestamp

---

## 🎨 User Interface

### Screens
1. **Splash Screen** - App initialization
2. **Onboarding** - First-time user guide
3. **Welcome Screen** - Login/Signup entry
4. **OTP Auth** - Phone verification
5. **Main Screen** - Bottom navigation hub
6. **Home** - Dashboard with stats
7. **Refer** - Programs & referrals tabs
8. **Wallet** - Earnings & transactions
9. **Games** - Challenges & missions
10. **Leaderboard** - Rankings
11. **Profile** - User settings
12. **Application Journey** - Multi-step form
13. **Payment** - Fee payment screen

### Design System
- **Primary Color**: Blue (#2196F3)
- **Success Color**: Green (#4CAF50)
- **Accent Color**: Orange (#FF9800)
- **Typography**: Google Fonts (Poppins)
- **Icons**: Material Icons
- **Spacing**: 8px grid system

---

## 💾 Data Storage

### Local Storage (SharedPreferences)
- User session data
- Application drafts
- Offline queue
- Cache data

### Cloud Storage (Supabase)
- User profiles
- Programs catalog
- Applications
- Referrals
- Transactions
- Leaderboard data

---

## 🔐 Security Features

- ✅ Phone OTP authentication
- ✅ Secure token storage
- ✅ Row Level Security (RLS) in Supabase
- ✅ ProGuard/R8 code obfuscation
- ✅ Encrypted local storage
- ✅ HTTPS-only communication
- ✅ Input validation
- ✅ SQL injection prevention

---

## 📱 App Permissions

- **Internet** - API communication
- **Network State** - Check connectivity
- **Storage** (Android 12 and below) - Document uploads
- **Read Media Images/Video** (Android 13+) - Document uploads

---

## 🚀 Build Information

### Release Files
- **APK**: `build/app/outputs/flutter-apk/app-release.apk` (59.4MB)
- **AAB**: `build/app/outputs/bundle/release/app-release.aab` (48.2MB)

### Signing
- Keystore configured in `android/key.properties`
- Release builds are signed automatically

### Build Commands
```bash
# APK (for direct installation)
flutter build apk --release

# AAB (for Play Store)
flutter build appbundle --release
```

---

## 📈 App Flow

```
Splash Screen
    ↓
Onboarding (first time only)
    ↓
Welcome Screen
    ↓
OTP Authentication
    ↓
Main Screen (Bottom Navigation)
    ├─ Home Tab
    ├─ Refer Tab
    │   ├─ Programs
    │   └─ Referrals
    ├─ Wallet Tab
    ├─ Games Tab
    └─ Leaderboard Tab
```

---

## 🎯 Monetization Model

### How Users Earn
1. **Referral Earnings**: Earn when referred students enroll
2. **Welcome Bonus**: ₹100 for new users
3. **Mission Rewards**: Complete challenges for bonus coins
4. **Milestone Bonuses**: Special rewards for achievements

### Earning Stages
- **Application Submitted**: ₹X
- **Student Enrolled**: ₹Y
- **Course Completed**: ₹Z

---

## 📞 Support & Contact

- **App Name**: Uptop Careers
- **Website**: https://uptop.careers
- **Deep Link**: uptop.careers/ref/{referralCode}
- **Custom Scheme**: uptopcareers://

---

## 🔄 Version History

### v1.0.0 (Current)
- Initial release
- Phone OTP authentication
- Program browsing and referrals
- Application journey system
- Wallet and earnings tracking
- Games and missions
- Leaderboard
- Payment integration (Razorpay)
- Offline support
- Back button navigation fixes
- MainActivity crash fix

---

## 📝 Notes

- App works in offline mode with limited functionality
- Supabase configuration is optional (uses local storage as fallback)
- All monetary values are in Indian Rupees (₹)
- Minimum withdrawal amount: ₹500
- Referral codes are unique 6-character alphanumeric strings

