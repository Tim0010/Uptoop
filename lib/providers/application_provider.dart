import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uptop_careers/models/application.dart';
import 'package:uptop_careers/services/application_referral_sync_service.dart';
import 'package:uptop_careers/services/application_data_service.dart';
import 'package:uptop_careers/services/offline_queue_service.dart';
import 'package:uptop_careers/services/conflict_resolution_service.dart';

class ApplicationProvider extends ChangeNotifier {
  final Map<String, Application> _applications = {};
  String? _currentApplicationId;
  String? _error;
  bool _isLoading = false;

  // Getters
  Map<String, Application> get applications => _applications;
  Application? get currentApplication => _currentApplicationId != null
      ? _applications[_currentApplicationId]
      : null;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Get applications by status
  List<Application> getApplicationsByStatus(ApplicationStatus status) {
    return _applications.values.where((app) => app.status == status).toList();
  }

  // Get applications by stage
  List<Application> getApplicationsByStage(ApplicationStage stage) {
    return _applications.values.where((app) => app.stage == stage).toList();
  }

  // Get application by ID
  Application? getApplicationById(String applicationId) {
    return _applications[applicationId];
  }

  // Get application by program ID
  Application? getApplicationByProgramId(String programId) {
    try {
      return _applications.values.firstWhere(
        (app) => app.programId == programId,
      );
    } catch (e) {
      return null;
    }
  }

  // Create new application
  Future<Application> createApplication({
    required String programId,
    required String userId,
    String? referralId,
  }) async {
    _isLoading = true;
    _error = null;
    // Defer notification to avoid setState during build
    Future.microtask(() => notifyListeners());

    try {
      // Try to create in Supabase first
      String? supabaseId = await ApplicationDataService.createApplication(
        userId: userId,
        programId: programId,
        referralId: referralId,
      );

      // Use Supabase ID if available, otherwise generate local ID
      final id = supabaseId ?? DateTime.now().millisecondsSinceEpoch.toString();

      final application = Application(
        id: id,
        programId: programId,
        userId: userId,
        referralId: referralId,
        fullName: '',
        email: '',
        phoneNumber: '',
        createdAt: DateTime.now(),
      );

      _applications[id] = application;
      _currentApplicationId = id;
      await _saveApplications();

      // If linked to a referral, sync initial status
      if (referralId != null) {
        ApplicationReferralSyncService.syncApplicationToReferral(
          application,
        ).catchError((e) {
          debugPrint('⚠️ Failed to sync initial referral: $e');
          return false;
        });
      }

      _isLoading = false;
      // Defer notification to avoid setState during build
      Future.microtask(() => notifyListeners());
      return application;
    } catch (e) {
      _error = 'Failed to create application: $e';
      _isLoading = false;
      // Defer notification to avoid setState during build
      Future.microtask(() => notifyListeners());
      rethrow;
    }
  }

