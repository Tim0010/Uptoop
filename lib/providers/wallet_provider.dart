import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/supabase_service.dart';

class WalletProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  String _selectedFilter = 'All'; // All, Earnings, Withdrawals, Bonus

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedFilter => _selectedFilter;

  // Filters
  List<String> get filters => ['All', 'Earnings', 'Withdrawals', 'Bonus'];

  // Filtered transactions
  List<Transaction> get filteredTransactions {
    switch (_selectedFilter) {
      case 'Earnings':
        return _transactions.where((t) => t.isEarning).toList();
      case 'Withdrawals':
        return _transactions.where((t) => t.isWithdrawal).toList();
      case 'Bonus':
        return _transactions.where((t) => t.isBonus).toList();
      default:
        return _transactions;
    }
  }

  // Computed values
  double get totalEarnings => _transactions
      .where((t) => t.isCredit && t.isCompleted)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalWithdrawals => _transactions
      .where((t) => t.isDebit && t.isCompleted)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get pendingAmount => _transactions
      .where((t) => t.isCredit && t.isPending)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get availableBalance => totalEarnings - totalWithdrawals;

  int get pendingTransactionsCount =>
      _transactions.where((t) => t.isPending).length;

  // Load transactions
  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (SupabaseService.isConfigured && SupabaseService.isAuthenticated) {
        final rows = await SupabaseService.getUserTransactions();
        _transactions = rows.map((r) {
          return Transaction(
            id: r['id'] as String,
            type: r['type'] as String,
            amount: (r['amount'] as num).toDouble(),
            status: r['status'] as String,
            description: (r['description'] as String?) ?? '',
            referralId: r['referral_id'] as String?,
            referralName: r['referral_name'] as String?,
            createdAt: DateTime.parse(r['created_at'] as String),
            completedAt: r['completed_at'] != null
                ? DateTime.parse(r['completed_at'] as String)
                : null,
            paymentMethod: r['payment_method'] as String?,
            transactionId: r['transaction_ref'] as String?,
          );
        }).toList();

        // Already ordered by created_at desc
      } else {
        // Fallback: mock data when Supabase is not configured
        await Future.delayed(const Duration(milliseconds: 300));
        _transactions = [
          Transaction(
            id: 'txn1',
            type: 'earning',
            amount: 2500,
            status: 'completed',
            description: 'Referral earning from Ananya Patel',
            referralId: 'ref3',
            referralName: 'Ananya Patel',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            completedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          Transaction(
            id: 'txn2',
            type: 'earning',
            amount: 1500,
            status: 'pending',
            description: 'Referral earning from Priya Sharma',
            referralId: 'ref1',
            referralName: 'Priya Sharma',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ];

        // Sort by date (newest first)
        _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter transactions
  void filterTransactions(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // Request withdrawal
  Future<bool> requestWithdrawal(double amount, String paymentMethod) async {
    try {
      if (SupabaseService.isConfigured && SupabaseService.isAuthenticated) {
        final inserted = await SupabaseService.createWithdrawal(
          amount: amount,
          paymentMethod: paymentMethod,
        );

        final t = Transaction(
          id: inserted['id'] as String,
          type: inserted['type'] as String,
          amount: (inserted['amount'] as num).toDouble(),
          status: inserted['status'] as String,
          description: (inserted['description'] as String?) ?? '',
          referralId: inserted['referral_id'] as String?,
          referralName: inserted['referral_name'] as String?,
          createdAt: DateTime.parse(inserted['created_at'] as String),
          completedAt: inserted['completed_at'] != null
              ? DateTime.parse(inserted['completed_at'] as String)
              : null,
          paymentMethod: inserted['payment_method'] as String?,
          transactionId: inserted['transaction_ref'] as String?,
        );
        _transactions.insert(0, t);
        notifyListeners();
        return true;
      } else {
        // Offline fallback: simulate insert
        await Future.delayed(const Duration(milliseconds: 500));
        final withdrawal = Transaction(
          id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
          type: 'withdrawal',
          amount: amount,
          status: 'processing',
          description: 'Withdrawal to ${paymentMethod.toUpperCase()}',
          createdAt: DateTime.now(),
          paymentMethod: paymentMethod,
        );
        _transactions.insert(0, withdrawal);
        notifyListeners();
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  // Add welcome bonus
  Future<bool> addWelcomeBonus(String userId, double amount) async {
    try {
      if (SupabaseService.isConfigured) {
        final inserted = await SupabaseService.createWelcomeBonus(
          userId: userId,
          amount: amount,
        );

        // If null, user already has welcome bonus
        if (inserted == null) {
          return false;
        }

        final t = Transaction(
          id: inserted['id'] as String,
          type: inserted['type'] as String,
          amount: (inserted['amount'] as num).toDouble(),
          status: inserted['status'] as String,
          description: (inserted['description'] as String?) ?? '',
          referralId: inserted['referral_id'] as String?,
          referralName: inserted['referral_name'] as String?,
          createdAt: DateTime.parse(inserted['created_at'] as String),
          completedAt: inserted['completed_at'] != null
              ? DateTime.parse(inserted['completed_at'] as String)
              : null,
          paymentMethod: inserted['payment_method'] as String?,
          transactionId: inserted['transaction_ref'] as String?,
        );
        _transactions.insert(0, t);
        notifyListeners();
        return true;
      } else {
        // Offline fallback: simulate insert
        await Future.delayed(const Duration(milliseconds: 500));
        final bonus = Transaction(
          id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
          type: 'bonus',
          amount: amount,
          status: 'completed',
          description: 'Welcome Bonus! 🎉',
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        );
        _transactions.insert(0, bonus);
        notifyListeners();
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
