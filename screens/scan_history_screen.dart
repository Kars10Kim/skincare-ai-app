import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skincare_scanner/providers/product_provider.dart';
import 'package:skincare_scanner/utils/analytics_service.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _refreshScanHistory();
    
    // Log screen view
    AnalyticsService.logScreenView('ScanHistoryScreen', 'ScanHistoryScreen');
  }
  
  Future<void> _refreshScanHistory() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadScanHistory();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
              _showFilterOptions();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshScanHistory,
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            final scanHistory = productProvider.scanHistory;
            
            if (productProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (scanHistory.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'No scan history yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan products to see your history',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/camera');
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan Now'),
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: scanHistory.length,
              itemBuilder: (context, index) {
                final product = scanHistory[index];
                return _buildHistoryItem(context, product);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/camera');
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
  
  Widget _buildHistoryItem(BuildContext context, dynamic product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final productProvider = Provider.of<ProductProvider>(context, listen: false);
          productProvider.setCurrentProduct(product);
          Navigator.of(context).pushNamed('/product_details');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              SizedBox(
                height: 120,
                width: double.infinity,
                child: Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                color: Colors.teal.shade50,
                child: const Center(
                  child: Icon(Icons.spa, size: 40, color: Colors.teal),
                ),
              ),
            
            // Product info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and brand
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.brand != null && product.brand!.isNotEmpty)
                    Text(
                      product.brand!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Conflict status
                  if (product.hasConflicts)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, size: 16, color: Colors.red.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Conflicts',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Safe',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  const SizedBox(height: 8),
                  
                  // Barcode
                  Row(
                    children: [
                      const Icon(Icons.qr_code, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        product.barcode,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.sort),
            title: const Text('Sort By Date (Newest First)'),
            onTap: () {
              Navigator.of(context).pop();
              // Implement sorting logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.sort),
            title: const Text('Sort By Date (Oldest First)'),
            onTap: () {
              Navigator.of(context).pop();
              // Implement sorting logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber),
            title: const Text('Show Conflicts Only'),
            onTap: () {
              Navigator.of(context).pop();
              // Implement filtering logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Show Safe Products Only'),
            onTap: () {
              Navigator.of(context).pop();
              // Implement filtering logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Reset Filters'),
            onTap: () {
              Navigator.of(context).pop();
              // Reset filters
              _refreshScanHistory();
            },
          ),
        ],
      ),
    );
  }
}