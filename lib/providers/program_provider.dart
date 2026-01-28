import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/program.dart';
import '../config/constants.dart';
import '../services/program_data_service.dart';
import '../services/supabase_service.dart';

class ProgramProvider with ChangeNotifier {
  List<Program> _programs = [];
  List<Program> _filteredPrograms = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedMode = 'All';
  RealtimeChannel? _programsChannel;

  // Getters
  List<Program> get programs => _programs;
  List<Program> get filteredPrograms => _filteredPrograms;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedMode => _selectedMode;

  // Categories
  List<String> get categories => [
    'All',
    'Engineering',
    'Business',
    'Arts',
    'Science',
    'Law',
    'Medical',
  ];

  // Modes
  List<String> get modes => ['All', 'Online', 'Offline', 'Hybrid'];

  // Load programs
  Future<void> loadPrograms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch programs from database
      final programsData = await ProgramDataService.getPrograms();

      if (programsData.isEmpty) {
        debugPrint('⚠️ No programs found in database. Using fallback data.');
        // Fallback to mock data if database is empty
        _programs = _getMockPrograms();
      } else {
        // Convert database data to Program objects
        _programs = programsData.map((data) => Program.fromJson(data)).toList();
        debugPrint('✅ Loaded ${_programs.length} programs from database');
      }

      _filteredPrograms = List.from(_programs);
      _isLoading = false;
      notifyListeners();

