import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv_package;
import 'package:uptop_careers/config/env_config.dart';

/// Service class for Supabase operations
/// Handles authentication, user management, and database operations
class SupabaseService {
  static SupabaseClient? _client;
  static bool _initialized = false;

  /// Get Supabase client instance (nullable - check before use!)
  static SupabaseClient? get client => _client;

  /// Get Supabase client instance (throws if not initialized)
  static SupabaseClient get clientOrThrow {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Check if Supabase is initialized and client is available
  static bool get isInitialized => _initialized && _client != null;

  /// Check if Supabase is configured
  static bool get isConfigured {
    // Try to get from .env first (development)
    final envUrl = dotenv_package.dotenv.maybeGet('SUPABASE_URL');
    final envKey = dotenv_package.dotenv.maybeGet('SUPABASE_ANON_KEY');

    if (envUrl != null &&
        envUrl.isNotEmpty &&
        envKey != null &&
        envKey.isNotEmpty) {
      return true;
    }

    // Fall back to compiled config (production)
    return EnvConfig.supabaseUrl.isNotEmpty &&
        EnvConfig.supabaseAnonKey.isNotEmpty &&
        !EnvConfig.supabaseUrl.contains('your_') &&
        !EnvConfig.supabaseAnonKey.contains('your_');
  }

  /// Initialize Supabase
  static Future<void> initialize() async {
    if (_initialized) {
      debugPrint('ℹ️ Supabase already initialized');
      return;
    }

    try {
      if (!isConfigured) {
        debugPrint('⚠️ Supabase not configured. Running in offline mode.');
        _initialized = true; // Mark as initialized to prevent repeated attempts
        return;
      }

      // Try to get from .env first (development)
      String url = dotenv_package.dotenv.maybeGet('SUPABASE_URL') ?? '';
      String anonKey =
          dotenv_package.dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '';

      // Fall back to compiled config (production)
      if (url.isEmpty || anonKey.isEmpty) {
        url = EnvConfig.supabaseUrl;
        anonKey = EnvConfig.supabaseAnonKey;
        debugPrint('ℹ️ Using compiled environment config');
      } else {
        debugPrint('ℹ️ Using .env file config');
      }

      debugPrint('🔧 Initializing Supabase...');
      debugPrint('   URL: ${url.substring(0, 20)}...');

      await Supabase.initialize(url: url, anonKey: anonKey, debug: kDebugMode);

      _client = Supabase.instance.client;
      _initialized = true;
      debugPrint('✅ Supabase initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing Supabase: $e');
      debugPrint('Stack trace: $stackTrace');
      _initialized = true; // Mark as initialized to prevent repeated attempts
      // Don't rethrow - allow app to continue in offline mode
    }
  }

  /// Sign in with phone number (OTP)
  static Future<void> signInWithPhone(String phoneNumber) async {
    if (!isConfigured || client == null) {
      throw Exception('Supabase not configured');
    }

    try {
      await client!.auth.signInWithOtp(
        phone: phoneNumber,
        shouldCreateUser: true,
      );
      debugPrint('✅ OTP sent to $phoneNumber');
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      rethrow;
    }
  }

  /// Verify OTP
  static Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    if (!isConfigured || client == null) {
      throw Exception('Supabase not configured');
    }

    try {
      final response = await client!.auth.verifyOTP(
        phone: phoneNumber,
        token: otp,
        type: OtpType.sms,
      );

      debugPrint('✅ OTP verified successfully');
      return response;
    } catch (e) {
      debugPrint('❌ Error verifying OTP: $e');
      rethrow;
    }
  }

  /// Get current user
  static User? get currentUser => client?.auth.currentUser;

