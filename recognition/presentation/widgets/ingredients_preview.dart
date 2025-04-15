import 'package:flutter/material.dart';

/// Preview of extracted ingredients
class IngredientsPreview extends StatelessWidget {
  /// Extracted ingredients
  final List<String> ingredients;
  
  /// On process callback
  final VoidCallback onProcess;
  
  /// Create ingredients preview
  const IngredientsPreview({
    Key? key,
    required this.ingredients,
    required this.onProcess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.science_outlined,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'Extracted Ingredients',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${ingredients.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Ingredients list
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ingredients.take(8).map((ingredient) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ingredient,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
          
          // More text
          if (ingredients.length > 8) ...[
            const SizedBox(height: 8),
            Text(
              '+ ${ingredients.length - 8} more ingredients',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Process button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onProcess,
              icon: const Icon(Icons.check),
              label: const Text('Analyze Ingredients'),
              style: FilledButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}