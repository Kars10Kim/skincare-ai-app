import 'dart:convert';

/// Status of a sync operation
enum SyncStatus {
  /// Pending synchronization
  pending,
  
  /// Synchronization in progress
  inProgress,
  
  /// Synchronization completed successfully
  completed,
  
  /// Synchronization failed
  failed,
}

/// Type of sync operation
enum SyncOperationType {
  /// Create operation
  create,
  
  /// Update operation
  update,
  
  /// Delete operation
  delete,
}

/// Model for a sync operation
class SyncOperation {
  /// Unique ID for the operation
  final String id;
  
  /// Type of entity being synchronized
  final String entityType;
  
  /// ID of the entity being synchronized
  final String entityId;
  
  /// Type of operation
  final SyncOperationType operationType;
  
  /// Operation data
  final Map<String, dynamic> data;
  
  /// Status of the operation
  final SyncStatus status;
  
  /// Timestamp when operation was created
  final DateTime createdAt;
  
  /// Timestamp when operation was last updated
  final DateTime updatedAt;
  
  /// Error message if operation failed
  final String? errorMessage;
  
  /// Retry count
  final int retryCount;
  
  /// Creates a sync operation
  SyncOperation({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.data,
    this.status = SyncStatus.pending,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.errorMessage,
    this.retryCount = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  
  /// Create from JSON
  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'],
      entityType: json['entity_type'],
      entityId: json['entity_id'],
      operationType: SyncOperationType.values[json['operation_type']],
      data: jsonDecode(json['data']),
      status: SyncStatus.values[json['status']],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      errorMessage: json['error_message'],
      retryCount: json['retry_count'],
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation_type': operationType.index,
      'data': jsonEncode(data),
      'status': status.index,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'error_message': errorMessage,
      'retry_count': retryCount,
    };
  }
  
  /// Create a copy with updated fields
  SyncOperation copyWith({
    String? id,
    String? entityType,
    String? entityId,
    SyncOperationType? operationType,
    Map<String, dynamic>? data,
    SyncStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? errorMessage,
    int? retryCount,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      data: data ?? this.data,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
    );
  }
  
  /// Mark the operation as in progress
  SyncOperation markInProgress() {
    return copyWith(
      status: SyncStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Mark the operation as completed
  SyncOperation markCompleted() {
    return copyWith(
      status: SyncStatus.completed,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Mark the operation as failed
  SyncOperation markFailed(String error) {
    return copyWith(
      status: SyncStatus.failed,
      errorMessage: error,
      updatedAt: DateTime.now(),
      retryCount: retryCount + 1,
    );
  }
  
  /// Check if the operation can be retried
  bool get canRetry => status == SyncStatus.failed && retryCount < 3;
}