import 'package:flutter/material.dart';
import '../../models/product/product_model.dart';
import '../../utils/constants.dart';
import '../conflict_card.dart';

/// Widget to display ingredient conflicts
class ConflictListWidget extends StatelessWidget {
  /// List of conflicts
  final List<IngredientConflict> conflicts;

  /// Creates a conflict list widget
  const ConflictListWidget({
    Key? key,
    required this.conflicts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return conflicts.isEmpty
        ? _buildEmptyState()
        : _buildConflictList(context);
  }
  
  /// Builds an empty state when no conflicts are found
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 72,
              color: Colors.green[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Conflicts Detected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Great news! We haven\'t found any problematic ingredient combinations in this product.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Builds the conflict list
  Widget _buildConflictList(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Ingredient Conflicts (${conflicts.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'These ingredients may interact with each other, potentially reducing effectiveness or causing irritation.',
            style: TextStyle(
              color: AppColors.textSecondaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          
          // Legend
          Row(
            children: [
              const Text(
                'Severity Level:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              _buildSeverityIndicator(1, 'Low'),
              const SizedBox(width: 8),
              _buildSeverityIndicator(3, 'Medium'),
              const SizedBox(width: 8),
              _buildSeverityIndicator(5, 'High'),
            ],
          ),
          const SizedBox(height: 24),
          
          // Conflicts list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: conflicts.length,
            itemBuilder: (context, index) {
              final conflict = conflicts[index];
              return _buildConflictItem(context, conflict);
            },
          ),
        ],
      ),
    );
  }
  
  /// Builds a severity indicator
  Widget _buildSeverityIndicator(int level, String label) {
    final color = _getSeverityColor(level);
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  /// Builds a conflict item
  Widget _buildConflictItem(
    BuildContext context,
    IngredientConflict conflict,
  ) {
    return ConflictCard(
      conflict: conflict,
    );
  }
  
  /// Builds a severity badge
  Widget _buildSeverityBadge(int severity) {
    final color = _getSeverityColor(severity);
    final label = _getSeverityLabel(severity);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            5,
            (index) => Icon(
              Icons.circle,
              size: 8,
              color: index < severity
                  ? color
                  : color.withOpacity(0.3),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Get severity color based on level
  Color _getSeverityColor(int severity) {
    if (severity <= 1) return Colors.green;
    if (severity <= 2) return Colors.lightGreen;
    if (severity <= 3) return Colors.orange;
    if (severity <= 4) return Colors.deepOrange;
    return Colors.red;
  }
  
  /// Get severity label based on level
  String _getSeverityLabel(int severity) {
    if (severity <= 1) return 'Low';
    if (severity <= 2) return 'Mild';
    if (severity <= 3) return 'Moderate';
    if (severity <= 4) return 'High';
    return 'Severe';
  }
}