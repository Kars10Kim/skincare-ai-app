import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

/// Content for the bottom sheet on the home screen
class BottomSheetContent extends StatelessWidget {
  /// Current state
  final HomeState state;
  
  /// Scroll controller for the drag handle
  final ScrollController scrollController;
  
  /// Create bottom sheet content
  const BottomSheetContent({
    Key? key,
    required this.state,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        _buildDragHandle(context),
        
        // Header with action buttons
        _buildHeader(context),
        
        // Stats overview
        if (state.scanHistory.isNotEmpty)
          _buildStatsOverview(context),
      ],
    );
  }
  
  /// Build the drag handle
  Widget _buildDragHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
  
  /// Build the header with action buttons
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Your Analysis History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (state.scanHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearHistoryDialog(context),
              tooltip: 'Clear History',
            ),
        ],
      ),
    );
  }
  
  /// Build stats overview
  Widget _buildStatsOverview(BuildContext context) {
    // Calculate some basic stats
    final totalScans = state.scanHistory.length;
    final favoriteScans = state.scanHistory.where((scan) => scan.isFavorite).length;
    final recentScans = state.scanHistory
        .where((scan) => 
            scan.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .length;
            
    // Get most scanned brand if available
    String? mostScannedBrand;
    if (totalScans > 0) {
      final brandCounts = <String, int>{};
      for (final scan in state.scanHistory) {
        if (scan.brand != null) {
          brandCounts[scan.brand!] = (brandCounts[scan.brand!] ?? 0) + 1;
        }
      }
      
      if (brandCounts.isNotEmpty) {
        mostScannedBrand = brandCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: totalScans.toString(),
                  subtitle: 'Total Scans',
                  icon: Icons.history,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: favoriteScans.toString(),
                  subtitle: 'Favorites',
                  icon: Icons.favorite,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: recentScans.toString(),
                  subtitle: 'Last 7 Days',
                  icon: Icons.calendar_today,
                ),
              ),
            ],
          ),
          if (mostScannedBrand != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Most scanned brand: ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  mostScannedBrand,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
  
  /// Build a stat card
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Show the clear history confirmation dialog
  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text(
          'This will remove all scan history items. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HomeCubit>().clearScanHistory();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}