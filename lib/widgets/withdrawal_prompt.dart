import 'package:flutter/material.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/config/theme.dart';

class WithdrawalPrompt extends StatefulWidget {
  final double withdrawableBalance;

  const WithdrawalPrompt({super.key, required this.withdrawableBalance});

  @override
  State<WithdrawalPrompt> createState() => _WithdrawalPromptState();
}

class _WithdrawalPromptState extends State<WithdrawalPrompt> {
  final _upiController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _upiController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppConstants.spacingLG),
            _buildAvailableBalance(),
            const SizedBox(height: AppConstants.spacingLG),
            _buildUpiField(),
            const SizedBox(height: AppConstants.spacingMD),
            _buildAmountField(),
            const SizedBox(height: AppConstants.spacingLG),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Withdraw to UPI', style: Theme.of(context).textTheme.titleLarge),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildAvailableBalance() {
    final bool hasMinimumBalance =
        widget.withdrawableBalance >= AppConstants.minWithdrawalAmount;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          decoration: BoxDecoration(
            color: hasMinimumBalance
                ? AppTheme.successGreen.withOpacity(0.1)
                : AppTheme.accentOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          ),
          child: Column(
            children: [
              Text(
                'Available to Withdraw',
                style: TextStyle(
                  color: hasMinimumBalance
                      ? AppTheme.successGreen
                      : AppTheme.accentOrange,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSM),
              Text(
                '${AppConstants.currency}${widget.withdrawableBalance.toStringAsFixed(0)}',
                style: TextStyle(
                  color: hasMinimumBalance
                      ? AppTheme.successGreen
                      : AppTheme.accentOrange,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSM),
              Text(
                'Only completed earnings can be withdrawn',
                style: TextStyle(
                  color: hasMinimumBalance
                      ? AppTheme.successGreen.withOpacity(0.7)
                      : AppTheme.accentOrange.withOpacity(0.7),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        // Minimum requirement notice
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          decoration: BoxDecoration(
            color: hasMinimumBalance
                ? AppTheme.primaryBlue.withOpacity(0.1)
                : AppTheme.errorRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            border: Border.all(
              color: hasMinimumBalance
                  ? AppTheme.primaryBlue.withOpacity(0.3)
                  : AppTheme.errorRed.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasMinimumBalance ? Icons.check_circle : Icons.info,
                color: hasMinimumBalance
                    ? AppTheme.primaryBlue
                    : AppTheme.errorRed,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacingSM),
              Expanded(
                child: Text(
                  hasMinimumBalance
                      ? 'Minimum withdrawal is ${AppConstants.currency}${AppConstants.minWithdrawalAmount.toStringAsFixed(0)}. You can withdraw now!'
                      : widget.withdrawableBalance > 0
                      ? 'Minimum withdrawal is ${AppConstants.currency}${AppConstants.minWithdrawalAmount.toStringAsFixed(0)}. You need ${AppConstants.currency}${(AppConstants.minWithdrawalAmount - widget.withdrawableBalance).toStringAsFixed(0)} more in available balance.'
                      : 'Minimum withdrawal is ${AppConstants.currency}${AppConstants.minWithdrawalAmount.toStringAsFixed(0)}. You need ${AppConstants.currency}${AppConstants.minWithdrawalAmount.toStringAsFixed(0)} in available balance. (Pending earnings cannot be withdrawn)',
                  style: TextStyle(
                    color: hasMinimumBalance
                        ? AppTheme.primaryBlue
                        : AppTheme.errorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpiField() {
    final bool hasMinimumBalance =
        widget.withdrawableBalance >= AppConstants.minWithdrawalAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('UPI ID', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppConstants.spacingSM),
        TextFormField(
          controller: _upiController,
          enabled: hasMinimumBalance,
          decoration: InputDecoration(
            hintText: hasMinimumBalance
                ? 'yourname@upi'
                : 'Minimum balance required',
          ),
          validator: (value) {
            if (!hasMinimumBalance) return null; // Skip validation if disabled
            if (value == null || value.isEmpty) {
              return 'Please enter your UPI ID';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid UPI ID';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    final bool hasMinimumBalance =
        widget.withdrawableBalance >= AppConstants.minWithdrawalAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount (₹)', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppConstants.spacingSM),
        TextFormField(
          controller: _amountController,
          enabled: hasMinimumBalance,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hasMinimumBalance
                ? 'Enter amount (Min ${AppConstants.currency}${AppConstants.minWithdrawalAmount.toStringAsFixed(0)})'
                : 'Minimum balance required',
          ),
          validator: (value) {
            if (!hasMinimumBalance) return null; // Skip validation if disabled
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null) {
              return 'Please enter a valid amount';
            }
            if (amount > widget.withdrawableBalance) {
              return 'Amount exceeds withdrawable balance';
            }
            if (amount < AppConstants.minWithdrawalAmount) {
              return 'Minimum withdrawal is ${AppConstants.currency}${AppConstants.minWithdrawalAmount.toStringAsFixed(0)}';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    final bool hasMinimumBalance =
        widget.withdrawableBalance >= AppConstants.minWithdrawalAmount;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasMinimumBalance
            ? () {
                if (_formKey.currentState!.validate()) {
                  // Pop the bottom sheet
                  Navigator.pop(context);
                  // Show confirmation dialog
                  _showConfirmationDialog();
                }
              }
            : null, // Disabled when below minimum
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMD),
          backgroundColor: hasMinimumBalance ? null : Colors.grey,
        ),
        child: Text(
          hasMinimumBalance
              ? 'Confirm Withdrawal'
              : 'Insufficient Balance (Min ${AppConstants.currency}${AppConstants.minWithdrawalAmount.toStringAsFixed(0)})',
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          ),
          title: const Text('Withdrawal Submitted'),
          content: const Text(
            'Your withdrawal request has been received and is being processed. It may take up to 24 hours to reflect in your account.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
