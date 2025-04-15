import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart';

import 'app_database.dart';

// Provider class for database operations
class DatabaseProvider extends ChangeNotifier {
  final AppDatabase _db;
  bool _initialized = false;
  final _orchestrator = DatabaseOrchestrator.instance; // Added line

  // Constructor
  DatabaseProvider() : _db = AppDatabase() {
    _initialize();
  }

  // Getter for the database
  AppDatabase get database => _db;

  // Initialize the database
  Future<void> _initialize() async {
    if (_initialized) return;

    try {
      // Initialize ingredient conflict rules
      await _db.initializeConflictRules();
      _initialized = true;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  // Make sure database is initialized
  Future<void> ensureInitialized() async {
    if (!_initialized) {
      await _initialize();
    }
  }

  // Scan history methods

  /// Get scan history
  Future<List<ScanHistory>> getScanHistory({int limit = 20}) async {
    await ensureInitialized();
    return _db.getScanHistory(limit);
  }

  /// Get favorite scans
  Future<List<ScanHistory>> getFavorites({int limit = 20}) async {
    await ensureInitialized();
    return _db.getFavorites(limit);
  }

  /// Toggle favorite for a scan
  Future<ScanHistory?> toggleFavorite(int scanId) async {
    await ensureInitialized();
    final updated = await _db.toggleFavorite(scanId);
    notifyListeners();
    return updated;
  }

  // User preferences methods
  Future<UserPreference?> getUserPreferences() async {
    await ensureInitialized();
    return _db.getUserPreferences();
  }

  Future<void> saveUserPreferences({
    required String skinType,
    required List<String> skinConcerns,
    required List<String> allergies,
    List<String>? preferredBrands,
    List<String>? avoidIngredients,
  }) async {
    await ensureInitialized();

    final preferences = UserPreferencesCompanion.insert(
      skinType: skinType,
      skinConcerns: _listToJson(skinConcerns),
      allergies: _listToJson(allergies),
      preferredBrands: Value(_listToJson(preferredBrands)),
      avoidIngredients: Value(_listToJson(avoidIngredients)),
    );

    await _db.setUserPreferences(preferences);
    notifyListeners();
  }

  // Product methods
  Future<List<Product>> getAllProducts() async {
    await ensureInitialized();
    return _db.getAllProducts();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    await ensureInitialized();
    return _db.getProductByBarcode(barcode);
  }

  Future<void> saveProduct({
    required String barcode,
    required String name,
    required String ingredients,
    String? brand,
    String? imageUrl,
    bool hasConflicts = false,
  }) async {
    await ensureInitialized();

    final product = ProductsCompanion.insert(
      barcode: barcode,
      name: name,
      ingredients: ingredients,
      brand: Value(brand),
      imageUrl: Value(imageUrl),
      hasConflicts: Value(hasConflicts),
    );

    await _db.insertProduct(product);
    notifyListeners();
  }

  // Scan history methods
  Future<List<ScanHistoryWithProduct>> getRecentScans({int limit = 20}) async {
    await ensureInitialized();
    return _db.getRecentScans(limit: limit);
  }

  Future<void> addScan({
    required String productBarcode,
    String? notes,
    String? conflictsDetected,
    bool favorite = false,
  }) async {
    await ensureInitialized();

    final scan = ScanHistoryCompanion.insert(
      productBarcode: productBarcode,
      notes: Value(notes),
      conflictsDetected: Value(conflictsDetected),
      favorite: Value(favorite),
    );

    await _db.insertScan(scan);
    notifyListeners();
  }

  Future<void> clearScanHistory() async {
    await ensureInitialized();
    await _db.clearScanHistory();
    notifyListeners();
  }

  // Ingredient conflict methods
  Future<List<IngredientConflictWithDetails>> getConflictsForIngredient(String ingredientName) async {
    await ensureInitialized();
    return _db.getConflictsForIngredient(ingredientName);
  }

  // Check if any of the ingredients have conflicts with each other
  Future<Map<String, List<String>>> checkIngredientConflicts(List<String> ingredients) async {
    await ensureInitialized();

    // Normalize ingredient names (trim whitespace, lowercase)
    final normalizedIngredients = ingredients.map(
      (i) => i.trim().toLowerCase()
    ).toList();

    // Get all possible conflicts
    final Map<String, List<String>> conflicts = {};

    for (final ingredient in normalizedIngredients) {
      final ingredientConflicts = await _db.getConflictsForIngredient(ingredient);

      if (ingredientConflicts.isNotEmpty) {
        for (final conflict in ingredientConflicts) {
          final conflictingName = conflict.conflictingName.toLowerCase();

          // Check if the conflicting ingredient is in our product
          if (normalizedIngredients.contains(conflictingName)) {
            // Add to conflicts map
            if (!conflicts.containsKey(ingredient)) {
              conflicts[ingredient] = [];
            }
            conflicts[ingredient]!.add(conflictingName);
          }
        }
      }
    }

    return conflicts;
  }

  // Recommendation caching methods
  Future<List<Product>> getCachedRecommendations(SkinType skinType) async {
    try {
      final recommendations = await (_db.select(_db.products)
        ..orderBy([
          (p) => OrderingTerm(
            expression: p.recommendationScore,
            mode: OrderingMode.desc,
          ),
        ])
        ..limit(20))
        .get();
      return recommendations
          .map((row) => Product.fromDb(row))
          .where((product) =>
              product.recommendedForSkinType(skinType.toString()))
          .toList();
    } catch (e) {
      print('Error getting cached recommendations: $e');
      return [];
    }
  }

  Future<void> cacheRecommendations(List<Product> products) async {
    try {
      await _db.batch((batch) {
        for (var product in products) {
          batch.insert(
            _db.products,
            product.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
      notifyListeners();
    } catch (e) {
      print('Error caching recommendations: $e');
    }
  }


  // Dispose method
  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  // Helper method to convert list to JSON string
  String _listToJson(List<String>? list) {
    if (list == null || list.isEmpty) return '[]';
    return '["${list.join('","')}"]';
  }
}

// Extension method for Provider
extension DatabaseProviderExtension on BuildContext {
  DatabaseProvider get databaseProvider => read<DatabaseProvider>();
}