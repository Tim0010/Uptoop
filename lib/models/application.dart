// Application status enum
enum ApplicationStatus {
  draft,
  inProgress,
  submitted,
  accepted,
  rejected,
  withdrawn,
}

// Application stage enum
enum ApplicationStage {
  invited,
  applicationStarted,
  personalInfoSubmitted,
  academicInfoSubmitted,
  documentsSubmitted,
  applicationFeePaid,
  applicationSubmitted,
}

// Application model
class Application {
  final String id;
  final String programId;
  final String userId;
  final String? referralId;
  // Link to referral if this application came from a referral
  final String fullName;
  final String email;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final String? nationality;
  final bool termsAndConditionsAccepted;
  final String? profilePictureUrl;
  final String? photoIdUrl;
  final String? marksheet10thUrl;
  final String? marksheet12thUrl;
  final String? graduationMarksheetsUrl;
  final String? degreeCertificateUrl;
  final bool documentsSubmitted;
  final bool enrollmentConfirmed;
  final bool applicationFeePaid;
  final bool enrollmentFeePaid;
  final ApplicationStatus status;
  final ApplicationStage stage; // Application stage
  final DateTime createdAt;
  final DateTime? submittedAt;
  final DateTime? completedAt;

  // Document Collection Fields
  final String? fatherName;
  final String? motherName;
  final String? gender;
  final String?
  aadharNumber; // Aadhar number limit to 12 digits as per government guidelines
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pinCode;
  final String? category;
  final Map<String, String> uploadedDocuments;

  // Constructor
  Application({
    required this.id,
    required this.programId,
    required this.userId,
    this.referralId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.documentsSubmitted = false,
    this.dateOfBirth,
    this.nationality,
    this.termsAndConditionsAccepted = false,
    this.profilePictureUrl,
    this.photoIdUrl,
    this.marksheet10thUrl,
    this.marksheet12thUrl,
    this.graduationMarksheetsUrl,
    this.degreeCertificateUrl,
    this.enrollmentConfirmed = false,
    this.applicationFeePaid = false,
    this.enrollmentFeePaid = false,
    this.status = ApplicationStatus.draft,
    this.stage = ApplicationStage.invited,
    required this.createdAt,
    this.submittedAt,
    this.completedAt,
    this.fatherName,
    this.motherName,
    this.gender,
    this.aadharNumber,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pinCode,
    this.category,
    this.uploadedDocuments = const {},
  });

  // Calculate progress percentage
  int get progressPercentage {
    int completed = 0;
    if (fullName.isNotEmpty && email.isNotEmpty && phoneNumber.isNotEmpty) {
      completed++;
    }
    if (documentsSubmitted) completed++;
    if (enrollmentConfirmed) completed++;
    if (applicationFeePaid) completed++;
    if (enrollmentFeePaid) completed++;
    return ((completed / 5) * 100).toInt();
  }

  // Check if application is complete
  bool get isComplete =>
      fullName.isNotEmpty &&
      email.isNotEmpty &&
      phoneNumber.isNotEmpty &&
      documentsSubmitted &&
      enrollmentConfirmed &&
      applicationFeePaid &&
      enrollmentFeePaid;

