import 'package:flutter/material.dart';

import '../../domain/entities/scan_history_item.dart';

/// Card displaying scan result
class ScanResultCard extends StatelessWidget {
  /// Scan data
  final ScanHistoryItem scan;
  
  /// Detected conflicts
  final List<String>? conflicts;
  
  /// On view details callback
  final VoidCallback onViewDetails;
  
  /// On add to favorites callback
  final VoidCallback onAddToFavorites;
  
  /// Create scan result card
  const ScanResultCard({
    Key? key,
    required this.scan,
    this.conflicts,
    required this.onViewDetails,
    required this.onAddToFavorites,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type and timestamp
            Row(
              children: [
                // Scan type indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getScanTypeColor(context, scan.scanType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getScanTypeIcon(scan.scanType),
                        size: 16,
                        color: _getScanTypeColor(context, scan.scanType),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getScanTypeName(scan.scanType),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getScanTypeColor(context, scan.scanType),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Timestamp
                Text(
                  _formatTimestamp(scan.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                
                const Spacer(),
                
                // Favorite button
                IconButton(
                  onPressed: onAddToFavorites,
                  icon: Icon(
                    scan.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: scan.isFavorite
                        ? Colors.red
                        : Theme.of(context).colorScheme.outline,
                  ),
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                  tooltip: scan.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Product info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                if (scan.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.network(
                        scan.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                
                const SizedBox(width: 12),
                
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        scan.name ?? 'Unknown Product',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Brand
                      if (scan.brand != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          scan.brand!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                      
                      // Barcode
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.qr_code,
                            size: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              scan.barcode,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Ingredients list
            if (scan.ingredients != null && scan.ingredients!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: scan.ingredients!.take(6).map((ingredient) {
                  final hasConflict = conflicts?.contains(ingredient) ?? false;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hasConflict
                          ? Colors.red.shade100
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: hasConflict
                          ? Border.all(color: Colors.red.shade300)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasConflict) ...[
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          ingredient,
                          style: TextStyle(
                            fontSize: 12,
                            color: hasConflict
                                ? Colors.red.shade700
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              
              if ((scan.ingredients?.length ?? 0) > 6) ...[
                const SizedBox(height: 8),
                Text(
                  '+ ${scan.ingredients!.length - 6} more ingredients',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ],
            
            // Conflict summary
            if (conflicts != null && conflicts!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Potential Conflicts Detected',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Found ${conflicts!.length} ingredients that may cause conflicts with your skin profile',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Get scan type icon
  IconData _getScanTypeIcon(ScanType type) {
    switch (type) {
      case ScanType.barcode:
        return Icons.qr_code_scanner;
      case ScanType.image:
        return Icons.image_search;
      case ScanType.text:
        return Icons.text_fields;
    }
  }
  
  /// Get scan type name
  String _getScanTypeName(ScanType type) {
    switch (type) {
      case ScanType.barcode:
        return 'Barcode';
      case ScanType.image:
        return 'Image';
      case ScanType.text:
        return 'Text';
    }
  }
  
  /// Get scan type color
  Color _getScanTypeColor(BuildContext context, ScanType type) {
    switch (type) {
      case ScanType.barcode:
        return Colors.blue;
      case ScanType.image:
        return Colors.green;
      case ScanType.text:
        return Colors.purple;
    }
  }
  
  /// Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}