import 'package:flutter/material.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/models/game.dart';

class ChallengeCard extends StatelessWidget {
  final DailyChallenge challenge;
  final VoidCallback? onClaim;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getIconColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: _getIconColor(),
                    size: AppConstants.iconMD,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMD),

                // Title and reward
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            size: 16,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${challenge.reward} coins',
                            style: TextStyle(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status or claim button
                if (challenge.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppTheme.successGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Done',
                          style: TextStyle(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (challenge.canClaim)
                  ElevatedButton(
                    onPressed: onClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Claim'),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMD),

            // Description
            Text(
              challenge.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMD),

            // Progress bar
            if (!challenge.isCompleted) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${challenge.progress}/${challenge.target}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    challenge.timeRemaining,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                child: LinearProgressIndicator(
                  value: challenge.progressPercent / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(),
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (challenge.isCompleted) return Icons.check_circle;
    if (challenge.canClaim) return Icons.card_giftcard;
    return Icons.flag;
  }

  Color _getIconColor() {
    if (challenge.isCompleted) return AppTheme.successGreen;
    if (challenge.canClaim) return AppTheme.accentOrange;
    return AppTheme.primaryBlue;
  }

  Color _getProgressColor() {
    if (challenge.progressPercent >= 100) return AppTheme.successGreen;
    if (challenge.progressPercent >= 50) return AppTheme.accentOrange;
    return AppTheme.primaryBlue;
  }
}

