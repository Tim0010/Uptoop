import 'package:flutter/foundation.dart';
import '../models/leaderboard_entry.dart';
import '../services/supabase_service.dart';

class LeaderboardProvider with ChangeNotifier {
  List<LeaderboardEntry> _entries = [];
  String _selectedPeriod =
      'all_time'; // 'daily', 'weekly', 'monthly', 'all_time'
  bool _isLoading = false;
  String? _error;
  double? _weeklyUserEarnings;
  double? _monthlyUserEarnings;

  // Getters
  List<LeaderboardEntry> get entries => _entries;
  String get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get weeklyUserEarnings => _weeklyUserEarnings;
  double? get monthlyUserEarnings => _monthlyUserEarnings;

  // Computed values
  LeaderboardEntry? get currentUserEntry =>
      _entries.firstWhere((e) => e.isCurrentUser, orElse: () => _entries.first);

  List<LeaderboardEntry> get topThree =>
      _entries.where((e) => e.rank <= 3).toList();

  int get totalParticipants => _entries.length;

  String get periodLabel {
    switch (_selectedPeriod) {
      case 'daily':
        return 'Today';
      case 'weekly':
        return 'This Week';
      case 'monthly':
        return 'This Month';
      case 'all_time':
        return 'All Time';
      default:
        return 'All Time';
    }
  }

  // Load leaderboard data
  Future<void> loadLeaderboard({String? period}) async {
    if (period != null) {
      _selectedPeriod = period;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (SupabaseService.isConfigured && SupabaseService.isAuthenticated) {
        final supaPeriod = _selectedPeriod == 'monthly' ? 'monthly' : 'weekly';
        final rows = await SupabaseService.getLeaderboard(
          period: supaPeriod,
          limit: 100,
          offset: 0,
        );

        final currentUserId = SupabaseService.currentUser?.id;
        _entries = rows.map((r) {
          final userId = r['user_id'] as String;
          return LeaderboardEntry(
            id: '${userId}_$supaPeriod',
            userId: userId,
            name: (r['display_name'] as String?) ?? 'User',
            avatarUrl: r['avatar_url'] as String?,
            rank: (r['rank'] as num).toInt(),
            totalReferrals: (r['total_referrals'] as num?)?.toInt() ?? 0,
            totalEarnings: (r['total_earnings'] as num?)?.toDouble() ?? 0.0,
            coins: (r['coins'] as num?)?.toInt() ?? 0,
            level: (r['level'] as num?)?.toInt() ?? 1,
            university: null,
            city: null,
            isCurrentUser: userId == currentUserId,
          );
        }).toList();

        // Also compute user's weekly and monthly earnings for summary cards
        await _refreshUserEarnings();
      } else {
        // Fallback: mock data when Supabase is not configured
        await Future.delayed(const Duration(milliseconds: 300));
        _entries = [
          LeaderboardEntry(
            id: 'entry1',
            userId: 'user1',
            name: 'Priya Sharma',
            rank: 1,
            totalReferrals: 45,
            totalEarnings: 112500,
            coins: 2500,
            level: 10,
            university: 'Shoolini University',
            city: 'Solan',
          ),
          LeaderboardEntry(
            id: 'entry2',
            userId: 'user2',
            name: 'Rahul Kumar',
            rank: 2,
            totalReferrals: 38,
            totalEarnings: 95000,
            coins: 2100,
            level: 9,
            university: 'UPES',
            city: 'Dehradun',
          ),
          LeaderboardEntry(
            id: 'entry3',
            userId: 'user3',
            name: 'Ananya Patel',
            rank: 3,
            totalReferrals: 32,
            totalEarnings: 80000,
            coins: 1800,
            level: 8,
            university: 'Amity University',
            city: 'Noida',
          ),
        ];

        // Mock summary amounts for offline mode
        _weeklyUserEarnings = 2850;
        _monthlyUserEarnings = 12850;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change period filter
  void changePeriod(String period) {
    if (_selectedPeriod != period) {
      loadLeaderboard(period: period);
    }
  }

  Future<void> _refreshUserEarnings() async {
    try {
      if (!(SupabaseService.isConfigured && SupabaseService.isAuthenticated)) {
        return;
      }

      final currentUserId = SupabaseService.currentUser?.id;
      if (currentUserId == null) return;

      // Fetch weekly and monthly leaderboards and pick current user's earnings
      final weeklyRows = await SupabaseService.getLeaderboard(
        period: 'weekly',
        limit: 100,
        offset: 0,
      );
      final monthlyRows = await SupabaseService.getLeaderboard(
        period: 'monthly',
        limit: 100,
        offset: 0,
      );

      double weekly = 0;
      for (final r in weeklyRows) {
        if (r['user_id'] == currentUserId) {
          weekly = (r['total_earnings'] as num?)?.toDouble() ?? 0.0;
          break;
        }
      }

      double monthly = 0;
      for (final r in monthlyRows) {
        if (r['user_id'] == currentUserId) {
          monthly = (r['total_earnings'] as num?)?.toDouble() ?? 0.0;
          break;
        }
      }

      _weeklyUserEarnings = weekly;
      _monthlyUserEarnings = monthly;
      notifyListeners();
    } catch (_) {
      // Silently ignore; keep previous values
    }
  }
}
