import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game.dart';

class GameProvider with ChangeNotifier {
  List<GameReward> _rewardHistory = [];
  List<DailyChallenge> _dailyChallenges = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastSpinTime;
  int _scratchCardsAvailable = 3;

  // Getters
  List<GameReward> get rewardHistory => _rewardHistory;
  List<DailyChallenge> get dailyChallenges => _dailyChallenges;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastSpinTime => _lastSpinTime;
  int get scratchCardsAvailable => _scratchCardsAvailable;

  // Computed values
  int get totalCoinsEarned =>
      _rewardHistory.fold(0, (sum, reward) => sum + reward.coins);

  bool get canSpin {
    if (_lastSpinTime == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_lastSpinTime!);
    return difference.inHours >= 24;
  }

  String get nextSpinTime {
    if (_lastSpinTime == null) return 'Available now!';
    final nextSpin = _lastSpinTime!.add(const Duration(hours: 24));
    final now = DateTime.now();
    final difference = nextSpin.difference(now);

    if (difference.isNegative) return 'Available now!';

    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }

  List<DailyChallenge> get activeChallenges =>
      _dailyChallenges.where((c) => !c.isCompleted && !c.isExpired).toList();

  List<DailyChallenge> get completedChallenges =>
      _dailyChallenges.where((c) => c.isCompleted).toList();

  // Load game data
  Future<void> loadGameData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock reward history
      _rewardHistory = [
        GameReward(
          id: 'reward1',
          type: 'spin',
          coins: 50,
          description: 'Spin Wheel Reward',
          earnedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        GameReward(
          id: 'reward2',
          type: 'daily_challenge',
          coins: 100,
          description: 'Daily Login Streak',
          earnedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        GameReward(
          id: 'reward3',
          type: 'scratch',
          coins: 25,
          description: 'Scratch Card Win',
          earnedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      // Mock daily challenges
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      _dailyChallenges = [
        DailyChallenge(
          id: 'challenge1',
          title: 'Share 3 Programs',
          description: 'Share 3 programs with friends today',
          reward: 50,
          progress: 1,
          target: 3,
          isCompleted: false,
          expiresAt: tomorrow,
        ),
        DailyChallenge(
          id: 'challenge2',
          title: 'Daily Login',
          description: 'Login to the app today',
          reward: 20,
          progress: 1,
          target: 1,
          isCompleted: true,
          completedAt: DateTime.now(),
          expiresAt: tomorrow,
        ),
        DailyChallenge(
          id: 'challenge3',
          title: 'Refer a Friend',
          description: 'Add a new referral today',
          reward: 100,
          progress: 0,
          target: 1,
          isCompleted: false,
          expiresAt: tomorrow,
        ),
      ];

      // Set last spin time (24 hours ago for testing)
      _lastSpinTime = DateTime.now().subtract(const Duration(hours: 25));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Spin wheel
  Future<int> spinWheel() async {
    if (!canSpin) return 0;

    // Simulate spinning
    await Future.delayed(const Duration(seconds: 2));

    // Random reward between 10-100 coins
    final random = Random();
    final rewards = [10, 20, 25, 50, 75, 100];
    final coins = rewards[random.nextInt(rewards.length)];

    // Add to history
    final reward = GameReward(
      id: 'reward_${DateTime.now().millisecondsSinceEpoch}',
      type: 'spin',
      coins: coins,
      description: 'Spin Wheel Reward',
      earnedAt: DateTime.now(),
    );

    _rewardHistory.insert(0, reward);
    _lastSpinTime = DateTime.now();
    notifyListeners();

    return coins;
  }

  // Scratch card
  Future<int> scratchCard() async {
    if (_scratchCardsAvailable <= 0) return 0;

    // Simulate scratching
    await Future.delayed(const Duration(seconds: 1));

    // Random reward between 5-50 coins
    final random = Random();
    final rewards = [5, 10, 15, 20, 25, 50];
    final coins = rewards[random.nextInt(rewards.length)];

    // Add to history
    final reward = GameReward(
      id: 'reward_${DateTime.now().millisecondsSinceEpoch}',
      type: 'scratch',
      coins: coins,
      description: 'Scratch Card Win',
      earnedAt: DateTime.now(),
    );

    _rewardHistory.insert(0, reward);
    _scratchCardsAvailable--;
    notifyListeners();

    return coins;
  }
}

