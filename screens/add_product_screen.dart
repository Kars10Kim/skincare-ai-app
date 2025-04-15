import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skincare_scanner/models/product_model.dart';
import 'package:skincare_scanner/providers/product_provider.dart';
import 'package:skincare_scanner/utils/analytics_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _ingredientsController = TextEditingController();
  String? _barcode;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _getBarcode();
    
    // Log screen view
    AnalyticsService.logScreenView('AddProductScreen', 'AddProductScreen');
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }
  
  // Get barcode from route arguments
  void _getBarcode() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('barcode')) {
        setState(() {
          _barcode = args['barcode'] as String;
        });
      }
    });
  }
  
  // Save the product
  Future<void> _saveProduct() async {
    // Validate form
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create product object
      final product = Product(
        barcode: _barcode ?? '',
        name: _nameController.text,
        brand: _brandController.text.isNotEmpty ? _brandController.text : null,
        ingredients: _parseIngredients(_ingredientsController.text),
      );
      
      // Save product
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final success = await productProvider.saveProduct(product);
      
      if (success && mounted) {
        // Log analytics event
        AnalyticsService.logEvent('product_added', {'barcode': product.barcode});
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
        
        // Navigate to product details
        Navigator.of(context).pushReplacementNamed('/product_details');
      } else if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: ${productProvider.error}')),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Parse ingredients string into a list
  List<String> _parseIngredients(String ingredientsStr) {
    return ingredientsStr
        .split(',')
        .map((i) => i.trim())
        .where((i) => i.isNotEmpty)
        .toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barcode display
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.qr_code, size: 40, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              'Barcode: ${_barcode ?? 'Unknown'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'This product was not found in our database. Please provide the details below.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Product name
                    const Text(
                      'Product Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter product name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Brand
                    const Text(
                      'Brand',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        hintText: 'Enter brand name (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Ingredients
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _ingredientsController,
                      decoration: const InputDecoration(
                        hintText: 'Enter ingredients, separated by commas',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product ingredients';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Ingredient instructions
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Ingredient Tips',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Enter ingredients as listed on the product packaging, separated by commas. This helps identify potential conflicts with your skin type.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProduct,
                        child: const Text('Save Product'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Cancel button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}