class GameReward {
  final String id;
  final String type; // 'spin', 'scratch', 'daily_challenge'
  final int coins;
  final String description;
  final DateTime earnedAt;

  GameReward({
    required this.id,
    required this.type,
    required this.coins,
    required this.description,
    required this.earnedAt,
  });

  // From JSON
  factory GameReward.fromJson(Map<String, dynamic> json) {
    return GameReward(
      id: json['id'] as String,
      type: json['type'] as String,
      coins: json['coins'] as int,
      description: json['description'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'coins': coins,
      'description': description,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }

  String get typeLabel {
    switch (type) {
      case 'spin':
        return 'Spin Wheel';
      case 'scratch':
        return 'Scratch Card';
      case 'daily_challenge':
        return 'Daily Challenge';
      default:
        return 'Game';
    }
  }
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int reward;
  final int progress;
  final int target;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime expiresAt;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.progress,
    required this.target,
    required this.isCompleted,
    this.completedAt,
    required this.expiresAt,
  });

  // From JSON
  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      reward: json['reward'] as int,
      progress: json['progress'] as int,
      target: json['target'] as int,
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reward': reward,
      'progress': progress,
      'target': target,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  // Copy with
  DailyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    int? reward,
    int? progress,
    int? target,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? expiresAt,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reward: reward ?? this.reward,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  // Computed properties
  double get progressPercent => (progress / target * 100).clamp(0, 100);
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canClaim => progress >= target && !isCompleted;

  String get timeRemaining {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) return 'Expired';

    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m left';
    } else {
      return '${difference.inMinutes}m left';
    }
  }
}

