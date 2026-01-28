import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

/// Service for managing user data
/// Handles both Supabase and local storage
class UserDataService {
  /// Get current user's complete profile
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      // Get userId from SharedPreferences (this is the actual user ID, not the anonymous auth ID)
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (kDebugMode) {
        print('🔍 Loading user profile for ID: $userId');
        print('📡 Supabase configured: ${SupabaseService.isConfigured}');
        print('🔐 Supabase authenticated: ${SupabaseService.isAuthenticated}');
      }

      if (userId == null) {
        if (kDebugMode) {
          print('⚠️ No userId found in SharedPreferences');
        }
        return null;
      }

      // Try Supabase first (using the actual user ID from SharedPreferences)
      if (SupabaseService.isConfigured && SupabaseService.isAuthenticated) {
        final profile = await SupabaseService.getUserProfile(userId);
        if (profile != null) {
          if (kDebugMode) {
            print('✅ Loaded profile from Supabase: ${profile['full_name']}');
          }
          return profile;
        } else {
          if (kDebugMode) {
            print('⚠️ No profile found in Supabase for ID: $userId');
          }
        }
      }

      // Fallback to local storage
      if (kDebugMode) {
        print('💾 Falling back to local storage');
      }

      return {
        'id': userId,
        'phone_number': prefs.getString('phoneNumber'),
        'full_name': prefs.getString('fullName'),
        'email': prefs.getString('email'),
        'age': prefs.getInt('age'),
        'college': prefs.getString('college'),
        'referral_code': prefs.getString('referralCode'),
      };
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting user profile: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return null;
    }
  }

  /// Update user profile
  static Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        debugPrint('❌ No user ID found');
        return false;
      }

      // Update in Supabase if configured
      if (SupabaseService.isConfigured) {
        await SupabaseService.updateUserProfile(userId, updates);
      }

      // Update local storage
      updates.forEach((key, value) {
        if (value is String) {
          prefs.setString(key, value);
        } else if (value is int) {
          prefs.setInt(key, value);
        } else if (value is bool) {
          prefs.setBool(key, value);
        } else if (value is double) {
          prefs.setDouble(key, value);
        }
      });

      debugPrint('✅ User profile updated');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating user profile: $e');
      return false;
    }
  }

  /// Get user's referral code
  static Future<String?> getUserReferralCode() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?['referral_code'];
    } catch (e) {
      debugPrint('❌ Error getting referral code: $e');
      return null;
    }
  }

  /// Get user's referrals
  static Future<List<Map<String, dynamic>>> getUserReferrals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return [];

      if (SupabaseService.isConfigured) {
        return await SupabaseService.getUserReferrals(userId);
      }

      // Return empty list if Supabase not configured
      return [];
    } catch (e) {
      debugPrint('❌ Error getting referrals: $e');
      return [];
    }
  }

  /// Create a new referral
  /// Returns the referral ID if successful, null otherwise
  static Future<String?> createReferral({
    required String referredName,
    String? referredEmail,
    String? referredPhone,
    String? referredCollege,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        debugPrint('❌ No user ID found');
        return null;
      }

      if (SupabaseService.isConfigured) {
        final response = await SupabaseService.createReferral(
          referrerId: userId,
          referredName: referredName,
          referredEmail: referredEmail,
          referredPhone: referredPhone,
          referredCollege: referredCollege,
        );
        final referralId = response['id'] as String?;
        debugPrint('✅ Referral created in Supabase with ID: $referralId');
        return referralId;
      } else {
        debugPrint('⚠️ Supabase not configured. Referral not saved.');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error creating referral: $e');
      return null;
    }
  }

  /// Link a referral to a referred user
  static Future<bool> linkReferralToUser({
    required String referralId,
    required String referredUserId,
    String? referredName,
    String? referredEmail,
    String? referredPhone,
    String? referredCollege,
  }) async {
    try {
      if (!SupabaseService.isConfigured) {
        debugPrint('⚠️ Supabase not configured');
        return false;
      }

      final result = await SupabaseService.linkReferralToUser(
        referralId: referralId,
        referredUserId: referredUserId,
        referredName: referredName,
        referredEmail: referredEmail,
        referredPhone: referredPhone,
        referredCollege: referredCollege,
      );

      if (result != null) {
        debugPrint('✅ Referral linked to user successfully');
        return true;
      } else {
        debugPrint('⚠️ Failed to link referral to user');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error linking referral to user: $e');
      return false;
    }
  }

  /// Update referral status
  static Future<bool> updateReferralStatus({
    required String referralId,
    String? status,
    String? applicationStage,
    bool? isCompleted,
  }) async {
    try {
      if (!SupabaseService.isConfigured) {
        debugPrint('⚠️ Supabase not configured');
        return false;
      }

      await SupabaseService.updateReferralStatus(
        referralId: referralId,
        status: status,
        applicationStage: applicationStage,
        isCompleted: isCompleted,
      );

      debugPrint('✅ Referral status updated');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating referral status: $e');
      return false;
    }
  }

  /// Get user statistics
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final profile = await getCurrentUserProfile();

      if (profile == null) {
        return {
          'total_referrals': 0,
          'active_referrals': 0,
          'successful_referrals': 0,
          'total_earnings': 0.0,
          'level': 1,
          'coins': 0,
        };
      }

      return {
        'total_referrals': profile['total_referrals'] ?? 0,
        'active_referrals': profile['active_referrals'] ?? 0,
        'successful_referrals': profile['successful_referrals'] ?? 0,
        'total_earnings': profile['total_earnings'] ?? 0.0,
        'level': profile['level'] ?? 1,
        'coins': profile['coins'] ?? 0,
      };
    } catch (e) {
      debugPrint('❌ Error getting user stats: $e');
      return {
        'total_referrals': 0,
        'active_referrals': 0,
        'successful_referrals': 0,
        'total_earnings': 0.0,
        'level': 1,
        'coins': 0,
      };
    }
  }
}
