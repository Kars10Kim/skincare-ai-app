import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skincare_scanner/providers/product_provider.dart';
import 'package:skincare_scanner/providers/user_provider.dart';
import 'package:skincare_scanner/utils/analytics_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Log screen view for analytics
    AnalyticsService.logScreenView('HomeScreen', 'HomeScreen');
  }
  
  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Fetch scan history if the user has authentication
    if (userProvider.authToken != null) {
      await productProvider.loadScanHistory(authToken: userProvider.authToken);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skincare Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).pushNamed('/scan_history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero image
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal.shade300,
                    Colors.teal.shade700,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan Your Skincare Products',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Analyze ingredients and detect conflicts',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Quick actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildActionCard(
                        context,
                        'Scan',
                        Icons.qr_code_scanner,
                        Colors.teal,
                        () => Navigator.of(context).pushNamed('/camera'),
                      ),
                      _buildActionCard(
                        context,
                        'History',
                        Icons.history,
                        Colors.indigo,
                        () => Navigator.of(context).pushNamed('/scan_history'),
                      ),
                      _buildActionCard(
                        context,
                        'Recommendations',
                        Icons.auto_awesome,
                        Colors.amber,
                        () => _showRecommendationsBottomSheet(),
                      ),
                      _buildActionCard(
                        context,
                        'Settings',
                        Icons.settings,
                        Colors.blueGrey,
                        () => Navigator.of(context).pushNamed('/settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Recent scans
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                final recentScans = productProvider.scanHistory.take(3).toList();
                
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Scans',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/scan_history'),
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (recentScans.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.history, size: 48, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No scan history yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Scan your first product',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        ...recentScans.map((product) => _buildRecentScanItem(context, product)),
                    ],
                  ),
                );
              },
            ),
            
            // Info section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Skincare Scanner',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This app helps you analyze skincare products to identify potential ingredients that may cause conflicts with your skin type or other products.',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Simply scan the barcode of any skincare product to get detailed information and personalized recommendations.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/camera'),
        label: const Text('Scan Now'),
        icon: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecentScanItem(BuildContext context, dynamic product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: product.imageUrl != null && product.imageUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    product.imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, color: Colors.grey);
                    },
                  ),
                )
              : const Icon(Icons.spa, color: Colors.teal),
        ),
        title: Text(product.name),
        subtitle: Text(product.brand ?? 'Unknown Brand'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          final productProvider = Provider.of<ProductProvider>(context, listen: false);
          productProvider.setCurrentProduct(product);
          Navigator.of(context).pushNamed('/product_details');
        },
      ),
    );
  }
  
  // Show recommendations bottom sheet
  void _showRecommendationsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              
              // Recommendations list (empty state)
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Placeholder for recommendations
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.auto_awesome, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Scan products to get personalized recommendations',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}