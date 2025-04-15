import 'package:flutter/material.dart';
import '../../models/product/product_model.dart';
import '../../utils/constants.dart';
import '../../widgets/card_container.dart';
import '../../widgets/product_card.dart';

/// Widget to display product recommendations
class RecommendationsWidget extends StatelessWidget {
  /// List of recommended products
  final List<Product> recommendations;

  /// Creates a recommendations widget
  const RecommendationsWidget({
    Key? key,
    required this.recommendations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        if (connectivity.isOffline && recommendations.isEmpty) {
          return _buildOfflineState();
        }
        
        return ShimmerLoading(
          isLoading: isLoading,
          child: recommendations.isEmpty
              ? _buildEmptyState()
              : _buildRecommendationsList(context),
        );
      },
    );
  }

  Widget _buildOfflineState() {
    return CardContainer(
      useGlassmorphism: true,
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).offlineRecommendationsMessage,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  }
  
  /// Builds an empty state when no recommendations are available
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.recommend,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Recommendations Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We couldn\'t find any alternative product recommendations based on your skin profile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // In a real app, this would navigate to a screen to update preferences
              },
              icon: const Icon(Icons.settings),
              label: const Text('Update Your Preferences'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Builds the recommendations list
  Widget _buildRecommendationsList(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Recommended Products (${recommendations.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'These products match your skin type and preferences, and don\'t have the conflicts found in the current product.',
            style: TextStyle(
              color: AppColors.textSecondaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          
          // Recommendations list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final product = recommendations[index];
              return _buildRecommendationItem(context, product);
            },
          ),
          
          // Disclaimer
          const SizedBox(height: 24),
          CardContainer(
            useGlassmorphism: true,
            backgroundColor: AppColors.infoColor.withOpacity(0.05),
            title: 'Disclaimer',
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.infoColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'Recommendations are based on your skin profile and formulation analysis. '
                    'Individual skin responses may vary. Always patch test new products.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Builds a recommendation item
  Widget _buildRecommendationItem(
    BuildContext context,
    Product product,
  ) {
    return Column(
      children: [
        ProductCard(
          product: product,
          isOnboarding: true,
        ),
        // Action buttons below the card
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  // In a real app, this would navigate to product details
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: BorderSide(
                    color: AppColors.primaryColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Details'),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  // In a real app, this would add to favorites
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to favorites'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.favorite_border),
                color: AppColors.errorColor,
              ),
              IconButton(
                onPressed: () {
                  // In a real app, this would share the product
                },
                icon: const Icon(Icons.share),
                color: AppColors.textSecondaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Format ingredients list for preview
  String _formatIngredientPreview(List<String> ingredients) {
    if (ingredients.isEmpty) return 'No ingredients listed';
    
    final previewCount = ingredients.length > 3 ? 3 : ingredients.length;
    final preview = ingredients.sublist(0, previewCount).join(', ');
    
    if (ingredients.length > previewCount) {
      return '$preview, and ${ingredients.length - previewCount} more...';
    }
    
    return preview;
  }
}