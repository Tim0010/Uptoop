/// Environment Configuration
/// This file contains environment variables that are compiled into the app.
/// For production, these values should be set properly.
class EnvConfig {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hndxhixadfhrgfrkshjy.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_r5KbhZNL2iHDDddnwAXqfQ_a3ivDudF',
  );

  // Razorpay Configuration
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_test_1234567890abcd',
  );

  static const String razorpayKeySecret = String.fromEnvironment(
    'RAZORPAY_KEY_SECRET',
    defaultValue: 'your_test_key_secret_here',
  );

  // Twilio Configuration (if needed)
  static const String twilioAccountSid = String.fromEnvironment(
    'TWILIO_ACCOUNT_SID',
    defaultValue: 'your_twilio_account_sid',
  );

  static const String twilioAuthToken = String.fromEnvironment(
    'TWILIO_AUTH_TOKEN',
    defaultValue: 'your_twilio_auth_token',
  );

  static const String twilioPhoneNumber = String.fromEnvironment(
    'TWILIO_PHONE_NUMBER',
    defaultValue: '+12185683702',
  );

  static const String twilioVerifyServiceSid = String.fromEnvironment(
    'TWILIO_VERIFY_SERVICE_SID',
    defaultValue: 'MGb1868a2471ce9c7faa5fbf31a21963d7',
  );

  // Helper method to check if running in production
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');

  // Helper method to get environment name
  static String get environmentName {
    if (isProduction) return 'production';
    return 'development';
  }
}
