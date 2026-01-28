import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptop_careers/models/leaderboard_entry.dart';
import 'package:uptop_careers/providers/leaderboard_provider.dart';
import 'package:uptop_careers/widgets/leaderboard_item.dart';
import 'package:uptop_careers/widgets/empty_state.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial leaderboard after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardProvider>().loadLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    _buildYourRankCard(
                      rank: provider.entries.isNotEmpty
                          ? (provider.entries.any((e) => e.isCurrentUser)
                                ? provider.entries
                                      .firstWhere((e) => e.isCurrentUser)
                                      .rank
                                : null)
                          : null,
                      participants: provider.totalParticipants,
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryCards(context),
                    const SizedBox(height: 16),
                    _buildPeriodToggle(context),
                    const SizedBox(height: 16),
                    if (provider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (provider.error != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Failed to load leaderboard: ${provider.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else if (provider.entries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: EmptyState(
                          icon: Icons.emoji_events_outlined,
                          title: 'No leaderboard yet',
                          message:
                              'Once ambassadors start referring, you\'ll see ranks here.',
                          actionText: 'Retry',
                          onAction: () => context
                              .read<LeaderboardProvider>()
                              .loadLeaderboard(),
                        ),
                      )
                    else
                      _buildLeaderboardList(provider.entries),
                    const SizedBox(height: 24),
                    _buildWeeklyRewardsCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const SliverAppBar(
      title: Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      pinned: false,
    );
  }

  Widget _buildYourRankCard({required int? rank, required int participants}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue.shade700,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.white.withOpacity(0.8),
              size: 48,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Rank',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    rank != null ? '#$rank' : '#-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Out of $participants campus ambassadors',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();
    String fmt(double? v) => v == null ? '₹—' : '₹${v.toStringAsFixed(0)}';
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.trending_up,
            iconColor: Colors.green,
            amount: fmt(provider.weeklyUserEarnings),
            period: 'This Week',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.calendar_today,
            iconColor: Colors.blue,
            amount: fmt(provider.monthlyUserEarnings),
            period: 'This Month',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String amount,
    required String period,
  }) {
    return Card(
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              amount,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              period,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodToggle(BuildContext context) {
    final selected = context.watch<LeaderboardProvider>().selectedPeriod;
    final isWeekly = selected == 'weekly';
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  context.read<LeaderboardProvider>().changePeriod('weekly'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isWeekly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'This Week',
                    style: TextStyle(
                      fontWeight: isWeekly
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  context.read<LeaderboardProvider>().changePeriod('monthly'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isWeekly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'This Month',
                    style: TextStyle(
                      fontWeight: !isWeekly
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> entries) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return LeaderboardItem(entry: entries[index]);
      },
    );
  }

  Widget _buildWeeklyRewardsCard() {
    return Card(
      elevation: 0,
      color: Colors.amber.shade100.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber.shade800,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Rewards',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRewardTier(
              rank: '#1',
              reward: '₹5,000 bonus + exclusive badge',
            ),
            _buildRewardTier(rank: '#2-3', reward: '₹2,500 bonus'),
            _buildRewardTier(rank: '#4-10', reward: '₹1,000 bonus'),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardTier({required String rank, required String reward}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 18),
          const SizedBox(width: 8),
          Text(
            rank,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(reward, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
