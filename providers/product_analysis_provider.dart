import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/product/product_model.dart';
import '../models/onboarding_model.dart';
import '../repositories/scan_repository.dart';
import '../services/connectivity_service.dart';
import '../services/error_handler.dart';
import '../services/service_locator.dart';
import '../services/sync_service.dart';
import '../utils/memory_management.dart';
import 'onboarding_provider.dart';

/// Provider for product analysis functionality
class ProductAnalysisProvider extends ChangeNotifier with DisposeBag {
  /// Most recent analysis result
  ProductAnalysisResult? _latestResult;
  
  /// Loading state
  bool _isLoading = false;
  
  /// Error state
  bool _hasError = false;
  
  /// Error message
  String _errorMessage = '';
  
  /// Scan history
  List<ProductAnalysisResult> _scanHistory = [];
  
  /// Connectivity status
  bool _isOffline = false;
  
  /// UUID generator
  final _uuid = const Uuid();
  
  /// Scan repository
  late final ScanRepository _scanRepository;
  
  /// Connectivity service
  late final ConnectivityService _connectivityService;
  
  /// Get latest analysis result
  ProductAnalysisResult? get latestResult => _latestResult;
  
  /// Get whether analysis is loading
  bool get isLoading => _isLoading;
  
  /// Get whether there's an error
  bool get hasError => _hasError;
  
  /// Get error message
  String get errorMessage => _errorMessage;
  
  /// Get scan history
  List<ProductAnalysisResult> get scanHistory => _scanHistory;
  
  /// Get whether the device is offline
  bool get isOffline => _isOffline;
  
  /// Connection status subscription
  late final StreamSubscription<bool> _connectionSubscription;
  
  /// HTTP client for API requests
  final _httpClient = http.Client();
  
  /// Constructor
  ProductAnalysisProvider() {
    try {
      _scanRepository = getIt<ScanRepository>();
      _connectivityService = getIt<ConnectivityService>();
      
      // Listen to connectivity changes
      _connectionSubscription = _connectivityService.connectionStream.listen((isConnected) {
        _isOffline = !isConnected;
        notifyListeners();
      });
      
      // Add to dispose bag
      addDisposable(_connectionSubscription);
      
      // Add the http client to dispose bag
      addDisposable(_httpClient);
      
    } catch (e, stackTrace) {
      getIt<ErrorHandler>().handleError(
        'Error initializing ProductAnalysisProvider: $e',
        stackTrace,
      );
    }
  }
  
  @override
  void dispose() {
    // This will dispose all the registered disposables
    disposeAll();
    super.dispose();
  }
  
  /// Initialize the provider
  Future<void> initialize() async {
    try {
      _isOffline = !_connectivityService.isConnected;
      await _loadScanHistory();
      
      // Check for pending syncs when online
      if (_connectivityService.isConnected) {
        final syncService = getIt<SyncService>();
        syncService.syncNow().catchError((e, stackTrace) {
          // Log errors during initial sync
          getIt<ErrorHandler>().handleError(
            'Initial sync error: $e',
            stackTrace,
            severity: ErrorSeverity.warning,
          );
        });
      }
    } catch (e, stackTrace) {
      getIt<ErrorHandler>().handleError(
        'Error initializing product analysis provider: $e',
        stackTrace,
      );
    }
  }
  
  /// Load scan history from database
  Future<void> _loadScanHistory() async {
    try {
      _scanHistory = await _scanRepository.getAllScans();
      notifyListeners();
    } catch (e, stackTrace) {
      getIt<ErrorHandler>().handleError(
        'Error loading scan history: $e',
        stackTrace,
        severity: ErrorSeverity.warning,
        recoveryActions: [
          ErrorRecoveryAction.retry(
            'Retry Loading History',
            _loadScanHistory,
          ),
        ],
      );
    }
  }

