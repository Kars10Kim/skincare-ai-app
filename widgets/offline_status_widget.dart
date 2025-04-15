import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';
import '../services/sync_queue_service.dart';
import '../utils/constants.dart';
import '../utils/memory_management.dart';
import '../services/error_handler.dart';
import '../services/service_locator.dart';

/// Widget to display offline status and pending sync items
class OfflineStatusWidget extends StatefulWidget {
  /// Whether to use compact mode
  final bool compact;
  
  /// Creates an offline status widget
  const OfflineStatusWidget({
    Key? key,
    this.compact = false,
  }) : super(key: key);

  @override
  State<OfflineStatusWidget> createState() => _OfflineStatusWidgetState();
}

class _OfflineStatusWidgetState extends State<OfflineStatusWidget> 
    with AutoDisposeMixin<OfflineStatusWidget> {
  /// Notifier for connection status
  late final ValueNotifier<bool> _isConnected;
  
  /// Notifier for sync queue length
  late final ValueNotifier<int> _queueLength;
  
  /// Connection status subscription
  late final StreamSubscription<bool> _connectionSubscription;
  
  /// Sync queue length subscription
  late final StreamSubscription<int> _queueSubscription;
  
  /// Whether syncing is in progress
  bool _isSyncing = false;
  
  @override
  void initState() {
    super.initState();
    try {
      // Initialize value notifiers
      _isConnected = ValueNotifier<bool>(getIt<ConnectivityService>().isConnected);
      _queueLength = ValueNotifier<int>(getIt<SyncQueueService>().queueLength);
      
      // Add to dispose bag
      addDisposable(_isConnected);
      addDisposable(_queueLength);
      
      // Listen for connectivity changes
      _connectionSubscription = getIt<ConnectivityService>().connectionStream.listen(_handleConnectivityChange);
      addDisposable(_connectionSubscription);
      
      // Listen for queue length changes
      _queueSubscription = getIt<SyncQueueService>().queueStream.listen(_handleQueueChange);
      addDisposable(_queueSubscription);
      
      // Initialize sync status
      _isSyncing = getIt<SyncQueueService>().isSyncing;
    } catch (e, stackTrace) {
      getIt<ErrorHandler>().handleError(
        'Failed to initialize offline status widget: $e',
        stackTrace,
      );
    }
  }
  
  /// Handle connectivity changes
  void _handleConnectivityChange(bool isConnected) {
    try {
      _isConnected.value = isConnected;
      
      // If we're back online and have pending items, trigger sync
      if (isConnected && _queueLength.value > 0 && !_isSyncing) {
        _triggerSync();
      }
    } catch (e, stackTrace) {
      getIt<ErrorHandler>().handleError(
        'Error handling connectivity change: $e',
        stackTrace,
      );
    }
  }
  
  /// Handle queue length changes
  void _handleQueueChange(int queueLength) {
    try {
      _queueLength.value = queueLength;
    } catch (e, stackTrace) {
      getIt<ErrorHandler>().handleError(
        'Error handling queue change: $e',
        stackTrace,
      );
    }
  }
  
  /// Trigger sync process
  Future<void> _triggerSync() async {
    try {
      if (_isSyncing) return;
      
      setState(() {
        _isSyncing = true;
      });
      
      await getIt<SyncQueueService>().syncNow();
      
      setState(() {
        _isSyncing = false;
      });
    } catch (e, stackTrace) {
      getIt<ErrorHandler>().handleError(
        'Error triggering sync: $e',
        stackTrace,
        context: context,
      );
      
      setState(() {
        _isSyncing = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    try {
      return ValueListenableBuilder<bool>(
        valueListenable: _isConnected,
        builder: (context, isConnected, _) {
          return ValueListenableBuilder<int>(
            valueListenable: _queueLength,
            builder: (context, queueLength, _) {
              // If online and no pending items, don't show anything
              if (isConnected && queueLength == 0 && !_isSyncing) {
                return const SizedBox.shrink();
              }
              
              return _buildStatusIndicator(isConnected, queueLength);
            },
          );
        },
      );
    } catch (e, stackTrace) {
      // Schedule error handling after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getIt<ErrorHandler>().handleError(
          'Offline status widget error: $e',
          stackTrace,
          context: context,
        );
      });
      
      // Return a minimal fallback widget
      return const SizedBox.shrink();
    }
  }
  
  /// Build status indicator based on connectivity and queue length
  Widget _buildStatusIndicator(bool isConnected, int queueLength) {
    // Compact view just shows an icon in the app bar
    if (widget.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _isSyncing 
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isConnected ? Colors.white : Colors.orange,
                    ),
                  ),
                )
              : Icon(
                  isConnected ? Icons.cloud_queue : Icons.cloud_off,
                  color: isConnected ? Colors.white : Colors.orange,
                  size: 20,
                ),
          if (queueLength > 0) ...[
            const SizedBox(width: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _isSyncing ? Colors.orange : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                queueLength.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      );
    }
    
    // Full view shows a card with more details
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0, // Using custom shadow in AnimatedContainer
        color: isConnected 
            ? _isSyncing 
                ? Colors.lightBlue.shade50 
                : Colors.blue.shade50 
            : Colors.orange.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isConnected 
                ? _isSyncing 
                    ? Colors.lightBlue.shade200 
                    : Colors.blue.shade200 
                : Colors.orange.shade200,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isSyncing 
                    ? SizedBox(
                        key: const ValueKey('syncing'),
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isConnected ? Colors.blue : Colors.orange,
                          ),
                        ),
                      )
                    : Icon(
                        key: const ValueKey('status'),
                        isConnected ? Icons.cloud_done : Icons.cloud_off,
                        color: isConnected ? Colors.blue : Colors.orange,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        key: ValueKey(isConnected 
                            ? (_isSyncing ? 'syncing' : 'connected') 
                            : 'offline'),
                        isConnected 
                            ? (_isSyncing ? 'Syncing...' : 'Connected') 
                            : 'Offline Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isConnected 
                              ? Colors.blue.shade700 
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                    if (queueLength > 0) ...[
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          key: ValueKey('$queueLength items'),
                          '$queueLength ${queueLength == 1 ? 'item' : 'items'} pending sync',
                          style: TextStyle(
                            fontSize: 12,
                            color: isConnected 
                                ? Colors.blue.shade700 
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (queueLength > 0) ...[
                _isSyncing 
                    ? IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                        tooltip: 'Cancel Sync',
                        onPressed: () {
                          try {
                            setState(() => _isSyncing = false);
                            getIt<SyncQueueService>().cancelSync();
                          } catch (e, stackTrace) {
                            getIt<ErrorHandler>().handleError(
                              'Error canceling sync: $e',
                              stackTrace,
                              context: context,
                            );
                          }
                        },
                      )
                    : isConnected 
                        ? TextButton.icon(
                            icon: const Icon(Icons.sync),
                            label: const Text('Sync Now'),
                            onPressed: () {
                              try {
                                _triggerSync();
                              } catch (e, stackTrace) {
                                getIt<ErrorHandler>().handleError(
                                  'Error starting sync: $e',
                                  stackTrace,
                                  context: context,
                                  recoveryActions: [
                                    ErrorRecoveryAction.retry(
                                      'Try Again',
                                      () async => _triggerSync(),
                                    ),
                                  ],
                                );
                              }
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.sync_disabled, color: Colors.grey),
                            tooltip: 'Waiting for connection',
                            onPressed: null,
                          ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}