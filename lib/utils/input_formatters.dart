import 'package:flutter/services.dart';

/// Custom input formatters for various fields
class AppInputFormatters {
  /// Formatter for Aadhaar number - allows only 12 digits
  static final aadhaarFormatter = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(12),
  ];

  /// Formatter for phone number - allows only 10 digits
  static final phoneFormatter = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ];

  /// Formatter for PIN code - allows only 6 digits
  static final pinCodeFormatter = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(6),
  ];

  /// Formatter for OTP - allows only 6 digits
  static final otpFormatter = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(6),
  ];

  /// Formatter for name fields - allows only letters and spaces
  static final nameFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  ];

  /// Formatter for numbers only
  static final digitsOnlyFormatter = [
    FilteringTextInputFormatter.digitsOnly,
  ];

  /// Formatter for alphanumeric
  static final alphanumericFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
  ];
}

