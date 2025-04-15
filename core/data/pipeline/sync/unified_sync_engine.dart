import 'dart:async';
import 'package:mutex/mutex.dart';
import '../operations/priority_queue.dart';
import '../database_orchestrator.dart';

class UnifiedSyncEngine {
  final _queue = PriorityQueue<DatabaseOperation>();
  final _batchLock = Mutex();
  static const _maxBatchSize = 100;
  static const _batchTimeout = Duration(seconds: 5);
  final _cache = Cache(); // Assuming Cache class exists and has invalidate method


  Future<void> queueOperation(DatabaseOperation operation) async {
    await _queue.enqueue(operation);
  }

  Future<void> syncNow({bool force = false}) async {
    if (!await _batchLock.tryLock()) {
      throw DatabaseLockException('Sync already in progress');
    }

    try {
      final operations = await _getPendingOperations();
      await _executeBatch(operations);
      await _verifyConsistency();
      await _invalidateAffectedCaches(operations);
    } finally {
      _batchLock.unlock();
    }
  }

  Future<void> _invalidateAffectedCaches(List<DatabaseOperation> operations) async {
    final affectedTables = operations.map((op) => op.table).toSet();
    for (final table in affectedTables) {
      await _cache.invalidate(table);
    }
  }

  Future<List<DatabaseOperation>> _getPendingOperations() async {
    return await _queue.drain(
      maxOperations: _maxBatchSize,
      timeout: _batchTimeout,
    );
  }

  Future<void> _executeBatch(List<DatabaseOperation> operations) async {
    if (operations.isEmpty) return;

    final batches = _createBatches(operations);
    for (final batch in batches) {
      await DatabaseOrchestrator.instance.executeBatch(batch);
    }
  }

  List<List<DatabaseOperation>> _createBatches(List<DatabaseOperation> operations) {
    final batches = <List<DatabaseOperation>>[];
    for (var i = 0; i < operations.length; i += _maxBatchSize) {
      final end = (i + _maxBatchSize < operations.length)
          ? i + _maxBatchSize
          : operations.length;
      batches.add(operations.sublist(i, end));
    }
    return batches;
  }

  Future<void> _verifyConsistency() async {
    final localChecksum = await _computeChecksum();
    final remoteChecksum = await _fetchRemoteChecksum();

    if (localChecksum != remoteChecksum) {
      await _triggerRepairWorkflow();
    }
  }

  Future<String> _computeChecksum() async {
    final tables = ['scan_history', 'products', 'ingredients'];
    String checksum = '';

    for (final table in tables) {
      final result = await DatabaseOrchestrator.instance
          .executeBatch([DatabaseOperation(
              type: OperationType.batch,
              table: table,
              data: {'action': 'checksum'})]);
      checksum += result.first.toString();
    }

    return checksum;
  }

  Future<void> _triggerRepairWorkflow() async {
    // Queue full sync operation with highest priority
    await _queue.enqueue(DatabaseOperation(
        type: OperationType.batch,
        table: 'all',
        data: {'action': 'full_sync'},
        priority: 10));
  }

  Future<String> _fetchRemoteChecksum() async {
    //Implementation to fetch remote checksum
    return ""; // Replace with actual implementation
  }
    Future<void> rollback(DatabaseOperation operation) async {
    await _cache.invalidate(operation.table);
    _queue.remove(operation);
  }
}

class Cache {
  Future<void> invalidate(String table) async {
    //Implementation to invalidate cache for given table
    print("Cache invalidated for table: $table");
  }
}