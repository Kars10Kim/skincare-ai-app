import 'package:flutter/material.dart';

import '../../../recognition/domain/entities/scan_history_item.dart';
import 'scan_history_tile.dart';

/// Widget for displaying scan history items
class ScanHistoryList extends StatelessWidget {
  /// Scan history items to display
  final List<ScanHistoryItem> scanHistory;
  
  /// Whether data is loading
  final bool isLoading;
  
  /// Callback when an item is tapped
  final Function(ScanHistoryItem) onItemTap;
  
  /// Create a scan history list
  const ScanHistoryList({
    Key? key,
    required this.scanHistory,
    required this.isLoading,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (scanHistory.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No scan history yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Scan a product to see it here',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = scanHistory[index];
          return ScanHistoryTile(
            scan: item,
            onTap: () => onItemTap(item),
          );
        },
        childCount: scanHistory.length,
      ),
    );
  }
}