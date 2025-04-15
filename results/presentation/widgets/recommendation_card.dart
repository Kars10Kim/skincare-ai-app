import 'package:flutter/material.dart';
import '../../domain/entities/personalized_recommendation.dart';

/// Widget to display personalized recommendation
class RecommendationCard extends StatelessWidget {
  /// Personalized recommendation
  final PersonalizedRecommendation recommendation;
  
  /// Card elevation
  final double elevation;
  
  /// On tap callback
  final VoidCallback? onTap;
  
  /// On save callback
  final VoidCallback? onSave;
  
  /// Create recommendation card
  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.elevation = 1.0,
    this.onTap,
    this.onSave,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image if available
            if (recommendation.imageUrl != null) ...[
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
                child: Image.network(
                  recommendation.imageUrl!,
                  height: 150.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150.0,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 48.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recommendation type
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      recommendation.getTypeText(),
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8.0),
                  
                  // Brand and product name
                  Text(
                    recommendation.brand,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    recommendation.productName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8.0),
                  
                  // Description
                  Text(
                    recommendation.description,
                    style: textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12.0),
                  
                  // Key ingredients
                  if (recommendation.keyIngredients.isNotEmpty) ...[
                    Text(
                      'Key Ingredients:',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      children: recommendation.keyIngredients
                          .take(5)
                          .map((ingredient) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              ingredient,
                              style: textTheme.bodySmall,
                            ),
                          ))
                          .toList(),
                    ),
                    const SizedBox(height: 12.0),
                  ],
                  
                  // Match reasons
                  if (recommendation.matchReasons.isNotEmpty) ...[
                    Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      children: recommendation.getMatchReasonTexts()
                          .take(3)
                          .map((reason) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 14.0,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                reason,
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ))
                          .toList(),
                    ),
                    const SizedBox(height: 12.0),
                  ],
                  
                  // Safety score and match quality
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Safety Score',
                              style: textTheme.bodySmall,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 24.0,
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getSafetyColor(recommendation.safetyScore),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${recommendation.safetyScore}',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  recommendation.safetyRating,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Match Quality',
                              style: textTheme.bodySmall,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 24.0,
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getMatchColor(recommendation.strength),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${recommendation.strength}',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  recommendation.matchQuality,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Save button
            if (onSave != null) ...[
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: ElevatedButton.icon(
                  onPressed: onSave,
                  icon: Icon(
                    recommendation.isSaved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                  label: Text(
                    recommendation.isSaved
                        ? 'Saved'
                        : 'Save',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: recommendation.isSaved
                        ? Colors.grey.shade200
                        : theme.colorScheme.primary,
                    foregroundColor: recommendation.isSaved
                        ? Colors.black
                        : Colors.white,
                    minimumSize: const Size(double.infinity, 36.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Get color for safety score
  Color _getSafetyColor(int score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 60) {
      return Colors.greenAccent.shade700;
    } else if (score >= 40) {
      return Colors.orange;
    } else if (score >= 20) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }
  
  /// Get color for match strength
  Color _getMatchColor(int strength) {
    if (strength >= 80) {
      return Colors.purple;
    } else if (strength >= 60) {
      return Colors.blue;
    } else if (strength >= 40) {
      return Colors.teal;
    } else {
      return Colors.blueGrey;
    }
  }
}