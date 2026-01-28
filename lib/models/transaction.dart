class Transaction {
  final String id;
  final String type; // 'earning', 'withdrawal', 'bonus', 'penalty'
  final double amount;
  final String status; // 'pending', 'completed', 'failed', 'processing'
  final String description;
  final String? referralId;
  final String? referralName;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? paymentMethod; // 'upi', 'bank', 'paytm'
  final String? transactionId;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.description,
    this.referralId,
    this.referralName,
    required this.createdAt,
    this.completedAt,
    this.paymentMethod,
    this.transactionId,
  });

  // From JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      description: json['description'] as String,
      referralId: json['referralId'] as String?,
      referralName: json['referralName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'status': status,
      'description': description,
      'referralId': referralId,
      'referralName': referralName,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
    };
  }

  // Copy with
  Transaction copyWith({
    String? id,
    String? type,
    double? amount,
    String? status,
    String? description,
    String? referralId,
    String? referralName,
    DateTime? createdAt,
    DateTime? completedAt,
    String? paymentMethod,
    String? transactionId,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      description: description ?? this.description,
      referralId: referralId ?? this.referralId,
      referralName: referralName ?? this.referralName,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  // Computed properties
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing';

  bool get isEarning => type == 'earning';
  bool get isWithdrawal => type == 'withdrawal';
  bool get isBonus => type == 'bonus';
  bool get isPenalty => type == 'penalty';

  bool get isCredit => isEarning || isBonus;
  bool get isDebit => isWithdrawal || isPenalty;

  String get typeLabel {
    switch (type) {
      case 'earning':
        return 'Referral Earning';
      case 'withdrawal':
        return 'Withdrawal';
      case 'bonus':
        return 'Bonus';
      case 'penalty':
        return 'Penalty';
      default:
        return 'Transaction';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'processing':
        return 'Processing';
      default:
        return 'Unknown';
    }
  }

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'upi':
        return 'UPI';
      case 'bank':
        return 'Bank Transfer';
      case 'paytm':
        return 'Paytm';
      default:
        return 'N/A';
    }
  }
}

