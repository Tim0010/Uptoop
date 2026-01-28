import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/user_data_service.dart';
import '../models/referral.dart';
import '../models/mission.dart';
import '../models/program.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  List<Referral> _referrals = [];
  List<Mission> _missions = [];
  final List<Program> _programs = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  List<Referral> get referrals => _referrals;
  List<Mission> get missions => _missions;
  List<Program> get programs => _programs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered getters
  List<Referral> get activeReferrals =>
      _referrals.where((r) => r.isActive).toList();

  List<Referral> get completedReferrals =>
      _referrals.where((r) => r.isCompleted).toList();

  List<Referral> get recentReferrals => _referrals.take(5).toList();

  int get totalReferralCount => _referrals.length;

  int get enrolledReferralCount =>
      _referrals.where((r) => r.status == 'enrolled').length;

  List<Mission> get dailyMissions =>
      _missions.where((m) => m.isDailyMission && !m.isExpired).toList();

  List<Mission> get weeklyMissions =>
      _missions.where((m) => m.isWeeklyMission && !m.isExpired).toList();

  List<Mission> get activeMissions =>
      _missions.where((m) => !m.isCompleted && !m.isExpired).toList();

  // Update user coins
  void updateCoins(int coinsToAdd) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        coins: _currentUser!.coins + coinsToAdd,
      );
      notifyListeners();
    }
  }

  // Create new user account
  Future<void> createUserAccount({
    required String name,
    required String age,
    required String email,
    required String college,
    required String phoneNumber,
    String? referralCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1000));

      // Generate unique user ID and referral code
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final userReferralCode = _generateReferralCode(name);

      // Create new user
      _currentUser = User(
        id: userId,
        name: name,
        email: email,
        phone: phoneNumber,
        referralCode: userReferralCode,
        avatarUrl: null,
        level: 1,
        totalEarnings: 0,
        pendingEarnings: 0,
        monthlyEarnings: 0,
        totalReferrals: 0,
        activeReferrals: 0,
        currentStreak: 0,
        coins: referralCode != null ? 100 : 0, // Bonus coins for referred users
        interests: [],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        age: age,
        school: college,
      );

      // If user was referred, create a referral record
      if (referralCode != null) {
        // TODO: In production, this would create a referral record on the backend
        // linking this new user to the referrer
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to create account: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate referral code from name
  String _generateReferralCode(String name) {
    final cleanName = name.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    final prefix = cleanName.length >= 3
        ? cleanName.substring(0, 3)
        : cleanName;
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final suffix = timestamp.substring(timestamp.length - 4);
    return '$prefix$suffix';
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? age,
    String? school,
    String? email,
    String? phone,
    List<String>? interests,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = _currentUser!.copyWith(
        name: name,
        age: age,
        school: school,
        email: email,
        phone: phone,
        interests: interests,
      );

      _error = null;
    } catch (e) {
      _error = 'Failed to update profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user data from Supabase (with local fallback)
  Future<void> loadUserData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) {
        try {
          return DateTime.parse(v);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    String? toString(dynamic v) {
      if (v == null) return null;
      if (v is String) return v;
      return v.toString();
    }

    try {
      final profile = await UserDataService.getCurrentUserProfile();

      if (profile == null) {
        // No user found: clear state gracefully
        _currentUser = null;
        _referrals = [];
        _missions = _defaultMissions();
        _isLoading = false;
        notifyListeners();
        return;
      }

      final id = (profile['id'] ?? '') as String;
      final fullName =
          (profile['full_name'] ?? profile['fullName'] ?? 'User') as String;
      final email = (profile['email'] ?? '') as String;
      final phone =
          (profile['phone_number'] ?? profile['phoneNumber'] ?? '') as String;
      final referralCode =
          (profile['referral_code'] ??
                  profile['referralCode'] ??
                  _generateReferralCode(fullName))
              as String;

      final level = (profile['level'] ?? 1) as int;
      final totalEarnings = (profile['total_earnings'] != null)
          ? (profile['total_earnings'] as num).toDouble()
          : 0.0;
      final pendingEarnings = (profile['pending_earnings'] != null)
          ? (profile['pending_earnings'] as num).toDouble()
          : 0.0;
      final monthlyEarnings = (profile['monthly_earnings'] != null)
          ? (profile['monthly_earnings'] as num).toDouble()
          : 0.0;
      final totalReferrals = (profile['total_referrals'] ?? 0) as int;
      final activeReferrals = (profile['active_referrals'] ?? 0) as int;
      final currentStreak = (profile['current_streak'] ?? 0) as int;
      final coins = (profile['coins'] ?? 0) as int;

      final createdAt = parseDate(profile['created_at']) ?? DateTime.now();
      final lastLoginAt = parseDate(profile['last_login_at']);
      final age = toString(profile['age']);
      final school =
          (profile['college'] as String?) ?? toString(profile['school']);

      _currentUser = User(
        id: id,
        name: fullName,
        email: email,
        phone: phone,
        referralCode: referralCode,
        avatarUrl: profile['avatar_url'] as String?,
        level: level,
        totalEarnings: totalEarnings,
        pendingEarnings: pendingEarnings,
        monthlyEarnings: monthlyEarnings,
        totalReferrals: totalReferrals,
        activeReferrals: activeReferrals,
        currentStreak: currentStreak,
        coins: coins,
        interests: <String>[],
        createdAt: createdAt,
        lastLoginAt: lastLoginAt,
        age: age,
        school: school,
      );

      // Load referrals from Supabase (or empty list)
      final refsData = await UserDataService.getUserReferrals();
      _referrals = refsData
          .map(
            (r) => Referral(
              id: (r['id'] ?? '') as String,
              friendName: (r['referred_name'] ?? '') as String,
              friendEmail: (r['referred_email'] ?? '') as String,
              friendPhone: (r['referred_phone'] ?? '') as String,
              profilePictureUrl: r['profile_picture_url'] as String?,
              programId: (r['program_id'] ?? '') as String,
              programName: (r['program_name'] ?? '') as String,
              universityName: (r['university_name'] ?? '') as String,
              status: (r['status'] ?? 'pending') as String,
              applicationStageString: r['application_stage'] as String?,
              earning: (r['reward_amount'] != null)
                  ? (r['reward_amount'] as num).toDouble()
                  : 0.0,
              createdAt: parseDate(r['created_at']) ?? DateTime.now(),
              updatedAt: parseDate(r['updated_at']),
              enrolledAt: parseDate(r['enrolled_at']),
            ),
          )
          .toList();

      // Keep missions as local for now
      _missions = _defaultMissions();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Mission> _defaultMissions() {
    return [
      Mission(
        id: 'm1',
        title: 'Share 3 Programs',
        description: 'Share any 3 programs with your friends today',
        type: 'daily',
        reward: 50,
        progress: 0,
        total: 3,
        expiresAt: DateTime.now().add(const Duration(hours: 12)),
      ),
      Mission(
        id: 'm2',
        title: 'Daily Login',
        description: 'Login to the app today',
        type: 'daily',
        reward: 20,
        progress: 0,
        total: 1,
        isCompleted: false,
        expiresAt: DateTime.now().add(const Duration(hours: 12)),
      ),
    ];
  }

  // Update user earnings
  void updateEarnings(double amount) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        totalEarnings: _currentUser!.totalEarnings + amount,
      );
      notifyListeners();
    }
  }

  // Add referral
  void addReferral(Referral referral) {
    _referrals.insert(0, referral);
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        totalReferrals: _currentUser!.totalReferrals + 1,
      );
    }
    notifyListeners();
  }

  // Update referral status
  void updateReferralStatus(String referralId, String newStatus) {
    final index = _referrals.indexWhere((r) => r.id == referralId);
    if (index != -1) {
      _referrals[index] = _referrals[index].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
}
