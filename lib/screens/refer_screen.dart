// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/models/application.dart';
import 'package:uptop_careers/providers/program_provider.dart';
import 'package:uptop_careers/providers/user_provider.dart';
import 'package:uptop_careers/widgets/program_card.dart';
import 'package:uptop_careers/widgets/loading_indicator.dart';
import 'package:uptop_careers/widgets/empty_state.dart';
import 'package:uptop_careers/widgets/referral_tracker.dart';
import 'package:uptop_careers/models/program.dart';
import 'package:uptop_careers/widgets/program_details_popup.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uptop_careers/services/user_data_service.dart';
import 'package:uptop_careers/services/deep_link_service.dart';

class ReferScreen extends StatefulWidget {
  final String defaultTab;

  const ReferScreen({super.key, this.defaultTab = 'programs'});

  @override
  State<ReferScreen> createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late int _currentTabIndex;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.defaultTab == 'referrals' ? 1 : 0;
    _tabController = TabController(
      initialIndex: _currentTabIndex,
      length: 2,
      vsync: this,
    );
    _tabController.addListener(_handleTabSelection);

    // Load programs when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramProvider>().loadPrograms();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  Future<void> _shareProgram(String programId, String programName) async {
    final userProvider = context.read<UserProvider>();
    final referralCode = userProvider.currentUser?.referralCode ?? '';
    final userName = userProvider.currentUser?.fullName ?? 'Your friend';

    try {
      // Create a referral record in the database
      final referralId = await UserDataService.createReferral(
        referredName: 'Invited Friend', // Placeholder until they sign up
        referredEmail: null,
        referredPhone: null,
        referredCollege: null,
      );

      if (referralId == null) {
        debugPrint('⚠️ Failed to create referral record');
        // Still allow sharing even if referral creation fails
      }

      // Generate referral link with referralId
      final referralLink = DeepLinkService.generateReferralLink(
        referralCode: referralCode,
        referralId: referralId ?? 'unknown',
        programId: programId,
      );

      final message =
          '$userName just shared this program on Uptop Careers: $programName. Join using my referral link and earn cash!\n$referralLink';

      await Share.share(message);

      // Refresh referrals list to show the new referral
      if (referralId != null) {
        await userProvider.loadUserData();
      }
    } catch (e) {
      debugPrint('❌ Error sharing program: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create referral. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showProgramDetailsPopup(Program program) {
    // Check if there's a pending referral from deep link
    final deepLinkService = DeepLinkService();
    final pendingReferralId = deepLinkService.getPendingReferralId();
    final pendingProgramId = deepLinkService.getPendingProgramId();

    // If the pending program matches this program, use the referral ID
    final referralId = (pendingProgramId == program.id)
        ? pendingReferralId
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ProgramDetailsPopup(program: program, referralId: referralId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final programProvider = context.watch<ProgramProvider>();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 1,
              title: Text(
                'Refer & Earn',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spacingMD,
                    0,
                    AppConstants.spacingMD,
                    8.0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => programProvider.searchPrograms(value),
                    decoration: const InputDecoration(
                      hintText: 'Search programs or universities...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
            ),
          ],
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMD,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusLG,
                      ),
                      color: AppTheme.cardBackground,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: AppTheme.textPrimary,
                    unselectedLabelColor: AppTheme.textSecondary,
                    tabs: const [
                      Tab(text: 'Programs'),
                      Tab(text: 'Track Referrals'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProgramsTab(programProvider),
                    _buildReferralsTab(userProvider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(ProgramProvider programProvider) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
        children: programProvider.categories.map((category) {
          final isSelected = programProvider.selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.spacingSM),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                // setState is needed here to rebuild the filter chips
                setState(() {
                  programProvider.filterByCategory(category);
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.borderColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgramsTab(ProgramProvider programProvider) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _currentTabIndex == 0 ? 1.0 : 0.0,
      child: _buildProgramsGrid(programProvider),
    );
  }

  Widget _buildProgramsGrid(ProgramProvider programProvider) {
    if (programProvider.isLoading) {
      return const LoadingIndicator(
        message: 'Loading programs...',
        fullScreen: true,
      );
    }

    if (programProvider.error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Oops!',
        message: 'Failed to load programs. Please try again.',
        actionText: 'Retry',
        onAction: () => programProvider.loadPrograms(),
      );
    }

    final programs = programProvider.filteredPrograms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppConstants.spacingMD,
            bottom: AppConstants.spacingMD,
          ),
          child: _buildFilterChips(programProvider),
        ),
        if (programs.isEmpty)
          const Expanded(
            child: Center(
              child: EmptyState(
                icon: Icons.school_outlined,
                title: 'No Programs Found',
                message: 'Try adjusting your search or filters',
              ),
            ),
          )
        else
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final crossAxisSpacing = AppConstants.spacingMD;
                final cardWidth = (screenWidth - (crossAxisSpacing * 2)) / 2;
                const cardHeight = 280;
                final childAspectRatio = cardWidth / cardHeight;

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spacingMD,
                    0,
                    AppConstants.spacingMD,
                    AppConstants.spacingMD,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: crossAxisSpacing,
                    mainAxisSpacing: AppConstants.spacingMD,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: programs.length,
                  itemBuilder: (context, index) {
                    final program = programs[index];
                    return ProgramCard(
                      universityName: program.universityName,
                      programName: program.programName,
                      duration: program.duration,
                      mode: program.mode,
                      earning: program.earning,
                      logoPath: program.logoPath,
                      onTap: () => _showProgramDetailsPopup(program),
                      onShare: () =>
                          _shareProgram(program.id, program.programName),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildReferralsTab(UserProvider userProvider) {
    final referrals = userProvider.referrals;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _currentTabIndex == 1 ? 1.0 : 0.0,
      child: Builder(
        builder: (context) {
          if (referrals.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              title: 'No Referrals Yet',
              message: 'Start referring friends to earn cash!',
            );
          }

          return Column(
            children: [
              _buildReferralSummary(userProvider),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  itemCount: referrals.length,
                  itemBuilder: (context, index) {
                    final referral = referrals[index];
                    return ReferralTracker(
                      friendName: referral.friendName,
                      profilePictureUrl: referral.profilePictureUrl,
                      programName:
                          '${referral.programName} - ${referral.universityName}',
                      applicationStage:
                          referral.applicationStage ?? ApplicationStage.invited,
                      earning: referral.earning,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReferralSummary(UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Referrals',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              Text(
                userProvider.totalReferralCount.toString(),
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Enrolled',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              Text(
                userProvider.enrolledReferralCount.toString(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Filter Bottom Sheet Widget
class _FilterBottomSheet extends StatefulWidget {
  final ProgramProvider programProvider;

  const _FilterBottomSheet({required this.programProvider});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String selectedCategory;
  late String selectedMode;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.programProvider.selectedCategory;
    selectedMode = widget.programProvider.selectedMode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = 'All';
                    selectedMode = 'All';
                  });
                  widget.programProvider.clearFilters();
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMD),

          // Category filter
          Text('Category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppConstants.spacingSM),
          Wrap(
            spacing: 8,
            children: widget.programProvider.categories.map((category) {
              final isSelected = selectedCategory == category;
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    selectedCategory = category;
                  });
                  widget.programProvider.filterByCategory(category);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spacingMD),

          // Mode filter
          Text('Mode', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppConstants.spacingSM),
          Wrap(
            spacing: 8,
            children: widget.programProvider.modes.map((mode) {
              final isSelected = selectedMode == mode;
              return FilterChip(
                label: Text(mode),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    selectedMode = mode;
                  });
                  widget.programProvider.filterByMode(mode);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spacingLG),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
