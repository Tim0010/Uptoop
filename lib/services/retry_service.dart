import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service to handle retry logic with exponential backoff
class RetryService {
  /// Retry a function with exponential backoff
  /// 
  /// [operation] - The async function to retry
  /// [maxAttempts] - Maximum number of retry attempts (default: 3)
  /// [initialDelay] - Initial delay in milliseconds (default: 1000ms)
  /// [maxDelay] - Maximum delay in milliseconds (default: 10000ms)
  /// [backoffMultiplier] - Multiplier for exponential backoff (default: 2.0)
  /// [retryIf] - Optional function to determine if retry should happen based on error
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    int initialDelay = 1000,
    int maxDelay = 10000,
    double backoffMultiplier = 2.0,
    bool Function(dynamic error)? retryIf,
  }) async {
    int attempt = 0;
    int delay = initialDelay;

    while (true) {
      attempt++;
      
      try {
        debugPrint('🔄 Attempt $attempt/$maxAttempts');
        return await operation();
      } catch (error) {
        // Check if we should retry
        final shouldRetry = retryIf?.call(error) ?? true;
        
        if (attempt >= maxAttempts || !shouldRetry) {
          debugPrint('❌ Max attempts reached or retry not allowed. Error: $error');
          rethrow;
        }

        // Calculate next delay with exponential backoff
        final nextDelay = (delay * backoffMultiplier).toInt();
        delay = nextDelay > maxDelay ? maxDelay : nextDelay;

        debugPrint('⏳ Retry in ${delay}ms (attempt $attempt/$maxAttempts)');
        debugPrint('   Error: $error');

        // Wait before retrying
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
  }

  /// Retry with custom retry conditions
  static Future<T> retryWithCondition<T>({
    required Future<T> Function() operation,
    required bool Function(dynamic error) shouldRetry,
    int maxAttempts = 3,
    int initialDelay = 1000,
  }) async {
    return retry<T>(
      operation: operation,
      maxAttempts: maxAttempts,
      initialDelay: initialDelay,
      retryIf: shouldRetry,
    );
  }

  /// Check if error is a network error (should retry)
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket') ||
        errorString.contains('failed host lookup');
  }

  /// Check if error is a server error (should retry)
  static bool isServerError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504') ||
        errorString.contains('internal server error');
  }

  /// Check if error is retryable (network or server error)
  static bool isRetryableError(dynamic error) {
    return isNetworkError(error) || isServerError(error);
  }

  /// Retry only on network/server errors
  static Future<T> retryOnNetworkError<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    int initialDelay = 1000,
  }) async {
    return retry<T>(
      operation: operation,
      maxAttempts: maxAttempts,
      initialDelay: initialDelay,
      retryIf: isRetryableError,
    );
  }
}

