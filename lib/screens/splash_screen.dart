import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/providers/auth_provider.dart';
import 'package:uptop_careers/providers/user_provider.dart';
import 'package:uptop_careers/screens/main_screen.dart';
import 'package:uptop_careers/screens/onboarding_screen.dart';
import 'package:uptop_careers/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  final String? referralCode;

  const SplashScreen({super.key, this.referralCode});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool showOnboarding = prefs.getBool('showOnboarding') ?? true;
    final bool isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    final bool profileCompleted =
        prefs.getBool(AppConstants.keyProfileCompleted) ?? false;

    // Check auth status
    if (mounted) {
      await context.read<AuthProvider>().checkAuthStatus();
    }

    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      Widget target;
      if (showOnboarding) {
        target = const OnboardingScreen();
      } else if (isAuthenticated && profileCompleted) {
        // User is fully authenticated and onboarded
        await context.read<UserProvider>().loadUserData();
        target = const MainScreen();
      } else {
        // User needs to authenticate or complete onboarding
        target = WelcomeScreen(referralCode: widget.referralCode);
      }

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => target));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppConstants.logoPath, height: 120),
            const SizedBox(height: 16),
            const Text(
              'Uptop Careers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
