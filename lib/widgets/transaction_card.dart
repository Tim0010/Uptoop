import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: Icon(
                  _getIcon(),
                  color: _getIconBackgroundColor(),
                  size: AppConstants.iconMD,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type and status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction.typeLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _buildStatusChip(),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      transaction.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Date
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a')
                          .format(transaction.createdAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),

              // Amount
              Text(
                '${transaction.isCredit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: transaction.isCredit
                      ? AppTheme.successGreen
                      : Colors.red[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (transaction.isEarning) return Icons.account_balance_wallet;
    if (transaction.isWithdrawal) return Icons.arrow_upward;
    if (transaction.isBonus) return Icons.card_giftcard;
    return Icons.remove_circle_outline;
  }

  Color _getIconBackgroundColor() {
    if (transaction.isEarning) return AppTheme.successGreen;
    if (transaction.isWithdrawal) return AppTheme.accentOrange;
    if (transaction.isBonus) return AppTheme.primaryBlue;
    return Colors.red;
  }

  Widget _buildStatusChip() {
    Color chipColor;
    Color textColor;

    switch (transaction.status) {
      case 'completed':
        chipColor = AppTheme.successGreen.withOpacity(0.1);
        textColor = AppTheme.successGreen;
        break;
      case 'pending':
        chipColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'processing':
        chipColor = AppTheme.primaryBlue.withOpacity(0.1);
        textColor = AppTheme.primaryBlue;
        break;
      case 'failed':
        chipColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
      ),
      child: Text(
        transaction.statusLabel,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

