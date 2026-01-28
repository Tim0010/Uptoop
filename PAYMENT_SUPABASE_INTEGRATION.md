# 💳 Payment System + Supabase Integration

## 🎯 Overview

Since you already have **Supabase working**, let's integrate the payment system with Supabase instead of SharedPreferences. This gives you:

- ✅ Cloud storage (data persists across devices)
- ✅ Real-time updates
- ✅ Admin dashboard access
- ✅ Better scalability
- ✅ Automatic backups

## 📊 Step 1: Create Payment Table in Supabase

### Go to Supabase SQL Editor

1. Open your Supabase project: https://hndxhixadfhrgfrkshjy.supabase.co
2. Click **SQL Editor** in the left sidebar
3. Click **New query**
4. Copy and paste the SQL below
5. Click **Run**

### SQL Schema

```sql
-- Create payments table
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL CHECK (type IN ('applicationFee', 'enrollmentFee', 'deposit')),
  mode VARCHAR(50) NOT NULL CHECK (mode IN ('cash', 'cheque', 'dd', 'online')),
  status VARCHAR(50) NOT NULL CHECK (status IN ('pending', 'verified', 'failed', 'refunded')),
  amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  verified_at TIMESTAMP WITH TIME ZONE,
  verified_by UUID REFERENCES users(id),
  transaction_id VARCHAR(255),
  cheque_number VARCHAR(255),
  dd_number VARCHAR(255),
  bank_name VARCHAR(255),
  payment_date TIMESTAMP WITH TIME ZONE,
  verification_notes TEXT,
  receipt_url TEXT,
  rejection_reason TEXT,
  razorpay_payment_id VARCHAR(255),
  razorpay_order_id VARCHAR(255),
  razorpay_signature VARCHAR(255),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_application_id ON payments(application_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_type ON payments(type);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at DESC);

-- Enable Row Level Security
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view own payments" ON payments;
DROP POLICY IF EXISTS "Users can create own payments" ON payments;
DROP POLICY IF EXISTS "Admins can view all payments" ON payments;
DROP POLICY IF EXISTS "Admins can update payments" ON payments;

-- Users can view their own payments
CREATE POLICY "Users can view own payments" ON payments
  FOR SELECT 
  USING (user_id = auth.uid());

-- Users can create their own payments
CREATE POLICY "Users can create own payments" ON payments
  FOR INSERT 
  WITH CHECK (user_id = auth.uid());

-- Admins can view all payments
CREATE POLICY "Admins can view all payments" ON payments
  FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- Admins can update payments (for verification)
CREATE POLICY "Admins can update payments" ON payments
  FOR UPDATE 
  USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_payments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_payments_updated_at ON payments;
CREATE TRIGGER set_payments_updated_at
  BEFORE UPDATE ON payments
  FOR EACH ROW
  EXECUTE FUNCTION update_payments_updated_at();

-- Add is_admin column to users table if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'users' AND column_name = 'is_admin'
  ) THEN
    ALTER TABLE users ADD COLUMN is_admin BOOLEAN DEFAULT false;
  END IF;
END $$;

-- Create a view for payment statistics
CREATE OR REPLACE VIEW payment_stats AS
SELECT 
  user_id,
  COUNT(*) as total_payments,
  COUNT(*) FILTER (WHERE status = 'verified') as verified_payments,
  COUNT(*) FILTER (WHERE status = 'pending') as pending_payments,
  COUNT(*) FILTER (WHERE status = 'failed') as failed_payments,
  SUM(amount) FILTER (WHERE status = 'verified') as total_verified_amount,
  SUM(amount) FILTER (WHERE status = 'pending') as total_pending_amount
FROM payments
GROUP BY user_id;

-- Grant access to the view
GRANT SELECT ON payment_stats TO authenticated;
```

## 🔧 Step 2: Update Payment Model

The payment model is already perfect! Just ensure the `toJson()` and `fromJson()` methods match Supabase format:

```dart
// In lib/models/payment.dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'application_id': applicationId,
    'user_id': userId,
    'type': type.name, // Use .name instead of .index for Supabase
    'mode': mode.name,
    'status': status.name,
    'amount': amount,
    'created_at': createdAt.toIso8601String(),
    'verified_at': verifiedAt?.toIso8601String(),
    'verified_by': verifiedBy,
    'transaction_id': transactionId,
    'cheque_number': chequeNumber,
    'dd_number': ddNumber,
    'bank_name': bankName,
    'payment_date': paymentDate?.toIso8601String(),
    'verification_notes': verificationNotes,
    'receipt_url': receiptUrl,
    'rejection_reason': rejectionReason,
    'razorpay_payment_id': razorpayPaymentId,
    'razorpay_order_id': razorpayOrderId,
    'razorpay_signature': razorpaySignature,
  };
}

factory Payment.fromJson(Map<String, dynamic> json) {
  return Payment(
    id: json['id'] as String,
    applicationId: json['application_id'] as String,
    userId: json['user_id'] as String,
    type: PaymentType.values.firstWhere((e) => e.name == json['type']),
    mode: PaymentMode.values.firstWhere((e) => e.name == json['mode']),
    status: PaymentStatus.values.firstWhere((e) => e.name == json['status']),
    amount: (json['amount'] as num).toDouble(),
    createdAt: DateTime.parse(json['created_at'] as String),
    verifiedAt: json['verified_at'] != null
        ? DateTime.parse(json['verified_at'] as String)
        : null,
    verifiedBy: json['verified_by'] as String?,
    transactionId: json['transaction_id'] as String?,
    chequeNumber: json['cheque_number'] as String?,
    ddNumber: json['dd_number'] as String?,
    bankName: json['bank_name'] as String?,
    paymentDate: json['payment_date'] != null
        ? DateTime.parse(json['payment_date'] as String)
        : null,
    verificationNotes: json['verification_notes'] as String?,
    receiptUrl: json['receipt_url'] as String?,
    rejectionReason: json['rejection_reason'] as String?,
    razorpayPaymentId: json['razorpay_payment_id'] as String?,
    razorpayOrderId: json['razorpay_order_id'] as String?,
    razorpaySignature: json['razorpay_signature'] as String?,
  );
}
```

