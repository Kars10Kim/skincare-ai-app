import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_analysis_provider.dart';
import '../utils/memory_management.dart';
import '../services/error_handler.dart';
import '../services/service_locator.dart';
import '../services/connectivity_service.dart';

/// Widget to display network status
class NetworkStatusIndicator extends StatefulWidget {
  /// Creates a network status indicator
  const NetworkStatusIndicator({Key? key}) : super(key: key);

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator> 
    with AutoDisposeMixin<NetworkStatusIndicator> {
  
  /// Subscription to connectivity changes
  late final StreamSubscription<bool> _connectivitySubscription;
  
  /// Local state to track offline status
  bool _isOffline = false;
  
  /// Whether indicator is animating in/out
  bool _isAnimating = false;
  
  @override
  void initState() {
    super.initState();
    
    // Listen to connectivity changes directly from the service
    final connectivityService = getIt<ConnectivityService>();
    _connectivitySubscription = connectivityService.connectionStream.listen(_handleConnectivityChange);
    
    // Register for auto-disposal
    addDisposable(_connectivitySubscription);
    
    // Initialize state from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final analysisProvider = Provider.of<ProductAnalysisProvider>(context, listen: false);
        _isOffline = analysisProvider.isOffline;
        if (mounted) setState(() {});
      } catch (e, stackTrace) {
        getIt<ErrorHandler>().handleError(
          'Failed to get initial network status: $e',
          stackTrace,
        );
      }
    });
  }
  
  /// Handle connectivity changes
  void _handleConnectivityChange(bool isConnected) {
    try {
      setState(() {
        _isOffline = !isConnected;
        _isAnimating = true;
      });
    } catch (e, stackTrace) {
      getIt<ErrorHandler>().handleError(
        'Error handling connectivity change: $e',
        stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (!_isOffline) {
        return const SizedBox.shrink(); // Return empty widget when online
      }
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: _isOffline ? 36 : 0,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        color: Colors.orange.shade700,
        onEnd: () {
          if (mounted) setState(() => _isAnimating = false);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Offline Mode',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      // Schedule error handling after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getIt<ErrorHandler>().handleError(
          'Network status indicator error: $e',
          stackTrace,
          context: context,
        );
      });
      
      // Return a minimal fallback widget
      return const SizedBox.shrink();
    }
  }
}