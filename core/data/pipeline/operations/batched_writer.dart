import 'dart:math';
import '../database_orchestrator.dart';
import 'package:sqflite/sqflite.dart';

class BatchedWriter {
  static const _kBatchSize = 50;

  Future<void> executeBatch(List<DatabaseOperation> ops) async {
    final db = await DatabaseOrchestrator.instance.database;
    await db.transaction((txn) async {
      for (var i = 0; i < ops.length; i += _kBatchSize) {
        final batch = ops.sublist(i, min(i + _kBatchSize, ops.length));
        await _processBatch(txn, batch);
      }
    });
  }

  Future<void> _processBatch(Transaction txn, List<DatabaseOperation> batch) async {
    final batchOp = txn.batch();

    for (final op in batch) {
      switch (op.type) {
        case OperationType.insert:
          batchOp.insert(op.table, op.data);
          break;
        case OperationType.update:
          batchOp.update(op.table, op.data, where: op.where, whereArgs: op.whereArgs);
          break;
        case OperationType.delete:
          batchOp.delete(op.table, where: op.where, whereArgs: op.whereArgs);
          break;
      }
    }

    await batchOp.commit(noResult: true);
  }
}