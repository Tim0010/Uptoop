import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for handling Twilio SMS and OTP functionality
class TwilioService {
  // Twilio credentials from environment variables
  static String get accountSid => dotenv.env['TWILIO_ACCOUNT_SID'] ?? '';
  static String get authToken => dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';
  static String get twilioPhoneNumber =>
      dotenv.env['TWILIO_PHONE_NUMBER'] ?? '';
  static String get verifyServiceSid =>
      dotenv.env['TWILIO_VERIFY_SERVICE_SID'] ?? '';

  // Twilio API endpoints
  static const String _baseUrl = 'https://api.twilio.com/2010-04-01';
  static const String _verifyBaseUrl = 'https://verify.twilio.com/v2';

  /// Check if Twilio is properly configured
  static bool isConfigured() {
    return accountSid.isNotEmpty &&
        authToken.isNotEmpty &&
        twilioPhoneNumber.isNotEmpty;
  }

  /// Send OTP using Twilio Verify API (Recommended)
  /// This is the easiest and most secure way to send OTPs
  static Future<Map<String, dynamic>> sendOtpWithVerify(
    String phoneNumber,
  ) async {
    try {
      if (verifyServiceSid.isEmpty) {
        throw Exception(
          'Twilio Verify Service SID not configured. Please set TWILIO_VERIFY_SERVICE_SID in .env',
        );
      }

      final url = Uri.parse(
        '$_verifyBaseUrl/Services/$verifyServiceSid/Verifications',
      );

      final credentials = base64Encode(utf8.encode('$accountSid:$authToken'));

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'To': phoneNumber, 'Channel': 'sms'},
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'OTP sent successfully',
          'sid': data['sid'],
          'status': data['status'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to send OTP',
          'code': error['code'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error sending OTP: $e'};
    }
  }

  /// Verify OTP using Twilio Verify API (Recommended)
  static Future<Map<String, dynamic>> verifyOtpWithVerify(
    String phoneNumber,
    String code,
  ) async {
    try {
      if (verifyServiceSid.isEmpty) {
        throw Exception(
          'Twilio Verify Service SID not configured. Please set TWILIO_VERIFY_SERVICE_SID in .env',
        );
      }

      final url = Uri.parse(
        '$_verifyBaseUrl/Services/$verifyServiceSid/VerificationCheck',
      );

      final credentials = base64Encode(utf8.encode('$accountSid:$authToken'));

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'To': phoneNumber, 'Code': code},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isValid = data['status'] == 'approved';

        return {
          'success': isValid,
          'message': isValid ? 'OTP verified successfully' : 'Invalid OTP',
          'status': data['status'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to verify OTP',
          'code': error['code'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error verifying OTP: $e'};
    }
  }

  /// Send OTP using regular SMS (Alternative method)
  /// Use this if you don't want to use Twilio Verify
  static Future<Map<String, dynamic>> sendOtpWithSms(
    String phoneNumber,
    String otp,
  ) async {
    try {
      if (!isConfigured()) {
        throw Exception(
          'Twilio not configured. Please set credentials in .env file',
        );
      }

      final url = Uri.parse('$_baseUrl/Accounts/$accountSid/Messages.json');

      final credentials = base64Encode(utf8.encode('$accountSid:$authToken'));

      final message =
          'Your Uptop Careers verification code is: $otp\n\n'
          'This code will expire in 5 minutes.\n\n'
          'If you didn\'t request this code, please ignore this message.';

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'From': twilioPhoneNumber, 'To': phoneNumber, 'Body': message},
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'OTP sent successfully',
          'sid': data['sid'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to send SMS',
          'code': error['code'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error sending SMS: $e'};
    }
  }

  /// Generate a random 6-digit OTP
  static String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Format phone number to E.164 format (required by Twilio)
  /// Example: +919876543210
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure it starts with +
    if (!cleaned.startsWith('+')) {
      // Assume India (+91) if no country code
      cleaned = '+91$cleaned';
    }

    return cleaned;
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    final formatted = formatPhoneNumber(phoneNumber);
    // E.164 format: + followed by 1-15 digits
    return RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(formatted);
  }
}
