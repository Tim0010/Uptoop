import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uptop_careers/services/supabase_service.dart';

/// Service to queue operations when offline and retry when online
class OfflineQueueService {
  static final OfflineQueueService _instance = OfflineQueueService._internal();
  factory OfflineQueueService() => _instance;
  OfflineQueueService._internal();

  static const String _queueKey = 'offline_queue';
  final List<QueuedOperation> _queue = [];
  bool _isProcessing = false;
  Timer? _retryTimer;

  /// Initialize the queue service
  Future<void> initialize() async {
    await _loadQueue();
    _startPeriodicRetry();
    debugPrint(
      '✅ Offline queue service initialized with ${_queue.length} pending operations',
    );
  }

  /// Add an operation to the queue
  Future<void> enqueue({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final operation = QueuedOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      data: data,
      timestamp: DateTime.now(),
      attempts: 0,
    );

    _queue.add(operation);
    await _saveQueue();
    debugPrint('📥 Queued operation: $type (${_queue.length} in queue)');

    // Try to process immediately
    _processQueue();
  }

  /// Process all queued operations
  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) {
      return;
    }

    if (!SupabaseService.isConfigured) {
      debugPrint('⚠️ Supabase not configured, skipping queue processing');
      return;
    }

    _isProcessing = true;
    debugPrint('🔄 Processing offline queue (${_queue.length} operations)');

    final operationsToProcess = List<QueuedOperation>.from(_queue);

    for (final operation in operationsToProcess) {
      try {
        final success = await _executeOperation(operation);

        if (success) {
          _queue.remove(operation);
          debugPrint('✅ Completed queued operation: ${operation.type}');
        } else {
          operation.attempts++;
          debugPrint(
            '❌ Failed queued operation: ${operation.type} (attempt ${operation.attempts})',
          );

          // Remove if max attempts reached
          if (operation.attempts >= 5) {
            _queue.remove(operation);
            debugPrint(
              '🗑️ Removed operation after max attempts: ${operation.type}',
            );
          }
        }
      } catch (e) {
        operation.attempts++;
        debugPrint('❌ Error executing queued operation: $e');

        if (operation.attempts >= 5) {
          _queue.remove(operation);
        }
      }
    }

    await _saveQueue();
    _isProcessing = false;

    if (_queue.isEmpty) {
      debugPrint('✅ Offline queue cleared');
    } else {
      debugPrint('⚠️ ${_queue.length} operations still pending');
    }
  }

  /// Execute a queued operation
  Future<bool> _executeOperation(QueuedOperation operation) async {
    switch (operation.type) {
      case 'update_referral':
        return await _updateReferral(operation.data);
      case 'update_application':
        return await _updateApplication(operation.data);
      case 'create_application':
        return await _createApplication(operation.data);
      default:
        debugPrint('⚠️ Unknown operation type: ${operation.type}');
        return false;
    }
  }

  /// Update referral status
  Future<bool> _updateReferral(Map<String, dynamic> data) async {
    try {
      await SupabaseService.client!
          .from('referrals')
          .update({
            'status': data['status'],
            'application_stage': data['applicationStage'],
            'is_completed': data['isCompleted'],
          })
          .eq('id', data['referralId']);
      return true;
    } catch (e) {
      debugPrint('❌ Error updating referral: $e');
      return false;
    }
  }

  /// Update application
  Future<bool> _updateApplication(Map<String, dynamic> data) async {
    try {
      await SupabaseService.client!
          .from('applications')
          .update(data['updateData'])
          .eq('id', data['applicationId']);
      return true;
    } catch (e) {
      debugPrint('❌ Error updating application: $e');
      return false;
    }
  }

  /// Create application
  Future<bool> _createApplication(Map<String, dynamic> data) async {
    try {
      await SupabaseService.client!.from('applications').insert(data);
      return true;
    } catch (e) {
      debugPrint('❌ Error creating application: $e');
      return false;
    }
  }

  /// Load queue from storage
  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);

      if (queueJson != null) {
        final List<dynamic> decoded = jsonDecode(queueJson);
        _queue.clear();
        _queue.addAll(decoded.map((e) => QueuedOperation.fromJson(e)));
      }
    } catch (e) {
      debugPrint('❌ Error loading queue: $e');
    }
  }

  /// Save queue to storage
  Future<void> _saveQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(_queue.map((e) => e.toJson()).toList());
      await prefs.setString(_queueKey, queueJson);
    } catch (e) {
      debugPrint('❌ Error saving queue: $e');
    }
  }

  /// Start periodic retry timer
  void _startPeriodicRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _processQueue();
    });
  }

  /// Manually trigger queue processing
  Future<void> processNow() async {
    await _processQueue();
  }

  /// Get queue size
  int get queueSize => _queue.length;

  /// Dispose
  void dispose() {
    _retryTimer?.cancel();
  }
}

/// Queued operation model
class QueuedOperation {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  int attempts;

  QueuedOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.attempts = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'attempts': attempts,
  };

  factory QueuedOperation.fromJson(Map<String, dynamic> json) =>
      QueuedOperation(
        id: json['id'],
        type: json['type'],
        data: Map<String, dynamic>.from(json['data']),
        timestamp: DateTime.parse(json['timestamp']),
        attempts: json['attempts'] ?? 0,
      );
}
