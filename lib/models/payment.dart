enum PaymentStatus {
  pending, // Payment submitted, awaiting verification
  verified, // Payment verified by admin
  failed, // Payment failed
  refunded, // Payment refunded
}

enum PaymentMode {
  cash,
  cheque,
  dd, // Demand Draft
  online, // Razorpay/UPI/Net Banking
}

enum PaymentType { applicationFee, enrollmentFee, deposit }

class Payment {
  final String id;
  final String applicationId;
  final String userId;
  final PaymentType type;
  final PaymentMode mode;
  final PaymentStatus status;
  final double amount;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? verifiedBy; // Admin ID who verified

  // Payment Details (for non-cash payments)
  final String? transactionId; // For online payments
  final String? chequeNumber; // For cheque
  final String? ddNumber; // For DD
  final String? bankName;
  final DateTime? paymentDate;

  // Verification Details
  final String? verificationNotes; // Admin notes
  final String? receiptUrl; // Receipt/proof upload
  final String? rejectionReason; // If payment rejected

  // Razorpay specific (for online payments)
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? razorpaySignature;

  Payment({
    required this.id,
    required this.applicationId,
    required this.userId,
    required this.type,
    required this.mode,
    required this.status,
    required this.amount,
    required this.createdAt,
    this.verifiedAt,
    this.verifiedBy,
    this.transactionId,
    this.chequeNumber,
    this.ddNumber,
    this.bankName,
    this.paymentDate,
    this.verificationNotes,
    this.receiptUrl,
    this.rejectionReason,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
  });

  // Helper getters
  bool get isVerified => status == PaymentStatus.verified;
  bool get isPending => status == PaymentStatus.pending;
  bool get isFailed => status == PaymentStatus.failed;
  bool get requiresAdminVerification =>
      mode == PaymentMode.cash ||
      mode == PaymentMode.cheque ||
      mode == PaymentMode.dd;

  String get statusText {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending Verification';
      case PaymentStatus.verified:
        return 'Verified';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  String get modeText {
    switch (mode) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.cheque:
        return 'Cheque';
      case PaymentMode.dd:
        return 'Demand Draft';
      case PaymentMode.online:
        return 'Online Payment';
    }
  }

  String get typeText {
    switch (type) {
      case PaymentType.applicationFee:
        return 'Application Fee';
      case PaymentType.enrollmentFee:
        return 'Enrollment Fee';
      case PaymentType.deposit:
        return 'Deposit';
    }
  }

  // Get payment reference number
  String get referenceNumber {
    if (razorpayPaymentId != null) return razorpayPaymentId!;
    if (transactionId != null) return transactionId!;
    if (chequeNumber != null) return chequeNumber!;
    if (ddNumber != null) return ddNumber!;
    return id.substring(0, 8).toUpperCase();
  }

  Payment copyWith({
    String? id,
    String? applicationId,
    String? userId,
    PaymentType? type,
    PaymentMode? mode,
    PaymentStatus? status,
    double? amount,
    DateTime? createdAt,
    DateTime? verifiedAt,
    String? verifiedBy,
    String? transactionId,
    String? chequeNumber,
    String? ddNumber,
    String? bankName,
    DateTime? paymentDate,
    String? verificationNotes,
    String? receiptUrl,
    String? rejectionReason,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? razorpaySignature,
  }) {
    return Payment(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      transactionId: transactionId ?? this.transactionId,
      chequeNumber: chequeNumber ?? this.chequeNumber,
      ddNumber: ddNumber ?? this.ddNumber,
      bankName: bankName ?? this.bankName,
      paymentDate: paymentDate ?? this.paymentDate,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      razorpayPaymentId: razorpayPaymentId ?? this.razorpayPaymentId,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      razorpaySignature: razorpaySignature ?? this.razorpaySignature,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicationId': applicationId,
      'userId': userId,
      'type': type.index,
      'mode': mode.index,
      'status': status.index,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verifiedBy': verifiedBy,
      'transactionId': transactionId,
      'chequeNumber': chequeNumber,
      'ddNumber': ddNumber,
      'bankName': bankName,
      'paymentDate': paymentDate?.toIso8601String(),
      'verificationNotes': verificationNotes,
      'receiptUrl': receiptUrl,
      'rejectionReason': rejectionReason,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpayOrderId': razorpayOrderId,
      'razorpaySignature': razorpaySignature,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      applicationId: json['applicationId'] as String,
      userId: json['userId'] as String,
      type: PaymentType.values[json['type'] as int],
      mode: PaymentMode.values[json['mode'] as int],
      status: PaymentStatus.values[json['status'] as int],
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      verifiedBy: json['verifiedBy'] as String?,
      transactionId: json['transactionId'] as String?,
      chequeNumber: json['chequeNumber'] as String?,
      ddNumber: json['ddNumber'] as String?,
      bankName: json['bankName'] as String?,
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'] as String)
          : null,
      verificationNotes: json['verificationNotes'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      razorpayPaymentId: json['razorpayPaymentId'] as String?,
      razorpayOrderId: json['razorpayOrderId'] as String?,
      razorpaySignature: json['razorpaySignature'] as String?,
    );
  }
}
