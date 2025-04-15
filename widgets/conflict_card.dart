import 'package:flutter/material.dart';
import '../models/product/product_model.dart';
import '../utils/constants.dart';
import 'card_container.dart';

/// Card for displaying ingredient conflicts
class ConflictCard extends StatelessWidget {
  /// Ingredient conflict data
  final IngredientConflict conflict;

  /// Creates a conflict card
  const ConflictCard({
    Key? key,
    required this.conflict,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine color based on severity
    final Color severityColor = _getSeverityColor(conflict.severity);
    
    return CardContainer(
      useGlassmorphism: true,
      margin: const EdgeInsets.only(bottom: 16),
      backgroundColor: Colors.white.withOpacity(0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ingredient name and severity indicator
          Row(
            children: [
              Expanded(
                child: Text(
                  conflict.ingredientName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: severityColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getSeverityText(conflict.severity),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Description
          Text(
            conflict.description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          
          // Skin type concerns
          if (conflict.skinTypes.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: conflict.skinTypes.map((skinType) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getSkinTypeText(skinType),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          
          // Recommendation
          if (conflict.recommendation != null && conflict.recommendation!.isNotEmpty) ...[
            Text(
              'Recommendation:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              conflict.recommendation!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Scientific reference
          if (conflict.reference.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.science_outlined,
                    size: 16,
                    color: AppColors.textSecondaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ref: ${conflict.reference}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Get color based on severity
  Color _getSeverityColor(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.high:
        return Colors.red;
      case ConflictSeverity.moderate:
        return Colors.orange;
      case ConflictSeverity.low:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  /// Get text based on severity
  String _getSeverityText(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.high:
        return 'High Risk';
      case ConflictSeverity.moderate:
        return 'Moderate Risk';
      case ConflictSeverity.low:
        return 'Low Risk';
      default:
        return 'Unknown';
    }
  }
  
  /// Get text based on skin type
  String _getSkinTypeText(SkinType skinType) {
    switch (skinType) {
      case SkinType.normal:
        return 'Normal Skin';
      case SkinType.dry:
        return 'Dry Skin';
      case SkinType.oily:
        return 'Oily Skin';
      case SkinType.combination:
        return 'Combination Skin';
      case SkinType.sensitive:
        return 'Sensitive Skin';
      default:
        return 'All Skin Types';
    }
  }
}