      // Subscribe to real-time updates after initial load
      subscribeToRealtimeUpdates();
    } catch (e) {
      debugPrint('❌ Error loading programs: $e');
      _error = e.toString();
      // Use fallback data on error
      _programs = _getMockPrograms();
      _filteredPrograms = List.from(_programs);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mock programs data as fallback
  List<Program> _getMockPrograms() {
    return [
      Program(
        id: 'prog1',
        universityId: 'uni1',
        universityName: 'Shoolini University',
        programName: 'BBA - Business Administration',
        category: 'Business',
        duration: '3 Years',
        mode: 'Online',
        earning: 2500,
        logoPath: AppConstants.shooliniLogo,
        description:
            'Bachelor of Business Administration with specialization in Marketing, Finance, and HR',
        highlights: [
          'Industry-recognized degree',
          'Internship opportunities',
          'Placement assistance',
        ],
      ),
      Program(
        id: 'prog2',
        universityId: 'uni2',
        universityName: 'UPES',
        programName: 'B.Tech CSE',
        category: 'Engineering',
        duration: '4 Years',
        mode: 'Offline',
        earning: 3000,
        logoPath: AppConstants.upesLogo,
        description:
            'Bachelor of Technology in Computer Science and Engineering',
        highlights: [
          'NAAC A+ accredited',
          'Top placements',
          'Modern curriculum',
        ],
      ),
      Program(
        id: 'prog3',
        universityId: 'uni3',
        universityName: 'Amity University',
        programName: 'MBA',
        category: 'Business',
        duration: '2 Years',
        mode: 'Hybrid',
        earning: 5000,
        logoPath: AppConstants.amityLogo,
        description:
            'Master of Business Administration with dual specialization',
        highlights: [
          'International exposure',
          'Industry mentorship',
          'Executive faculty',
        ],
      ),
      Program(
        id: 'prog4',
        universityId: 'uni4',
        universityName: 'Manipal University',
        programName: 'B.Sc Data Science',
        category: 'Science',
        duration: '3 Years',
        mode: 'Online',
        earning: 2800,
        logoPath: AppConstants.manipalLogo,
        description: 'Bachelor of Science in Data Science and Analytics',
        highlights: ['Industry projects', 'AI/ML focus', 'Job-ready skills'],
      ),
      Program(
        id: 'prog5',
        universityId: 'uni5',
        universityName: 'LPU',
        programName: 'B.Tech Mechanical',
        category: 'Engineering',
        duration: '4 Years',
        mode: 'Offline',
        earning: 2700,
        logoPath: AppConstants.lpuLogo,
        description: 'Bachelor of Technology in Mechanical Engineering',
        highlights: [
          'State-of-art labs',
          'Industry tie-ups',
          'Research opportunities',
        ],
      ),
      Program(
        id: 'prog6',
        universityId: 'uni6',
        universityName: 'Chandigarh University',
        programName: 'BBA Digital Marketing',
        category: 'Business',
        duration: '3 Years',
        mode: 'Online',
        earning: 2400,
        logoPath: AppConstants.chandigarhLogo,
        description: 'BBA with specialization in Digital Marketing',
        highlights: [
          'Google certifications',
          'Live projects',
          'Industry experts',
        ],
      ),
    ];
  }

  // Search programs
  void searchPrograms(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // Filter by mode
  void filterByMode(String mode) {
    _selectedMode = mode;
    _applyFilters();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _selectedMode = 'All';
    _applyFilters();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredPrograms = _programs.where((program) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          program.programName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          program.universityName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      // Category filter
      final matchesCategory =
          _selectedCategory == 'All' || program.category == _selectedCategory;

      // Mode filter
      final matchesMode =
          _selectedMode == 'All' || program.mode == _selectedMode;

      return matchesSearch && matchesCategory && matchesMode;
    }).toList();

    notifyListeners();
  }

  // Get program by ID
  Program? getProgramById(String id) {
    try {
      return _programs.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // REALTIME SUBSCRIPTIONS
  // ============================================

  /// Subscribe to real-time program updates
  void subscribeToRealtimeUpdates() {
    if (!SupabaseService.isConfigured) {
      debugPrint('⚠️ Supabase not configured. Realtime updates disabled.');
      return;
    }

    try {
      _programsChannel = SupabaseService.subscribeToProgramsChanges(
        onInsert: (payload) {
          _handleProgramInsert(payload);
        },
        onUpdate: (payload) {
          _handleProgramUpdate(payload);
        },
        onDelete: (payload) {
          _handleProgramDelete(payload);
        },
      );
      debugPrint('✅ Subscribed to real-time program updates');
    } catch (e) {
      debugPrint('❌ Error subscribing to realtime updates: $e');
    }
  }

  /// Unsubscribe from real-time updates
  Future<void> unsubscribeFromRealtimeUpdates() async {
    if (_programsChannel != null) {
      await SupabaseService.unsubscribe(_programsChannel!);
      _programsChannel = null;
      debugPrint('✅ Unsubscribed from real-time program updates');
    }
  }

  /// Handle program insert event
  void _handleProgramInsert(Map<String, dynamic> payload) {
    try {
      final newProgram = Program.fromJson(payload);

      // Check if program already exists
      final existingIndex = _programs.indexWhere((p) => p.id == newProgram.id);
      if (existingIndex == -1) {
        _programs.add(newProgram);
        debugPrint('➕ Added new program: ${newProgram.programName}');
        _applyFilters();
      }
    } catch (e) {
      debugPrint('❌ Error handling program insert: $e');
    }
  }

  /// Handle program update event
  void _handleProgramUpdate(Map<String, dynamic> payload) {
    try {
      final updatedProgram = Program.fromJson(payload);

      final index = _programs.indexWhere((p) => p.id == updatedProgram.id);
      if (index != -1) {
        _programs[index] = updatedProgram;
        debugPrint('🔄 Updated program: ${updatedProgram.programName}');
        _applyFilters();
      } else {
        // Program doesn't exist, add it
        _programs.add(updatedProgram);
        debugPrint(
          '➕ Added program from update: ${updatedProgram.programName}',
        );
        _applyFilters();
      }
    } catch (e) {
      debugPrint('❌ Error handling program update: $e');
    }
  }

  /// Handle program delete event
  void _handleProgramDelete(Map<String, dynamic> payload) {
    try {
      final programId = payload['id'] as String?;
      if (programId != null) {
        final index = _programs.indexWhere((p) => p.id == programId);
        if (index != -1) {
          final deletedProgram = _programs[index];
          _programs.removeAt(index);
          debugPrint('🗑️ Deleted program: ${deletedProgram.programName}');
          _applyFilters();
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling program delete: $e');
    }
  }

  @override
  void dispose() {
    // Unsubscribe when provider is disposed
    unsubscribeFromRealtimeUpdates();
    super.dispose();
  }
}
