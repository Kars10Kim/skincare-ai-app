import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/scan_history_item.dart';
import 'severity_badge.dart';

/// History item card
class HistoryItemCard extends StatelessWidget {
  /// Scan history item
  final ScanHistoryItem item;
  
  /// Callback when the card is tapped
  final VoidCallback onTap;
  
  /// Callback when the favorite toggle is tapped
  final VoidCallback onToggleFavorite;
  
  /// Create history item card
  const HistoryItemCard({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(context),
                  const SizedBox(height: 12),
                  _buildConflictsSummary(context),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildNotes(context),
                  ],
                  const SizedBox(height: 12),
                  _buildFooter(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _getHeaderColor(context),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat.yMMMd().add_jm().format(item.timestamp),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              SeverityBadge(severity: item.highestConflictSeverity),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: onToggleFavorite,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProductInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.product.imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              item.product.imageUrl!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (item.product.brand != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.product.brand!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildScanTypeBadge(),
                  const SizedBox(width: 8),
                  _buildSafetyScore(context),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildScanTypeBadge() {
    IconData icon;
    String label;
    Color color;
    
    switch (item.scanType) {
      case ScanHistoryItemType.barcode:
        icon = Icons.qr_code;
        label = 'Barcode';
        color = Colors.blue;
        break;
      case ScanHistoryItemType.camera:
        icon = Icons.camera_alt;
        label = 'Camera';
        color = Colors.green;
        break;
      case ScanHistoryItemType.manual:
        icon = Icons.edit;
        label = 'Manual';
        color = Colors.orange;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSafetyScore(BuildContext context) {
    Color color;
    if (item.safetyScore >= 70) {
      color = Colors.green;
    } else if (item.safetyScore >= 40) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            'Safety: ${item.safetyScore}%',
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConflictsSummary(BuildContext context) {
    if (item.conflicts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.5)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            SizedBox(width: 8),
            Text(
              'No conflicts detected with your preferences',
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getSeverityColor(item.highestConflictSeverity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getSeverityColor(item.highestConflictSeverity).withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.conflicts.length} ${item.conflicts.length == 1 ? 'conflict' : 'conflicts'} detected',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getSeverityColor(item.highestConflictSeverity),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getConflictsSummary(),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.note, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                'Notes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.notes!,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        if (item.tags.isNotEmpty) ...[
          const Icon(Icons.tag, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: item.tags.map((tag) {
                return Chip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Text(tag),
                  labelStyle: const TextStyle(fontSize: 12),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ),
        ] else ...[
          const Spacer(),
        ],
        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ],
    );
  }
  
  Color _getHeaderColor(BuildContext context) {
    if (item.conflicts.isEmpty) {
      return Colors.green;
    }
    
    return _getSeverityColor(item.highestConflictSeverity);
  }
  
  Color _getSeverityColor(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.high:
        return Colors.red;
      case ConflictSeverity.medium:
        return Colors.orange;
      case ConflictSeverity.low:
        return Colors.amber;
      case ConflictSeverity.none:
      default:
        return Colors.green;
    }
  }
  
  String _getConflictsSummary() {
    if (item.conflicts.isEmpty) {
      return 'No conflicts found';
    }
    
    if (item.conflicts.length <= 2) {
      return item.conflicts.map((conflict) => conflict.ingredientName).join(', ');
    }
    
    return '${item.conflicts[0].ingredientName}, ${item.conflicts[1].ingredientName}, and ${item.conflicts.length - 2} more';
  }
}