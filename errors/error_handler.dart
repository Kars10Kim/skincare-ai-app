import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../utils/memory_management.dart';

/// Severity level of an error
enum ErrorSeverity {
  /// Information only, not an error
  info,
  
  /// Minor issue that doesn't affect core functionality
  warning,
  
  /// Error that affects functionality but app can continue
  error,
  
  /// Critical error that prevents app from functioning
  critical,
  
  /// Unexpected error that crashes the app
  fatal,
}

/// Recovery action for an error
class ErrorRecoveryAction {
  /// User-friendly label for the action
  final String label;
  
  /// Function to execute when action is chosen
  final FutureOr<bool> Function() action;
  
  /// Condition to determine if this action should be shown
  final bool Function()? showWhenCondition;
  
  /// Create a recovery action
  ErrorRecoveryAction({
    required this.label,
    required this.action,
    this.showWhenCondition,
  });
  
  /// Factory for retry action
  static ErrorRecoveryAction retry(String label, FutureOr<void> Function() retryAction) {
    return ErrorRecoveryAction(
      label: label,
      action: () async {
        await retryAction();
        return true;
      },
    );
  }
  
  /// Factory for custom action
  static ErrorRecoveryAction custom(
    String label,
    FutureOr<bool> Function() customAction, {
    bool Function()? showWhenCondition,
  }) {
    return ErrorRecoveryAction(
      label: label,
      action: customAction,
      showWhenCondition: showWhenCondition,
    );
  }
  
  /// Should this action be shown
  bool shouldShow() {
    return showWhenCondition?.call() ?? true;
  }
}

/// Record of an error
class ErrorRecord {
  /// Unique ID for the error
  final String id;
  
  /// Error message
  final String message;
  
  /// Stack trace
  final StackTrace? stackTrace;
  
  /// When the error occurred
  final DateTime timestamp;
  
  /// Severity level
  final ErrorSeverity severity;
  
  /// Has this error been reported
  bool reported;
  
  /// Create an error record
  ErrorRecord({
    required this.id,
    required this.message,
    this.stackTrace,
    required this.timestamp,
    required this.severity,
    this.reported = false,
  });
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'stackTrace': stackTrace?.toString(),
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.toString(),
      'reported': reported,
    };
  }
  
  /// Create from JSON
  factory ErrorRecord.fromJson(Map<String, dynamic> json) {
    return ErrorRecord(
      id: json['id'] as String,
      message: json['message'] as String,
      stackTrace: json['stackTrace'] != null 
          ? StackTrace.fromString(json['stackTrace'] as String) 
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: ErrorSeverity.values.firstWhere(
        (e) => e.toString() == json['severity'],
        orElse: () => ErrorSeverity.error,
      ),
      reported: json['reported'] as bool? ?? false,
    );
  }
}

/// Centralized error handling for the app
class ErrorHandler with DisposeBag {
  /// Singleton instance
  static final ErrorHandler _instance = ErrorHandler._internal();
  
  /// Factory constructor
  factory ErrorHandler() => _instance;
  
  /// Queue of recent errors
  final Queue<ErrorRecord> _errorQueue = Queue<ErrorRecord>();
  
  /// Maximum number of errors to keep in memory
  final int _maxQueueSize = 50;
  
  /// Whether error reporting is enabled
  bool _reportingEnabled = true;
  
  /// UUID generator
  final _uuid = const Uuid();
  
  /// Listeners for error events
  final List<void Function(ErrorRecord)> _errorListeners = [];
  
  /// Controller for error events
  final StreamController<ErrorRecord> _errorStreamController = 
      StreamController<ErrorRecord>.broadcast();
  
  /// Get the error stream
  Stream<ErrorRecord> get errorStream => _errorStreamController.stream;
  
  /// Get recent errors
  List<ErrorRecord> get recentErrors => List.unmodifiable(_errorQueue);
  
  /// Whether error reporting is enabled
  bool get isReportingEnabled => _reportingEnabled;
  
  /// Internal constructor
  ErrorHandler._internal() {
    // Set up periodic error reporting
    final timer = Timer.periodic(const Duration(minutes: 15), (_) {
      _reportPendingErrors();
    });
    
    // Add timer to disposables
    addDisposable(timer);
    
    // Load previous errors from disk
    _loadErrorsFromDisk().then((_) {
      developer.log(
        'Loaded ${_errorQueue.length} previous errors',
        name: 'ErrorHandler',
      );
    });
  }
  