  /// Analyze a product by barcode
  Future<void> analyzeByBarcode(
    String barcode,
    OnboardingProvider onboardingProvider,
    {BuildContext? context}
  ) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // First check local database for cached product
      final cachedProduct = await _scanRepository.getProductByBarcode(barcode);
      
      if (cachedProduct != null && _isOffline) {
        // If offline, use cached product
        await _analyzeProductOffline(cachedProduct.product, onboardingProvider, context: context);
        return;
      }
      
      if (_isOffline) {
        // If offline and product not in cache, show error
        _hasError = true;
        _errorMessage = 'You are offline and this product has not been scanned before. Please connect to the internet to scan new products.';
        _isLoading = false;
        notifyListeners();
        
        // Log error with recovery option to retry when online
        getIt<ErrorHandler>().handleError(
          'Product scan failed: No internet connection and product not in cache',
          StackTrace.current,
          context: context,
          severity: ErrorSeverity.warning,
          recoveryActions: [
            ErrorRecoveryAction.custom(
              'Try Again When Online',
              () async {
                // We'll wait for connectivity to be restored
                if (!_connectivityService.isConnected) {
                  return false; // Not ready to retry yet
                }
                
                // Once we're back online, retry the scan
                await analyzeByBarcode(barcode, onboardingProvider, context: context);
                return true;
              },
              showWhenCondition: () => _connectivityService.isConnected,
            ),
          ],
        );
        return;
      }
      
