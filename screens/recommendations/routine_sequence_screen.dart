import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/database_provider.dart';
import '../../utils/constants.dart';

/// Screen for displaying optimal product usage sequence
class RoutineSequenceScreen extends StatefulWidget {
  final List<Product>? userProducts;
  
  const RoutineSequenceScreen({
    Key? key,
    this.userProducts,
  }) : super(key: key);

  @override
  State<RoutineSequenceScreen> createState() => _RoutineSequenceScreenState();
}

class _RoutineSequenceScreenState extends State<RoutineSequenceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, List<String>> _routineSequence = {};
  List<Product> _userProducts = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userProducts = widget.userProducts ?? [];
    _loadRoutineSequence();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  /// Load the routine sequence from API or local constants
  Future<void> _loadRoutineSequence() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final repository = Provider.of<DatabaseProvider>(context, listen: false).scanRepository;
      
      // If no user products were provided, load recent scans
      if (_userProducts.isEmpty) {
        _userProducts = await repository.getRecentScans();
      }
      
      // In a real app, you would fetch the sequence from the API
      // For now, we'll use the constants
      _routineSequence = {
        'morning': AppConstants.morningRoutineOrder,
        'evening': AppConstants.eveningRoutineOrder,
      };
      
    } catch (e) {
      debugPrint('Error loading routine sequence: $e');
      // Fallback to defaults
      _routineSequence = {
        'morning': AppConstants.morningRoutineOrder,
        'evening': AppConstants.eveningRoutineOrder,
      };
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  /// Get user products for a specific category, or null if none exists
  List<Product> _getProductsForCategory(String category) {
    return _userProducts.where((product) => 
      product.category?.toLowerCase() == category.toLowerCase()
    ).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Sequence'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Morning Routine'),
            Tab(text: 'Evening Routine'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Morning Routine
                _buildRoutineList('morning'),
                
                // Evening Routine
                _buildRoutineList('evening'),
              ],
            ),
    );
  }
  
  Widget _buildRoutineList(String routineType) {
    final sequence = _routineSequence[routineType] ?? [];
    
    return Container(
      color: Colors.grey[50],
      child: sequence.isEmpty
          ? Center(
              child: Text(
                'No $routineType routine sequence available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sequence.length,
              itemBuilder: (context, index) {
                final step = sequence[index];
                final matchingProducts = _getProductsForCategory(step);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Step header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              step,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Step content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step description
                            Text(
                              _getStepDescription(step, routineType),
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // User's matching products
                            if (matchingProducts.isNotEmpty) ...[
                              const Text(
                                'Your Products:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...matchingProducts.map((product) => 
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${product.brand != null ? "${product.brand} " : ""}${product.name}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'No matching products found for this step',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
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
                );
              },
            ),
    );
  }
  
  /// Get the description for a routine step
  String _getStepDescription(String step, String routineType) {
    // In a real app, this would come from the API or a more sophisticated source
    switch (step.toLowerCase()) {
      case 'cleanser':
      case 'oil cleanser':
      case 'water-based cleanser':
        return 'Start with clean skin. Use gentle, circular motions and rinse thoroughly with lukewarm water.';
      case 'toner':
        return 'Apply with clean hands or a cotton pad. Gently pat onto face and neck.';
      case 'essence':
        return 'Pour a small amount into palms and press gently into skin.';
      case 'serum (water-based)':
      case 'serum (oil-based)':
        return 'Apply a few drops to face and neck, gently pressing into skin.';
      case 'eye cream':
        return 'Use ring finger to tap product around the orbital bone.';
      case 'moisturizer':
        return 'Apply evenly to face and neck using upward, outward motions.';
      case 'face oil':
        return 'Warm 3-4 drops between palms and press onto skin.';
      case 'sunscreen':
        return 'Apply liberally as the final step of your morning routine. Reapply every 2 hours when exposed to sun.';
      case 'exfoliator':
        return 'Apply to damp skin and massage gently in circular motions. Rinse thoroughly.';
      case 'treatment':
        return 'Apply to targeted areas according to product instructions.';
      case 'sheet mask':
        return 'Apply to clean skin for 15-20 minutes, then remove and pat remaining essence into skin.';
      case 'sleeping mask':
        return 'Apply as the final step of your evening routine and leave on overnight.';
      default:
        return 'Apply according to product instructions.';
    }
  }
}