  /// Handle an error
  void handleError(
    String message,
    StackTrace? stackTrace, {
    BuildContext? context,
    ErrorSeverity severity = ErrorSeverity.error,
    List<ErrorRecoveryAction>? recoveryActions,
  }) {
    // Create error record
    final error = ErrorRecord(
      id: _uuid.v4(),
      message: message,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      severity: severity,
    );
    
    // Add to queue
    _addErrorToQueue(error);
    
    // Log to console
    _logError(error);
    
    // Notify listeners
    _notifyErrorListeners(error);
    
    // Show in UI if context is provided
    if (context != null && severity != ErrorSeverity.info) {
      _showErrorInUI(context, error, recoveryActions: recoveryActions);
    }
    
    // Report critical errors immediately
    if (severity == ErrorSeverity.critical || severity == ErrorSeverity.fatal) {
      _reportErrorImmediately(error);
    }
  }
  
  /// Add an error listener
  void addErrorListener(void Function(ErrorRecord) listener) {
    _errorListeners.add(listener);
  }
  
  /// Remove an error listener
  void removeErrorListener(void Function(ErrorRecord) listener) {
    _errorListeners.remove(listener);
  }
  
  /// Enable or disable error reporting
  void setReportingEnabled(bool enabled) {
    _reportingEnabled = enabled;
  }
  
  /// Clear all errors
  Future<void> clearErrors() async {
    _errorQueue.clear();
    await _saveErrorsToDisk();
  }
  
  /// Dispose resources
  void dispose() {
    _errorStreamController.close();
    _errorListeners.clear();
    
    // Save errors to disk
    _saveErrorsToDisk();
    
    // Dispose all
    disposeAll();
  }
  
  /// Add an error to the queue
  void _addErrorToQueue(ErrorRecord error) {
    _errorQueue.add(error);
    
    // Trim queue if too large
    while (_errorQueue.length > _maxQueueSize) {
      _errorQueue.removeFirst();
    }
    
    // Save to disk
    _saveErrorsToDisk();
  }
  
  /// Log an error to console
  void _logError(ErrorRecord error) {
    final severityTag = error.severity.toString().split('.').last.toUpperCase();
    
    developer.log(
      '[$severityTag] ${error.message}',
      name: 'ErrorHandler',
      error: error.message,
      stackTrace: error.stackTrace,
      level: _getSeverityLogLevel(error.severity),
    );
  }
  
  /// Notify error listeners
  void _notifyErrorListeners(ErrorRecord error) {
    // Notify stream listeners
    _errorStreamController.add(error);
    
    // Notify direct listeners
    for (final listener in _errorListeners) {
      try {
        listener(error);
      } catch (e) {
        developer.log(
          'Error in error listener: $e',
          name: 'ErrorHandler',
          error: e,
        );
      }
    }
  }
  
  /// Show an error in the UI
  void _showErrorInUI(
    BuildContext context,
    ErrorRecord error, {
    List<ErrorRecoveryAction>? recoveryActions,
  }) {
    // Only show if context is still mounted
    if (!context.mounted) return;
    
    // Skip info severity errors in UI
    if (error.severity == ErrorSeverity.info) return;
    
    // Show snackbar or dialog based on severity
    if (error.severity == ErrorSeverity.warning) {
      _showErrorSnackBar(context, error, recoveryActions: recoveryActions);
    } else {
      _showErrorDialog(context, error, recoveryActions: recoveryActions);
    }
  }
  
  /// Show an error in a snackbar
  void _showErrorSnackBar(
    BuildContext context,
    ErrorRecord error, {
    List<ErrorRecoveryAction>? recoveryActions,
  }) {
    // Get scaffold messenger
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Create snackbar
    final snackBar = SnackBar(
      content: Text(error.message),
      backgroundColor: _getSeverityColor(error.severity),
      duration: const Duration(seconds: 5),
      action: recoveryActions != null && recoveryActions.isNotEmpty
          ? SnackBarAction(
              label: recoveryActions.first.label,
              onPressed: () {
                recoveryActions.first.action();
              },
            )
          : null,
    );
    
    // Show snackbar
    scaffoldMessenger.showSnackBar(snackBar);
  }
  