  /// Get current session
  static Session? get currentSession => client?.auth.currentSession;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Sign in anonymously (for Twilio OTP flow)
  /// This creates a Supabase session without using Supabase OTP
  static Future<AuthResponse> signInAnonymously() async {
    if (!isConfigured || client == null) {
      throw Exception('Supabase not configured');
    }

    try {
      final response = await client!.auth.signInAnonymously();
      debugPrint('✅ Signed in anonymously to Supabase');
      return response;
    } catch (e) {
      debugPrint('❌ Error signing in anonymously: $e');
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    if (!isConfigured || client == null) return;

    try {
      await client!.auth.signOut();
      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
      rethrow;
    }
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    if (!isConfigured || client == null) {
      return Stream.empty();
    }
    return client!.auth.onAuthStateChange;
  }

  /// Create or update user profile
  static Future<Map<String, dynamic>> upsertUserProfile({
    required String phoneNumber,
    required String fullName,
    required String email,
    required int age,
    required String college,
    String? referredByCode,
  }) async {
    if (!isConfigured) {
      throw Exception('Supabase not configured');
    }

    try {
      // Check if user exists by phone number
      final existingUser = await client!
          .from('users')
          .select('id')
          .eq('phone_number', phoneNumber)
          .maybeSingle();

      String? userId = existingUser?['id'];
      // If no existing user, use current authenticated user's ID (e.g., anonymous auth)
      if (userId == null && isAuthenticated) {
        userId = currentUser!.id;
      }

      // Generate referral code
      final referralCode = await _generateReferralCode(fullName);

      // Find referrer if referral code provided
      String? referredByUserId;
      if (referredByCode != null && referredByCode.isNotEmpty) {
        final referrer = await client!
            .from('users')
            .select('id')
            .eq('referral_code', referredByCode)
            .maybeSingle();

        referredByUserId = referrer?['id'];
      }

      // Build user data - only include ID if user exists (for update)
      final userData = <String, dynamic>{
        'phone_number': phoneNumber,
        'full_name': fullName,
        'email': email,
        'age': age,
        'college': college,
        'referral_code': referralCode,
        'referred_by_code': referredByCode,
        'referred_by_user_id': referredByUserId,
        'is_phone_verified': true,
        'last_login_at': DateTime.now().toIso8601String(),
      };

      // Only include ID if updating existing user
      if (userId != null) {
        userData['id'] = userId;
      }

      final response = await client!
          .from('users')
          .upsert(userData)
          .select()
          .single();

      debugPrint('✅ User profile created/updated: ${response['full_name']}');
      return response;
    } catch (e) {
      debugPrint('❌ Error upserting user profile: $e');
      rethrow;
    }
  }

  /// Get user profile by ID
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    if (!isConfigured) return null;

    try {
      final response = await client!
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('❌ Error getting user profile: $e');
      return null;
    }
  }

