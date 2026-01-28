class AppConstants {
  // API Configuration
  static const String apiBaseUrl =
      'https://api.uptopcareers.com'; // Update with actual URL
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // App Info
  static const String appName = 'Uptop Careers';
  static const String appTagline = 'Refer & Earn';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyUserToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUserProfile = 'user_profile';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyProfileCompleted = 'profile_completed';
  static const String keyUserPassword = 'user_password';

  // Referral
  static const String referralCodePrefix = 'RFX';
  static const int referralCodeLength = 6;

  // Gamification
  static const int dailySpins = 2;
  static const int streakBonusCoins = 20;
  static const int maxStreakDays = 30;

  // Earnings & Withdrawals
  static const double minWithdrawalAmount =
      1000.0; // Minimum amount to withdraw
  static const String currency = '₹';
  static const String currencyCode = 'INR';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Assets
  static const String logoPath = 'assets/images/uptop-logo.png';
  static const String defaultAvatarPath = 'assets/images/Kumar.jpg';

  // University Logos
  static const String shooliniLogo = 'assets/images/Shoolini-University.jpg';
  static const String upesLogo = 'assets/images/UPES.jpeg';
  static const String amityLogo = 'assets/images/amity.jpeg';
  static const String jainLogo = 'assets/images/Jain-University.jpg';
  static const String eimtLogo = 'assets/images/EIMT.jpg';
  static const String iimSkillsLogo = 'assets/images/IIM Skills.png';
  static const String manipalLogo =
      'assets/images/uptop-logo.png'; // Placeholder
  static const String lpuLogo = 'assets/images/uptop-logo.png'; // Placeholder
  static const String chandigarhLogo =
      'assets/images/uptop-logo.png'; // Placeholder

  // Interest Options
  static const List<String> interestOptions = [
    'Gaming',
    'Tech',
    'Business',
    'Finance',
    'Marketing',
    'IT',
    'Design',
    'Engineering',
    'Healthcare',
    'Arts',
  ];

  // Program Categories
  static const List<String> programCategories = [
    'All',
    'UG',
    'PG',
    'Diploma',
    'Certificate',
  ];

  // Referral Status Steps
  static const List<String> referralSteps = [
    'invited',
    'application_started',
    'documents',
    'fee_paid',
    'enrolled',
  ];

  // Level Names
  static const Map<int, String> levelNames = {
    1: 'Starter',
    2: 'Influencer',
    3: 'Ambassador',
    4: 'Elite',
    5: 'Legend',
  };

  // Rewards
  static const Map<int, double> weeklyRewards = {
    1: 5000,
    2: 2500,
    3: 2500,
    4: 1000,
    5: 1000,
    6: 1000,
    7: 1000,
    8: 1000,
    9: 1000,
    10: 1000,
  };

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;

  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;

  // Icon Sizes
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
}
