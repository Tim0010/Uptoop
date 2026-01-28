import 'package:flutter/material.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/models/application.dart';

/// Widget to display the user's own application progress
class MyApplicationProgress extends StatelessWidget {
  final Application application;
  final String programName;
  final VoidCallback onTap;

  const MyApplicationProgress({
    super.key,
    required this.application,
    required this.programName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stage = application.calculateCurrentStage();
    final stageInfo = _getStageInfo(stage);
    final progress = _getProgressPercentage(stage);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingLG),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            gradient: LinearGradient(
              colors: [
                stageInfo['color'].withOpacity(0.1),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    color: stageInfo['color'],
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.spacingSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Application',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          programName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMD),
              
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stageInfo['label'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: stageInfo['color'],
                        ),
                      ),
                      Text(
                        '$progress%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: stageInfo['color'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingSM),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(stageInfo['color']),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMD),
              
              // Next step hint
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMD,
                  vertical: AppConstants.spacingSM,
                ),
                decoration: BoxDecoration(
                  color: stageInfo['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: stageInfo['color'],
                    ),
                    const SizedBox(width: AppConstants.spacingSM),
                    Expanded(
                      child: Text(
                        _getNextStepMessage(stage),
                        style: TextStyle(
                          fontSize: 12,
                          color: stageInfo['color'],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get stage display information (label and color)
  Map<String, dynamic> _getStageInfo(ApplicationStage stage) {
    switch (stage) {
      case ApplicationStage.invited:
        return {'label': 'Not Started', 'color': Colors.grey};
      case ApplicationStage.applicationStarted:
        return {'label': 'Application Started', 'color': AppTheme.accentOrange};
      case ApplicationStage.personalInfoSubmitted:
        return {'label': 'Personal Info Submitted', 'color': AppTheme.accentOrange};
      case ApplicationStage.academicInfoSubmitted:
        return {'label': 'Academic Info Submitted', 'color': AppTheme.accentOrange};
      case ApplicationStage.documentsSubmitted:
        return {'label': 'Documents Submitted', 'color': Colors.purple};
      case ApplicationStage.applicationFeePaid:
        return {'label': 'Fee Paid', 'color': Colors.purple};
      case ApplicationStage.applicationSubmitted:
        return {'label': 'Application Submitted', 'color': AppTheme.successGreen};
    }
  }

  /// Get progress percentage based on stage
  int _getProgressPercentage(ApplicationStage stage) {
    switch (stage) {
      case ApplicationStage.invited:
        return 0;
      case ApplicationStage.applicationStarted:
        return 15;
      case ApplicationStage.personalInfoSubmitted:
        return 30;
      case ApplicationStage.academicInfoSubmitted:
        return 50;
      case ApplicationStage.documentsSubmitted:
        return 70;
      case ApplicationStage.applicationFeePaid:
        return 85;
      case ApplicationStage.applicationSubmitted:
        return 100;
    }
  }

  /// Get next step message based on current stage
  String _getNextStepMessage(ApplicationStage stage) {
    switch (stage) {
      case ApplicationStage.invited:
        return 'Tap to start your application';
      case ApplicationStage.applicationStarted:
        return 'Complete personal information';
      case ApplicationStage.personalInfoSubmitted:
        return 'Fill in academic details';
      case ApplicationStage.academicInfoSubmitted:
        return 'Upload required documents';
      case ApplicationStage.documentsSubmitted:
        return 'Pay application fee';
      case ApplicationStage.applicationFeePaid:
        return 'Submit your application';
      case ApplicationStage.applicationSubmitted:
        return 'Application submitted successfully!';
    }
  }
}

