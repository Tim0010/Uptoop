import 'package:flutter/foundation.dart';
import 'package:uptop_careers/services/retry_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uptop_careers/models/application.dart';
import 'package:uptop_careers/services/supabase_service.dart';

/// Service to handle application data operations with Supabase
class ApplicationDataService {
  /// Create a new application in Supabase
  static Future<String?> createApplication({
    required String userId,
    required String programId,
    String? referralId,
  }) async {
    try {
      if (!SupabaseService.isConfigured) {
        debugPrint('⚠️ Supabase not configured - cannot create application');
        return null;
      }

      debugPrint('📝 Creating application in Supabase...');
      debugPrint('   User ID: $userId');
      debugPrint('   Program ID: $programId');
      debugPrint('   Referral ID: $referralId');

      final applicationData = {
        'user_id': userId,
        'program_id': programId,
        'referral_id': referralId,
        'status': 'draft',
        'stage': 'invited', // Granular stage tracking
        'progress': 0,
        'documents_submitted': false,
        'application_fee_paid': false,
        'enrollment_confirmed': false,
      };

      debugPrint('📤 Sending to Supabase: $applicationData');

      final response = await SupabaseService.client!
          .from('applications')
          .insert(applicationData)
          .select()
          .single();

      final applicationId = response['id'] as String?;
      debugPrint('✅ Application created in Supabase with ID: $applicationId');
      debugPrint('   Full response: $response');
      return applicationId;
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating application in Supabase: $e');
      debugPrint('   Stack trace: $stackTrace');
      return null;
    }
  }

  /// Update an existing application in Supabase with retry logic
  static Future<bool> updateApplication(Application application) async {
    try {
      if (!SupabaseService.isConfigured) {
        debugPrint('⚠️ Supabase not configured - cannot update application');
        return false;
      }

      debugPrint('🔄 Updating application in Supabase: ${application.id}');
      debugPrint('   Stage: ${application.getApplicationStageString()}');
      debugPrint('   Progress: ${application.progressPercentage}%');

      // Check if application ID looks like a Supabase UUID
      final isUUID = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      ).hasMatch(application.id);

      if (!isUUID) {
        debugPrint('⚠️ Application ID is not a UUID: ${application.id}');
        debugPrint(
          '   This application was created locally and not synced to Supabase',
        );
        debugPrint('   Attempting to create it in Supabase first...');

        // Try to create it in Supabase
        final newId = await createApplication(
          userId: application.userId,
          programId: application.programId,
          referralId: application.referralId,
        );

        if (newId == null) {
          debugPrint('❌ Failed to create application in Supabase');
          return false;
        }

        debugPrint('✅ Application created in Supabase with new ID: $newId');
        debugPrint('   Note: Local ID ${application.id} != Supabase ID $newId');
        // Continue with update using the new ID
      }

      // Use retry logic for network resilience
      return await RetryService.retryOnNetworkError(
        operation: () async {
          final updateData = {
            'status': application.status.toString().split('.').last,
            'stage': application
                .getApplicationStageString(), // Save granular stage
            'progress': application.progressPercentage,
            'full_name': application.fullName,
            'father_name': application.fatherName,
            'mother_name': application.motherName,
            'date_of_birth': application.dateOfBirth?.toIso8601String(),
            'gender': application.gender,
            'email': application.email,
            'phone': application.phoneNumber,
            'address_line1': application.address,
            'city': application.city,
            'state': application.state,
            'pincode': application.pinCode,
            'country': application.country,
            'photo_url': application.profilePictureUrl,
            'id_proof_url': application.photoIdUrl,
            'qualification_certificate_url': application.marksheet10thUrl,
            'documents_submitted': application.documentsSubmitted,
            'application_fee_paid': application.applicationFeePaid,
            'enrollment_confirmed': application.enrollmentConfirmed,
            'submitted_at': application.submittedAt?.toIso8601String(),
          };

          debugPrint('📤 Sending update to Supabase...');
          final response = await SupabaseService.client!
              .from('applications')
              .update(updateData)
              .eq('id', application.id)
              .select();

          debugPrint('✅ Application updated in Supabase: ${application.id}');
          debugPrint('   Response: $response');
          return true;
        },
        maxAttempts: 3,
        initialDelay: 1000,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating application in Supabase: $e');
      debugPrint('   Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get all applications for the current user
  static Future<List<Map<String, dynamic>>> getUserApplications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        debugPrint('❌ No user ID found');
        return [];
      }

      if (!SupabaseService.isConfigured) {
        debugPrint('⚠️ Supabase not configured');
        return [];
      }

      final response = await SupabaseService.client!
          .from('applications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint('✅ Fetched ${response.length} applications from Supabase');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching applications from Supabase: $e');
      return [];
    }
  }

  /// Get a specific application by ID
  static Future<Map<String, dynamic>?> getApplicationById(
    String applicationId,
  ) async {
    try {
      if (!SupabaseService.isConfigured) {
        debugPrint('⚠️ Supabase not configured');
        return null;
      }

      final response = await SupabaseService.client!
          .from('applications')
          .select()
          .eq('id', applicationId)
          .single();

      debugPrint('✅ Fetched application from Supabase: $applicationId');
      return response;
    } catch (e) {
      debugPrint('❌ Error fetching application from Supabase: $e');
      return null;
    }
  }
}
