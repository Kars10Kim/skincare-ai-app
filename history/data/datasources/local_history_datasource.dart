import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/favorite_product.dart';
import '../../domain/entities/scan_history_item.dart';

/// Local history data source interface
abstract class LocalHistoryDataSource {
  /// Get scan history
  Future<List<ScanHistoryItem>> getHistory();
  
  /// Add scan to history
  Future<ScanHistoryItem> addScanToHistory(ScanHistoryItem item);
  
  /// Clear history
  Future<void> clearHistory();
  
  /// Update scan note
  Future<ScanHistoryItem> updateScanNote(String scanId, String? note);
  
  /// Toggle favorite status
  Future<ScanHistoryItem> toggleFavorite(String scanId, bool isFavorite);
  
  /// Get all favorites
  Future<List<FavoriteProduct>> getFavorites();
  
  /// Get favorites by category
  Future<List<FavoriteProduct>> getFavoritesByCategory(FavoriteCategory category);
  
  /// Add to favorites
  Future<FavoriteProduct> addToFavorites(FavoriteProduct favorite);
  
  /// Remove from favorites
  Future<void> removeFromFavorites(String favoriteId);
  
  /// Update favorite category
  Future<FavoriteProduct> updateFavoriteCategory(String favoriteId, FavoriteCategory category);
  
  /// Update favorite notes
  Future<FavoriteProduct> updateFavoriteNotes(String favoriteId, String? notes);
}

/// Local history data source implementation using Hive
class LocalHistoryDataSourceImpl implements LocalHistoryDataSource {
  static const String _historyBoxName = 'scan_history';
  static const String _favoritesBoxName = 'favorites';
  
  /// UUID generator
  final Uuid _uuid = const Uuid();
  
  /// Gets the history box
  Future<Box<String>> get _historyBox async {
    if (!Hive.isBoxOpen(_historyBoxName)) {
      await Hive.openBox<String>(_historyBoxName);
    }
    return Hive.box<String>(_historyBoxName);
  }
  
  /// Gets the favorites box
  Future<Box<String>> get _favoritesBox async {
    if (!Hive.isBoxOpen(_favoritesBoxName)) {
      await Hive.openBox<String>(_favoritesBoxName);
    }
    return Hive.box<String>(_favoritesBoxName);
  }
  
  /// Converts a scan history item to a JSON string
  String _scanHistoryItemToJson(ScanHistoryItem item) {
    return jsonEncode({
      'id': item.id,
      'product': {
        'id': item.product.id,
        'name': item.product.name,
        'brand': item.product.brand,
        'category': item.product.category,
        'ingredients': item.product.ingredients,
        'barcode': item.product.barcode,
        'imageUrl': item.product.imageUrl,
      },
      'timestamp': item.timestamp.toIso8601String(),
      'scanType': item.scanType.toString().split('.').last,
      'isFavorite': item.isFavorite,
      'conflicts': item.conflicts.map((c) => {
        'ingredient1': c.ingredient1,
        'ingredient2': c.ingredient2,
        'severity': c.severity,
        'description': c.description,
        'source': c.source,
      }).toList(),
      'safetyScore': item.safetyScore,
      'notes': item.notes,
      'tags': item.tags,
    });
  }
  
  /// Converts a JSON string to a scan history item
  ScanHistoryItem _jsonToScanHistoryItem(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    
    final scanTypeStr = json['scanType'] as String;
    final scanType = ScanHistoryItemType.values.firstWhere(
      (e) => e.toString().split('.').last == scanTypeStr,
      orElse: () => ScanHistoryItemType.manual,
    );
    
    final conflictsJson = json['conflicts'] as List<dynamic>;
    final conflicts = conflictsJson.map((c) => IngredientConflict(
      ingredient1: c['ingredient1'] as String,
      ingredient2: c['ingredient2'] as String,
      severity: c['severity'] as int,
      description: c['description'] as String,
      source: c['source'] as String?,
    )).toList();
    
    final productJson = json['product'] as Map<String, dynamic>;
    final product = Product(
      id: productJson['id'] as String,
      name: productJson['name'] as String,
      brand: productJson['brand'] as String?,
      category: productJson['category'] as String?,
      ingredients: List<String>.from(productJson['ingredients'] as List),
      barcode: productJson['barcode'] as String?,
      imageUrl: productJson['imageUrl'] as String?,
    );
    
    return ScanHistoryItem(
      id: json['id'] as String,
      product: product,
      timestamp: DateTime.parse(json['timestamp'] as String),
      scanType: scanType,
      isFavorite: json['isFavorite'] as bool,
      conflicts: conflicts,
      safetyScore: json['safetyScore'] as int,
      notes: json['notes'] as String?,
      tags: List<String>.from(json['tags'] as List),
    );
  }
  
  /// Converts a favorite product to a JSON string
  String _favoriteProductToJson(FavoriteProduct favorite) {
    return jsonEncode({
      'id': favorite.id,
      'product': {
        'id': favorite.product.id,
        'name': favorite.product.name,
        'brand': favorite.product.brand,
        'category': favorite.product.category,
        'ingredients': favorite.product.ingredients,
        'barcode': favorite.product.barcode,
        'imageUrl': favorite.product.imageUrl,
      },
      'addedDate': favorite.addedDate.toIso8601String(),
      'category': favorite.category.toString().split('.').last,
      'notes': favorite.notes,
      'tags': favorite.tags,
    });
  }
  
