import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:skincare_scanner/constants/api_constants.dart';
import 'package:skincare_scanner/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  Product? _currentProduct;
  List<Product> _scanHistory = [];
  List<String> _ingredientConflicts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Product? get currentProduct => _currentProduct;
  List<Product> get scanHistory => _scanHistory;
  List<String> get ingredientConflicts => _ingredientConflicts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set current product
  void setCurrentProduct(Product product) {
    _currentProduct = product;
    _error = null;
    notifyListeners();
  }

  // Clear current product
  void clearCurrentProduct() {
    _currentProduct = null;
    _ingredientConflicts = [];
    _error = null;
    notifyListeners();
  }

  // Set scan history
  void setScanHistory(List<Product> history) {
    _scanHistory = history;
    notifyListeners();
  }

  // Add to scan history
  void addToScanHistory(Product product) {
    if (!_scanHistory.any((p) => p.barcode == product.barcode)) {
      _scanHistory.insert(0, product);
      notifyListeners();
    }
  }

  // Set ingredient conflicts
  void setIngredientConflicts(List<String> conflicts) {
    _ingredientConflicts = conflicts;
    notifyListeners();
  }

  // Fetch product by barcode
  Future<Product?> fetchProductByBarcode(String barcode, {String? authToken}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First try our internal API
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsEndpoint}?barcode=$barcode'),
        headers: authToken != null ? {'Authorization': 'Bearer $authToken'} : {},
      );

      if (response.statusCode == 200) {
        final product = Product.fromJson(json.decode(response.body));
        _currentProduct = product;
        _isLoading = false;
        notifyListeners();
        return product;
      } else if (response.statusCode == 404) {
        // If not found in our database, try OpenFoodFacts API
        return await _fetchFromOpenFoodFacts(barcode);
      } else {
        throw Exception('Failed to load product: Status ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Fetch from OpenFoodFacts API
  Future<Product?> _fetchFromOpenFoodFacts(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.openFoodFactsApi}$barcode.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 1) {
          final product = Product.fromOpenFoodFacts(data, barcode);
          _currentProduct = product;
          _isLoading = false;
          notifyListeners();
          return product;
        } else {
          _error = 'Product not found in external database';
          _isLoading = false;
          notifyListeners();
          return null;
        }
      } else {
        throw Exception('Failed to load product from external API: Status ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Save product
  Future<bool> saveProduct(Product product, {String? authToken}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final savedProduct = Product.fromJson(json.decode(response.body));
        _currentProduct = savedProduct;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to save product: Status ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check ingredient conflicts
  Future<List<String>> checkIngredientConflicts(List<String> ingredients, {String? authToken}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ingredientConflictsEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'ingredients': ingredients}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final conflicts = List<String>.from(data['conflicts'] ?? []);
        _ingredientConflicts = conflicts;
        _isLoading = false;
        notifyListeners();
        return conflicts;
      } else {
        throw Exception('Failed to check conflicts: Status ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Load scan history
  Future<void> loadScanHistory({String? authToken, int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.scanHistoryEndpoint}?limit=$limit'),
        headers: authToken != null ? {'Authorization': 'Bearer $authToken'} : {},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final history = (data['history'] as List)
            .map((item) => Product.fromJson(item['product']))
            .toList();
        _scanHistory = history;
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load history: Status ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset state
  void resetState() {
    _currentProduct = null;
    _scanHistory = [];
    _ingredientConflicts = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}