import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../utils/accessibility.dart';
import '../../utils/animations.dart';
import '../../utils/memory_management.dart';
import '../../utils/ui_performance.dart';
import '../../widgets/loading/loading_state_widget.dart';
import '../../widgets/results/safety_score_gauge.dart';

/// Results screen for product analysis
class ResultsScreen extends StatefulWidget {
  /// Product ID (barcode or ingredient text)
  final String productId;
  
  /// Whether the product was scanned via barcode or ingredients
  final bool isBarcodeScan;
  
  /// Create results screen
  const ResultsScreen({
    Key? key,
    required this.productId,
    required this.isBarcodeScan,
  }) : super(key: key);
  
  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with AutoDisposeMixin, AccessibilitySupport {
  /// Whether data is loading
  bool _isLoading = true;
  
  /// Whether there was an error loading data
  bool _hasError = false;
  
  /// Error message
  String? _errorMessage;
  
  /// Product name
  String? _productName;
  
  /// Product brand
  String? _productBrand;
  
  /// Product ingredients
  List<String> _ingredients = [];
  
  /// Product conflicts
  List<Map<String, dynamic>> _conflicts = [];
  
  /// Safety score (0-100)
  int _safetyScore = 0;
  
  /// Whether to show offline queue prompt
  bool _showOfflineQueuePrompt = false;
  
  /// Analytics service for tracking scans
  late final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
  
  @override
  void initState() {
    super.initState();
    
    UIPerformance.startMeasure('ResultsScreen');
    
    // Load product data
    _loadProductData();
  }
  
  /// Load product data
  Future<void> _loadProductData() async {
    // Set loading state
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    
    try {
      final productRepository = Provider.of<ProductRepository>(context, listen: false);
      final ingredientRepository = Provider.of<IngredientRepository>(context, listen: false);
      final conflictAnalyzer = Provider.of<ConflictAnalyzer>(context, listen: false);
      final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
      
      // Check if we're offline and handle appropriately
      final bool isOffline = !await connectivityService.isConnected();
      
      if (widget.isBarcodeScan) {
        // For barcode scans, get product data from repository
        try {
          // Try to get from local cache first (supports offline mode)
          final cachedProduct = await productRepository.getProductFromCache(widget.productId);
          
          if (cachedProduct != null) {
            // We have a cached version, use it
            setState(() {
              _productName = cachedProduct.name;
              _productBrand = cachedProduct.brand;
              _ingredients = cachedProduct.ingredients;
              _conflicts = cachedProduct.conflicts.map((conflict) => conflict.toMap()).toList();
              _safetyScore = cachedProduct.safetyScore;
            });
          } else if (isOffline) {
            // We're offline and don't have cache - handle gracefully
            throw ConnectivityException(
              'No internet connection available and no cached data for this product.',
              canUseFallbackData: false);
          } else {
            // Get from API/remote database
            final product = await productRepository.getProductByBarcode(widget.productId);
            
            // If we found the product
            if (product != null) {
              // Save to cache for future offline use
              await productRepository.saveProductToCache(product);
              
              setState(() {
                _productName = product.name;
                _productBrand = product.brand;
                _ingredients = product.ingredients;
                _conflicts = product.conflicts.map((conflict) => conflict.toMap()).toList();
                _safetyScore = product.safetyScore;
              });
            } else {
              throw ProductNotFoundException('Product with barcode ${widget.productId} not found');
            }
          }
        } on ConnectivityException catch (e) {
          // Handle connectivity errors with specific UX
          setState(() {
            _hasError = true;
            _errorMessage = e.message;
            // Allow the user to create an offline queue item
            _showOfflineQueuePrompt = e.canUseFallbackData == false;
          });
        } on ProductNotFoundException catch (e) {
          // Handle product not found errors
          setState(() {
            _hasError = true;
            _errorMessage = e.message;
          });
        } catch (e) {
          // Handle other errors
          setState(() {
            _hasError = true;
            _errorMessage = e.toString();
          });
        }
      } else {
        // For ingredient scans, parse text and analyze
        try {
          // Parse ingredients from text
          final recognizedIngredients = await ingredientRepository.parseIngredientText(widget.productId);
          
          if (recognizedIngredients.isEmpty) {
            throw IngredientParseException('No valid ingredients could be recognized from the text');
          }
          
          // Analyze ingredient conflicts
          final conflicts = await conflictAnalyzer.analyzeIngredients(recognizedIngredients);
          
          // Calculate safety score based on conflicts
          final score = conflictAnalyzer.calculateSafetyScore(recognizedIngredients, conflicts);
          
          // Create a transient product record for the scan
          final product = Product(
            id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
            barcode: 'none',
            name: 'Ingredient Scan',
            brand: DateTime.now().toIso8601String(),
            ingredients: recognizedIngredients,
            conflicts: conflicts,
            safetyScore: score,
          );
          
          // Save to scan history
          await productRepository.saveProductToHistory(product);
          
          setState(() {
            _productName = 'Ingredient Analysis';
            _productBrand = 'From Text Scan';
            _ingredients = recognizedIngredients;
            _conflicts = conflicts.map((conflict) => conflict.toMap()).toList();
            _safetyScore = score;
          });
        } on IngredientParseException catch (e) {
          setState(() {
            _hasError = true;
            _errorMessage = e.message;
          });
        } catch (e) {
          setState(() {
            _hasError = true;
            _errorMessage = e.toString();
          });
        }
      }
      
      // Save to scan history for analytics 
      if (!_hasError) {
        try {
          // Save scan to analytics if it was successful
          final userPreferences = Provider.of<UserPreferencesProvider>(context, listen: false);
          final userId = userPreferences.userId;
          
          if (userId != null) {
            await analyticsService.trackProductScan(
              userId: userId,
              productId: widget.productId,
              isBarcode: widget.isBarcodeScan,
              ingredientCount: _ingredients.length,
              conflictCount: _conflicts.length,
              safetyScore: _safetyScore,
            );
          }
        } catch (e) {
          // Just log analytics errors, don't interrupt the flow
          debugPrint('Analytics error: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading product data: $e');
      
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// Handle retry button press
  void _handleRetry() {
    _loadProductData();
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.resultsTitle),
        elevation: 0,
      ),
      body: LoadingStateWidget(
        isLoading: _isLoading,
        type: LoadingStateType.shimmer,
        skeletonLayout: SkeletonLayout.detail,
        message: localizations.resultsLoadingProduct,
        child: _hasError
            ? _buildErrorView(context, theme, localizations)
            : _buildResultsView(context, theme, localizations),
      ),
    );
  }
  
  /// Build error view
  Widget _buildErrorView(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? localizations.errorUnknown,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleRetry,
              child: Text(localizations.buttonTryAgain),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build results view
  Widget _buildResultsView(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return AccessibleFadeTransition(
      opacity: const AlwaysStoppedAnimation(1.0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product details card
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name and brand
                    Text(
                      _productName ?? 'Unknown Product',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_productBrand != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _productBrand!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    
                    // Safety score
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: SafetyScoreGauge(
                          score: _safetyScore,
                          size: 180,
                          animate: !accessibilitySettings.reducedMotion,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Ingredients analysis
            Text(
              localizations.resultsIngredientsAnalysis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Ingredients list
            if (_ingredients.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No ingredients found',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = _ingredients[index];
                  
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(ingredient),
                      trailing: const Icon(Icons.info_outline),
                      onTap: () {
                        // TODO: Show ingredient details
                      },
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            
            // Conflicts
            Text(
              localizations.resultsConflicts,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Conflicts list
            if (_conflicts.isEmpty)
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          localizations.resultsNoConflicts,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _conflicts.length,
                itemBuilder: (context, index) {
                  final conflict = _conflicts[index];
                  
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(conflict['name'] as String),
                      subtitle: Text(conflict['description'] as String),
                      trailing: Icon(
                        Icons.warning,
                        color: conflict['severity'] == 'high'
                            ? Colors.red
                            : conflict['severity'] == 'medium'
                                ? Colors.orange
                                : Colors.yellow,
                      ),
                      onTap: () {
                        // TODO: Show conflict details
                      },
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),
            
            // Save to history button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Save to scan history
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: Text(localizations.resultsSaveToHistory),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    UIPerformance.endMeasure('ResultsScreen');
    super.dispose();
  }
}