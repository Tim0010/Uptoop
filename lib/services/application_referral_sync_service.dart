import 'package:flutter/foundation.dart';
import 'package:uptop_careers/models/application.dart';
import 'package:uptop_careers/services/user_data_service.dart';
import 'package:uptop_careers/services/retry_service.dart';

/// Service to sync application progress with referral tracker status
///
/// This service uses the Application model's built-in methods to ensure
/// consistency across the app. All status/stage mapping logic is centralized
/// in the Application model.
class ApplicationReferralSyncService {
  /// Map application progress to referral status
  ///
  /// This method delegates to Application.getReferralStatus() to ensure
  /// consistent status mapping across the app.
  ///
  /// @deprecated Use application.getReferralStatus() directly instead
  static String getStatusFromApplication(Application application) {
    return application.getReferralStatus();
  }

  /// Get application stage for referral tracking
  ///
  /// This method delegates to Application.getApplicationStageString() to ensure
  /// consistent stage mapping across the app.
  ///
  /// @deprecated Use application.getApplicationStageString() directly instead
  static String getApplicationStage(Application application) {
    return application.getApplicationStageString();
  }

  /// Update referral status when application progresses
  /// Uses retry logic with exponential backoff for network errors
  static Future<bool> syncApplicationToReferral(Application application) async {
    if (application.referralId == null) {
      debugPrint('⚠️ No referral ID linked to this application');
      return false;
    }

    try {
      // Use Application model methods for consistent status/stage mapping
      final status = application.getReferralStatus();
      final applicationStage = application.getApplicationStageString();
      final isCompleted = application.enrollmentConfirmed;

      debugPrint(
        '🔄 Syncing application ${application.id} to referral ${application.referralId}',
      );
      debugPrint(
        '   Status: $status, Stage: $applicationStage, Completed: $isCompleted',
      );

      // Use retry logic for network resilience
      final success = await RetryService.retryOnNetworkError(
        operation: () async {
          return await UserDataService.updateReferralStatus(
            referralId: application.referralId!,
            status: status,
            applicationStage: applicationStage,
            isCompleted: isCompleted,
          );
        },
        maxAttempts: 3,
        initialDelay: 1000,
      );

      if (success) {
        debugPrint('✅ Referral status synced successfully');
      } else {
        debugPrint('❌ Failed to sync referral status');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error syncing application to referral: $e');
      return false;
    }
  }

  /// Check if application progress should trigger referral update
  static bool shouldSyncToReferral(
    Application oldApplication,
    Application newApplication,
  ) {
    // Check if any significant progress was made by comparing statuses
    final oldStatus = oldApplication.getReferralStatus();
    final newStatus = newApplication.getReferralStatus();

    return oldStatus != newStatus;
  }

  /// Get reward amount based on application stage
  static double getRewardAmount(Application application) {
    if (application.enrollmentConfirmed) {
      return 20000.0; // ₹20,000 when enrolled
    } else if (application.applicationFeePaid) {
      return 500.0; // ₹500 when application fee paid
    } else {
      return 0.0;
    }
  }

  /// Get reward message for display
  static String? getRewardMessage(Application application) {
    if (application.enrollmentConfirmed) {
      return 'Your referrer received a reward of ₹20,000';
    } else if (application.applicationFeePaid) {
      return 'Your referrer received a reward of ₹500';
    } else {
      return null;
    }
  }
}
