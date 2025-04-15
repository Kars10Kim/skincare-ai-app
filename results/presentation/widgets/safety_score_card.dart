import 'package:flutter/material.dart';
import '../../domain/entities/product_analysis.dart';

/// Widget to display safety score
class SafetyScoreCard extends StatelessWidget {
  /// Safety score
  final SafetyScore score;
  
  /// Card elevation
  final double elevation;
  
  /// Whether to show detailed scores
  final bool showDetailedScores;
  
  /// Create safety score card
  const SafetyScoreCard({
    super.key,
    required this.score,
    this.elevation = 1.0,
    this.showDetailedScores = true,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Safety Score',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  score.safetyRating,
                  style: textTheme.titleMedium?.copyWith(
                    color: _getSafetyColor(score.overall),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16.0),
            
            // Overall score
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall',
                      style: textTheme.bodyMedium,
                    ),
                    Text(
                      '${score.overall}%',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                LinearProgressIndicator(
                  value: score.overall / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_getSafetyColor(score.overall)),
                  borderRadius: BorderRadius.circular(4.0),
                  minHeight: 8.0,
                ),
              ],
            ),
            
            // Detailed scores
            if (showDetailedScores) ...[
              const SizedBox(height: 16.0),
              
              // Irritation score
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Irritation Risk',
                        style: textTheme.bodyMedium,
                      ),
                      Text(
                        '${score.irritation}%',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  LinearProgressIndicator(
                    value: score.irritation / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(_getSafetyColor(score.irritation)),
                    borderRadius: BorderRadius.circular(4.0),
                    minHeight: 6.0,
                  ),
                ],
              ),
              
              const SizedBox(height: 12.0),
              
              // Acne score
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Acne Risk',
                        style: textTheme.bodyMedium,
                      ),
                      Text(
                        '${score.acne}%',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  LinearProgressIndicator(
                    value: score.acne / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(_getSafetyColor(score.acne)),
                    borderRadius: BorderRadius.circular(4.0),
                    minHeight: 6.0,
                  ),
                ],
              ),
              
              const SizedBox(height: 12.0),
              
              // Sensitivity score
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sensitivity Risk',
                        style: textTheme.bodyMedium,
                      ),
                      Text(
                        '${score.sensitivity}%',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  LinearProgressIndicator(
                    value: score.sensitivity / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(_getSafetyColor(score.sensitivity)),
                    borderRadius: BorderRadius.circular(4.0),
                    minHeight: 6.0,
                  ),
                ],
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
}