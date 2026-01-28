import 'package:flutter/foundation.dart';
import 'package:uptop_careers/models/application.dart';

/// Merge strategy for resolving conflicts
enum MergeStrategy {
  /// Use local data (client wins)
  useLocal,

  /// Use remote data (server wins)
  useRemote,

  /// Use most recent data based on timestamp
  useMostRecent,

  /// Merge both, preferring non-null values
  mergePreferNonNull,
}

/// Service to handle data conflicts between local and remote data
class ConflictResolutionService {
  /// Resolve conflict between local and remote application
  ///
  /// Default strategy: Use most recent based on updatedAt timestamp
  static Application resolveApplicationConflict({
    required Application local,
    required Application remote,
    MergeStrategy strategy = MergeStrategy.useMostRecent,
  }) {
    debugPrint('🔀 Resolving conflict for application ${local.id}');
    debugPrint('   Local updated: ${local.createdAt}');
    debugPrint('   Remote updated: ${remote.createdAt}');

    switch (strategy) {
      case MergeStrategy.useLocal:
        debugPrint('   ✅ Using local version');
        return local;

      case MergeStrategy.useRemote:
        debugPrint('   ✅ Using remote version');
        return remote;

      case MergeStrategy.useMostRecent:
        // Compare timestamps - use the most recent one
        final localTime = local.createdAt;
        final remoteTime = remote.createdAt;

        if (localTime.isAfter(remoteTime)) {
          debugPrint('   ✅ Using local version (more recent)');
          return local;
        } else {
          debugPrint('   ✅ Using remote version (more recent)');
          return remote;
        }

      case MergeStrategy.mergePreferNonNull:
        debugPrint('   ✅ Merging with non-null preference');
        return _mergeApplications(local, remote);
    }
  }

  /// Merge two applications, preferring non-null values
  static Application _mergeApplications(Application local, Application remote) {
    return Application(
      id: local.id,
      programId: local.programId,
      userId: local.userId,
      referralId: local.referralId ?? remote.referralId,
      fullName: local.fullName.isNotEmpty ? local.fullName : remote.fullName,
      email: local.email.isNotEmpty ? local.email : remote.email,
      phoneNumber: local.phoneNumber.isNotEmpty
          ? local.phoneNumber
          : remote.phoneNumber,
      dateOfBirth: local.dateOfBirth ?? remote.dateOfBirth,
      nationality: local.nationality ?? remote.nationality,
      termsAndConditionsAccepted:
          local.termsAndConditionsAccepted || remote.termsAndConditionsAccepted,
      profilePictureUrl: local.profilePictureUrl ?? remote.profilePictureUrl,
      photoIdUrl: local.photoIdUrl ?? remote.photoIdUrl,
      marksheet10thUrl: local.marksheet10thUrl ?? remote.marksheet10thUrl,
      marksheet12thUrl: local.marksheet12thUrl ?? remote.marksheet12thUrl,
      graduationMarksheetsUrl:
          local.graduationMarksheetsUrl ?? remote.graduationMarksheetsUrl,
      degreeCertificateUrl:
          local.degreeCertificateUrl ?? remote.degreeCertificateUrl,
      documentsSubmitted: local.documentsSubmitted || remote.documentsSubmitted,
      enrollmentConfirmed:
          local.enrollmentConfirmed || remote.enrollmentConfirmed,
      applicationFeePaid: local.applicationFeePaid || remote.applicationFeePaid,
      enrollmentFeePaid: local.enrollmentFeePaid || remote.enrollmentFeePaid,
      status: _mergeStatus(local.status, remote.status),
      createdAt: local.createdAt.isBefore(remote.createdAt)
          ? local.createdAt
          : remote.createdAt,
      submittedAt: local.submittedAt ?? remote.submittedAt,
      completedAt: local.completedAt ?? remote.completedAt,
      fatherName: local.fatherName ?? remote.fatherName,
      motherName: local.motherName ?? remote.motherName,
      gender: local.gender ?? remote.gender,
      aadharNumber: local.aadharNumber ?? remote.aadharNumber,
      address: local.address ?? remote.address,
      city: local.city ?? remote.city,
      state: local.state ?? remote.state,
      country: local.country ?? remote.country,
      pinCode: local.pinCode ?? remote.pinCode,
      category: local.category ?? remote.category,
      uploadedDocuments: {
        ...remote.uploadedDocuments,
        ...local.uploadedDocuments,
      },
    );
  }

  /// Merge application status - prefer more advanced status
  static ApplicationStatus _mergeStatus(
    ApplicationStatus local,
    ApplicationStatus remote,
  ) {
    final statusPriority = {
      ApplicationStatus.draft: 0,
      ApplicationStatus.inProgress: 1,
      ApplicationStatus.submitted: 2,
      ApplicationStatus.accepted: 3,
      ApplicationStatus.rejected: 3,
      ApplicationStatus.withdrawn: 3,
    };

    final localPriority = statusPriority[local] ?? 0;
    final remotePriority = statusPriority[remote] ?? 0;

    return localPriority >= remotePriority ? local : remote;
  }

  /// Check if applications have conflicts
  static bool hasConflict(Application local, Application remote) {
    // Check if key fields differ
    return local.fullName != remote.fullName ||
        local.email != remote.email ||
        local.phoneNumber != remote.phoneNumber ||
        local.status != remote.status ||
        local.documentsSubmitted != remote.documentsSubmitted ||
        local.applicationFeePaid != remote.applicationFeePaid ||
        local.enrollmentConfirmed != remote.enrollmentConfirmed;
  }

  /// Get conflict details
  static Map<String, dynamic> getConflictDetails(
    Application local,
    Application remote,
  ) {
    final conflicts = <String, dynamic>{};

    if (local.fullName != remote.fullName) {
      conflicts['fullName'] = {
        'local': local.fullName,
        'remote': remote.fullName,
      };
    }
    if (local.email != remote.email) {
      conflicts['email'] = {'local': local.email, 'remote': remote.email};
    }
    if (local.phoneNumber != remote.phoneNumber) {
      conflicts['phoneNumber'] = {
        'local': local.phoneNumber,
        'remote': remote.phoneNumber,
      };
    }
    if (local.status != remote.status) {
      conflicts['status'] = {'local': local.status, 'remote': remote.status};
    }

    return conflicts;
  }
}
