import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/providers/wallet_provider.dart';
import 'package:uptop_careers/providers/user_provider.dart';
import 'package:uptop_careers/widgets/transaction_list_item.dart';
import 'package:uptop_careers/widgets/loading_indicator.dart';
import 'package:uptop_careers/widgets/empty_state.dart';
import 'package:uptop_careers/widgets/withdrawal_prompt.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().loadTransactions();
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
    final walletProvider = context.watch<WalletProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    if (walletProvider.isLoading) {
      return const LoadingIndicator(
        message: 'Loading Wallet...',
        fullScreen: true,
      );
    }

    if (user == null) {
      return const EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No Wallet Data',
        message: 'Please login to see your wallet.',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(
              user.totalEarnings,
              user.pendingEarnings,
              walletProvider.availableBalance,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _showWithdrawalPrompt(walletProvider.availableBalance),
                icon: const Icon(Icons.arrow_upward),
                label: const Text('Withdraw Funds'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spacingMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLG),
            _buildEarningsOverview(
              userProvider.totalReferralCount,
              userProvider.enrolledReferralCount,
              userProvider.activeReferrals.length,
            ),
            const SizedBox(height: AppConstants.spacingLG),
            _buildRecentTransactions(walletProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    double totalBalance,
    double pending,
    double withdrawable,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      color: AppTheme.primaryBlue,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white70,
                  size: 16,
                ),
                SizedBox(width: AppConstants.spacingSM),
                Text('Total Balance', style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              '${AppConstants.currency}${totalBalance.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMD),
            const Divider(color: Colors.white24),
            const SizedBox(height: AppConstants.spacingMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceDetail(
                  icon: Icons.pending_actions,
                  title: 'Pending',
                  amount: pending,
                ),
                _buildBalanceDetail(
                  icon: Icons.check_circle,
                  title: 'Withdrawable',
                  amount: withdrawable,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceDetail({
    required IconData icon,
    required String title,
    required double amount,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: AppConstants.spacingSM),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(width: AppConstants.spacingSM),
        Text(
          '${AppConstants.currency}${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
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

  Widget _buildRecentTransactions(WalletProvider walletProvider) {
    final transactions = walletProvider.filteredTransactions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppConstants.spacingMD),
        if (transactions.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No Transactions',
            message: 'Your transaction history will appear here',
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return TransactionListItem(transaction: transactions[index]);
            },
          ),
      ],
    );
  }
}
