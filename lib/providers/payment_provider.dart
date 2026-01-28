import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/payment.dart';

class PaymentProvider with ChangeNotifier {
  final Map<String, Payment> _payments = {};
  final Map<String, List<String>> _applicationPayments =
      {}; // applicationId -> [paymentIds]
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Payment> get allPayments => _payments.values.toList();

  // Initialize and load payments from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadPayments();
      _error = null;
    } catch (e) {
      _error = 'Failed to load payments: $e';
      if (kDebugMode) print('❌ Error loading payments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load payments from SharedPreferences
  Future<void> _loadPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final paymentsJson = prefs.getString('payments');

    if (paymentsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(paymentsJson);
      _payments.clear();
      _applicationPayments.clear();

      decoded.forEach((key, value) {
        final payment = Payment.fromJson(value);
        _payments[key] = payment;

        // Build application -> payments index
        if (!_applicationPayments.containsKey(payment.applicationId)) {
          _applicationPayments[payment.applicationId] = [];
        }
        _applicationPayments[payment.applicationId]!.add(payment.id);
      });

      if (kDebugMode) print('✅ Loaded ${_payments.length} payments');
    }
  }

  // Save payments to SharedPreferences
  Future<void> _savePayments() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> paymentsMap = {};

    _payments.forEach((key, value) {
      paymentsMap[key] = value.toJson();
    });

    await prefs.setString('payments', jsonEncode(paymentsMap));
    if (kDebugMode) print('✅ Saved ${_payments.length} payments');
  }

  // Create a new payment
  Future<Payment> createPayment({
    required String applicationId,
    required String userId,
    required PaymentType type,
    required PaymentMode mode,
    required double amount,
    String? transactionId,
    String? chequeNumber,
    String? ddNumber,
    String? bankName,
    DateTime? paymentDate,
    String? receiptUrl,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
  }) async {
    try {
      final payment = Payment(
        id: const Uuid().v4(),
        applicationId: applicationId,
        userId: userId,
        type: type,
        mode: mode,
        status: mode == PaymentMode.online
            ? PaymentStatus
                  .verified // Online payments auto-verified
            : PaymentStatus.pending, // Others need admin verification
        amount: amount,
        createdAt: DateTime.now(),
        verifiedAt: mode == PaymentMode.online ? DateTime.now() : null,
        transactionId: transactionId,
        chequeNumber: chequeNumber,
        ddNumber: ddNumber,
        bankName: bankName,
        paymentDate: paymentDate,
        receiptUrl: receiptUrl,
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
      );

      _payments[payment.id] = payment;

      // Update application -> payments index
      if (!_applicationPayments.containsKey(applicationId)) {
        _applicationPayments[applicationId] = [];
      }
      _applicationPayments[applicationId]!.add(payment.id);

      await _savePayments();
      notifyListeners();

      if (kDebugMode) {
        print('✅ Payment created: ${payment.id} (${payment.modeText})');
      }

      return payment;
    } catch (e) {
      _error = 'Failed to create payment: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Get payments for an application
  List<Payment> getPaymentsByApplication(String applicationId) {
    final paymentIds = _applicationPayments[applicationId] ?? [];
    return paymentIds.map((id) => _payments[id]).whereType<Payment>().toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get verified payment for application and type
  Payment? getVerifiedPayment(String applicationId, PaymentType type) {
    final payments = getPaymentsByApplication(applicationId);
    return payments.firstWhere(
      (p) => p.type == type && p.isVerified,
      orElse: () => payments.first, // Return any payment if none verified
    );
  }

  // Check if application has verified payment
  bool hasVerifiedPayment(String applicationId, PaymentType type) {
    final payments = getPaymentsByApplication(applicationId);
    return payments.any((p) => p.type == type && p.isVerified);
  }

  // Get pending payments (for admin verification)
  List<Payment> getPendingPayments() {
    return _payments.values.where((p) => p.isPending).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Verify payment (admin action)
  Future<void> verifyPayment({
    required String paymentId,
    required String adminId,
    String? notes,
  }) async {
    try {
      final payment = _payments[paymentId];
      if (payment == null) {
        throw Exception('Payment not found');
      }

      _payments[paymentId] = payment.copyWith(
        status: PaymentStatus.verified,
        verifiedAt: DateTime.now(),
        verifiedBy: adminId,
        verificationNotes: notes,
      );

      await _savePayments();
      notifyListeners();

      if (kDebugMode) {
        print('✅ Payment verified: $paymentId by $adminId');
      }
    } catch (e) {
      _error = 'Failed to verify payment: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Reject payment (admin action)
  Future<void> rejectPayment({
    required String paymentId,
    required String adminId,
    required String reason,
  }) async {
    try {
      final payment = _payments[paymentId];
      if (payment == null) {
        throw Exception('Payment not found');
      }

      _payments[paymentId] = payment.copyWith(
        status: PaymentStatus.failed,
        verifiedAt: DateTime.now(),
        verifiedBy: adminId,
        rejectionReason: reason,
      );

      await _savePayments();
      notifyListeners();

      if (kDebugMode) {
        print('❌ Payment rejected: $paymentId - $reason');
      }
    } catch (e) {
      _error = 'Failed to reject payment: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update payment
  Future<void> updatePayment(Payment payment) async {
    try {
      _payments[payment.id] = payment;
      await _savePayments();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update payment: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Get payment by ID
  Payment? getPaymentById(String paymentId) {
    return _payments[paymentId];
  }

  // Clear all payments (for testing)
  Future<void> clearAllPayments() async {
    _payments.clear();
    _applicationPayments.clear();
    await _savePayments();
    notifyListeners();
  }
}
