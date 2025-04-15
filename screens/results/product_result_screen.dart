import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../utils/constants.dart';

/// Screen for displaying product scan results
class ProductResultScreen extends StatelessWidget {
  /// Product to display
  final Product product;
  
  /// Whether this is a new scan
  final bool isNewScan;
  
  /// Creates a product result screen
  const ProductResultScreen({
    Key? key,
    required this.product,
    this.isNewScan = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: AppTextStyles.heading1,
              ),
              if (product.brand != null) ...[
                const SizedBox(height: 4),
                Text(
                  product.brand!,
                  style: AppTextStyles.bodySmall,
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Ingredients (${product.ingredients.length})',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: product.ingredients.map((ingredient) {
                      return ListTile(
                        title: Text(ingredient),
                        leading: const Icon(Icons.check_circle_outline),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan Another Product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}