  /// Get user profile by phone number
  static Future<Map<String, dynamic>?> getUserByPhone(
    String phoneNumber,
  ) async {
    if (!isConfigured) return null;

    try {
      debugPrint('🔍 Searching for user with phone: $phoneNumber');

      final response = await client!
          .from('users')
          .select()
          .eq('phone_number', phoneNumber)
          .maybeSingle();

      if (response != null) {
        debugPrint(
          '✅ Found user: ${response['full_name']} (ID: ${response['id']})',
        );
      } else {
        debugPrint('⚠️ No user found with phone: $phoneNumber');

        // Debug: Let's check what phone numbers exist in the database
        final allUsers = await client!
            .from('users')
            .select('phone_number, full_name')
            .limit(5);

        debugPrint('📋 Sample phone numbers in database:');
        for (var user in allUsers) {
          debugPrint('   - ${user['phone_number']} (${user['full_name']})');
        }
      }

      return response;
    } catch (e) {
      debugPrint('❌ Error getting user by phone: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    if (!isConfigured) {
      throw Exception('Supabase not configured');
    }

    try {
      final response = await client!
          .from('users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      debugPrint('✅ User profile updated');
      return response;
    } catch (e) {
      debugPrint('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  /// Create a referral
  static Future<Map<String, dynamic>> createReferral({
    required String referrerId,
    required String referredName,
    String? referredEmail,
    String? referredPhone,
    String? referredCollege,
  }) async {
    if (!isConfigured) {
      throw Exception('Supabase not configured');
    }

    try {
      final referralData = {
        'referrer_id': referrerId,
        'referred_name': referredName,
        'referred_email': referredEmail,
        'referred_phone': referredPhone,
        'referred_college': referredCollege,
        'status': 'pending',
        'application_stage': 'not_started',
      };

      final response = await client!
          .from('referrals')
          .insert(referralData)
          .select()
          .single();

      debugPrint('✅ Referral created: $referredName');
      return response;
    } catch (e) {
      debugPrint('❌ Error creating referral: $e');
      rethrow;
    }
  }

  /// Get user's referrals with profile pictures and names from users and applications
  static Future<List<Map<String, dynamic>>> getUserReferrals(
    String userId,
  ) async {
    if (!isConfigured) return [];

    try {
      // Join with both users and applications tables
      // - users table: Get referred user's name and avatar (if they signed up)
      // - applications table: Get application data (if they started an application)
      final response = await client!
          .from('referrals')
          .select('''
            *,
            referred_user:users!referred_user_id(full_name, avatar_url),
            applications!left(photo_url, full_name)
          ''')
          .eq('referrer_id', userId)
          .order('created_at', ascending: false);

      // Flatten the response to include profile picture and name at top level
      final referrals = List<Map<String, dynamic>>.from(response);
      for (var referral in referrals) {
        String? profilePictureUrl;
        String? userName;

        try {
          // Priority 1: Get data from applications table (if application exists)
          // Note: applications!left returns an array, so we need to check if it's not empty
          if (referral['applications'] != null) {
            final applications = referral['applications'];

            // Check if it's a list (array) or a single object
            if (applications is List && applications.isNotEmpty) {
              // It's an array - take the first item
              final firstApp = applications[0];
              profilePictureUrl = firstApp['photo_url'] as String?;
              userName = firstApp['full_name'] as String?;
            } else if (applications is Map) {
              // It's a single object
              profilePictureUrl = applications['photo_url'] as String?;
              userName = applications['full_name'] as String?;
            }
          }

          // Priority 2: Get data from users table (if user signed up but no application)
          if (referral['referred_user'] != null) {
            // Safely cast to String
            profilePictureUrl ??=
                referral['referred_user']['avatar_url'] as String?;
            userName ??= referral['referred_user']['full_name'] as String?;
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing referral data: $e');
          debugPrint('   Referral: ${referral['id']}');
          debugPrint('   Applications: ${referral['applications']}');
          debugPrint('   Referred user: ${referral['referred_user']}');
        }

        // Set profile picture URL
        referral['profile_picture_url'] = profilePictureUrl;

        // Use fetched name if referred_name is empty or placeholder
        if (referral['referred_name'] == null ||
            (referral['referred_name'] as String).isEmpty ||
            referral['referred_name'] == 'Invited Friend' ||
            referral['referred_name'] == 'Pending') {
          referral['referred_name'] = userName ?? 'Invited Friend';
        }
      }

      return referrals;
    } catch (e) {
      debugPrint('❌ Error getting referrals: $e');
      return [];
    }
  }

  /// Link a referral to a referred user
  static Future<Map<String, dynamic>?> linkReferralToUser({
    required String referralId,
    required String referredUserId,
    String? referredName,
    String? referredEmail,
    String? referredPhone,
    String? referredCollege,
  }) async {
    if (!isConfigured) {
      debugPrint('⚠️ Supabase not configured');
      return null;
    }

    try {
      final updates = <String, dynamic>{'referred_user_id': referredUserId};

      if (referredName != null) updates['referred_name'] = referredName;
      if (referredEmail != null) updates['referred_email'] = referredEmail;
      if (referredPhone != null) updates['referred_phone'] = referredPhone;
      if (referredCollege != null) {
        updates['referred_college'] = referredCollege;
      }

      // First check if referral exists
      debugPrint('🔍 Checking if referral exists: $referralId');

      final existingReferral = await client!
          .from('referrals')
          .select('id, referrer_id, referred_user_id')
          .eq('id', referralId)
          .maybeSingle();

      if (existingReferral == null) {
        debugPrint('⚠️ Referral not found in database: $referralId');

        // Debug: Check all referrals in database
        final allReferrals = await client!
            .from('referrals')
            .select('id, referrer_id')
            .limit(5);
        debugPrint('📋 Sample referrals in database:');
        for (var ref in allReferrals) {
          debugPrint('   - ${ref['id']} (referrer: ${ref['referrer_id']})');
        }

        return null;
      }

      debugPrint('✅ Referral found: ${existingReferral['id']}');
      debugPrint('   Referrer: ${existingReferral['referrer_id']}');
      debugPrint(
        '   Current referred_user_id: ${existingReferral['referred_user_id']}',
      );

      final response = await client!
          .from('referrals')
          .update(updates)
          .eq('id', referralId)
          .select()
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ Failed to update referral: $referralId');
        return null;
      }

      debugPrint('✅ Referral linked to user: $referredUserId');
      return response;
    } catch (e) {
      debugPrint('❌ Error linking referral to user: $e');
      return null;
    }
  }

  /// Update referral status
  static Future<Map<String, dynamic>> updateReferralStatus({
    required String referralId,
    String? status,
    String? applicationStage,
    bool? isCompleted,
  }) async {
    if (!isConfigured) {
      throw Exception('Supabase not configured');
    }

    try {
      final updates = <String, dynamic>{};
      if (status != null) updates['status'] = status;
      if (applicationStage != null) {
        updates['application_stage'] = applicationStage;
      }
      if (isCompleted != null) {
        updates['is_completed'] = isCompleted;
        if (isCompleted) {
          updates['completed_at'] = DateTime.now().toIso8601String();
        }
      }

      final response = await client!
          .from('referrals')
          .update(updates)
          .eq('id', referralId)
          .select()
          .single();

      debugPrint('✅ Referral updated');
      return response;
    } catch (e) {
      debugPrint('❌ Error updating referral: $e');
      rethrow;
    }
  }

  /// Generate unique referral code
  static Future<String> _generateReferralCode(String fullName) async {
    // Get first 3 letters of name
    final cleanName = fullName.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    String prefix = cleanName
        .substring(0, cleanName.length >= 3 ? 3 : cleanName.length)
        .toUpperCase();

    // Pad with X if less than 3 characters
    while (prefix.length < 3) {
      prefix += 'X';
    }

    // Generate random 4-digit suffix
    String code;
    bool exists = true;

    while (exists) {
      final suffix =
          (1000 +
                  (9000 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)
                      .floor())
              .toString();
      code = '$prefix$suffix';

      // Check if code exists
      final result = await client!
          .from('users')
          .select('id')
          .eq('referral_code', code)
          .maybeSingle();

      exists = result != null;

      if (!exists) return code;
    }

    return '${prefix}0000'; // Fallback
  }

  /// Create user session
  static Future<void> createUserSession({
    required String userId,
    String? deviceInfo,
    String? ipAddress,
    String? userAgent,
  }) async {
    if (!isConfigured) return;

    try {
      await client!.from('user_sessions').insert({
        'user_id': userId,
        'device_info': deviceInfo,
        'ip_address': ipAddress,
        'user_agent': userAgent,
        'expires_at': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
      });

      debugPrint('✅ User session created');
    } catch (e) {
      debugPrint('❌ Error creating session: $e');
    }
  }

  /// Get leaderboard snapshot via RPC (weekly/monthly)
  static Future<List<Map<String, dynamic>>> getLeaderboard({
    required String period,
    int limit = 50,
    int offset = 0,
  }) async {
    if (!isConfigured) return [];
    try {
      final result = await client!.rpc(
        'get_leaderboard',
        params: {
          'period': period,
          'limit_count': limit,
          'offset_count': offset,
        },
      );
      return List<Map<String, dynamic>>.from(result as List);
    } catch (e) {
      debugPrint('❌ Error fetching leaderboard: $e');
      return [];
    }
  }

  /// Fetch current user's transactions
  static Future<List<Map<String, dynamic>>> getUserTransactions({
    int limit = 200,
  }) async {
    if (!isConfigured || !isAuthenticated) return [];
    try {
      final uid = currentUser!.id;
      final result = await client!
          .from('transactions')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(result as List);
    } catch (e) {
      debugPrint('❌ Error fetching transactions: $e');
      return [];
    }
  }

  /// Create a withdrawal request for the current user
  static Future<Map<String, dynamic>> createWithdrawal({
    required double amount,
    required String paymentMethod,
  }) async {
    if (!isConfigured) {
      throw Exception('Supabase not configured');
    }
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      final uid = currentUser!.id;
      final data = {
        'user_id': uid,
        'type': 'withdrawal',
        'status': 'processing', // aligns with UI expectation
        'amount': amount,
        'description': 'Withdrawal to ${paymentMethod.toUpperCase()}',
        'payment_method': paymentMethod,
      };

      final inserted = await client!
          .from('transactions')
          .insert(data)
          .select()
          .single();

      return Map<String, dynamic>.from(inserted as Map);
    } catch (e) {
      debugPrint('❌ Error creating withdrawal: $e');
      rethrow;
    }
  }

  /// Check if user has already received welcome bonus
  static Future<bool> hasWelcomeBonus(String userId) async {
    if (!isConfigured) return false;

    try {
      final result = await client!
          .from('transactions')
          .select('id')
          .eq('user_id', userId)
          .eq('type', 'bonus')
          .eq('description', 'Welcome Bonus! 🎉')
          .limit(1);

      return (result as List).isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking welcome bonus: $e');
      return false;
    }
  }

  /// Create a welcome bonus transaction for a new user
  static Future<Map<String, dynamic>?> createWelcomeBonus({
    required String userId,
    required double amount,
  }) async {
    if (!isConfigured) {
      throw Exception('Supabase not configured');
    }

    try {
      // Check if user already has welcome bonus
      final alreadyHasBonus = await hasWelcomeBonus(userId);
      if (alreadyHasBonus) {
        debugPrint('⚠️ User $userId already has welcome bonus, skipping');
        return null;
      }

      final data = {
        'user_id': userId,
        'type': 'bonus',
        'amount': amount,
        'status': 'completed',
        'description': 'Welcome Bonus! 🎉',
        'completed_at': DateTime.now().toIso8601String(),
      };

      final inserted = await client!
          .from('transactions')
          .insert(data)
          .select()
          .single();

      // Update user's total_earnings by adding the bonus amount
      // First get current earnings
      final userResult = await client!
          .from('users')
          .select('total_earnings')
          .eq('id', userId)
          .single();

      final currentEarnings =
          (userResult['total_earnings'] as num?)?.toDouble() ?? 0.0;
      final newEarnings = currentEarnings + amount;

      await client!
          .from('users')
          .update({'total_earnings': newEarnings})
          .eq('id', userId);

      debugPrint('✅ Welcome bonus created: ₹$amount for user $userId');
      return Map<String, dynamic>.from(inserted as Map);
    } catch (e) {
      debugPrint('❌ Error creating welcome bonus: $e');
      rethrow;
    }
  }

  // ============================================
  // PROGRAMS OPERATIONS
  // ============================================

  /// Get all active programs
  static Future<List<Map<String, dynamic>>> getPrograms({
    String? category,
    String? mode,
    String? searchQuery,
    int? limit,
    int offset = 0,
  }) async {
    if (!isConfigured) return [];

    try {
      // Start with base query
      var queryBuilder = client!
          .from('programs')
          .select()
          .eq('is_active', true);

      // Apply category filter
      if (category != null && category != 'All') {
        queryBuilder = queryBuilder.eq('category', category);
      }

      // Apply mode filter
      if (mode != null && mode != 'All') {
        queryBuilder = queryBuilder.eq('mode', mode);
      }

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryBuilder = queryBuilder.or(
          'program_name.ilike.%$searchQuery%,university_name.ilike.%$searchQuery%',
        );
      }

      // Apply ordering and pagination
      var finalQuery = queryBuilder.order('created_at', ascending: false);

      if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      if (offset > 0) {
        finalQuery = finalQuery.range(offset, offset + (limit ?? 100) - 1);
      }

      final response = await finalQuery;
      debugPrint(
        '✅ Loaded ${(response as List).length} programs from database',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error getting programs: $e');
      return [];
    }
  }

  /// Get a single program by ID
  static Future<Map<String, dynamic>?> getProgramById(String programId) async {
    if (!isConfigured) return null;

    try {
      final response = await client!
          .from('programs')
          .select()
          .eq('id', programId)
          .maybeSingle();

      if (response != null) {
        debugPrint('✅ Loaded program: ${response['program_name']}');
      }
      return response;
    } catch (e) {
      debugPrint('❌ Error getting program: $e');
      return null;
    }
  }

  /// Get programs by university
  static Future<List<Map<String, dynamic>>> getProgramsByUniversity(
    String universityId,
  ) async {
    if (!isConfigured) return [];

    try {
      final response = await client!
          .from('programs')
          .select()
          .eq('university_id', universityId)
          .eq('is_active', true)
          .order('program_name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error getting programs by university: $e');
      return [];
    }
  }

  /// Get all universities
  static Future<List<Map<String, dynamic>>> getUniversities() async {
    if (!isConfigured) return [];

    try {
      final response = await client!
          .from('universities')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      debugPrint('✅ Loaded ${(response as List).length} universities');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error getting universities: $e');
      return [];
    }
  }

  /// Increment program referral count
  static Future<void> incrementProgramReferrals(String programId) async {
    if (!isConfigured) return;

    try {
      await client!.rpc(
        'increment_program_referrals',
        params: {'program_id': programId},
      );
      debugPrint('✅ Incremented referral count for program $programId');
    } catch (e) {
      debugPrint('❌ Error incrementing program referrals: $e');
      // Don't rethrow - this is not critical
    }
  }

  // ============================================
  // REALTIME SUBSCRIPTIONS
  // ============================================

  /// Subscribe to programs table changes
  /// Returns a RealtimeChannel that can be used to unsubscribe
  static RealtimeChannel subscribeToProgramsChanges({
    required void Function(Map<String, dynamic> payload) onInsert,
    required void Function(Map<String, dynamic> payload) onUpdate,
    required void Function(Map<String, dynamic> payload) onDelete,
  }) {
    if (!isConfigured) {
      throw Exception('Supabase not configured');
    }

    final channel = client!
        .channel('programs_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'programs',
          callback: (payload) {
            debugPrint('🔔 Program inserted: ${payload.newRecord}');
            onInsert(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'programs',
          callback: (payload) {
            debugPrint('🔔 Program updated: ${payload.newRecord}');
            onUpdate(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'programs',
          callback: (payload) {
            debugPrint('🔔 Program deleted: ${payload.oldRecord}');
            onDelete(payload.oldRecord);
          },
        )
        .subscribe();

    debugPrint('✅ Subscribed to programs table changes');
    return channel;
  }

  /// Subscribe to universities table changes
  static RealtimeChannel subscribeToUniversitiesChanges({
    required void Function(Map<String, dynamic> payload) onInsert,
    required void Function(Map<String, dynamic> payload) onUpdate,
    required void Function(Map<String, dynamic> payload) onDelete,
  }) {
    if (!isConfigured) {
      throw Exception('Supabase not configured');
    }

    final channel = client!
        .channel('universities_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'universities',
          callback: (payload) {
            debugPrint('🔔 University inserted: ${payload.newRecord}');
            onInsert(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'universities',
          callback: (payload) {
            debugPrint('🔔 University updated: ${payload.newRecord}');
            onUpdate(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'universities',
          callback: (payload) {
            debugPrint('🔔 University deleted: ${payload.oldRecord}');
            onDelete(payload.oldRecord);
          },
        )
        .subscribe();

    debugPrint('✅ Subscribed to universities table changes');
    return channel;
  }

  /// Unsubscribe from a channel
  static Future<void> unsubscribe(RealtimeChannel channel) async {
    try {
      await client!.removeChannel(channel);
      debugPrint('✅ Unsubscribed from channel');
    } catch (e) {
      debugPrint('❌ Error unsubscribing: $e');
    }
  }
}
