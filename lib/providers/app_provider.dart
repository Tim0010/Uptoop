import 'package:flutter/material.dart';

class AppProvider with ChangeNotifier {
  int _currentTabIndex = 0;
  String _referralSubTab = 'programs';
  int _notificationCount = 3;
  bool _isLoading = false;

  // Getters
  int get currentTabIndex => _currentTabIndex;
  String get referralSubTab => _referralSubTab;
  int get notificationCount => _notificationCount;
  bool get isLoading => _isLoading;

  // Tab Navigation
  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void navigateToTab(int index, {String? subTab}) {
    _currentTabIndex = index;
    if (subTab != null && index == 1) {
      // Index 1 is Refer tab
      _referralSubTab = subTab;
    }
    notifyListeners();
  }

  void setReferralSubTab(String subTab) {
    _referralSubTab = subTab;
    notifyListeners();
  }

  // Notifications
  void incrementNotifications() {
    _notificationCount++;
    notifyListeners();
  }

  void decrementNotifications() {
    if (_notificationCount > 0) {
      _notificationCount--;
    }
    notifyListeners();
  }

  void clearNotifications() {
    _notificationCount = 0;
    notifyListeners();
  }

  void setNotificationCount(int count) {
    _notificationCount = count;
    notifyListeners();
  }

  // Loading State
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Reset
  void reset() {
    _currentTabIndex = 0;
    _referralSubTab = 'programs';
    _notificationCount = 0;
    _isLoading = false;
    notifyListeners();
  }
}

