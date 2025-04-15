import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skincare_scanner/providers/product_provider.dart';
import 'package:skincare_scanner/utils/analytics_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Log screen view
    AnalyticsService.logScreenView('ProductDetailsScreen', 'ProductDetailsScreen');
    
    // Check for ingredient conflicts
    _checkIngredientConflicts();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Check for ingredient conflicts
  Future<void> _checkIngredientConflicts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final product = productProvider.currentProduct;
    
    if (product != null && product.ingredients.isNotEmpty) {
      await productProvider.checkIngredientConflicts(product.ingredients);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final product = productProvider.currentProduct;
        final conflicts = productProvider.ingredientConflicts;
        
        if (product == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Product Details'),
            ),
            body: const Center(
              child: Text('No product selected'),
            ),
          );
        }
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App bar with product image
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Product image
                      if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                        Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.teal.shade200,
                              child: const Icon(Icons.image_not_supported, size: 80, color: Colors.white),
                            );
                          },
                        )
                      else
                        Container(
                          color: Colors.teal.shade200,
                          child: const Icon(Icons.spa, size: 80, color: Colors.white),
                        ),
                      
                      // Gradient overlay
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Product information
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand
                          if (product.brand != null && product.brand!.isNotEmpty)
                            Text(
                              product.brand!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          
                          const SizedBox(height: 8),
                          
                          // Barcode
                          Row(
                            children: [
                              const Icon(Icons.qr_code, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Barcode: ${product.barcode}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Conflict warning if any
                          if (conflicts.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.warning_amber, color: Colors.red.shade700),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Ingredient Conflicts Detected',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This product contains ingredients that may conflict with your skin type or other products you use.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Tab bar
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Theme.of(context).primaryColor,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: 'Ingredients'),
                        Tab(text: 'Conflicts'),
                        Tab(text: 'Details'),
                      ],
                    ),
                    
                    // Tab content
                    SizedBox(
                      height: 300,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Ingredients tab
                          _buildIngredientsTab(product),
                          
                          // Conflicts tab
                          _buildConflictsTab(conflicts),
                          
                          // Details tab
                          _buildDetailsTab(product),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // Share product
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing functionality would be implemented here')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add to history
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to favorites')),
                      );
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Ingredients tab
  Widget _buildIngredientsTab(dynamic product) {
    if (product.ingredients.isEmpty) {
      return const Center(
        child: Text('No ingredient information available'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: product.ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = product.ingredients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(ingredient),
            trailing: const Icon(Icons.info_outline),
            onTap: () {
              // Show ingredient info
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(ingredient),
                  content: const Text(
                    'Detailed information about this ingredient would be displayed here.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  // Conflicts tab
  Widget _buildConflictsTab(List<String> conflicts) {
  final productProvider = Provider.of<ProductProvider>(context, listen: false);
  final product = productProvider.currentProduct;
  
  if (product == null) return const SizedBox();
  
  final analysis = ConflictAnalyzerService.checkConflicts(
    product.ingredients,
    skinType: SkinType.sensitive // TODO: Get from user preferences
  );
  
  if (analysis.isEmpty) {
    if (conflicts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green.shade300),
            const SizedBox(height: 16),
            const Text(
              'No conflicts detected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This product should be safe for your skin type',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: conflicts.length,
      itemBuilder: (context, index) {
        final conflict = conflicts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.red.shade50,
          child: ListTile(
            leading: Icon(Icons.warning_amber, color: Colors.red.shade700),
            title: Text(conflict),
            trailing: const Icon(Icons.info_outline),
            onTap: () {
              // Show conflict info
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(conflict),
                  content: const Text(
                    'Detailed information about this conflict would be displayed here.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  // Details tab
  Widget _buildRecommendationsTab(dynamic product, List<Map<String, dynamic>> analysis) {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: analysis.length,
    itemBuilder: (context, index) {
      final conflict = analysis[index];
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alternative Products for ${conflict['ingredient']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Why: ${conflict['reason']}'),
              const SizedBox(height: 16),
              Text(
                'Try these instead:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: conflict['alternatives'].map<Widget>((alt) => 
                  Chip(
                    label: Text(alt),
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  )
                ).toList(),
              ),
            ],
          ),
        ),
      );
    },
  );
}

_buildDetailsTab(dynamic product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Product details
          _buildDetailRow('Name', product.name),
          _buildDetailRow('Brand', product.brand ?? 'Unknown'),
          _buildDetailRow('Barcode', product.barcode),
          
          const SizedBox(height: 24),
          
          const Text(
            'Safety Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow('Conflicts', product.hasConflicts ? 'Yes' : 'No'),
          _buildDetailRow('Added On', product.createdAt != null 
              ? '${product.createdAt!.day}/${product.createdAt!.month}/${product.createdAt!.year}'
              : 'Unknown'),
        ],
      ),
    );
  }
  
  // Helper to build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}