class LeaderboardEntry {
  final String id;
  final String userId;
  final String name;
  final String? avatarUrl;
  final int rank;
  final int totalReferrals;
  final double totalEarnings;
  final int coins;
  final int level;
  final String? university;
  final String? city;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.rank,
    required this.totalReferrals,
    required this.totalEarnings,
    required this.coins,
    required this.level,
    this.university,
    this.city,
    this.isCurrentUser = false,
  });

  // From JSON
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      rank: json['rank'] as int,
      totalReferrals: json['totalReferrals'] as int,
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      coins: json['coins'] as int,
      level: json['level'] as int,
      university: json['university'] as String?,
      city: json['city'] as String?,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'avatarUrl': avatarUrl,
      'rank': rank,
      'totalReferrals': totalReferrals,
      'totalEarnings': totalEarnings,
      'coins': coins,
      'level': level,
      'university': university,
      'city': city,
      'isCurrentUser': isCurrentUser,
    };
  }

  // Copy with
  LeaderboardEntry copyWith({
    String? id,
    String? userId,
    String? name,
    String? avatarUrl,
    int? rank,
    int? totalReferrals,
    double? totalEarnings,
    int? coins,
    int? level,
    String? university,
    String? city,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rank: rank ?? this.rank,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      coins: coins ?? this.coins,
      level: level ?? this.level,
      university: university ?? this.university,
      city: city ?? this.city,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  // Computed properties
  bool get isTopThree => rank <= 3;
  
  String get rankBadge {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  String get levelName {
    if (level >= 10) return 'Master';
    if (level >= 7) return 'Expert';
    if (level >= 5) return 'Advanced';
    if (level >= 3) return 'Intermediate';
    return 'Beginner';
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  String get location {
    if (university != null && city != null) {
      return '$university, $city';
    } else if (university != null) {
      return university!;
    } else if (city != null) {
      return city!;
    }
    return 'India';
  }
}

