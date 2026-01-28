import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/widgets/earnings_card.dart';
import 'package:uptop_careers/widgets/referral_tracker.dart';
import 'package:uptop_careers/widgets/loading_indicator.dart';
import 'package:uptop_careers/widgets/empty_state.dart';
import 'package:uptop_careers/providers/user_provider.dart';
import 'package:uptop_careers/providers/leaderboard_provider.dart';
import 'package:uptop_careers/providers/wallet_provider.dart';
import 'package:uptop_careers/providers/application_provider.dart';
import 'package:uptop_careers/providers/program_provider.dart';
import 'package:uptop_careers/widgets/quick_action_button.dart';
import 'package:uptop_careers/widgets/leaderboard_item.dart';
import 'package:uptop_careers/widgets/withdrawal_prompt.dart';
import 'package:uptop_careers/widgets/my_application_progress.dart';
import 'package:uptop_careers/screens/login_screen.dart';
import 'package:uptop_careers/screens/application_journey_screen.dart';
import 'package:uptop_careers/models/application.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onProfileClick;
  final Function(int, {String? subTab}) onNavigate;

  const HomeScreen({
    super.key,
    required this.onProfileClick,
    required this.onNavigate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load user data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserData();
      // Load leaderboard so Top Earner card can show real data
      context.read<LeaderboardProvider>().loadLeaderboard();
      // Load applications so we can show user's own application progress
      context.read<ApplicationProvider>().loadApplications();
    });
  }

  void _showWithdrawalPrompt(double withdrawableBalance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: WithdrawalPrompt(withdrawableBalance: withdrawableBalance),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;
    final leaderboardProvider = context.watch<LeaderboardProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final applicationProvider = context.watch<ApplicationProvider>();
    final programProvider = context.watch<ProgramProvider>();
    final recentReferrals = userProvider.recentReferrals;

    // Show loading state
    if (userProvider.isLoading) {
      return const LoadingIndicator(
        message: 'Loading your dashboard...',
        fullScreen: true,
      );
    }

    // Show error state
    if (userProvider.error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Oops!',
        message: 'Something went wrong. Please try again.',
        actionText: 'Retry',
        onAction: () => userProvider.loadUserData(),
      );
    }

    // Show empty state if no user
    if (user == null) {
      return EmptyState(
        icon: Icons.person_outline,
        title: 'No User Data',
        message: 'Please login to continue',
        actionText: 'Login',
        onAction: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
        },
      );
    }
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              toolbarHeight: 80,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(AppConstants.logoPath, height: 40),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: GestureDetector(
                      onTap: widget.onProfileClick,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: user.avatarUrl == null
                            ? AppTheme.primaryBlue
                            : Colors.transparent,
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? const Icon(
                                Icons.person_outline,
                                size: 24,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              automaticallyImplyLeading: false,
              titleSpacing: AppConstants.spacingMD,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMD,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppConstants.spacingLG),
                  // Welcome
                  Text(
                    'Hey, ${user.name.split(' ')[0]}! 👋',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppConstants.spacingSM),
                  Text(
                    'Ready to earn some cash today?',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: AppConstants.spacingLG),

                  // Earnings Card
                  EarningsCard(
                    totalEarnings: user.totalEarnings,
                    pendingEarnings: user.pendingEarnings,
                    monthlyEarnings: user.monthlyEarnings,
                    onTap: () => widget.onNavigate(2), // Navigate to Wallet
                    onWithdraw: () =>
                        _showWithdrawalPrompt(walletProvider.availableBalance),
                  ),
                  const SizedBox(height: AppConstants.spacingLG),

                  // My Application Progress (for referred users)
                  if (applicationProvider.applications.isNotEmpty)
                    Builder(
                      builder: (context) {
                        // Get the first in-progress application
                        final inProgressApps = applicationProvider
                            .applications
                            .values
                            .where(
                              (app) =>
                                  app.calculateCurrentStage() !=
                                  ApplicationStage.applicationSubmitted,
                            )
                            .toList();

                        if (inProgressApps.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final application = inProgressApps.first;

                        // Get program name from ProgramProvider
                        try {
                          final program = programProvider.programs.firstWhere(
                            (p) => p.id == application.programId,
                          );

                          return Column(
                            children: [
                              MyApplicationProgress(
                                application: application,
                                programName:
                                    '${program.programName} - ${program.universityName}',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ApplicationJourneyScreen(
                                        program: program,
                                        referralId: application.referralId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: AppConstants.spacingLG),
                            ],
                          );
                        } catch (e) {
                          // Program not found, don't show the widget
                          return const SizedBox.shrink();
                        }
                      },
                    ),

                  // Top Earner Card (wired to leaderboard data)
                  Text(
                    'Top Earner Today',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.spacingMD),
                  Builder(
                    builder: (context) {
                      if (leaderboardProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (leaderboardProvider.error != null) {
                        return EmptyState(
                          icon: Icons.emoji_events_outlined,
                          title: 'Couldn\'t load top earner',
                          message: 'Please try again.',
                          actionText: 'Retry',
                          onAction: () => context
                              .read<LeaderboardProvider>()
                              .loadLeaderboard(),
                        );
                      }
                      if (leaderboardProvider.entries.isEmpty) {
                        return const EmptyState(
                          icon: Icons.emoji_events_outlined,
                          title: 'No data yet',
                          message:
                              'Top earner will appear once there is activity.',
                        );
                      }
                      // Pick the entry with the best (lowest) rank
                      final top = leaderboardProvider.entries.reduce(
                        (a, b) => a.rank <= b.rank ? a : b,
                      );
                      return LeaderboardItem(entry: top);
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingLG),

                  // Earnings Overview Card
                  _buildEarningsOverview(
                    userProvider.totalReferralCount,
                    userProvider.enrolledReferralCount,
                    userProvider.activeReferrals.length,
                  ),
                  const SizedBox(height: AppConstants.spacingLG),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.spacingMD),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppConstants.spacingMD,
                    mainAxisSpacing: AppConstants.spacingMD,
                    childAspectRatio: 1.5,
                    children: [
                      QuickActionButton(
                        text: 'Refer & Earn',
                        icon: Icons.card_giftcard,
                        color: const Color(0xFF4A4AFF),
                        onTap: () => widget.onNavigate(1),
                      ),
                      QuickActionButton(
                        text: 'Track Referrals',
                        icon: Icons.people_alt,
                        color: const Color(0xFF28B463),
                        onTap: () => widget.onNavigate(1, subTab: 'referrals'),
                      ),
                      QuickActionButton(
                        text: 'Wallet',
                        icon: Icons.account_balance_wallet,
                        color: const Color(0xFFE67E22),
                        onTap: () => widget.onNavigate(2),
                      ),
                      QuickActionButton(
                        text: 'Play & Win',
                        icon: Icons.sports_esports,
                        color: const Color(0xFFF1C40F),
                        onTap: () => widget.onNavigate(3),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLG),

                  // Recent Referrals
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Referrals',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () =>
                            widget.onNavigate(1, subTab: 'referrals'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingSM),

                  // Referral Trackers
                  if (recentReferrals.isEmpty)
                    const EmptyState(
                      icon: Icons.people_outline,
                      title: 'No Referrals Yet',
                      message: 'Start referring friends to earn cash!',
                    )
                  else
                    ...recentReferrals
                        .take(2)
                        .map(
                          (referral) => ReferralTracker(
                            friendName: referral.friendName,
                            profilePictureUrl: referral.profilePictureUrl,
                            programName:
                                '${referral.programName} - ${referral.universityName}',
                            applicationStage: referral.applicationStage!,
                            earning: referral.earning,
                          ),
                        ),
                  const SizedBox(height: AppConstants.spacingLG),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsOverview(
    int totalReferrals,
    int enrolled,
    int inProgress,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: AppTheme.textPrimary,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacingSM),
                Text(
                  'Earnings Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewItem(
                  totalReferrals.toString(),
                  'Total Referrals',
                ),
                _buildOverviewItem(
                  enrolled.toString(),
                  'Enrolled',
                  color: AppTheme.successGreen,
                ),
                _buildOverviewItem(
                  inProgress.toString(),
                  'In Progress',
                  color: AppTheme.accentOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String value, String label, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color ?? AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
