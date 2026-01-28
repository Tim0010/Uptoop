import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';

/// Service to handle deep links and referral links
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // Callback for when a referral link is received
  Function(String referralId, String? programId)? onReferralLinkReceived;

  // Callback for when a referral link is received by an existing user
  Function(String referralId, String? programId)?
  onExistingUserReferralReceived;

  // Store the latest referral data
  String? _pendingReferralId;
  String? _pendingProgramId;

  /// Initialize deep link listening
  Future<void> initialize() async {
    try {
      // Check if app was opened with a link
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('🔗 App opened with initial link: $initialUri');
        _handleDeepLink(initialUri);
      }

      // Listen for links while app is running
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          debugPrint('🔗 Received deep link: $uri');
          _handleDeepLink(uri);
        },
        onError: (err) {
          debugPrint('❌ Deep link error: $err');
        },
      );

      debugPrint('✅ Deep link service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing deep link service: $e');
    }
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri) {
    debugPrint('📱 Processing deep link: ${uri.toString()}');
    debugPrint('   Path: ${uri.path}');
    debugPrint('   Query params: ${uri.queryParameters}');

    // Check if it's a referral link
    // Format: https://uptop.careers/ref/{referralCode}?programId={programId}&referralId={referralId}
    // Or: uptopcareers://ref/{referralCode}?programId={programId}&referralId={referralId}

    if (uri.path.startsWith('/ref') || uri.path.startsWith('ref')) {
      final referralId = uri.queryParameters['referralId'];
      final programId = uri.queryParameters['programId'];

      if (referralId != null && programId != null) {
        debugPrint('✅ Referral link detected:');
        debugPrint('   Referral ID: $referralId');
        debugPrint('   Program ID: $programId');

        // Store for later use
        _pendingReferralId = referralId;
        _pendingProgramId = programId;

        // Notify listeners
        if (onReferralLinkReceived != null) {
          onReferralLinkReceived!(referralId, programId);
        }
      } else {
        debugPrint('⚠️ Referral link missing required parameters');
        debugPrint('   Has referralId: ${referralId != null}');
        debugPrint('   Has programId: ${programId != null}');
      }
    } else {
      debugPrint('ℹ️ Not a referral link: ${uri.path}');
    }
  }

  /// Get pending referral data and clear it
  Map<String, String?> consumePendingReferral() {
    final data = {
      'referralId': _pendingReferralId,
      'programId': _pendingProgramId,
    };

    // Clear after consuming
    _pendingReferralId = null;
    _pendingProgramId = null;

    return data;
  }

  /// Check if there's a pending referral
  bool hasPendingReferral() {
    return _pendingReferralId != null;
  }

  /// Get pending referral ID without consuming
  String? getPendingReferralId() {
    return _pendingReferralId;
  }

  /// Get pending program ID without consuming
  String? getPendingProgramId() {
    return _pendingProgramId;
  }

  /// Clear pending referral data
  void clearPendingReferral() {
    _pendingReferralId = null;
    _pendingProgramId = null;
    debugPrint('🗑️ Cleared pending referral data');
  }

  /// Generate a referral link
  static String generateReferralLink({
    required String referralCode,
    required String referralId,
    String? programId,
  }) {
    final baseUrl = 'https://uptop.careers/ref/$referralCode';
    final params = <String>[];

    params.add('referralId=$referralId');
    if (programId != null) {
      params.add('programId=$programId');
    }

    final link = '$baseUrl?${params.join('&')}';
    debugPrint('🔗 Generated referral link: $link');
    return link;
  }

  /// Generate a custom scheme link (for app-to-app)
  static String generateAppLink({
    required String referralCode,
    required String referralId,
    String? programId,
  }) {
    final baseUrl = 'uptopcareers://ref/$referralCode';
    final params = <String>[];

    params.add('referralId=$referralId');
    if (programId != null) {
      params.add('programId=$programId');
    }

    return '$baseUrl?${params.join('&')}';
  }

  /// Dispose and clean up
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    debugPrint('🗑️ Deep link service disposed');
  }
}
