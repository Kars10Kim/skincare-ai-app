import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import '../models/product/product_model.dart';
import '../services/connectivity_service.dart';
import '../utils/exceptions.dart';

/// Repository for managing product data
class ProductRepository {
  /// API base URL for product data
  final String _apiBaseUrl;
  
  /// Connectivity service for handling offline mode
  final ConnectivityService _connectivityService;
  
  /// Secure storage for sensitive product data
  final FlutterSecureStorage _secureStorage;
  
  /// Database for local cache
  Database? _database;
  
  /// Create a product repository
  ProductRepository({
    required String apiBaseUrl,
    required ConnectivityService connectivityService,
    FlutterSecureStorage? secureStorage,
  }) : _apiBaseUrl = apiBaseUrl,
       _connectivityService = connectivityService,
       _secureStorage = secureStorage ?? const FlutterSecureStorage();
  
  /// Initialize the repository
  Future<void> initialize() async {
    await _initDatabase();
  }
  
  /// Initialize the local database
  Future<void> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = '${documentsDirectory.path}/products.db';
      
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          // Create products table
          await db.execute('''
            CREATE TABLE products (
              id TEXT PRIMARY KEY,
              barcode TEXT,
              name TEXT,
              brand TEXT,
              ingredients TEXT,
              conflicts TEXT,
              safety_score INTEGER,
              data TEXT,
              last_updated TEXT
            )
          ''');
          
