import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptop_careers/providers/app_provider.dart';
import 'package:uptop_careers/providers/user_provider.dart';
import 'package:uptop_careers/providers/program_provider.dart';
import 'package:uptop_careers/models/program.dart';
import 'package:uptop_careers/screens/home_screen.dart';
import 'package:uptop_careers/screens/refer_screen.dart';
import 'package:uptop_careers/screens/wallet_screen.dart';
import 'package:uptop_careers/screens/games_screen.dart';
import 'package:uptop_careers/screens/leaderboard_screen.dart';
import 'package:uptop_careers/screens/profile_screen.dart';
import 'package:uptop_careers/widgets/bottom_nav.dart';
import 'package:uptop_careers/widgets/program_details_popup.dart';
import 'package:uptop_careers/services/deep_link_service.dart';
import 'package:uptop_careers/services/user_data_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _showProfile = false;

  @override
  void initState() {
    super.initState();
    // Ensure user data is available when entering MainScreen (not only via Splash)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.currentUser == null && !userProvider.isLoading) {
        userProvider.loadUserData();
      }

      // Load programs immediately when MainScreen loads
      final programProvider = context.read<ProgramProvider>();
      if (programProvider.programs.isEmpty && !programProvider.isLoading) {
        debugPrint('Loading programs in MainScreen...');
        programProvider.loadPrograms();
      }

      // Check for pending referral and navigate to program
      _handlePendingReferral();

      // Set up deep link listener for when app is already running
      final deepLinkService = DeepLinkService();
      debugPrint('Setting up deep link callback in MainScreen');
      deepLinkService.onReferralLinkReceived = (referralId, programId) {
        debugPrint('Deep link callback triggered!');
        debugPrint('   Referral ID: $referralId');
        debugPrint('   Program ID: $programId');

        // Handle the referral link immediately
        _handlePendingReferral();
      };
      debugPrint('Deep link callback registered');
    });
  }

  @override
  void dispose() {
    // Clean up the callback
    final deepLinkService = DeepLinkService();
    deepLinkService.onReferralLinkReceived = null;
    super.dispose();
  }

  /// Handle pending referral from deep link
  void _handlePendingReferral() async {
    final deepLinkService = DeepLinkService();

    debugPrint('_handlePendingReferral() called');
    debugPrint(
      '   Has pending referral: ${deepLinkService.hasPendingReferral()}',
    );

    if (deepLinkService.hasPendingReferral()) {
      final programId = deepLinkService.getPendingProgramId();
      final referralId = deepLinkService.getPendingReferralId();

      debugPrint('Handling pending referral:');
      debugPrint('   Program ID: $programId');
      debugPrint('   Referral ID: $referralId');

      // Check if user is already logged in
      final userProvider = context.read<UserProvider>();
      final currentUser = userProvider.currentUser;

      if (currentUser != null && referralId != null) {
        debugPrint('User is logged in - linking referral immediately');

        // Link the referral to this existing user
        await _linkReferralToExistingUser(
          referralId: referralId,
          userId: currentUser.id,
          userName: currentUser.name,
          userEmail: currentUser.email,
          userPhone: currentUser.phone,
          userCollege: currentUser.school ?? '',
        );
      }

      // Check if still mounted after async operation
      if (!mounted) return;

      if (programId != null) {
        // Stay on current screen (don't navigate away)
        // Just show the program details popup directly

        // Wait for programs to load, then show the popup
        _showProgramDetailsWhenReady(programId, referralId);
      } else {
        // No program ID in referral link, clear it
        debugPrint('Referral link missing program ID');
        deepLinkService.clearPendingReferral();
      }
    }
  }

  /// Link referral to an existing user who clicked the link
  Future<void> _linkReferralToExistingUser({
    required String referralId,
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required String userCollege,
  }) async {
    try {
      debugPrint('Linking referral $referralId to existing user $userId');

      final success = await UserDataService.linkReferralToUser(
        referralId: referralId,
        referredUserId: userId,
        referredName: userName,
        referredEmail: userEmail,
        referredPhone: userPhone,
        referredCollege: userCollege,
      );

      if (success) {
        debugPrint('Referral linked successfully to existing user');

        // Refresh user data to show updated referrals
        if (mounted) {
          final userProvider = context.read<UserProvider>();
          await userProvider.loadUserData();
        }
      } else {
        debugPrint('Failed to link referral to existing user');
      }
    } catch (e) {
      debugPrint('Error linking referral to existing user: $e');
    }
  }

  /// Show program details popup when programs are loaded
  void _showProgramDetailsWhenReady(
    String programId,
    String? referralId,
  ) async {
    final deepLinkService = DeepLinkService();
    final programProvider = context.read<ProgramProvider>();

    debugPrint('Waiting for programs to load...');
    debugPrint('   Current programs count: ${programProvider.programs.length}');

    // Wait for programs to load (max 10 seconds)
    int attempts = 0;
    while (programProvider.programs.isEmpty && attempts < 20) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
      debugPrint(
        '   Attempt $attempts: ${programProvider.programs.length} programs loaded',
      );
    }

    if (!mounted) return;

    if (programProvider.programs.isEmpty) {
      debugPrint('Programs failed to load after 10 seconds');
      deepLinkService.clearPendingReferral();
      return;
    }

    // Try to find the exact program
    Program? targetProgram;
    try {
      targetProgram = programProvider.programs.firstWhere(
        (p) => p.id == programId,
      );
      debugPrint('Found program: ${targetProgram.programName}');
    } catch (e) {
      debugPrint(
        'Program with ID $programId not found in ${programProvider.programs.length} programs',
      );
      debugPrint('   Available program IDs:');
      for (var program in programProvider.programs.take(5)) {
        debugPrint('   - ${program.id}: ${program.programName}');
      }
      deepLinkService.clearPendingReferral();
      return;
    }

    // Show program details popup immediately with referral ID
    if (mounted && targetProgram != null) {
      debugPrint(
        'Showing program details popup for: ${targetProgram.programName}',
      );

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ProgramDetailsPopup(
          program: targetProgram!,
          referralId: referralId,
        ),
      );

      // Clear pending referral after showing the popup
      deepLinkService.clearPendingReferral();
      debugPrint('Referral link handled and cleared');
    }
  }

  void _handleProfileClick() {
    setState(() {
      _showProfile = true;
    });
  }

  void _handleProfileBack() {
    setState(() {
      _showProfile = false;
    });
  }

  void _handleNavigation(int index, {String? subTab}) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.navigateToTab(index, subTab: subTab);
  }

  Widget _buildCurrentScreen(int currentIndex, String referralSubTab) {
    switch (currentIndex) {
      case 0:
        return HomeScreen(
          onProfileClick: _handleProfileClick,
          onNavigate: _handleNavigation,
        );
      case 1:
        return ReferScreen(defaultTab: referralSubTab);
      case 2:
        return const WalletScreen();
      case 3:
        return const GamesScreen();
      case 4:
        return const LeaderboardScreen();
      default:
        return HomeScreen(
          onProfileClick: _handleProfileClick,
          onNavigate: _handleNavigation,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        // Show Profile Screen
        if (_showProfile) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                _handleProfileBack();
              }
            },
            child: ProfileScreen(onBack: _handleProfileBack),
          );
        }

        // Main Screen with Bottom Navigation
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              // When back button is pressed on main screen, go to home tab
              if (appProvider.currentTabIndex != 0) {
                _handleNavigation(0);
              } else {
                // If already on home tab, show exit confirmation
                _showExitConfirmation(context);
              }
            }
          },
          child: Scaffold(
            body: _buildCurrentScreen(
              appProvider.currentTabIndex,
              appProvider.referralSubTab,
            ),
            bottomNavigationBar: BottomNav(
              currentIndex: appProvider.currentTabIndex,
              onTap: (index) => _handleNavigation(index),
            ),
          ),
        );
      },
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Exit the app
              Navigator.of(context).pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