  /// Show an error in a dialog
  void _showErrorDialog(
    BuildContext context,
    ErrorRecord error, {
    List<ErrorRecoveryAction>? recoveryActions,
  }) {
    // Create actions
    final actions = <Widget>[];
    
    // Add dismiss button
    actions.add(
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Dismiss'),
      ),
    );
    
    // Add recovery actions
    if (recoveryActions != null) {
      for (final action in recoveryActions) {
        // Only show if condition is met
        if (action.shouldShow()) {
          actions.add(
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await action.action();
                } catch (e) {
                  developer.log(
                    'Error in recovery action: $e',
                    name: 'ErrorHandler',
                    error: e,
                  );
                }
              },
              child: Text(action.label),
            ),
          );
        }
      }
    }
    
    // Show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getSeverityTitle(error.severity)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(error.message),
              if (kDebugMode && error.stackTrace != null) ...[
                const SizedBox(height: 16),
                const Text('Stack Trace (Debug Only):', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  error.stackTrace.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        actions: actions,
      ),
    );
  }
  
  /// Report pending errors to analytics
  Future<void> _reportPendingErrors() async {
    if (!_reportingEnabled) return;
    
    final unreportedErrors = _errorQueue
        .where((e) => !e.reported)
        .toList();
    
    for (final error in unreportedErrors) {
      try {
        // Report to analytics (in a real app)
        // analyticsService.logError(error.message, {
        //   'severity': error.severity.toString(),
        //   'stack_trace': error.stackTrace?.toString(),
        //   'timestamp': error.timestamp.toIso8601String(),
        // });
        
        // Mark as reported
        error.reported = true;
      } catch (e) {
        developer.log(
          'Error reporting error: $e',
          name: 'ErrorHandler',
          error: e,
        );
      }
    }
    
    // Save updated error records
    await _saveErrorsToDisk();
  }
  
  /// Report an error immediately
  Future<void> _reportErrorImmediately(ErrorRecord error) async {
    if (!_reportingEnabled) return;
    
    try {
      // Report to analytics (in a real app)
      // analyticsService.logError(error.message, {
      //   'severity': error.severity.toString(),
      //   'stack_trace': error.stackTrace?.toString(),
      //   'timestamp': error.timestamp.toIso8601String(),
      // });
      
      // Mark as reported
      error.reported = true;
    } catch (e) {
      developer.log(
        'Error reporting error immediately: $e',
        name: 'ErrorHandler',
        error: e,
      );
    }
  }
  
  /// Save errors to disk
  Future<void> _saveErrorsToDisk() async {
    try {
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/errors.json');
      
      // Convert to JSON
      final jsonList = _errorQueue.map((e) => e.toJson()).toList();
      
      // Write to file
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      developer.log(
        'Error saving errors to disk: $e',
        name: 'ErrorHandler',
        error: e,
      );
    }
  }
  
  /// Load errors from disk
  Future<void> _loadErrorsFromDisk() async {
    try {
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/errors.json');
      
      // Check if file exists
      if (!file.existsSync()) {
        return;
      }
      
      // Read and parse file
      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      
      // Convert to error records
      final errors = jsonList
          .map((json) => ErrorRecord.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Add to queue
      _errorQueue.clear();
      _errorQueue.addAll(errors);
    } catch (e) {
      developer.log(
        'Error loading errors from disk: $e',
        name: 'ErrorHandler',
        error: e,
      );
    }
  }
  
  /// Get a color for a severity level
  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.deepPurple;
      case ErrorSeverity.fatal:
        return Colors.black;
    }
  }
  
  /// Get a title for a severity level
  String _getSeverityTitle(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return 'Information';
      case ErrorSeverity.warning:
        return 'Warning';
      case ErrorSeverity.error:
        return 'Error';
      case ErrorSeverity.critical:
        return 'Critical Error';
      case ErrorSeverity.fatal:
        return 'Fatal Error';
    }
  }
  
  /// Get a log level for a severity level
  int _getSeverityLogLevel(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return 800; // INFO
      case ErrorSeverity.warning:
        return 900; // WARNING
      case ErrorSeverity.error:
        return 1000; // ERROR
      case ErrorSeverity.critical:
        return 1200; // CRITICAL
      case ErrorSeverity.fatal:
        return 1200; // CRITICAL (same as critical)
    }
  }
}