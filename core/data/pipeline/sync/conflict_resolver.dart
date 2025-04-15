
import '../database_orchestrator.dart';

enum ConflictType {
  timestamp,
  server,
  client,
}

class ConflictResolver {
  final _strategies = <ConflictType, Future<DatabaseOperation> Function(DatabaseOperation, DatabaseOperation)>{
    ConflictType.timestamp: _resolveByTimestamp,
    ConflictType.server: _resolveServerPrecedence,
    ConflictType.client: _resolveClientPrecedence,
  };

  Future<DatabaseOperation> resolveConflict(
    DatabaseOperation local,
    DatabaseOperation remote,
    ConflictType strategy,
  ) async {
    final resolver = _strategies[strategy];
    if (resolver == null) {
      throw UnsupportedError('Unsupported conflict resolution strategy');
    }
    return await resolver(local, remote);
  }

  static Future<DatabaseOperation> _resolveByTimestamp(
    DatabaseOperation local,
    DatabaseOperation remote,
  ) async {
    if (local.timestamp == null || remote.timestamp == null) {
      return remote; // Default to remote if timestamps missing
    }
    
    if (local.timestamp!.isAfter(remote.timestamp!)) {
      await _logResolution('timestamp_local_win', local, remote);
      return local;
    } else {
      await _logResolution('timestamp_remote_win', local, remote);
      return remote;
    }
  }

  static Future<void> _logResolution(
    String strategy,
    DatabaseOperation winner,
    DatabaseOperation loser,
  ) async {
    await DatabaseOrchestrator.instance.logSync(
      type: 'conflict_resolution',
      data: {
        'strategy': strategy,
        'winner_timestamp': winner.timestamp?.toIso8601String(),
        'loser_timestamp': loser.timestamp?.toIso8601String(),
        'table': winner.table,
      }
    );
  }

  static Future<DatabaseOperation> _resolveServerPrecedence(
    DatabaseOperation local,
    DatabaseOperation remote,
  ) async {
    return remote;
  }

  static Future<DatabaseOperation> _resolveClientPrecedence(
    DatabaseOperation local,
    DatabaseOperation remote,
  ) async {
    return local;
  }
}
