
import 'dart:collection';
import '../database_orchestrator.dart';

class PriorityQueue<T extends DatabaseOperation> {
  final SplayTreeSet<T> _queue = SplayTreeSet<T>((a, b) {
    final priorityCompare = b.priority.compareTo(a.priority);
    if (priorityCompare != 0) return priorityCompare;
    return a.timestamp.compareTo(b.timestamp);
  });

  void add(T operation) {
    _queue.add(operation);
  }

  Future<List<T>> drain({
    int maxOperations = 100,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final operations = <T>[];
    
    while (_queue.isNotEmpty && operations.length < maxOperations) {
      operations.add(_queue.first);
      _queue.remove(_queue.first);
    }
    
    return operations;
  }

  bool get isEmpty => _queue.isEmpty;
  int get length => _queue.length;
}
