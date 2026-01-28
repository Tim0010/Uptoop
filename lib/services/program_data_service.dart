import 'package:flutter/foundation.dart';
import 'package:uptop_careers/services/supabase_service.dart';

/// Service for managing program data
class ProgramDataService {
  /// Get all programs with optional filters
  static Future<List<Map<String, dynamic>>> getPrograms({
    String? category,
    String? mode,
    String? searchQuery,
    int? limit,
    int offset = 0,
  }) async {
    try {
      if (SupabaseService.isConfigured) {
        return await SupabaseService.getPrograms(
          category: category,
          mode: mode,
          searchQuery: searchQuery,
          limit: limit,
          offset: offset,
        );
      }

      // Return empty list if Supabase not configured
      debugPrint('⚠️ Supabase not configured. No programs available.');
      return [];
    } catch (e) {
      debugPrint('❌ Error getting programs: $e');
      return [];
    }
  }

  /// Get a single program by ID
  static Future<Map<String, dynamic>?> getProgramById(String programId) async {
    try {
      if (SupabaseService.isConfigured) {
        return await SupabaseService.getProgramById(programId);
      }

      debugPrint('⚠️ Supabase not configured');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting program: $e');
      return null;
    }
  }

  /// Get programs by university
  static Future<List<Map<String, dynamic>>> getProgramsByUniversity(
    String universityId,
  ) async {
    try {
      if (SupabaseService.isConfigured) {
        return await SupabaseService.getProgramsByUniversity(universityId);
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error getting programs by university: $e');
      return [];
    }
  }

  /// Get all universities
  static Future<List<Map<String, dynamic>>> getUniversities() async {
    try {
      if (SupabaseService.isConfigured) {
        return await SupabaseService.getUniversities();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error getting universities: $e');
      return [];
    }
  }

  /// Increment program referral count
  static Future<void> incrementProgramReferrals(String programId) async {
    try {
      if (SupabaseService.isConfigured) {
        await SupabaseService.incrementProgramReferrals(programId);
      }
    } catch (e) {
      debugPrint('❌ Error incrementing program referrals: $e');
    }
  }
}