  /// Converts a JSON string to a favorite product
  FavoriteProduct _jsonToFavoriteProduct(String jsonStr) {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    
    final categoryStr = json['category'] as String;
    final category = FavoriteCategory.values.firstWhere(
      (e) => e.toString().split('.').last == categoryStr,
      orElse: () => FavoriteCategory.general,
    );
    
    final productJson = json['product'] as Map<String, dynamic>;
    final product = Product(
      id: productJson['id'] as String,
      name: productJson['name'] as String,
      brand: productJson['brand'] as String?,
      category: productJson['category'] as String?,
      ingredients: List<String>.from(productJson['ingredients'] as List),
      barcode: productJson['barcode'] as String?,
      imageUrl: productJson['imageUrl'] as String?,
    );
    
    return FavoriteProduct(
      id: json['id'] as String,
      product: product,
      addedDate: DateTime.parse(json['addedDate'] as String),
      category: category,
      notes: json['notes'] as String?,
      tags: List<String>.from(json['tags'] as List),
    );
  }
  
  @override
  Future<List<ScanHistoryItem>> getHistory() async {
    final box = await _historyBox;
    final historyItems = <ScanHistoryItem>[];
    
    for (final key in box.keys) {
      final jsonStr = box.get(key);
      if (jsonStr != null) {
        try {
          final item = _jsonToScanHistoryItem(jsonStr);
          historyItems.add(item);
        } catch (e) {
          // Skip invalid items
          continue;
        }
      }
    }
    
    // Sort by timestamp, newest first
    historyItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return historyItems;
  }
  
  @override
  Future<ScanHistoryItem> addScanToHistory(ScanHistoryItem item) async {
    final box = await _historyBox;
    
    // If the ID is empty, generate a new one
    final id = item.id.isEmpty ? _uuid.v4() : item.id;
    final updatedItem = item.copyWith(id: id);
    
    await box.put(id, _scanHistoryItemToJson(updatedItem));
    
    return updatedItem;
  }
  
  @override
  Future<void> clearHistory() async {
    final box = await _historyBox;
    await box.clear();
  }
  
  @override
  Future<ScanHistoryItem> updateScanNote(String scanId, String? note) async {
    final box = await _historyBox;
    final jsonStr = box.get(scanId);
    
    if (jsonStr == null) {
      throw Exception('Scan item not found');
    }
    
    final item = _jsonToScanHistoryItem(jsonStr);
    final updatedItem = item.copyWith(notes: note);
    
    await box.put(scanId, _scanHistoryItemToJson(updatedItem));
    
    return updatedItem;
  }
  
  @override
  Future<ScanHistoryItem> toggleFavorite(String scanId, bool isFavorite) async {
    final box = await _historyBox;
    final jsonStr = box.get(scanId);
    
    if (jsonStr == null) {
      throw Exception('Scan item not found');
    }
    
    final item = _jsonToScanHistoryItem(jsonStr);
    final updatedItem = item.copyWith(isFavorite: isFavorite);
    
    await box.put(scanId, _scanHistoryItemToJson(updatedItem));
    
    // If favorited, also add to favorites
    if (isFavorite) {
      final favorite = FavoriteProduct(
        id: _uuid.v4(),
        product: item.product,
        addedDate: DateTime.now(),
      );
      await addToFavorites(favorite);
    }
    
    return updatedItem;
  }
  
  @override
  Future<List<FavoriteProduct>> getFavorites() async {
    final box = await _favoritesBox;
    final favorites = <FavoriteProduct>[];
    
    for (final key in box.keys) {
      final jsonStr = box.get(key);
      if (jsonStr != null) {
        try {
          final favorite = _jsonToFavoriteProduct(jsonStr);
          favorites.add(favorite);
        } catch (e) {
          // Skip invalid items
          continue;
        }
      }
    }
    
    // Sort by added date, newest first
    favorites.sort((a, b) => b.addedDate.compareTo(a.addedDate));
    
    return favorites;
  }
  
  @override
  Future<List<FavoriteProduct>> getFavoritesByCategory(FavoriteCategory category) async {
    final favorites = await getFavorites();
    return favorites.where((f) => f.category == category).toList();
  }
  
  @override
  Future<FavoriteProduct> addToFavorites(FavoriteProduct favorite) async {
    final box = await _favoritesBox;
    
    // If the ID is empty, generate a new one
    final id = favorite.id.isEmpty ? _uuid.v4() : favorite.id;
    final updatedFavorite = favorite.copyWith(id: id);
    
    await box.put(id, _favoriteProductToJson(updatedFavorite));
    
    return updatedFavorite;
  }
  
  @override
  Future<void> removeFromFavorites(String favoriteId) async {
    final box = await _favoritesBox;
    await box.delete(favoriteId);
  }
  
  @override
  Future<FavoriteProduct> updateFavoriteCategory(String favoriteId, FavoriteCategory category) async {
    final box = await _favoritesBox;
    final jsonStr = box.get(favoriteId);
    
    if (jsonStr == null) {
      throw Exception('Favorite not found');
    }
    
    final favorite = _jsonToFavoriteProduct(jsonStr);
    final updatedFavorite = favorite.copyWith(category: category);
    
    await box.put(favoriteId, _favoriteProductToJson(updatedFavorite));
    
    return updatedFavorite;
  }
  
  @override
  Future<FavoriteProduct> updateFavoriteNotes(String favoriteId, String? notes) async {
    final box = await _favoritesBox;
    final jsonStr = box.get(favoriteId);
    
    if (jsonStr == null) {
      throw Exception('Favorite not found');
    }
    
    final favorite = _jsonToFavoriteProduct(jsonStr);
    final updatedFavorite = favorite.copyWith(notes: notes);
    
    await box.put(favoriteId, _favoriteProductToJson(updatedFavorite));
    
    return updatedFavorite;
  }
}