import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../models/scan_history_model.dart';
import '../models/user_preferences_model.dart';
import '../repositories/scan_repository.dart';

/// Provider class for database operations
class DatabaseProvider extends ChangeNotifier {
  late final ScanRepository _scanRepository;
  UserPreferences? _userPreferences;
  List<Product> _recentProducts = [];
  List<ScanHistory> _scanHistory = [];
  bool _isLoading = true;
  String? _lastError;
  
  /// Constructor - initialize repositories and load initial data
  DatabaseProvider() {
    _scanRepository = ScanRepository();
    _loadInitialData();
  }
  
  /// Get scan repository instance
  ScanRepository get scanRepository => _scanRepository;
  
  /// User preferences getter
  UserPreferences? get userPreferences => _userPreferences;
  
  /// Recent products getter
  List<Product> get recentProducts => _recentProducts;
  
  /// Scan history getter
  List<ScanHistory> get scanHistory => _scanHistory;
  
  /// Loading state getter
  bool get isLoading => _isLoading;
  
  /// Error message getter
  String? get lastError => _lastError;
  
  /// Load initial data from local database
  Future<void> _loadInitialData() async {
    try {
      setLoading(true);
      
      // Load user preferences
      _userPreferences = await _scanRepository.getUserPreferences();
      
      // Load recent products
      _recentProducts = await _scanRepository.getRecentScans(limit: 10);
      
      // Load scan history
      _scanHistory = await _scanRepository.getScanHistory(limit: 20);
      
      _lastError = null;
    } catch (e) {
      _lastError = 'Failed to load initial data: $e';
      debugPrint(_lastError);
    } finally {
      setLoading(false);
    }
  }
  
  /// Save user preferences
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      setLoading(true);
      
      // Save to repository
      final saved = await _scanRepository.saveUserPreferences(preferences);
      
      if (saved != null) {
        _userPreferences = saved;
        _lastError = null;
      } else {
        _lastError = 'Failed to save preferences';
      }
    } catch (e) {
      _lastError = 'Error saving preferences: $e';
      debugPrint(_lastError);
    } finally {
      setLoading(false);
    }
  }
  
  /// Add a product scan to history
  Future<void> addScan(Product product, {String? notes, String? conflictsJson}) async {
    try {
      setLoading(true);
      
      // Create a new scan history entry
      final scan = ScanHistory(
        productBarcode: product.barcode,
        scanDate: DateTime.now(),
        notes: notes,
        conflictsDetected: conflictsJson,
        product: product,
      );
      
      // Add to repository
      final added = await _scanRepository.addScanToHistory(scan);
      
      if (added != null) {
        // Add to local cache
        _scanHistory.insert(0, added);
        
        // Update recent products if needed
        final existingIndex = _recentProducts.indexWhere(
          (p) => p.barcode == product.barcode
        );
        
        if (existingIndex >= 0) {
          _recentProducts.removeAt(existingIndex);
        }
        
        _recentProducts.insert(0, product);
        
        // Keep lists at reasonable size
        if (_scanHistory.length > 100) {
          _scanHistory = _scanHistory.sublist(0, 100);
        }
        
        if (_recentProducts.length > 20) {
          _recentProducts = _recentProducts.sublist(0, 20);
        }
        
        _lastError = null;
      } else {
        _lastError = 'Failed to add scan to history';
      }
    } catch (e) {
      _lastError = 'Error adding scan: $e';
      debugPrint(_lastError);
    } finally {
      setLoading(false);
    }
  }
  
  /// Get product by barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      // First check local cache
      final localProduct = _recentProducts.firstWhere(
        (p) => p.barcode == barcode,
        orElse: () => Product(
          barcode: '',
          name: '',
          ingredients: [],
        ),
      );
      
      if (localProduct.barcode.isNotEmpty) {
        return localProduct;
      }
      
      // If not in cache, get from repository
      return await _scanRepository.getProductByBarcode(barcode);
    } catch (e) {
      _lastError = 'Error getting product: $e';
      debugPrint(_lastError);
      return null;
    }
  }
  
  /// Get recommended products based on user preferences
  Future<List<Product>> getRecommendedProducts() async {
    try {
      return await _scanRepository.getRecommendedProducts();
    } catch (e) {
      _lastError = 'Error getting recommended products: $e';
      debugPrint(_lastError);
      return [];
    }
  }
  
  /// Set loading state and notify listeners
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Refresh data from local and remote sources
  Future<void> refreshData() async {
    await _loadInitialData();
  }
  
  /// Helper to get DatabaseProvider from BuildContext
  static DatabaseProvider repositoryOf(BuildContext context) {
    return Provider.of<DatabaseProvider>(context, listen: false);
  }
}