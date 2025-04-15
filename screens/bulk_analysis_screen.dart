import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/product_model.dart';
import '../widgets/results/conflict_card.dart';
import '../services/conflict_analyzer_service.dart';
import '../services/analytics_service.dart';
import '../services/recommendation_service.dart'; // Added import


class BulkAnalysisCubit extends Cubit<BulkAnalysisState> {
  BulkAnalysisCubit() : super(BulkAnalysisInitial());

  List<Product> _products = [];
  Set<String> _selectedProducts = {};

  void addProduct(Product product) {
    _products.add(product);
    emit(BulkAnalysisUpdated(_products, [], [])); // added empty lists for recommendations
  }

  static const int MAX_BATCH_SIZE = 10;

  Future<void> analyzeConflicts() async {
    if (_products.isEmpty) {
      emit(BulkAnalysisError('No products selected for analysis'));
      return;
    }

    if (_products.length > MAX_BATCH_SIZE) {
      emit(BulkAnalysisError('Maximum batch size of $MAX_BATCH_SIZE exceeded'));
      return;
    }

    emit(BulkAnalysisLoading());
    
    try {
      final conflicts = await ConflictAnalyzer.findBatchConflicts(_products);
      final recommendations = await _recommendationService.getBatchRecommendations(
        products: _products,
        conflicts: conflicts,
      );

      await _analyticsService.logBatchAnalysis(
        productCount: _products.length,
        conflictCount: conflicts.length,
        processingTime: DateTime.now().difference(_startTime).inMilliseconds,
        batchSize: _products.length,
        errorCount: conflicts.length,
      );

      emit(BulkAnalysisUpdated(
        _products,
        conflicts,
        recommendations,
      ));
    } catch (e) {
      await _analyticsService.logError(
        'batch_analysis_error',
        {'error': e.toString(), 'batch_size': _products.length}
      );
      emit(BulkAnalysisError(e.toString()));
    }
  }
  //Added getter for selected products to be used by other functions.
  List<Product> get selectedProducts => _products.where((p) => _selectedProducts.contains(p.barcode)).toList();

}

class BulkAnalysisState {}

class BulkAnalysisInitial extends BulkAnalysisState {}

class BulkAnalysisLoading extends BulkAnalysisState {}

class BulkAnalysisUpdated extends BulkAnalysisState {
  final List<Product> products;
  final List<Conflict> conflicts;
  final List<Recommendation> recommendations;

  BulkAnalysisUpdated(this.products, this.conflicts, this.recommendations);
}

class BulkAnalysisError extends BulkAnalysisState {
  final String message;

  BulkAnalysisError(this.message);
}

class BulkAnalysisScreen extends StatefulWidget {
  final List<Product> scannedProducts;

  const BulkAnalysisScreen({
    Key? key,
    required this.scannedProducts,
  }) : super(key: key);

  @override
  State<BulkAnalysisScreen> createState() => _BulkAnalysisScreenState();
}

class _BulkAnalysisScreenState extends State<BulkAnalysisScreen> {
  late final BulkAnalysisCubit _cubit;
  Set<String> selectedProducts = {};
  final _recommendationService = RecommendationService(); // Added instance of RecommendationService
  final _analyticsService = AnalyticsService(); // Added instance of AnalyticsService


  @override
  void initState() {
    super.initState();
    _cubit = BulkAnalysisCubit();
    _initializeProducts();
    AnalyticsService().logScreenView('BulkAnalysisScreen');
  }

  void _initializeProducts() {
    for (var product in widget.scannedProducts) {
      _cubit.addProduct(product);
    }
  }

  Widget _buildProductGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: widget.scannedProducts.length,
          itemBuilder: (context, index) {
            final product = widget.scannedProducts[index];
            final isSelected = selectedProducts.contains(product.barcode);

            return ProductGridItem(
              product: product,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedProducts.remove(product.barcode);
                  } else {
                    selectedProducts.add(product.barcode);
                  }
                });
              },
            );
          },
        );
      }
    );
  }

  Widget _buildConflictHeatmap() {
    return BlocBuilder<BulkAnalysisCubit, BulkAnalysisState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is BulkAnalysisUpdated && state.conflicts.isEmpty) {
          return const Center(
            child: Text('No conflicts detected between products'),
          );
        }
        if (state is BulkAnalysisLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BulkAnalysisError){
          return Center(child: Text('Error: ${state.message}'));
        }

        return ConflictHeatmap(conflicts: (state is BulkAnalysisUpdated) ? state.conflicts : []);
      },
    );
  }

  Widget _buildComparisonTable() {
    return BlocBuilder<BulkAnalysisCubit, BulkAnalysisState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is BulkAnalysisUpdated){
          return ProductComparisonTable(
            products: state.products,
            conflicts: state.conflicts,
            recommendations: state.recommendations, // Added recommendations
            onSort: (columnIndex, ascending) {
              // Handle sorting
            },
          );
        }
        if (state is BulkAnalysisLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BulkAnalysisError){
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _handleExport() async {
    final selectedItems = _cubit.selectedProducts;

    if (selectedItems.isEmpty) return;

    try {
      // Export logic here
      await ShareService.shareProducts(selectedItems);

      FirebaseAnalytics().logEvent(
        name: 'batch_export',
        parameters: {
          'product_count': selectedItems.length,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batch Analysis (${_cubit._products.length}/$MAX_BATCH_SIZE)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cubit._products.isEmpty ? null : () => _cubit.analyzeConflicts(),
            tooltip: 'Analyze Conflicts',
          ),
          if (_cubit.selectedProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _handleExport,
              tooltip: 'Export Selected',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _buildProductGrid(),
          ),
          const Divider(),
          Expanded(
            flex: 1,
            child: _buildConflictHeatmap(),
          ),
          const Divider(),
          Expanded(
            flex: 2,
            child: _buildComparisonTable(),
          ),
        ],
      ),
    );
  }
}

class ProductGridItem extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback onTap;

  const ProductGridItem({
    Key? key,
    required this.product,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    product.imageUrl ?? 'placeholder_url',
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Positioned(
                right: 8,
                top: 8,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}


// Dummy classes for compilation
class Conflict {}
class Recommendation {}
class ShareService {
  static Future<void> shareProducts(List<Product> products) async {
    //Implementation for sharing products
    await Future.delayed(const Duration(seconds: 1));
  }
}
class ConflictAnalyzer {
  static Future<List<Conflict>> findBatchConflicts(List<Product> products) async {
    //Implementation for conflict analysis
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}
class ProductComparisonTable extends StatelessWidget {
  final List<Product> products;
  final List<Conflict> conflicts;
  final List<Recommendation> recommendations; // Added recommendations
  final Function(int, bool) onSort;

  const ProductComparisonTable({
    Key? key,
    required this.products,
    required this.conflicts,
    required this.recommendations,
    required this.onSort,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text("Comparison Table"); // Replace with actual implementation
  }
}
class ConflictHeatmap extends StatelessWidget{
  final List<Conflict> conflicts;

  const ConflictHeatmap({Key? key, required this.conflicts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text("Conflict Heatmap"); //Replace with actual implementation
  }
}

class AnalyticsService{
  Future<void> logBatchAnalysis({required int productCount, required int conflictCount}) async {
      //Implementation for analytics logging
      await Future.delayed(const Duration(seconds: 1));
  }
  void logScreenView(String screenName) {
    //Implementation for screen view logging
  }
}

class RecommendationService{
  Future<List<Recommendation>> getBatchRecommendations({required List<Product> products, required List<Conflict> conflicts}) async {
    //Implementation for recommendation generation
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}