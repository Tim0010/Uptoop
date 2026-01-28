class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String referralCode;
  final String? avatarUrl;
  final int level;
  final double totalEarnings;
  final double pendingEarnings;
  final double monthlyEarnings;
  final int totalReferrals;
  final int activeReferrals;
  final int currentStreak;
  final int coins;
  final List<String> interests;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? age;
  final String? school;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.referralCode,
    this.avatarUrl,
    required this.level,
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.monthlyEarnings,
    required this.totalReferrals,
    required this.activeReferrals,
    required this.currentStreak,
    required this.coins,
    required this.interests,
    required this.createdAt,
    this.lastLoginAt,
    this.age,
    this.school,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      referralCode: json['referralCode'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      level: json['level'] as int,
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      pendingEarnings: (json['pendingEarnings'] as num).toDouble(),
      monthlyEarnings: (json['monthlyEarnings'] as num).toDouble(),
      totalReferrals: json['totalReferrals'] as int,
      activeReferrals: json['activeReferrals'] as int,
      currentStreak: json['currentStreak'] as int,
      coins: json['coins'] as int,
      interests: List<String>.from(json['interests'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      age: json['age'] as String?,
      school: json['school'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'referralCode': referralCode,
      'avatarUrl': avatarUrl,
      'level': level,
      'totalEarnings': totalEarnings,
      'pendingEarnings': pendingEarnings,
      'monthlyEarnings': monthlyEarnings,
      'totalReferrals': totalReferrals,
      'activeReferrals': activeReferrals,
      'currentStreak': currentStreak,
      'coins': coins,
      'interests': interests,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'age': age,
      'school': school,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? referralCode,
    String? avatarUrl,
    int? level,
    double? totalEarnings,
    double? pendingEarnings,
    double? monthlyEarnings,
    int? totalReferrals,
    int? activeReferrals,
    int? currentStreak,
    int? coins,
    List<String>? interests,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? age,
    String? school,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      referralCode: referralCode ?? this.referralCode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      pendingEarnings: pendingEarnings ?? this.pendingEarnings,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      activeReferrals: activeReferrals ?? this.activeReferrals,
      currentStreak: currentStreak ?? this.currentStreak,
      coins: coins ?? this.coins,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      age: age ?? this.age,
      school: school ?? this.school,
    );
  }

  String get levelName {
    switch (level) {
      case 1:
        return 'Starter';
      case 2:
        return 'Influencer';
      case 3:
        return 'Ambassador';
      case 4:
        return 'Elite';
      case 5:
        return 'Legend';
      default:
        return 'Starter';
    }
  }

  get fullName => null;
}
