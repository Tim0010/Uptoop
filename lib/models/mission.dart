class Mission {
  final String id;
  final String title;
  final String description;
  final String type;
  final int reward;
  final int progress;
  final int total;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime expiresAt;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.reward,
    required this.progress,
    required this.total,
    this.isCompleted = false,
    this.completedAt,
    required this.expiresAt,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      reward: json['reward'] as int,
      progress: json['progress'] as int,
      total: json['total'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'reward': reward,
      'progress': progress,
      'total': total,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  Mission copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    int? reward,
    int? progress,
    int? total,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? expiresAt,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      reward: reward ?? this.reward,
      progress: progress ?? this.progress,
      total: total ?? this.total,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  double get progressPercent {
    if (total == 0) return 0.0;
    return (progress / total).clamp(0.0, 1.0);
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  bool get isDailyMission {
    return type == 'daily';
  }

  bool get isWeeklyMission {
    return type == 'weekly';
  }
}

