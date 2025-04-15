import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';
import 'card_container.dart';

/// Card for displaying product information
class ProductCard extends StatelessWidget {
  /// Product data
  final Product product;
  
  /// Safety score
  final int? safetyScore;
  
  /// Onboarding card
  final bool isOnboarding;
  
  /// Show favorite button
  final bool showFavoriteButton;
  
  /// Whether product is marked as favorite
  final bool isFavorite;
  
  /// Callback when favorite is toggled
  final VoidCallback? onFavoriteToggle;
  
  /// Conflicts detected in product
  final Map<String, dynamic>? conflicts;
  
  /// Creates a product card
  const ProductCard({
    Key? key,
    required this.product,
    this.safetyScore,
    this.isOnboarding = false,
    this.showFavoriteButton = false,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.conflicts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      useGlassmorphism: isOnboarding,
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product header with image and details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.spa,
                            color: AppColors.primaryColor,
                            size: 40,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.spa,
                        color: AppColors.primaryColor,
                        size: 40,
                      ),
              ),
              const SizedBox(width: 16),
              
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Favorite button
                        if (showFavoriteButton)
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: onFavoriteToggle,
                            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                            iconSize: 24,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.brand,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Safety score indicator (if provided)
                    if (safetyScore != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 18,
                            color: _getSafetyColor(safetyScore!),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Safety: $safetyScore%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getSafetyColor(safetyScore!),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // Conflicts indicator if any
                    if (conflicts != null && conflicts!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Conflicts detected',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Product description
          if (product.description != null && product.description!.isNotEmpty) ...[
            Text(
              product.description!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textColor,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
          ],
          
          // Ingredients list
          Text(
            'Ingredients:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.ingredients.join(', '),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryColor,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          
          // See more button
          if (product.ingredients.length > 10) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _showIngredientsDialog(context);
                },
                child: const Text('See all ingredients'),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Show full ingredients list in a dialog
  void _showIngredientsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${product.name} Ingredients',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...product.ingredients.map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(
                          child: Text(ingredient),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  
  /// Get color based on safety score
  Color _getSafetyColor(int score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}