          // Create scan history table
          await db.execute('''
            CREATE TABLE scan_history (
              id TEXT PRIMARY KEY,
              product_id TEXT,
              scan_type TEXT,
              timestamp TEXT,
              data TEXT
            )
          ''');
        },
      );
    } catch (e) {
      debugPrint('Error initializing database: $e');
    }
  }
  
  /// Get a product by barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        // Try to get from cache if offline
        return await getProductFromCache(barcode);
      }
      
      // Otherwise fetch from API
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/products/barcode/$barcode'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final product = Product.fromJson(data);
        
        // Save to cache for offline use
        await saveProductToCache(product);
        
        return product;
      } else if (response.statusCode == 404) {
        // Product not found
        return null;
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting product by barcode: $e');
      // Try to get from cache as fallback
      return await getProductFromCache(barcode);
    }
  }
  
  /// Get a product from local cache
  Future<Product?> getProductFromCache(String barcode) async {
    try {
      if (_database == null) {
        await _initDatabase();
      }
      
      final List<Map<String, dynamic>> results = await _database!.query(
        'products',
        where: 'barcode = ?',
        whereArgs: [barcode],
      );
      
      if (results.isNotEmpty) {
        final productData = results.first;
        final data = jsonDecode(productData['data'] as String) as Map<String, dynamic>;
        return Product.fromJson(data);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting product from cache: $e');
      return null;
    }
  }
  
  /// Save a product to local cache
  Future<void> saveProductToCache(Product product) async {
    try {
      if (_database == null) {
        await _initDatabase();
      }
      
      // Convert ingredients and conflicts to JSON strings
      final data = product.toJson();
      
      await _database!.insert(
        'products',
        {
          'id': product.id,
          'barcode': product.barcode,
          'name': product.name,
          'brand': product.brand,
          'ingredients': jsonEncode(product.ingredients),
          'conflicts': jsonEncode(product.conflicts.map((c) => c.toJson()).toList()),
          'safety_score': product.safetyScore,
          'data': jsonEncode(data),
          'last_updated': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error saving product to cache: $e');
    }
  }
  
  /// Save a product to scan history
  Future<void> saveProductToHistory(Product product) async {
    try {
      if (_database == null) {
        await _initDatabase();
      }
      
      final historyId = 'history_${DateTime.now().millisecondsSinceEpoch}';
      
      await _database!.insert(
        'scan_history',
        {
          'id': historyId,
          'product_id': product.id,
          'scan_type': product.barcode == 'none' ? 'ingredient' : 'barcode',
          'timestamp': DateTime.now().toIso8601String(),
          'data': jsonEncode(product.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error saving product to history: $e');
    }
  }
  
  /// Get scan history
  Future<List<Product>> getScanHistory({int limit = 20}) async {
    try {
      if (_database == null) {
        await _initDatabase();
      }
      
      final List<Map<String, dynamic>> results = await _database!.query(
        'scan_history',
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      
      return results.map((result) {
        final data = jsonDecode(result['data'] as String) as Map<String, dynamic>;
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting scan history: $e');
      return [];
    }
  }
  
  /// Clear scan history
  Future<void> clearScanHistory() async {
    try {
      if (_database == null) {
        await _initDatabase();
      }
      
      await _database!.delete('scan_history');
    } catch (e) {
      debugPrint('Error clearing scan history: $e');
    }
  }
  
  /// Get favorite products
  Future<List<Product>> getFavoriteProducts() async {
    try {
      // Get favorite product IDs from secure storage
      final favoritesJson = await _secureStorage.read(key: 'favorite_products');
      if (favoritesJson == null || favoritesJson.isEmpty) {
        return [];
      }
      
      final List<String> favoriteIds = List<String>.from(jsonDecode(favoritesJson) as List);
      
      if (favoriteIds.isEmpty) {
        return [];
      }
      
      if (_database == null) {
        await _initDatabase();
      }
      
      // Build query parameters for SQL IN clause
      final params = List<String>.filled(favoriteIds.length, '?').join(',');
      
      final List<Map<String, dynamic>> results = await _database!.query(
        'products',
        where: 'id IN ($params)',
        whereArgs: favoriteIds,
      );
      
      return results.map((result) {
        final data = jsonDecode(result['data'] as String) as Map<String, dynamic>;
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting favorite products: $e');
      return [];
    }
  }
  
  /// Add a product to favorites
  Future<void> addToFavorites(Product product) async {
    try {
      // Get current favorites
      final favoritesJson = await _secureStorage.read(key: 'favorite_products');
      final List<String> favoriteIds = favoritesJson != null 
          ? List<String>.from(jsonDecode(favoritesJson) as List)
          : [];
      
      // Add if not already favorited
      if (!favoriteIds.contains(product.id)) {
        favoriteIds.add(product.id);
      }
      
      // Save updated favorites
      await _secureStorage.write(
        key: 'favorite_products',
        value: jsonEncode(favoriteIds),
      );
      
      // Make sure product is cached
      await saveProductToCache(product);
    } catch (e) {
      debugPrint('Error adding product to favorites: $e');
    }
  }
  
  /// Remove a product from favorites
  Future<void> removeFromFavorites(String productId) async {
    try {
      // Get current favorites
      final favoritesJson = await _secureStorage.read(key: 'favorite_products');
      if (favoritesJson == null || favoritesJson.isEmpty) {
        return;
      }
      
      final List<String> favoriteIds = List<String>.from(jsonDecode(favoritesJson) as List);
      
      // Remove the product
      favoriteIds.remove(productId);
      
      // Save updated favorites
      await _secureStorage.write(
        key: 'favorite_products',
        value: jsonEncode(favoriteIds),
      );
    } catch (e) {
      debugPrint('Error removing product from favorites: $e');
    }
  }
  
  /// Check if a product is in favorites
  Future<bool> isFavorite(String productId) async {
    try {
      // Get current favorites
      final favoritesJson = await _secureStorage.read(key: 'favorite_products');
      if (favoritesJson == null || favoritesJson.isEmpty) {
        return false;
      }
      
      final List<String> favoriteIds = List<String>.from(jsonDecode(favoritesJson) as List);
      
      return favoriteIds.contains(productId);
    } catch (e) {
      debugPrint('Error checking if product is favorite: $e');
      return false;
    }
  }
  
  /// Search products by name or brand
  Future<List<Product>> searchProducts(String query, {int limit = 20}) async {
    try {
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        // Search in local cache when offline
        return _searchProductsLocally(query, limit: limit);
      }
      
      // Otherwise fetch from API
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/products/search?q=$query&limit=$limit'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        
        final products = data
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        
        // Cache results for offline use
        for (final product in products) {
          await saveProductToCache(product);
        }
        
        return products;
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching products: $e');
      // Fall back to local search
      return _searchProductsLocally(query, limit: limit);
    }
  }
  
  /// Search products in local cache
  Future<List<Product>> _searchProductsLocally(String query, {int limit = 20}) async {
    try {
      if (_database == null) {
        await _initDatabase();
      }
      
      final List<Map<String, dynamic>> results = await _database!.query(
        'products',
        where: 'name LIKE ? OR brand LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        limit: limit,
      );
      
      return results.map((result) {
        final data = jsonDecode(result['data'] as String) as Map<String, dynamic>;
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error searching products locally: $e');
      return [];
    }
  }
  
  /// Get product recommendations based on ingredients and skin profile
  Future<List<Product>> getRecommendations(
    Product currentProduct,
    Map<String, dynamic> skinProfile,
    {int limit = 10}
  ) async {
    try {
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        throw ConnectivityException(
          'Cannot get recommendations while offline',
        );
      }
      
      // Fetch from API
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/products/recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'product_id': currentProduct.id,
          'skin_profile': skinProfile,
          'limit': limit,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        
        final products = data
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        
        // Cache results for offline use
        for (final product in products) {
          await saveProductToCache(product);
        }
        
        return products;
      } else {
        throw Exception('Failed to get recommendations: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting product recommendations: $e');
      return [];
    }
  }
  
  /// Close database when done
  Future<void> dispose() async {
    await _database?.close();
  }
}