  // Get status display text
  String get statusText {
    switch (status) {
      case ApplicationStatus.draft:
        return 'Draft';
      case ApplicationStatus.inProgress:
        return 'In Progress';
      case ApplicationStatus.submitted:
        return 'Submitted';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  // Get stage display text
  String get stageText {
    switch (stage) {
      case ApplicationStage.invited:
        return 'Invited';
      case ApplicationStage.applicationStarted:
        return 'Application Started';
      case ApplicationStage.personalInfoSubmitted:
        return 'Personal Info Submitted';
      case ApplicationStage.academicInfoSubmitted:
        return 'Academic Info Submitted';
      case ApplicationStage.documentsSubmitted:
        return 'Documents Submitted';
      case ApplicationStage.applicationFeePaid:
        return 'Application Fee Paid';
      case ApplicationStage.applicationSubmitted:
        return 'Application Submitted';
    }
  }

  // Copy with method
  Application copyWith({
    String? id,
    String? programId,
    String? userId,
    String? referralId,
    String? fullName,
    String? email,
    String? phoneNumber,
    bool? documentsSubmitted,
    DateTime? dateOfBirth,
    String? nationality,
    bool? termsAndConditionsAccepted,
    String? profilePictureUrl,
    String? photoIdUrl,
    String? marksheet10thUrl,
    String? marksheet12thUrl,
    String? graduationMarksheetsUrl,
    String? degreeCertificateUrl,
    bool? enrollmentConfirmed,
    bool? applicationFeePaid,
    bool? enrollmentFeePaid,
    ApplicationStatus? status,
    ApplicationStage? stage,
    DateTime? createdAt,
    DateTime? submittedAt,
    DateTime? completedAt,
    String? fatherName,
    String? motherName,
    String? gender,
    String? aadharNumber,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pinCode,
    String? category,
    Map<String, String>? uploadedDocuments,
  }) {
    return Application(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      userId: userId ?? this.userId,
      referralId: referralId ?? this.referralId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      documentsSubmitted: documentsSubmitted ?? this.documentsSubmitted,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      termsAndConditionsAccepted:
          termsAndConditionsAccepted ?? this.termsAndConditionsAccepted,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      photoIdUrl: photoIdUrl ?? this.photoIdUrl,
      marksheet10thUrl: marksheet10thUrl ?? this.marksheet10thUrl,
      marksheet12thUrl: marksheet12thUrl ?? this.marksheet12thUrl,
      graduationMarksheetsUrl:
          graduationMarksheetsUrl ?? this.graduationMarksheetsUrl,
      degreeCertificateUrl: degreeCertificateUrl ?? this.degreeCertificateUrl,
      enrollmentConfirmed: enrollmentConfirmed ?? this.enrollmentConfirmed,
      applicationFeePaid: applicationFeePaid ?? this.applicationFeePaid,
      enrollmentFeePaid: enrollmentFeePaid ?? this.enrollmentFeePaid,
      status: status ?? this.status,
      stage: stage ?? this.stage,
      createdAt: createdAt ?? this.createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      completedAt: completedAt ?? this.completedAt,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      gender: gender ?? this.gender,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pinCode: pinCode ?? this.pinCode,
      category: category ?? this.category,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
    );
  }

  // JSON serialization
  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as String,
      programId: json['programId'] as String,
      userId: json['userId'] as String,
      referralId: json['referralId'] as String?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      documentsSubmitted: json['documentsSubmitted'] as bool? ?? false,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      nationality: json['nationality'] as String?,
      termsAndConditionsAccepted:
          json['termsAndConditionsAccepted'] as bool? ?? false,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      photoIdUrl: json['photoIdUrl'] as String?,
      marksheet10thUrl: json['marksheet10thUrl'] as String?,
      marksheet12thUrl: json['marksheet12thUrl'] as String?,
      graduationMarksheetsUrl: json['graduationMarksheetsUrl'] as String?,
      degreeCertificateUrl: json['degreeCertificateUrl'] as String?,
      enrollmentConfirmed: json['enrollmentConfirmed'] as bool? ?? false,
      applicationFeePaid: json['applicationFeePaid'] as bool? ?? false,
      enrollmentFeePaid: json['enrollmentFeePaid'] as bool? ?? false,
      status: ApplicationStatus.values[json['status'] as int? ?? 0],
      stage: ApplicationStage.values[json['stage'] as int? ?? 0],
      createdAt: DateTime.parse(json['createdAt'] as String),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      fatherName: json['fatherName'] as String?,
      motherName: json['motherName'] as String?,
      gender: json['gender'] as String?,
      aadharNumber: json['aadharNumber'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      pinCode: json['pinCode'] as String?,
      category: json['category'] as String?,
      uploadedDocuments: Map<String, String>.from(
        json['uploadedDocuments'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'programId': programId,
      'userId': userId,
      'referralId': referralId,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'documentsSubmitted': documentsSubmitted,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'nationality': nationality,
      'termsAndConditionsAccepted': termsAndConditionsAccepted,
      'profilePictureUrl': profilePictureUrl,
      'photoIdUrl': photoIdUrl,
      'marksheet10thUrl': marksheet10thUrl,
      'marksheet12thUrl': marksheet12thUrl,
      'graduationMarksheetsUrl': graduationMarksheetsUrl,
      'degreeCertificateUrl': degreeCertificateUrl,
      'enrollmentConfirmed': enrollmentConfirmed,
      'applicationFeePaid': applicationFeePaid,
      'enrollmentFeePaid': enrollmentFeePaid,
      'status': status.index,
      'stage': stage.index,
      'createdAt': createdAt.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'fatherName': fatherName,
      'motherName': motherName,
      'gender': gender,
      'aadharNumber': aadharNumber,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pinCode': pinCode,
      'category': category,
      'uploadedDocuments': uploadedDocuments,
    };
  }

  /// Get referral status based on application progress
  /// This is used to update the referral tracker status
  ///
  /// Mapping:
  /// - Application created -> 'invited'
  /// - Personal info saved -> 'application_started'
  /// - Documents submitted -> 'documents'
  /// - Application fee paid -> 'fee_paid'
  /// - Enrollment confirmed -> 'enrolled'
  String getReferralStatus() {
    if (enrollmentConfirmed) {
      return 'enrolled';
    } else if (applicationFeePaid) {
      return 'fee_paid';
    } else if (documentsSubmitted) {
      return 'documents';
    } else if (fullName.isNotEmpty || fatherName != null || address != null) {
      return 'application_started';
    } else {
      return 'invited';
    }
  }

  /// Get application stage string for referral tracking
  /// This maps the ApplicationStage enum to database string values
  String getApplicationStageString() {
    switch (stage) {
      case ApplicationStage.invited:
        return 'invited';
      case ApplicationStage.applicationStarted:
        return 'application_started';
      case ApplicationStage.personalInfoSubmitted:
        return 'personal_info_submitted';
      case ApplicationStage.academicInfoSubmitted:
        return 'academic_info_submitted';
      case ApplicationStage.documentsSubmitted:
        return 'documents_submitted';
      case ApplicationStage.applicationFeePaid:
        return 'application_fee_paid';
      case ApplicationStage.applicationSubmitted:
        return 'application_submitted';
    }
  }

  /// Calculate the current stage based on what's been completed
  /// This is called automatically when updating the application
  ApplicationStage calculateCurrentStage() {
    // Check from most advanced to least advanced
    if (enrollmentConfirmed || status == ApplicationStatus.submitted) {
      return ApplicationStage.applicationSubmitted;
    }
    if (applicationFeePaid) {
      return ApplicationStage.applicationFeePaid;
    }
    if (documentsSubmitted) {
      return ApplicationStage.documentsSubmitted;
    }
    // Check if academic info is filled (graduation details, category, etc.)
    if (category != null && category!.isNotEmpty) {
      return ApplicationStage.academicInfoSubmitted;
    }
    // Check if personal info is filled (name, email, phone, father name, etc.)
    if (fullName.isNotEmpty &&
        email.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        (fatherName != null && fatherName!.isNotEmpty)) {
      return ApplicationStage.personalInfoSubmitted;
    }
    // Check if any basic info is filled
    if (fullName.isNotEmpty || email.isNotEmpty || phoneNumber.isNotEmpty) {
      return ApplicationStage.applicationStarted;
    }
    // Default: just invited
    return ApplicationStage.invited;
  }
}
