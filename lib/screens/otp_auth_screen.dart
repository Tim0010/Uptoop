import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/providers/auth_provider.dart';
import 'package:uptop_careers/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/screens/main_screen.dart';
import 'package:uptop_careers/screens/simple_onboarding_screen.dart';
import 'package:uptop_careers/utils/animations.dart';
import 'package:uptop_careers/utils/error_handler.dart';
import 'package:uptop_careers/utils/validators.dart';

class OtpAuthScreen extends StatefulWidget {
  final String? referralCode;
  final bool isSignIn;

  const OtpAuthScreen({super.key, this.referralCode, this.isSignIn = false});

  @override
  State<OtpAuthScreen> createState() => _OtpAuthScreenState();
}

class _OtpAuthScreenState extends State<OtpAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set referral code if provided
    if (widget.referralCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuthProvider>().setReferralCode(widget.referralCode);
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendOtp(_phoneController.text.trim());

    if (!mounted) return;

    if (success) {
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to ${_phoneController.text}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _isLoading = false);
      ErrorHandler.showErrorSnackBar(
        context,
        authProvider.error ?? 'Failed to send OTP',
        onRetry: _sendOtp,
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      ErrorHandler.showErrorSnackBar(context, 'Please enter OTP');
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(_otpController.text.trim());

    if (!mounted) return;

    if (success) {
      // Check if user already has a profile by phone number
      final auth = context.read<AuthProvider>();
      final existingProfile = await auth.getUserProfileByPhone();

      if (kDebugMode) {
        print('🔍 Checking for existing profile...');
        print('📱 Phone: ${auth.phoneNumber}');
        print('👤 Profile found: ${existingProfile != null}');
        if (existingProfile != null) {
          print('📝 Full name: ${existingProfile['full_name']}');
          print('🆔 User ID: ${existingProfile['id']}');
        }
      }

      final fullName =
          (existingProfile?['full_name'] ?? existingProfile?['fullName'] ?? '')
              .toString()
              .trim();

      if (fullName.isNotEmpty) {
        // Existing user - update userId and load their data
        final userId = existingProfile!['id'] as String;
        await auth.updateUserId(userId);

        if (kDebugMode) {
          print('✅ Existing user detected - signing in');
        }

        // Mark profile as completed (especially important on fresh installs/new devices)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.keyProfileCompleted, true);
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userId', userId);

        if (!mounted) return;

        // Ensure user data is loaded
        await context.read<UserProvider>().loadUserData();

        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacement(AppAnimations.slideTransition(const MainScreen()));
      } else {
        // New user (or no profile found) -> continue to lightweight onboarding
        if (kDebugMode) {
          print('🆕 New user detected - going to onboarding');
        }
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          AppAnimations.slideTransition(const SimpleOnboardingScreen()),
        );
      }
    } else {
      setState(() => _isLoading = false);
      ErrorHandler.showErrorSnackBar(
        context,
        authProvider.error ?? 'Invalid OTP',
        onRetry: _verifyOtp,
      );
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resendOtp();

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ErrorHandler.showErrorSnackBar(
        context,
        authProvider.error ?? 'Failed to resend OTP',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  widget.isSignIn ? 'Welcome Back!' : 'Phone Verification',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _otpSent
                      ? 'Enter the OTP sent to your phone'
                      : widget.isSignIn
                      ? 'Sign in with your phone number'
                      : 'Enter your phone number to get started',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 48),
                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  enabled: !_otpSent && !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+91 98765 43210',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.validatePhoneNumber,
                ),
                if (_otpSent) ...[
                  const SizedBox(height: 24),
                  // OTP Field
                  TextFormField(
                    controller: _otpController,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Enter OTP',
                      hintText: '123456',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                ],
                const SizedBox(height: 32),
                // Action Button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_otpSent ? _verifyOtp : _sendOtp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          _otpSent ? 'Verify OTP' : 'Send OTP',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
                if (_otpSent) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading ? null : _resendOtp,
                    child: const Text('Resend OTP'),
                  ),
                ],
                if (widget.referralCode != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.card_giftcard, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Referral Code Applied',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              Text(
                                widget.referralCode!,
                                style: TextStyle(color: Colors.green.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
