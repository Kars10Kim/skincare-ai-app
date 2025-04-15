import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../recognition/domain/entities/scan_history_item.dart';
import '../cubit/home_cubit.dart';

/// Widget for displaying a scan history item
class ScanHistoryTile extends StatelessWidget {
  /// Scan history item to display
  final ScanHistoryItem scan;
  
  /// Callback when the tile is tapped
  final VoidCallback onTap;
  
  /// Create a scan history tile
  const ScanHistoryTile({
    Key? key,
    required this.scan,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd().add_jm();
    
    return Dismissible(
      key: Key('scan_${scan.barcode}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        context.read<HomeCubit>().deleteScan(scan.barcode);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Product image or icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: scan.imageUrl != null
                        ? null
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: scan.imageUrl != null
                      ? Image.network(
                          scan.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported_outlined);
                          },
                        )
                      : Icon(
                          Icons.inventory_2_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.name ?? 'Unknown Product',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scan.brand ?? 'Unknown Brand',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scanned: ${dateFormat.format(scan.timestamp)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                
                // Favorite button
                IconButton(
                  icon: Icon(
                    scan.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: scan.isFavorite
                        ? Colors.redAccent
                        : null,
                  ),
                  onPressed: () {
                    context.read<HomeCubit>().toggleFavorite(scan.barcode);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}