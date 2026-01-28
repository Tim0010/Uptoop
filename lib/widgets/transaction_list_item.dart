import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/models/transaction.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final isPending = transaction.isPending;
    final iconData = _getIconForTransaction(transaction);
    final color = isCredit ? AppTheme.successGreen : AppTheme.errorRed;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(iconData, color: color, size: 20),
            ),
            const SizedBox(width: AppConstants.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPending ? 'Pending' : DateFormat('MMM d, yyyy').format(transaction.createdAt),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.spacingMD),
            Text(
              '${isCredit ? '+' : '-'}${AppConstants.currency}${transaction.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: isPending ? AppTheme.textSecondary : color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTransaction(Transaction transaction) {
    if (transaction.isPending) {
      return Icons.hourglass_empty;
    }
    if (transaction.isCredit) {
      return Icons.arrow_downward;
    }
    if (transaction.isDebit) {
      return Icons.arrow_upward;
    }
    return Icons.help_outline;
  }
}
