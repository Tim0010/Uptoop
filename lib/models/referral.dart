import 'package:uptop_careers/models/application.dart';

class Referral {
  final String id;
  final String friendName;
  final String friendEmail;
  final String friendPhone;
  final String? profilePictureUrl; // Profile picture of the referred user
  final String programId;
  final String programName;
  final String universityName;
  final String status;
  final String?
  applicationStageString; // Store the raw application_stage from database
  final double earning;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? enrolledAt;

  Referral({
    required this.id,
    required this.friendName,
    required this.friendEmail,
    required this.friendPhone,
    this.profilePictureUrl,
    required this.programId,
    required this.programName,
    required this.universityName,
    required this.status,
    this.applicationStageString,
    required this.earning,
    required this.createdAt,
    this.updatedAt,
    this.enrolledAt,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] as String,
      friendName: json['friendName'] as String,
      friendEmail: json['friendEmail'] as String,
      friendPhone: json['friendPhone'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      programId: json['programId'] as String,
      programName: json['programName'] as String,
      universityName: json['universityName'] as String,
      status: json['status'] as String,
      applicationStageString: json['applicationStage'] as String?,
      earning: (json['earning'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      enrolledAt: json['enrolledAt'] != null
          ? DateTime.parse(json['enrolledAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'friendName': friendName,
      'friendEmail': friendEmail,
      'friendPhone': friendPhone,
      'profilePictureUrl': profilePictureUrl,
      'programId': programId,
      'programName': programName,
      'universityName': universityName,
      'status': status,
      'applicationStage': applicationStageString,
      'earning': earning,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'enrolledAt': enrolledAt?.toIso8601String(),
    };
  }

  Referral copyWith({
    String? id,
    String? friendName,
    String? friendEmail,
    String? friendPhone,
    String? profilePictureUrl,
    String? programId,
    String? programName,
    String? universityName,
    String? status,
    String? applicationStageString,
    double? earning,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? enrolledAt,
  }) {
    return Referral(
      id: id ?? this.id,
      friendName: friendName ?? this.friendName,
      friendEmail: friendEmail ?? this.friendEmail,
      friendPhone: friendPhone ?? this.friendPhone,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      programId: programId ?? this.programId,
      programName: programName ?? this.programName,
      universityName: universityName ?? this.universityName,
      status: status ?? this.status,
      applicationStageString:
          applicationStageString ?? this.applicationStageString,
      earning: earning ?? this.earning,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      enrolledAt: enrolledAt ?? this.enrolledAt,
    );
  }

  bool get isActive {
    return status != 'enrolled' && status != 'rejected';
  }

  bool get isCompleted {
    return status == 'enrolled';
  }

  String get statusLabel {
    switch (status) {
      case 'invited':
        return 'Friend invited';
      case 'application_started':
        return 'Application in progress';
      case 'documents':
        return 'Documents submitted';
      case 'fee_paid':
        return 'Fee paid';
      case 'enrolled':
        return 'Enrolled - You earned!';
      case 'rejected':
        return 'Application rejected';
      default:
        return status;
    }
  }

  // Convert the string application_stage from database to ApplicationStage enum
  ApplicationStage? get applicationStage {
    if (applicationStageString == null) {
      // If no application stage is set, derive it from status
      return _getStageFromStatus();
    }

    // Map database application_stage strings to ApplicationStage enum
    switch (applicationStageString) {
      case 'invited':
        return ApplicationStage.invited;
      case 'application_started':
      case 'personal_info_submitted':
        return ApplicationStage.applicationStarted;
      case 'academic_info_submitted':
        return ApplicationStage.academicInfoSubmitted;
      case 'documents':
      case 'documents_submitted':
        return ApplicationStage.documentsSubmitted;
      case 'application_fee_paid':
      case 'fee_paid':
        return ApplicationStage.applicationFeePaid;
      case 'application_submitted':
      case 'enrolled':
        return ApplicationStage.applicationSubmitted;
      default:
        return _getStageFromStatus();
    }
  }

  // Fallback: derive stage from status if application_stage is not available
  ApplicationStage _getStageFromStatus() {
    switch (status) {
      case 'invited':
      case 'pending':
        return ApplicationStage.invited;
      case 'application_started':
        return ApplicationStage.applicationStarted;
      case 'documents':
        return ApplicationStage.documentsSubmitted;
      case 'fee_paid':
        return ApplicationStage.applicationFeePaid;
      case 'enrolled':
        return ApplicationStage.applicationSubmitted;
      default:
        return ApplicationStage.invited;
    }
  }
}
