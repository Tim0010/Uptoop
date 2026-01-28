import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/providers/auth_provider.dart';
import 'package:uptop_careers/providers/user_provider.dart';
import 'package:uptop_careers/providers/wallet_provider.dart';
import 'package:uptop_careers/screens/main_screen.dart';
import 'package:uptop_careers/utils/animations.dart';
import 'package:uptop_careers/utils/error_handler.dart';
import 'package:uptop_careers/utils/validators.dart';
import 'package:uptop_careers/widgets/welcome_bonus_dialog.dart';
import 'package:uptop_careers/services/supabase_service.dart';

class SimpleOnboardingScreen extends StatefulWidget {
  const SimpleOnboardingScreen({super.key});

  @override
  State<SimpleOnboardingScreen> createState() => _SimpleOnboardingScreenState();
}

class _SimpleOnboardingScreenState extends State<SimpleOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _collegeController = TextEditingController();

  int? _selectedAge; // Changed from controller to dropdown value
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();
      final walletProvider = context.read<WalletProvider>();

      // Save user profile to Supabase (and local storage)
      final success = await authProvider.saveUserProfile(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        age: _selectedAge!,
        college: _collegeController.text.trim(),
      );

      if (!success) {
        throw Exception(authProvider.error ?? 'Failed to save user profile');
      }

      // Create user account in local provider
      await userProvider.createUserAccount(
        name: _nameController.text.trim(),
        age: _selectedAge.toString(),
        email: _emailController.text.trim(),
        college: _collegeController.text.trim(),
        phoneNumber: authProvider.phoneNumber!,
        referralCode: authProvider.referralCode,
      );

      // Mark as logged in and profile completed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true);
      await prefs.setBool(AppConstants.keyProfileCompleted, true);

      if (!mounted) return;

      // Ensure providers have fresh data from storage/backend
      await userProvider.loadUserData();

      // Add welcome bonus (10 rupees)
      const welcomeBonusAmount = 10.0;
      final userId =
          SupabaseService.currentUser?.id ?? userProvider.currentUser?.id ?? '';

      bool bonusAdded = false;
      if (userId.isNotEmpty) {
        bonusAdded = await walletProvider.addWelcomeBonus(
          userId,
          welcomeBonusAmount,
        );

        // Reload user data to reflect the bonus in total_earnings
        await userProvider.loadUserData();
        await walletProvider.loadTransactions();
      }

      if (!mounted) return;

      // Show celebration dialog only if bonus was added
      if (bonusAdded) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WelcomeBonusDialog(
            bonusAmount: welcomeBonusAmount,
            onClose: () {
              Navigator.of(context).pop();
            },
          ),
        );
      }

      if (!mounted) return;

      // Navigate to main screen
      Navigator.of(
        context,
      ).pushReplacement(AppAnimations.slideTransition(const MainScreen()));
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showErrorSnackBar(
        context,
        ErrorHandler.getErrorMessage(e),
        onRetry: _createAccount,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Create Your Account',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
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
                const Text(
                  'Tell us about yourself',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Just a few details to get you started',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 32),
                // Name Field
                TextFormField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: AppValidators.validateName,
                ),
                const SizedBox(height: 20),
                // Age Dropdown (16-100 years)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    hintText: 'Select your age',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  items: List.generate(
                    85, // 100 - 16 + 1 = 85 options
                    (index) {
                      final age = 16 + index;
                      return DropdownMenuItem<int>(
                        value: age,
                        child: Text('$age years'),
                      );
                    },
                  ),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedAge = value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'your.email@example.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.validateEmail,
                ),
                const SizedBox(height: 20),
                // College/University Field
                TextFormField(
                  controller: _collegeController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'College / University',
                    hintText: 'Enter your college or university name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your college or university';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Phone Number Display (Read-only)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone Number (Verified)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authProvider.phoneNumber ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.verified, color: Colors.green.shade600),
                    ],
                  ),
                ),
                if (authProvider.referralCode != null) ...[
                  const SizedBox(height: 16),
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
                                'Referred by',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authProvider.referralCode!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // Create Account Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _createAccount,
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
                      : const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
