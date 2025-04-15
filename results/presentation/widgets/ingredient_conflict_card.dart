import 'package:flutter/material.dart';
import '../../domain/entities/ingredient_conflict.dart';

/// Widget to display ingredient conflict
class IngredientConflictCard extends StatelessWidget {
  /// Ingredient conflict
  final IngredientConflict conflict;
  
  /// Card elevation
  final double elevation;
  
  /// On tap callback
  final VoidCallback? onTap;
  
  /// Create ingredient conflict card
  const IngredientConflictCard({
    super.key,
    required this.conflict,
    this.elevation = 1.0,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Card(
      elevation: elevation,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with severity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      conflict.getConflictName(),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(conflict.severity),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      conflict.getSeverityText(),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8.0),
              
              // Conflict type
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  conflict.getTypeText(),
                  style: textTheme.bodySmall,
                ),
              ),
              
              const SizedBox(height: 12.0),
              
              // Description
              Text(
                conflict.description,
                style: textTheme.bodyMedium,
              ),
              
              if (conflict.recommendation != null) ...[
                const SizedBox(height: 12.0),
                
                // Recommendation
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16.0,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        conflict.recommendation!,
                        style: textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Show scientific validation badge if has verified references
              if (conflict.hasVerifiedReferences) ...[
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16.0,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Scientifically Verified',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (onTap != null) ...[
                      const Spacer(),
                      Text(
                        'View References',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12.0,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// Get color for severity
  Color _getSeverityColor(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.high:
        return Colors.red;
      case ConflictSeverity.medium:
        return Colors.orange;
      case ConflictSeverity.low:
        return Colors.green;
    }
  }
}