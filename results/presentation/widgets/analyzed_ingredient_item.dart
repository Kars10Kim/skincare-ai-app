import 'package:flutter/material.dart';
import '../../domain/entities/ingredient_conflict.dart';

/// Widget to display analyzed ingredient
class AnalyzedIngredientItem extends StatelessWidget {
  /// Analyzed ingredient
  final AnalyzedIngredient ingredient;
  
  /// On tap callback
  final VoidCallback? onTap;
  
  /// Create analyzed ingredient item
  const AnalyzedIngredientItem({
    super.key,
    required this.ingredient,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status icon
            Container(
              width: 16.0,
              height: 16.0,
              margin: const EdgeInsets.only(top: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ingredient.hasConflict 
                    ? Colors.amber 
                    : (ingredient.ewgScore != null && ingredient.ewgScore! > 5) 
                      ? Colors.orange 
                      : Colors.green,
              ),
              child: ingredient.hasConflict
                  ? const Icon(
                      Icons.warning,
                      size: 10.0,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.check,
                      size: 10.0,
                      color: Colors.white,
                    ),
            ),
            
            const SizedBox(width: 12.0),
            
            // Ingredient info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  if (ingredient.purpose != null) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      ingredient.purpose!,
                      style: textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  
                  if (ingredient.concerns != null && ingredient.concerns!.isNotEmpty) ...[
                    const SizedBox(height: 4.0),
                    Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      children: ingredient.concerns!.map((concern) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          concern,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 10.0,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
            
            // EWG score
            if (ingredient.ewgScore != null) ...[
              Container(
                width: 28.0,
                height: 28.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getEwgScoreColor(ingredient.ewgScore!),
                ),
                child: Center(
                  child: Text(
                    '${ingredient.ewgScore}',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
            
            // Arrow if tappable
            if (onTap != null) ...[
              const SizedBox(width: 8.0),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14.0,
                color: Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Get color for EWG score
  Color _getEwgScoreColor(int score) {
    if (score <= 2) {
      return Colors.green;
    } else if (score <= 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}