import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../services/twilio_service.dart';
import '../services/supabase_service.dart';
import '../services/user_data_service.dart';
import '../services/deep_link_service.dart';

/// Authentication provider with Twilio OTP integration
/// Supports both Twilio Verify API and regular SMS methods
class AuthProvider with ChangeNotifier {
  String? _phoneNumber;
  String? _otpCode;
  String? _userId;
  String? _referralCode;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  DateTime? _otpSentAt;
  String? _twilioSid; // Store Twilio verification SID
  final bool _useTwilioVerify = true; // Toggle between Verify API and SMS

  // Getters
  String? get phoneNumber => _phoneNumber;
  String? get otpCode => _otpCode;
  String? get userId => _userId;
  String? get referralCode => _referralCode;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get otpSentAt => _otpSentAt;

  // Check if OTP is still valid (5 minutes)
  bool get isOtpValid {
    if (_otpSentAt == null) return false;
    final difference = DateTime.now().difference(_otpSentAt!);
    return difference.inMinutes < 5;
  }

  // Set referral code (from deep link or referral flow)
  void setReferralCode(String? code) {
    _referralCode = code;
    notifyListeners();
  }

  // Send OTP to phone number
  Future<bool> sendOtp(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Format phone number to E.164 format
      final formattedPhone = TwilioService.formatPhoneNumber(phoneNumber);

      // Validate phone number
      if (!TwilioService.isValidPhoneNumber(formattedPhone)) {
        _error = 'Invalid phone number format';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _phoneNumber = formattedPhone;

      // Check if Twilio is configured
      if (!TwilioService.isConfigured()) {
        // Fallback to development mode
        if (kDebugMode) {
          print('⚠️ Twilio not configured. Using development mode.');
          return await _sendOtpDevelopmentMode(formattedPhone);
        } else {
          _error = 'SMS service not configured';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Try Twilio Verify API first (recommended)
      if (_useTwilioVerify) {
        final result = await TwilioService.sendOtpWithVerify(formattedPhone);

        if (result['success']) {
          _twilioSid = result['sid'];
          _otpSentAt = DateTime.now();

          if (kDebugMode) {
            print('✅ OTP sent via Twilio Verify to $formattedPhone');
          }

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          // If Verify fails, try regular SMS
          if (kDebugMode) {
            print('⚠️ Twilio Verify failed: ${result['message']}');
            print('Trying regular SMS...');
          }
          return await _sendOtpViaSms(formattedPhone);
        }
      } else {
        // Use regular SMS
        return await _sendOtpViaSms(formattedPhone);
      }
    } catch (e) {
      _error = 'Failed to send OTP: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Send OTP via regular SMS
  Future<bool> _sendOtpViaSms(String phoneNumber) async {
    try {
      // Generate OTP
      _otpCode = TwilioService.generateOtp();

      // Send SMS
      final result = await TwilioService.sendOtpWithSms(phoneNumber, _otpCode!);

      if (result['success']) {
        _otpSentAt = DateTime.now();

        if (kDebugMode) {
          print('✅ OTP sent via SMS to $phoneNumber: $_otpCode');
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to send SMS: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Development mode OTP (when Twilio is not configured)
  Future<bool> _sendOtpDevelopmentMode(String phoneNumber) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final random = Random();
      _otpCode = (100000 + random.nextInt(900000)).toString();
      _otpSentAt = DateTime.now();

      if (kDebugMode) {
        print('🔐 [DEV MODE] OTP sent to $phoneNumber: $_otpCode');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to send OTP: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String enteredOtp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if OTP is valid
      if (!isOtpValid) {
        _error = 'OTP has expired. Please request a new one.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      bool isValid = false;

      // Check if Twilio is configured
      if (!TwilioService.isConfigured()) {
        // Development mode - verify locally
        isValid = await _verifyOtpDevelopmentMode(enteredOtp);
      } else if (_useTwilioVerify && _twilioSid != null) {
        // Verify using Twilio Verify API
        final result = await TwilioService.verifyOtpWithVerify(
          _phoneNumber!,
          enteredOtp,
        );

        if (result['success']) {
          isValid = true;
          if (kDebugMode) {
            print('✅ OTP verified via Twilio Verify');
          }
        } else {
          _error = result['message'];
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        // Verify locally (when using regular SMS)
        isValid = await _verifyOtpDevelopmentMode(enteredOtp);
      }

      if (isValid) {
        // Sign in to Supabase if configured
        if (SupabaseService.isConfigured) {
          try {
            await SupabaseService.signInAnonymously();
            _userId =
                SupabaseService.currentUser?.id ??
                'user_${DateTime.now().millisecondsSinceEpoch}';
            if (kDebugMode) {
              print('✅ Signed in to Supabase with ID: $_userId');
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Failed to sign in to Supabase: $e');
              print('⚠️ Continuing with local user ID');
            }
            _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
          }
        } else {
          // Generate user ID (in production, this comes from backend)
          _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        }

        _isAuthenticated = true;

        // Save authentication state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userId', _userId!);
        await prefs.setString('phoneNumber', _phoneNumber!);
        if (_referralCode != null) {
          await prefs.setString('referralCode', _referralCode!);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid OTP. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to verify OTP: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify OTP in development mode
  Future<bool> _verifyOtpDevelopmentMode(String enteredOtp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return enteredOtp == _otpCode;
  }

  // Resend OTP
  Future<bool> resendOtp() async {
    if (_phoneNumber == null) {
      _error = 'Phone number not found';
      notifyListeners();
      return false;
    }
    return await sendOtp(_phoneNumber!);
  }

  // Check authentication status
  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      _userId = prefs.getString('userId');
      _phoneNumber = prefs.getString('phoneNumber');
      _referralCode = prefs.getString('referralCode');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to check auth status: $e';
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isAuthenticated');
      await prefs.remove('userId');
      await prefs.remove('phoneNumber');
      await prefs.remove('referralCode');
      await prefs.remove('loggedIn');

      // Sign out from Supabase
      if (SupabaseService.isConfigured) {
        await SupabaseService.signOut();
      }

      _isAuthenticated = false;
      _userId = null;
      _phoneNumber = null;
      _referralCode = null;
      _otpCode = null;
      _otpSentAt = null;

      notifyListeners();
    } catch (e) {
      _error = 'Failed to logout: $e';
      notifyListeners();
    }
  }

  // Save user profile to Supabase after onboarding
  Future<bool> saveUserProfile({
    required String fullName,
    required String email,
    required int age,
    required String college,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_phoneNumber == null) {
        _error = 'Phone number not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Save to Supabase if configured
      if (SupabaseService.isConfigured) {
        final userProfile = await SupabaseService.upsertUserProfile(
          phoneNumber: _phoneNumber!,
          fullName: fullName,
          email: email,
          age: age,
          college: college,
          referredByCode: _referralCode,
        );

        // Update local state with Supabase user ID
        _userId = userProfile['id'];

        if (kDebugMode) {
          print(
            '✅ User profile saved to Supabase: ${userProfile['referral_code']}',
          );
        }
      } else {
        // Fallback to local storage only
        _userId = 'local_${DateTime.now().millisecondsSinceEpoch}';

        if (kDebugMode) {
          print('⚠️ Supabase not configured. User data saved locally only.');
        }
      }

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _userId!);
      await prefs.setString('fullName', fullName);
      await prefs.setString('email', email);
      await prefs.setInt('age', age);
      await prefs.setString('college', college);

      // Link referral if user came from a referral link
      await _linkPendingReferral(fullName, email, _phoneNumber!, college);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save user profile: $e';
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('❌ Error saving user profile: $e');
      }

      return false;
    }
  }

  // Get user profile from Supabase
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (_userId == null) return null;

      if (SupabaseService.isConfigured) {
        return await SupabaseService.getUserProfile(_userId!);
      } else {
        // Return from local storage
        final prefs = await SharedPreferences.getInstance();
        return {
          'id': _userId,
          'phone_number': _phoneNumber,
          'full_name': prefs.getString('fullName'),
          'email': prefs.getString('email'),
          'age': prefs.getInt('age'),
          'college': prefs.getString('college'),
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user profile: $e');
      }
      return null;
    }
  }

  // Get user profile by phone number
  Future<Map<String, dynamic>?> getUserProfileByPhone() async {
    try {
      if (_phoneNumber == null) {
        if (kDebugMode) {
          print('⚠️ Phone number is null, cannot search for profile');
        }
        return null;
      }

      if (kDebugMode) {
        print('🔍 Searching for profile with phone: $_phoneNumber');
        print('📡 Supabase configured: ${SupabaseService.isConfigured}');
      }

      if (SupabaseService.isConfigured) {
        final result = await SupabaseService.getUserByPhone(_phoneNumber!);
        if (kDebugMode) {
          print(
            '📊 Supabase query result: ${result != null ? "Found" : "Not found"}',
          );
        }
        return result;
      } else {
        // Return from local storage
        final prefs = await SharedPreferences.getInstance();
        final storedPhone = prefs.getString('phoneNumber');
        if (kDebugMode) {
          print(
            '💾 Checking local storage: stored=$storedPhone, current=$_phoneNumber',
          );
        }
        if (storedPhone == _phoneNumber) {
          return {
            'id': prefs.getString('userId'),
            'phone_number': _phoneNumber,
            'full_name': prefs.getString('fullName'),
            'email': prefs.getString('email'),
            'age': prefs.getInt('age'),
            'college': prefs.getString('college'),
          };
        }
        return null;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error getting user profile by phone: $e');
        print('📍 Stack trace: $stackTrace');
      }
      return null;
    }
  }

  // Update user ID (for existing users signing in)
  Future<void> updateUserId(String userId) async {
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    notifyListeners();
  }

  // Link pending referral to the new user
  Future<void> _linkPendingReferral(
    String fullName,
    String email,
    String phone,
    String college,
  ) async {
    try {
      // Check if there's a pending referral from deep link
      final deepLinkService = DeepLinkService();
      final pendingReferralId = deepLinkService.getPendingReferralId();

      if (kDebugMode) {
        print('🔍 Checking for pending referral...');
        print('   Pending Referral ID: $pendingReferralId');
        print('   User ID: $_userId');
        print('   User Name: $fullName');
        print('   User Email: $email');
        print('   User Phone: $phone');
        print('   User College: $college');
      }

      if (pendingReferralId != null && _userId != null) {
        if (kDebugMode) {
          print('🔗 Linking referral $pendingReferralId to user $_userId');
        }

        // Link the referral to this user
        final success = await UserDataService.linkReferralToUser(
          referralId: pendingReferralId,
          referredUserId: _userId!,
          referredName: fullName,
          referredEmail: email,
          referredPhone: phone,
          referredCollege: college,
        );

        if (success) {
          if (kDebugMode) {
            print('✅ Referral linked successfully');
          }
          // Clear the pending referral
          deepLinkService.clearPendingReferral();
        } else {
          if (kDebugMode) {
            print('⚠️ Failed to link referral');
          }
        }
      } else {
        if (kDebugMode) {
          print('ℹ️ No pending referral to link');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error linking pending referral: $e');
      }
    }
  }
}