## 🔄 Step 3: Update PaymentProvider to Use Supabase

Create a new file: `lib/providers/payment_provider_supabase.dart`

```dart
import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../services/supabase_service.dart';

class PaymentProvider with ChangeNotifier {
  final Map<String, Payment> _payments = {};
  final Map<String, List<String>> _applicationPayments = {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Payment> get allPayments => _payments.values.toList();

  // Initialize and load payments from Supabase
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

  // Load payments from Supabase
  Future<void> _loadPayments() async {
    if (!SupabaseService.isConfigured) {
      if (kDebugMode) print('⚠️ Supabase not configured');
      return;
    }

    final response = await SupabaseService.client
        .from('payments')
        .select()
        .order('created_at', ascending: false);

    _payments.clear();
    _applicationPayments.clear();

    for (var data in response) {
      final payment = Payment.fromJson(data);
      _payments[payment.id] = payment;

      if (!_applicationPayments.containsKey(payment.applicationId)) {
        _applicationPayments[payment.applicationId] = [];
      }
      _applicationPayments[payment.applicationId]!.add(payment.id);
    }

    if (kDebugMode) print('✅ Loaded ${_payments.length} payments from Supabase');
  }

  // Create payment in Supabase
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
        id: '', // Supabase will generate UUID
        applicationId: applicationId,
        userId: userId,
        type: type,
        mode: mode,
        status: mode == PaymentMode.online
            ? PaymentStatus.verified
            : PaymentStatus.pending,
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

      // Insert into Supabase
      final response = await SupabaseService.client
          .from('payments')
          .insert(payment.toJson())
          .select()
          .single();

      final createdPayment = Payment.fromJson(response);
      _payments[createdPayment.id] = createdPayment;

      if (!_applicationPayments.containsKey(applicationId)) {
        _applicationPayments[applicationId] = [];
      }
      _applicationPayments[applicationId]!.add(createdPayment.id);

      notifyListeners();

      if (kDebugMode) {
        print('✅ Payment created in Supabase: ${createdPayment.id}');
      }

      return createdPayment;
    } catch (e) {
      _error = 'Failed to create payment: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Verify payment (admin action)
  Future<void> verifyPayment({
    required String paymentId,
    required String adminId,
    String? notes,
  }) async {
    try {
      await SupabaseService.client.from('payments').update({
        'status': PaymentStatus.verified.name,
        'verified_at': DateTime.now().toIso8601String(),
        'verified_by': adminId,
        'verification_notes': notes,
      }).eq('id', paymentId);

      // Reload payments
      await _loadPayments();
      notifyListeners();

      if (kDebugMode) print('✅ Payment verified: $paymentId');
    } catch (e) {
      _error = 'Failed to verify payment: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Get payments by application
  List<Payment> getPaymentsByApplication(String applicationId) {
    final paymentIds = _applicationPayments[applicationId] ?? [];
    return paymentIds
        .map((id) => _payments[id])
        .whereType<Payment>()
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Check if payment verified
  bool hasVerifiedPayment(String applicationId, PaymentType type) {
    final payments = getPaymentsByApplication(applicationId);
    return payments.any((p) => p.type == type && p.isVerified);
  }

  // Get pending payments (admin)
  List<Payment> getPendingPayments() {
    return _payments.values.where((p) => p.isPending).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
```

## ✅ Step 4: Test the Integration

```bash
flutter pub get
flutter run
```

## 🎯 Benefits of Supabase Integration

- ✅ **Cloud Storage** - Data persists across devices
- ✅ **Real-time Updates** - Payments update instantly
- ✅ **Admin Dashboard** - View payments in Supabase dashboard
- ✅ **Automatic Backups** - Supabase handles backups
- ✅ **Scalable** - Handles thousands of payments
- ✅ **Secure** - Row Level Security policies
- ✅ **SQL Queries** - Advanced reporting and analytics

## 📊 View Payments in Supabase Dashboard

1. Go to **Table Editor**
2. Select **payments** table
3. See all payments in real-time
4. Filter by status, user, application
5. Export to CSV for reports

---

**Next:** Update your payment submission UI to use the new Supabase-powered PaymentProvider!