  // Update application
  Future<void> updateApplication(Application application) async {
    try {
      final oldApplication = _applications[application.id];

      // Auto-calculate current stage based on completed fields
      final calculatedStage = application.calculateCurrentStage();
      final updatedApplication = application.copyWith(stage: calculatedStage);

      _applications[updatedApplication.id] = updatedApplication;

      // Log stage change for debugging
      if (oldApplication != null && oldApplication.stage != calculatedStage) {
        debugPrint('📊 Application stage updated:');
        debugPrint('   Old: ${oldApplication.stage.toString()}');
        debugPrint('   New: ${calculatedStage.toString()}');
        debugPrint('   Stage Text: ${updatedApplication.stageText}');
        debugPrint(
          '   Stage DB Value: ${updatedApplication.getApplicationStageString()}',
        );
      }

      // Log all field updates for verification
      debugPrint('💾 Saving application data:');
      debugPrint('   ID: ${updatedApplication.id}');
      debugPrint('   Full Name: ${updatedApplication.fullName}');
      debugPrint('   Email: ${updatedApplication.email}');
      debugPrint('   Phone: ${updatedApplication.phoneNumber}');
      debugPrint('   Father Name: ${updatedApplication.fatherName}');
      debugPrint('   Mother Name: ${updatedApplication.motherName}');
      debugPrint('   Gender: ${updatedApplication.gender}');
      debugPrint('   DOB: ${updatedApplication.dateOfBirth}');
      debugPrint('   Address: ${updatedApplication.address}');
      debugPrint('   City: ${updatedApplication.city}');
      debugPrint('   State: ${updatedApplication.state}');
      debugPrint(
        '   Documents Submitted: ${updatedApplication.documentsSubmitted}',
      );
      debugPrint('   Fee Paid: ${updatedApplication.applicationFeePaid}');
      debugPrint('   Stage: ${updatedApplication.getApplicationStageString()}');
      debugPrint('   Progress: ${updatedApplication.progressPercentage}%');

      // Save to local storage
      await _saveApplications();

      // Sync to Supabase in background
      ApplicationDataService.updateApplication(updatedApplication)
          .then((success) {
            if (success) {
              debugPrint(
                '✅ Application successfully synced to Supabase database',
              );
            } else {
              debugPrint('❌ Failed to sync application to Supabase');
            }
          })
          .catchError((e) {
            debugPrint('⚠️ Failed to sync application to Supabase: $e');

            // Queue for offline sync if failed
            OfflineQueueService().enqueue(
              type: 'update_application',
              data: {
                'applicationId': updatedApplication.id,
                'updateData': {
                  'status': updatedApplication.status
                      .toString()
                      .split('.')
                      .last,
                  'stage': updatedApplication.getApplicationStageString(),
                  'progress': updatedApplication.progressPercentage,
                  'full_name': updatedApplication.fullName,
                  'email': updatedApplication.email,
                  'phone': updatedApplication.phoneNumber,
                  'documents_submitted': updatedApplication.documentsSubmitted,
                  'application_fee_paid': updatedApplication.applicationFeePaid,
                  'enrollment_confirmed':
                      updatedApplication.enrollmentConfirmed,
                },
              },
            );
          });

      // Sync with referral tracker if application is linked to a referral
      if (updatedApplication.referralId != null) {
        // Check if stage changed (always sync on stage change)
        final stageChanged =
            oldApplication == null ||
            oldApplication.stage != updatedApplication.stage;

        final shouldSync =
            oldApplication != null &&
            ApplicationReferralSyncService.shouldSyncToReferral(
              oldApplication,
              updatedApplication,
            );

        if (stageChanged || shouldSync) {
          // Sync in background, don't wait for it
          ApplicationReferralSyncService.syncApplicationToReferral(
            updatedApplication,
          ).catchError((e) {
            debugPrint('⚠️ Failed to sync referral: $e');

            // Queue for offline sync if failed
            OfflineQueueService().enqueue(
              type: 'update_referral',
              data: {
                'referralId': updatedApplication.referralId!,
                'status': updatedApplication.getReferralStatus(),
                'applicationStage': updatedApplication
                    .getApplicationStageString(),
                'isCompleted': updatedApplication.enrollmentConfirmed,
              },
            );

            return false;
          });
        }
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to update application: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update specific fields
  Future<void> updateApplicationField({
    required String applicationId,
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      final app = _applications[applicationId];
      if (app != null) {
        _applications[applicationId] = app.copyWith(
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
        );
        await _saveApplications();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update application: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update enrollment confirmation
  Future<void> updateEnrollmentConfirmation({
    required String applicationId,
    required bool confirmed,
  }) async {
    try {
      final app = _applications[applicationId];
      if (app != null) {
        _applications[applicationId] = app.copyWith(
          enrollmentConfirmed: confirmed,
        );
        await _saveApplications();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update enrollment: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Update payment status
  Future<void> updatePaymentStatus({
    required String applicationId,
    required bool applicationFeePaid,
    required bool enrollmentFeePaid,
  }) async {
    try {
      final app = _applications[applicationId];
      if (app != null) {
        _applications[applicationId] = app.copyWith(
          applicationFeePaid: applicationFeePaid,
          enrollmentFeePaid: enrollmentFeePaid,
        );
        await _saveApplications();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update payment: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Submit application
  Future<void> submitApplication(String applicationId) async {
    try {
      final app = _applications[applicationId];
      if (app != null && app.isComplete) {
        _applications[applicationId] = app.copyWith(
          status: ApplicationStatus.submitted,
          submittedAt: DateTime.now(),
        );
        await _saveApplications();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to submit application: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Load applications from storage and Supabase with conflict resolution
  Future<void> loadApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load local applications first
      final prefs = await SharedPreferences.getInstance();
      final applicationsJson = prefs.getString('applications');
      final Map<String, Application> localApps = {};

      if (applicationsJson != null) {
        final decoded = jsonDecode(applicationsJson) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          localApps[key] = Application.fromJson(value);
        });
      }

      // Try to load from Supabase
      final supabaseApps = await ApplicationDataService.getUserApplications();

      if (supabaseApps.isNotEmpty) {
        _applications.clear();

        for (final appData in supabaseApps) {
          try {
            final remoteApp = _applicationFromSupabaseData(appData);
            final localApp = localApps[remoteApp.id];

            // Check for conflicts and resolve
            if (localApp != null) {
              if (ConflictResolutionService.hasConflict(localApp, remoteApp)) {
                debugPrint(
                  '⚠️ Conflict detected for application ${remoteApp.id}',
                );
                final conflicts = ConflictResolutionService.getConflictDetails(
                  localApp,
                  remoteApp,
                );
                debugPrint('   Conflicts: $conflicts');

                // Resolve using most recent strategy
                final resolved =
                    ConflictResolutionService.resolveApplicationConflict(
                      local: localApp,
                      remote: remoteApp,
                      strategy: MergeStrategy.useMostRecent,
                    );

                _applications[resolved.id] = resolved;

                // Sync resolved version back to Supabase
                ApplicationDataService.updateApplication(resolved).catchError((
                  e,
                ) {
                  debugPrint('⚠️ Failed to sync resolved application: $e');
                  return false;
                });
              } else {
                // No conflict, use remote
                _applications[remoteApp.id] = remoteApp;
              }
            } else {
              // New application from server
              _applications[remoteApp.id] = remoteApp;
            }
          } catch (e) {
            debugPrint('⚠️ Error parsing application: $e');
          }
        }

        // Add any local-only applications (not yet synced)
        localApps.forEach((id, app) {
          if (!_applications.containsKey(id)) {
            _applications[id] = app;
            debugPrint('📤 Found local-only application: $id');

            // Try to sync to Supabase by updating (since it has an ID)
            ApplicationDataService.updateApplication(app).catchError((e) {
              debugPrint('⚠️ Failed to sync local application: $e');
              return false;
            });
          }
        });

        // Save merged data to local storage
        await _saveApplications();
      } else {
        // Fallback to local storage if Supabase is empty or unavailable
        _applications.clear();
        _applications.addAll(localApps);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load applications: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Convert Supabase data to Application model
  Application _applicationFromSupabaseData(Map<String, dynamic> data) {
    return Application(
      id: data['id'] as String,
      programId: data['program_id'] as String,
      userId: data['user_id'] as String,
      referralId: data['referral_id'] as String?,
      status: _parseApplicationStatus(data['status'] as String?),
      stage: _parseApplicationStage(data['application_stage'] as String?),
      fullName: data['full_name'] as String? ?? '',
      fatherName: data['father_name'] as String?,
      motherName: data['mother_name'] as String?,
      dateOfBirth: data['date_of_birth'] != null
          ? DateTime.parse(data['date_of_birth'] as String)
          : null,
      gender: data['gender'] as String?,
      email: data['email'] as String? ?? '',
      phoneNumber: data['phone'] as String? ?? '',
      address: data['address_line1'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      pinCode: data['pincode'] as String?,
      country: data['country'] as String?,
      nationality: data['country'] as String?,
      profilePictureUrl: data['photo_url'] as String?,
      photoIdUrl: data['id_proof_url'] as String?,
      marksheet10thUrl: data['qualification_certificate_url'] as String?,
      documentsSubmitted: (data['documents_submitted'] as bool?) ?? false,
      applicationFeePaid: (data['application_fee_paid'] as bool?) ?? false,
      enrollmentConfirmed: (data['enrollment_confirmed'] as bool?) ?? false,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : DateTime.now(),
      submittedAt: data['submitted_at'] != null
          ? DateTime.parse(data['submitted_at'] as String)
          : null,
    );
  }

  // Parse application status from string
  ApplicationStatus _parseApplicationStatus(String? status) {
    switch (status) {
      case 'draft':
        return ApplicationStatus.draft;
      case 'in_progress':
        return ApplicationStatus.inProgress;
      case 'submitted':
        return ApplicationStatus.submitted;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.draft;
    }
  }

  // Parse application stage from string
  ApplicationStage _parseApplicationStage(String? stage) {
    switch (stage) {
      case 'invited':
        return ApplicationStage.invited;
      case 'application_started':
        return ApplicationStage.applicationStarted;
      case 'personal_info_submitted':
        return ApplicationStage.personalInfoSubmitted;
      case 'academic_info_submitted':
        return ApplicationStage.academicInfoSubmitted;
      case 'documents_submitted':
        return ApplicationStage.documentsSubmitted;
      case 'application_fee_paid':
        return ApplicationStage.applicationFeePaid;
      case 'application_submitted':
        return ApplicationStage.applicationSubmitted;
      default:
        return ApplicationStage.invited;
    }
  }

  // Save applications to storage
  Future<void> _saveApplications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final applicationsJson = jsonEncode(
        _applications.map((key, value) => MapEntry(key, value.toJson())),
      );
      await prefs.setString('applications', applicationsJson);
    } catch (e) {
      _error = 'Failed to save applications: $e';
      notifyListeners();
    }
  }

  // Delete application
  Future<void> deleteApplication(String applicationId) async {
    try {
      _applications.remove(applicationId);
      if (_currentApplicationId == applicationId) {
        _currentApplicationId = null;
      }
      await _saveApplications();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete application: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
