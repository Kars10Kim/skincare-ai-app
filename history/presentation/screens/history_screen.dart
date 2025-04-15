import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/scan_history_item.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/severity_badge.dart';
import 'history_detail_screen.dart';

/// History screen
class HistoryScreen extends StatefulWidget {
  /// Create history screen
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final HistoryCubit _historyCubit;
  
  @override
  void initState() {
    super.initState();
    _historyCubit = sl<HistoryCubit>();
    _historyCubit.loadHistory();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _historyCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan History'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearchDialog,
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterMenu,
            ),
          ],
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is HistoryInitial || state is HistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is HistoryError) {
              return Center(
                child: Text(state.message),
              );
            } else if (state is HistoryLoaded) {
              if (state.items.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.history,
                  title: 'No Scan History',
                  message: 'Scanned products will appear here. '
                      'Start scanning products to track your history.',
                  actionText: 'SCAN PRODUCT',
                  onAction: () {
                    // Navigate to home/scan screen
                    // In a real implementation, this would navigate to the scan page
                    Navigator.of(context).pop();
                  },
                );
              }
              
              return Column(
                children: [
                  _buildFilterChips(context, state),
                  Expanded(
                    child: _buildHistoryList(context, state),
                  ),
                ],
              );
            }
            
            return const Center(
              child: Text('Unknown state'),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showClearHistoryConfirmation,
          backgroundColor: Colors.red,
          child: const Icon(Icons.delete_sweep),
        ),
      ),
    );
  }
  
  Widget _buildFilterChips(BuildContext context, HistoryLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            'Favorites',
            Icons.favorite,
            state.favoritesOnly,
            (value) => _historyCubit.toggleFavoritesOnly(value),
          ),
          const SizedBox(width: 8),
          Text(
            'Filtered by: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          _buildSelectedFilter(context, state.filter),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(
    BuildContext context,
    String label,
    IconData icon,
    bool selected,
    Function(bool) onSelected,
  ) {
    return FilterChip(
      selected: selected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? Colors.white : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey[800],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor,
      onSelected: onSelected,
    );
  }
  
  Widget _buildSelectedFilter(BuildContext context, HistoryFilter filter) {
    late final String label;
    late final Color color;
    
    switch (filter) {
      case HistoryFilter.all:
        label = 'All Scans';
        color = Colors.blue;
        break;
      case HistoryFilter.safe:
        label = 'Safe Products';
        color = Colors.green;
        break;
      case HistoryFilter.conflicts:
        label = 'With Conflicts';
        color = Colors.orange;
        break;
      case HistoryFilter.highSeverity:
        label = 'High Severity';
        color = Colors.red;
        break;
    }
    
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      onDeleted: filter != HistoryFilter.all
          ? () => _historyCubit.applyFilter(HistoryFilter.all)
          : null,
      deleteIcon: filter != HistoryFilter.all
          ? const Icon(Icons.clear, size: 16, color: Colors.white)
          : null,
    );
  }
  
  Widget _buildHistoryList(BuildContext context, HistoryLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return _buildHistoryCard(context, item);
      },
    );
  }
  
  Widget _buildHistoryCard(BuildContext context, ScanHistoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToDetail(context, item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getScanTypeColor(item.scanType).withOpacity(0.2),
                    child: Icon(
                      _getScanTypeIcon(item.scanType),
                      color: _getScanTypeColor(item.scanType),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.product.brand != null) ...[
                          Text(
                            item.product.brand!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          SeverityBadge(
                            severity: item.highestConflictSeverity,
                            showLabel: true,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              item.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: item.isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => _toggleFavorite(item),
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(item.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    'Safety',
                    '${item.safetyScore}%',
                    _getSafetyScoreColor(item.safetyScore),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    'Conflicts',
                    '${item.conflicts.length}',
                    item.conflicts.isEmpty ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    'Ingredients',
                    '${item.product.ingredients.length}',
                    Colors.blue,
                  ),
                ],
              ),
              if (item.notes != null && item.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.notes!,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 24,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: item.tags.map((tag) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[800],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getScanTypeIcon(ScanHistoryItemType scanType) {
    switch (scanType) {
      case ScanHistoryItemType.barcode:
        return Icons.qr_code;
      case ScanHistoryItemType.camera:
        return Icons.camera_alt;
      case ScanHistoryItemType.manual:
        return Icons.edit;
    }
  }
  
  Color _getScanTypeColor(ScanHistoryItemType scanType) {
    switch (scanType) {
      case ScanHistoryItemType.barcode:
        return Colors.purple;
      case ScanHistoryItemType.camera:
        return Colors.blue;
      case ScanHistoryItemType.manual:
        return Colors.teal;
    }
  }
  
  Color _getSafetyScoreColor(int score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 60) {
      return Colors.lightGreen;
    } else if (score >= 40) {
      return Colors.orange;
    } else if (score >= 20) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }
  
  String _formatDate(DateTime date) {
    // Format date as 'Today', 'Yesterday', or 'MMM dd'
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);
    
    if (dateDay == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (dateDay == yesterday) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${_getMonth(date.month)} ${date.day}, ${_formatTime(date)}';
    }
  }
  
  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
  
  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
  
  void _toggleFavorite(ScanHistoryItem item) {
    _historyCubit.toggleFavorite(item.id, !item.isFavorite);
  }
  
  void _navigateToDetail(BuildContext context, ScanHistoryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HistoryDetailScreen(item: item),
      ),
    );
  }
  
  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Scans'),
              leading: const Icon(Icons.all_inclusive, color: Colors.blue),
              onTap: () {
                _historyCubit.applyFilter(HistoryFilter.all);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Safe Products'),
              leading: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () {
                _historyCubit.applyFilter(HistoryFilter.safe);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Products with Conflicts'),
              leading: const Icon(Icons.warning, color: Colors.orange),
              onTap: () {
                _historyCubit.applyFilter(HistoryFilter.conflicts);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('High Severity Conflicts'),
              leading: const Icon(Icons.dangerous, color: Colors.red),
              onTap: () {
                _historyCubit.applyFilter(HistoryFilter.highSeverity);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final controller = TextEditingController();
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Product name, brand, ingredient, etc.',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => controller.clear(),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _historyCubit.searchHistory(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search Tips',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    TextButton(
                      onPressed: () {
                        final value = controller.text.trim();
                        if (value.isNotEmpty) {
                          _historyCubit.searchHistory(value);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('SEARCH'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSearchTip('Moisturizer', () {
                      controller.text = 'Moisturizer';
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }),
                    _buildSearchTip('CeraVe', () {
                      controller.text = 'CeraVe';
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }),
                    _buildSearchTip('Hyaluronic Acid', () {
                      controller.text = 'Hyaluronic Acid';
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }),
                    _buildSearchTip('Conflicts', () {
                      controller.text = 'Conflicts';
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSearchTip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
  
  void _showClearHistoryConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Scan History?'),
        content: const Text(
          'Are you sure you want to clear your entire scan history? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              _historyCubit.clearHistory();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }
}