      // If online, make API request
      try {
        final response = await _httpClient.get(
          Uri.parse('https://api.example.com/product/$barcode'),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('API request timed out after 10 seconds');
          },
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          // Create product object
          final product = Product.fromJson(data['product']);
          
          // Analyze product online
          await _analyzeProductOnline(product, onboardingProvider, context: context);
        } else if (cachedProduct != null) {
          // If API fails but we have a cached product, use that
          await _analyzeProductOffline(cachedProduct.product, onboardingProvider, context: context);
          
          // Log that we're using cached product
          getIt<ErrorHandler>().handleError(
            'Using cached product data due to API error: ${response.statusCode}',
            StackTrace.current,
            context: context,
            severity: ErrorSeverity.warning,
            recoveryActions: [
              ErrorRecoveryAction.retry(
                'Retry Online Analysis',
                () async => analyzeByBarcode(barcode, onboardingProvider, context: context),
              ),
            ],
          );
        } else {
          _hasError = true;
          _errorMessage = 'Product not found. Please try a different product or enter details manually.';
          
          // Log product not found error
          getIt<ErrorHandler>().handleError(
            'Product not found with barcode: $barcode',
            StackTrace.current,
            context: context,
            severity: ErrorSeverity.warning,
          );
        }
      } catch (e, stackTrace) {
        // If API request fails but we have a cached product, use that
        if (cachedProduct != null) {
          await _analyzeProductOffline(cachedProduct.product, onboardingProvider, context: context);
          
          // Log fallback to offline analysis
          getIt<ErrorHandler>().handleError(
            'Falling back to cached product data due to API error: $e',
            stackTrace,
            context: context,
            severity: ErrorSeverity.warning,
            recoveryActions: [
              ErrorRecoveryAction.retry(
                'Retry Online Analysis',
                () async => analyzeByBarcode(barcode, onboardingProvider, context: context),
              ),
            ],
          );
        } else {
          _hasError = true;
          _errorMessage = 'Error analyzing product: ${e.toString()}';
          
          // Log API error
          getIt<ErrorHandler>().handleError(
            'API error while analyzing product: $e',
            stackTrace,
            context: context,
            recoveryActions: [
              ErrorRecoveryAction.retry(
                'Try Again',
                () async => analyzeByBarcode(barcode, onboardingProvider, context: context),
              ),
            ],
          );
        }
      }
    } catch (e, stackTrace) {
      _hasError = true;
      _errorMessage = 'Error analyzing product: ${e.toString()}';
      
      // Log general error
      getIt<ErrorHandler>().handleError(
        'Error analyzing product: $e',
        stackTrace,
        context: context,
        recoveryActions: [
          ErrorRecoveryAction.retry(
            'Try Again',
            () async => analyzeByBarcode(barcode, onboardingProvider, context: context),
          ),
        ],
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Analyze a product's ingredients list
  Future<void> analyzeIngredientsList(
    String ingredients,
    String productName,
    String brand,
    OnboardingProvider onboardingProvider,
    {BuildContext? context}
  ) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Process ingredient list (split by commas, clean up)
      final ingredientsList = ingredients
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
      
      if (ingredientsList.isEmpty) {
        _hasError = true;
        _errorMessage = 'No ingredients found. Please check the text and try again.';
        _isLoading = false;
        notifyListeners();
        
        getIt<ErrorHandler>().handleError(
          'No ingredients found in submitted text',
          StackTrace.current,
          context: context,
          severity: ErrorSeverity.warning,
        );
        return;
      }
      
      // Create a manual product
      final product = Product(
        id: 'manual_${_uuid.v4()}',
        barcode: 'manual',
        name: productName.isEmpty ? 'Manual Entry' : productName,
        brand: brand.isEmpty ? 'Unknown' : brand,
        ingredients: ingredientsList,
      );
      
      // For ingredient analysis, we can do it offline
      if (_isOffline) {
        await _analyzeProductOffline(product, onboardingProvider, context: context);
        
        // Log that we're performing offline analysis
        getIt<ErrorHandler>().handleError(
          'Performing offline ingredient analysis due to no connectivity',
          StackTrace.current,
          context: context,
          severity: ErrorSeverity.info,
        );
      } else {
        await _analyzeProductOnline(product, onboardingProvider, context: context);
      }
    } catch (e, stackTrace) {
      _hasError = true;
      _errorMessage = 'Error analyzing ingredients: ${e.toString()}';
      
      // Log error
      getIt<ErrorHandler>().handleError(
        'Error analyzing ingredients: $e',
        stackTrace,
        context: context,
        recoveryActions: [
          ErrorRecoveryAction.retry(
            'Try Again',
            () async => analyzeIngredientsList(
              ingredients, 
              productName, 
              brand, 
              onboardingProvider, 
              context: context
            ),
          ),
        ],
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Clear analysis result
  void clearAnalysisResult() {
    _latestResult = null;
    notifyListeners();
  }
  
  /// Clear error
  void clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }
  
  /// Clear scan history
  Future<void> clearScanHistory() async {
    // We'll need to implement this once we have the database working
    // For now, just clear the in-memory list
    _scanHistory = [];
    notifyListeners();
  }
  
  /// Remove a specific scan from history
  Future<void> removeFromHistory(String scanId) async {
    final success = await _scanRepository.deleteScan(scanId);
    
    if (success) {
      await _loadScanHistory(); // Reload from database
    }
  }
  
  /// Analyze a product online (with API access)
  Future<void> _analyzeProductOnline(
    Product product,
    OnboardingProvider onboardingProvider,
    {BuildContext? context}
  ) async {
    try {
      // Get user preferences
      final skinType = onboardingProvider.data.skinType;
      final concerns = onboardingProvider.data.selectedConcerns;
      final allergens = onboardingProvider.data.selectedAllergens;
      
      // In a real app, this would be an API request to analyze the product
      try {
        // Simulate API request with timeout protection
        await Future.delayed(const Duration(seconds: 1)).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('API request timed out after 10 seconds');
          },
        );
        
        // Simulate ingredient analysis
        final conflicts = _simulateIngredientAnalysis(product.ingredients, allergens);
        
        // Calculate a safety score based on conflicts
        final safetyScore = _calculateSafetyScore(conflicts);
        
        // Find allergen matches
        final allergenMatches = _findAllergenMatches(product.ingredients, allergens);
        
        // Create final analysis result
        final analysisResult = ProductAnalysisResult(
          product: product,
          conflicts: conflicts,
          safetyScore: safetyScore,
          allergenMatches: allergenMatches,
        );
        
        // Save result
        _latestResult = analysisResult;
        
        // Save to database and queue for sync
        await _scanRepository.saveScan(analysisResult);
        
        // Update scan history
        await _loadScanHistory();
      } catch (e, stackTrace) {
        // If API request fails, try to do offline analysis
        if (_isOffline) {
          await _analyzeProductOffline(product, onboardingProvider, context: context);
          
          // Log fallback
          getIt<ErrorHandler>().handleError(
            'Falling back to offline analysis due to API error: $e',
            stackTrace,
            context: context,
            severity: ErrorSeverity.warning,
          );
        } else {
          // Rethrow to be caught by outer try-catch
          rethrow;
        }
      }
    } catch (e, stackTrace) {
      _hasError = true;
      _errorMessage = 'Error analyzing product: ${e.toString()}';
      
      // Log analysis error
      getIt<ErrorHandler>().handleError(
        'Error during online product analysis: $e',
        stackTrace,
        context: context,
      );
    }
  }
  
  /// Analyze a product offline (without API access)
  Future<void> _analyzeProductOffline(
    Product product,
    OnboardingProvider onboardingProvider,
    {BuildContext? context}
  ) async {
    try {
      // Get user preferences
      final skinType = onboardingProvider.data.skinType;
      final concerns = onboardingProvider.data.selectedConcerns;
      final allergens = onboardingProvider.data.selectedAllergens;
      
      // For offline analysis, we do a local analysis
      try {
        // Process ingredients with timeout protection
        final conflicts = _simulateIngredientAnalysis(product.ingredients, allergens);
        
        // Calculate a safety score based on conflicts
        final safetyScore = _calculateSafetyScore(conflicts);
        
        // Find allergen matches
        final allergenMatches = _findAllergenMatches(product.ingredients, allergens);
        
        // Create final analysis result
        final analysisResult = ProductAnalysisResult(
          product: product,
          conflicts: conflicts,
          safetyScore: safetyScore,
          allergenMatches: allergenMatches,
        );
        
        // Save result
        _latestResult = analysisResult;
        
        // Save to database and queue for later sync
        await _scanRepository.saveIngredientAnalysis(
          product.ingredients.join(', '),
          analysisResult,
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw TimeoutException('Database save operation timed out after 5 seconds');
          },
        );
        
        // Update scan history
        await _loadScanHistory();
      } catch (e, stackTrace) {
        if (e is TimeoutException) {
          // Special handling for timeouts
          getIt<ErrorHandler>().handleError(
            'Timeout during database operation: $e',
            stackTrace,
            context: context,
            severity: ErrorSeverity.error,
          );
          rethrow;
        } else {
          // Rethrow other errors to the outer catch block
          rethrow;
        }
      }
    } catch (e, stackTrace) {
      _hasError = true;
      _errorMessage = 'Error analyzing product offline: ${e.toString()}';
      
      // Log offline analysis error
      getIt<ErrorHandler>().handleError(
        'Error during offline product analysis: $e',
        stackTrace,
        context: context,
      );
    }
  }
  
  /// Simulate ingredient analysis
  List<IngredientConflict> _simulateIngredientAnalysis(
    List<String> ingredients,
    List<String> allergens,
  ) {
    // This is a simulation of what would normally happen server-side
    // In a real app, this would be done by the backend
    
    // Create some example conflicts
    final conflicts = <IngredientConflict>[];
    
    // Check for some common problem ingredients
    if (ingredients.any((i) => i.toLowerCase().contains('sodium lauryl sulfate'))) {
      conflicts.add(
        IngredientConflict(
          ingredientName: 'Sodium Lauryl Sulfate',
          severity: ConflictSeverity.moderate,
          description: 'Can be irritating for sensitive skin',
          skinTypes: [SkinType.sensitive, SkinType.dry],
          recommendation: 'Consider alternatives like sodium cocoyl isethionate for sensitive skin',
          reference: 'DOI: 10.1016/j.jaci.2008.01.017',
        ),
      );
    }
    
    if (ingredients.any((i) => i.toLowerCase().contains('alcohol denat'))) {
      conflicts.add(
        IngredientConflict(
          ingredientName: 'Alcohol Denat',
          severity: ConflictSeverity.high,
          description: 'Can be drying and irritating for dry or sensitive skin',
          skinTypes: [SkinType.dry, SkinType.sensitive],
          recommendation: 'Avoid if you have dry or sensitive skin',
          reference: 'DOI: 10.1111/j.1365-2133.2007.08271.x',
        ),
      );
    }
    
    // Check for allergen matches
    for (final allergen in allergens) {
      if (ingredients.any((i) => i.toLowerCase().contains(allergen.toLowerCase()))) {
        conflicts.add(
          IngredientConflict(
            ingredientName: allergen,
            severity: ConflictSeverity.high,
            description: 'You marked this as an allergen',
            skinTypes: [SkinType.sensitive],
            recommendation: 'Avoid this ingredient',
            reference: 'Based on your personal allergen input',
          ),
        );
      }
    }
    
    return conflicts;
  }
  
  /// Calculate safety score
  int _calculateSafetyScore(List<IngredientConflict> conflicts) {
    if (conflicts.isEmpty) {
      return 100;
    }
    
    // Count by severity
    int highCount = 0;
    int moderateCount = 0;
    int lowCount = 0;
    
    for (final conflict in conflicts) {
      switch (conflict.severity) {
        case ConflictSeverity.high:
          highCount++;
          break;
        case ConflictSeverity.moderate:
          moderateCount++;
          break;
        case ConflictSeverity.low:
          lowCount++;
          break;
      }
    }
    
    // Calculate score (high issues have more impact)
    int score = 100;
    score -= highCount * 20;     // Each high severity reduces score by 20
    score -= moderateCount * 10; // Each moderate reduces score by 10
    score -= lowCount * 5;       // Each low reduces score by 5
    
    // Ensure score doesn't go below 0
    return score < 0 ? 0 : score;
  }
  
  /// Find allergen matches
  List<String> _findAllergenMatches(List<String> ingredients, List<String> allergens) {
    final matches = <String>[];
    
    for (final allergen in allergens) {
      if (ingredients.any((i) => i.toLowerCase().contains(allergen.toLowerCase()))) {
        matches.add(allergen);
      }
    }
    
    return matches;
  }
  
  /// Load scan details by scan ID
  Future<void> loadScanDetails(String scanId, {BuildContext? context}) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final scanResult = await _scanRepository.getScanById(scanId);
      
      if (scanResult == null) {
        _hasError = true;
        _errorMessage = 'Scan not found. It may have been deleted.';
        
        // Log scan not found error
        getIt<ErrorHandler>().handleError(
          'Scan not found with ID: $scanId',
          StackTrace.current,
          context: context,
          severity: ErrorSeverity.warning,
          recoveryActions: [
            ErrorRecoveryAction.custom(
              'View All Scans',
              () async {
                _latestResult = null;
                notifyListeners();
                return true;
              },
              showWhenCondition: () => true,
            ),
          ],
        );
      } else {
        _latestResult = scanResult;
      }
    } catch (e, stackTrace) {
      _hasError = true;
      _errorMessage = 'Error loading scan details: ${e.toString()}';
      
      // Log error
      getIt<ErrorHandler>().handleError(
        'Error loading scan details: $e',
        stackTrace,
        context: context,
        recoveryActions: [
          ErrorRecoveryAction.retry(
            'Try Again',
            () async => loadScanDetails(scanId, context: context),
          ),
          ErrorRecoveryAction.custom(
            'View Recent Scans',
            () async {
              await _loadScanHistory();
              return true;
            },
            showWhenCondition: () => true,
          ),
        ],
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}