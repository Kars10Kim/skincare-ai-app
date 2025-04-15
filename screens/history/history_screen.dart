import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_analysis_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/card_container.dart';
import '../../widgets/network_status_indicator.dart';
import '../../widgets/product_card.dart';

/// History screen showing past scans
class HistoryScreen extends StatelessWidget {
  /// Creates a history screen
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline indicator
          const NetworkStatusIndicator(),
          
          // Main content
          Expanded(
            child: Consumer<ProductAnalysisProvider>(
              builder: (context, provider, child) {
                if (provider.scanHistory.isEmpty) {
                  return _buildEmptyState(context);
                }
                
                return _buildHistoryList(context, provider);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// Builds the scan history list
  Widget _buildHistoryList(BuildContext context, ProductAnalysisProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: provider.scanHistory.length,
      itemBuilder: (context, index) {
        final item = provider.scanHistory[index];
        
        return InkWell(
          onTap: () {
            // Navigate to details when tapped
            provider.loadScanDetails(item.product.id);
            Navigator.pushNamed(context, '/results');
          },
          child: Column(
            children: [
              ProductCard(
                product: item.product,
                safetyScore: item.safetyScore,
              ),
              // Display time info in a separate container below
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '2 days ago', // Would be formatted timestamp in real app
                      style: TextStyle(
                        color: AppColors.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
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

  /// Builds the empty state when no history is available
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: CardContainer(
          useGlassmorphism: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                'No Scan History Yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start scanning products to build your history. Your scan results will appear here for easy reference.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to scan tab
                  Navigator.of(context).pushReplacementNamed('/');
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan a Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
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