import 'package:flutter/material.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/models/application.dart';

class ReferralTracker extends StatelessWidget {
  final String friendName;
  final String? profilePictureUrl; // Profile picture of the referred user
  final String programName;
  final ApplicationStage applicationStage;
  final double earning;
  final VoidCallback? onTap;

  const ReferralTracker({
    super.key,
    required this.friendName,
    this.profilePictureUrl,
    required this.programName,
    required this.applicationStage,
    required this.earning,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: AppConstants.spacingLG),
              _buildProgressSteps(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildProfileAvatar(),
        const SizedBox(width: AppConstants.spacingMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friendName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                programName,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _buildStatusChip(context),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final stageInfo = _getStageInfo(applicationStage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: stageInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        stageInfo['label'],
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: stageInfo['color'],
        ),
      ),
    );
  }

  /// Get stage display information (label and color)
  Map<String, dynamic> _getStageInfo(ApplicationStage stage) {
    switch (stage) {
      case ApplicationStage.invited:
        return {'label': 'Invited', 'color': Colors.blue};
      case ApplicationStage.applicationStarted:
        return {'label': 'Started', 'color': AppTheme.accentOrange};
      case ApplicationStage.personalInfoSubmitted:
        return {'label': 'Personal Info', 'color': AppTheme.accentOrange};
      case ApplicationStage.academicInfoSubmitted:
        return {'label': 'Academic Info', 'color': AppTheme.accentOrange};
      case ApplicationStage.documentsSubmitted:
        return {'label': 'Documents', 'color': AppTheme.accentOrange};
      case ApplicationStage.applicationFeePaid:
        return {'label': 'Fee Paid', 'color': Colors.purple};
      case ApplicationStage.applicationSubmitted:
        return {'label': 'Submitted', 'color': AppTheme.successGreen};
    }
  }

  Widget _buildProgressSteps(BuildContext context) {
    // Map ApplicationStage to step index (0-6)
    int currentStepIndex = _getStepIndex(applicationStage);

    const steps = [
      'Invited',
      'Started',
      'Personal',
      'Academic',
      'Docs',
      'Fee Paid',
      'Submitted',
    ];
    const icons = [
      Icons.mail_outline,
      Icons.edit_outlined,
      Icons.person_outline,
      Icons.school_outlined,
      Icons.description_outlined,
      Icons.payment,
      Icons.check_circle,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(steps.length, (index) {
          return Padding(
            padding: EdgeInsets.only(right: index < steps.length - 1 ? 8.0 : 0),
            child: _buildStepItem(
              context,
              steps[index],
              icons[index],
              index,
              currentStepIndex,
            ),
          );
        }),
      ),
    );
  }

  // Helper method to convert ApplicationStage to step index
  int _getStepIndex(ApplicationStage stage) {
    switch (stage) {
      case ApplicationStage.invited:
        return 0;
      case ApplicationStage.applicationStarted:
        return 1;
      case ApplicationStage.personalInfoSubmitted:
        return 2;
      case ApplicationStage.academicInfoSubmitted:
        return 3;
      case ApplicationStage.documentsSubmitted:
        return 4;
      case ApplicationStage.applicationFeePaid:
        return 5;
      case ApplicationStage.applicationSubmitted:
        return 6;
    }
  }

  Widget _buildStepItem(
    BuildContext context,
    String label,
    IconData icon,
    int index,
    int currentIndex,
  ) {
    final isCompleted = index < currentIndex;
    final isCurrent = index == currentIndex;

    Color iconColor;
    Color circleColor;

    if (isCompleted) {
      iconColor = Colors.white;
      circleColor = AppTheme.successGreen;
    } else if (isCurrent) {
      iconColor = AppTheme.primaryBlue;
      circleColor = AppTheme.primaryBlue.withValues(alpha: 0.2);
    } else {
      iconColor = Colors.grey[400]!;
      circleColor = Colors.grey[200]!;
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: circleColor,
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build profile avatar with picture or first initial
  Widget _buildProfileAvatar() {
    // If profile picture URL is available, show it
    if (profilePictureUrl != null && profilePictureUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: AppTheme.primaryBlue,
        backgroundImage: NetworkImage(profilePictureUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // If image fails to load, fall back to initial
          debugPrint('⚠️ Failed to load profile picture: $exception');
        },
        child: null, // No child when showing image
      );
    }

    // Otherwise, show first initial of name
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppTheme.primaryBlue,
      child: friendName.isEmpty
          ? const Icon(Icons.person, color: Colors.white)
          : Text(
              friendName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
    );
  }
}
