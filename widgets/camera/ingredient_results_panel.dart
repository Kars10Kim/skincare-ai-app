import 'package:flutter/material.dart';
import '../../models/ingredient_model.dart';

class IngredientResultsPanel extends StatelessWidget {
  final List<Ingredient> ingredients;
  final VoidCallback onAnalyze;
  final VoidCallback onClose;

  const IngredientResultsPanel({
    Key? key,
    required this.ingredients,
    required this.onAnalyze,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate a more adaptive height based on device screen size
    // Maximum of 60% of screen height, minimum 300 pixels
    final screenHeight = MediaQuery.of(context).size.height;
    final adaptiveHeight = screenHeight * 0.6 < 300 ? 300.0 : screenHeight * 0.6;
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: adaptiveHeight,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar for dragging - more visible on mobile
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          
          // Header with count and close button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detected Ingredients (${ingredients.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  tooltip: 'Close',
                  padding: const EdgeInsets.all(12), // Larger touch target for mobile
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Ingredients list - Flexible for better mobile adaptability
          Flexible(
            child: ingredients.isEmpty
                ? const Center(
                    child: Text('No ingredients detected'),
                  )
                : ListView.builder(
                    itemCount: ingredients.length,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    physics: const AlwaysScrollableScrollPhysics(), // Ensure scrollable on smaller devices
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          ingredient.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          ingredient.category,
                          style: TextStyle(
                            color: _getCategoryColor(ingredient.category).withOpacity(0.7),
                          ),
                        ),
                        leading: CircleAvatar(
                          radius: 18, // Slightly larger for better visibility
                          backgroundColor: _getCategoryColor(ingredient.category),
                          child: Text(
                            ingredient.name.isNotEmpty 
                                ? ingredient.name.substring(0, 1).toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        trailing: Icon(
                          _getCategoryIcon(ingredient.category),
                          color: _getCategoryColor(ingredient.category),
                          size: 22, // Slightly larger for mobile
                        ),
                      );
                    },
                  ),
          ),
          
          // Analyze button - bottom safe area padding for mobile
          Padding(
            padding: EdgeInsets.fromLTRB(
              16, 8, 16, 
              16 + MediaQuery.of(context).padding.bottom // Add bottom safe area padding
            ),
            child: ElevatedButton.icon(
              onPressed: ingredients.isEmpty ? null : onAnalyze,
              icon: const Icon(Icons.science),
              label: const Text('Analyze Ingredients'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14), // Taller button for easier tapping
                minimumSize: const Size(double.infinity, 50), // Ensure minimum height for touch
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'acid':
        return Colors.orange;
      case 'vitamin':
        return Colors.green;
      case 'oil':
        return Colors.amber;
      case 'plant extract':
        return Colors.teal;
      case 'alcohol':
        return Colors.red;
      case 'preservative':
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'acid':
        return Icons.science;
      case 'vitamin':
        return Icons.nutrition;
      case 'oil':
        return Icons.opacity;
      case 'plant extract':
        return Icons.eco;
      case 'alcohol':
        return Icons.warning;
      case 'preservative':
        return Icons.cleaning_services;
      default:
        return Icons.category;
    }
  }
}