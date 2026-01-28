class Program {
  final String id;
  final String universityId;
  final String universityName;
  final String programName;
  final String category;
  final String duration;
  final String mode;
  final double earning;
  final String? logoPath;
  final String? description;
  final List<String> highlights;
  final String? brochureUrl;
  final bool isActive;
  final int? maxReferrals;
  final int currentReferrals;

  Program({
    required this.id,
    required this.universityId,
    required this.universityName,
    required this.programName,
    required this.category,
    required this.duration,
    required this.mode,
    required this.earning,
    this.logoPath,
    this.description,
    required this.highlights,
    this.brochureUrl,
    this.isActive = true,
    this.maxReferrals,
    this.currentReferrals = 0,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'] as String,
      universityId:
          json['university_id'] as String? ??
          json['universityId'] as String? ??
          '',
      universityName:
          json['university_name'] as String? ??
          json['universityName'] as String,
      programName:
          json['program_name'] as String? ?? json['programName'] as String,
      category: json['category'] as String,
      duration: json['duration'] as String,
      mode: json['mode'] as String,
      earning: (json['earning'] as num).toDouble(),
      logoPath: json['logo_url'] as String? ?? json['logoPath'] as String?,
      description: json['description'] as String?,
      highlights: json['highlights'] != null
          ? List<String>.from(json['highlights'] as List)
          : [],
      brochureUrl:
          json['brochure_url'] as String? ?? json['brochureUrl'] as String?,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      maxReferrals:
          json['max_referrals'] as int? ?? json['maxReferrals'] as int?,
      currentReferrals:
          json['current_referrals'] as int? ??
          json['currentReferrals'] as int? ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'university_id': universityId,
      'university_name': universityName,
      'program_name': programName,
      'category': category,
      'duration': duration,
      'mode': mode,
      'earning': earning,
      'logo_url': logoPath,
      'description': description,
      'highlights': highlights,
      'brochure_url': brochureUrl,
      'is_active': isActive,
      'max_referrals': maxReferrals,
      'current_referrals': currentReferrals,
    };
  }

  Program copyWith({
    String? id,
    String? universityId,
    String? universityName,
    String? programName,
    String? category,
    String? duration,
    String? mode,
    double? earning,
    String? logoPath,
    String? description,
    List<String>? highlights,
    String? brochureUrl,
    bool? isActive,
    int? maxReferrals,
    int? currentReferrals,
  }) {
    return Program(
      id: id ?? this.id,
      universityId: universityId ?? this.universityId,
      universityName: universityName ?? this.universityName,
      programName: programName ?? this.programName,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      mode: mode ?? this.mode,
      earning: earning ?? this.earning,
      logoPath: logoPath ?? this.logoPath,
      description: description ?? this.description,
      highlights: highlights ?? this.highlights,
      brochureUrl: brochureUrl ?? this.brochureUrl,
      isActive: isActive ?? this.isActive,
      maxReferrals: maxReferrals ?? this.maxReferrals,
      currentReferrals: currentReferrals ?? this.currentReferrals,
    );
  }
}
