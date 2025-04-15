import '../../domain/entities/favorite_product.dart';
import '../../domain/entities/scan_history_item.dart';
import '../../presentation/cubit/favorites_state.dart';
import '../../../recognition/domain/entities/ingredient_conflict.dart';
import '../../../recognition/domain/entities/product.dart';

/// History local data source
abstract class HistoryLocalDataSource {
  /// Get scan history for user
  Future<List<ScanHistoryItem>> getScanHistory(String userId);
  
  /// Get favorited scans for user
  Future<List<ScanHistoryItem>> getFavoritedScans(String userId);
  
  /// Search scan history
  Future<List<ScanHistoryItem>> searchScanHistory({
    required String userId,
    required String query,
    bool favoritesOnly = false,
  });
  
  /// Add scan history item
  Future<void> addScanHistoryItem({
    required String userId,
    required ScanHistoryItem item,
  });
  
  /// Toggle favorite status
  Future<void> toggleFavoriteStatus({
    required String userId,
    required String id,
    required bool isFavorite,
  });
  
  /// Get favorite products for user
  Future<List<FavoriteProduct>> getFavoriteProducts(String userId);
  
  /// Get favorite categories for user
  Future<List<FavoriteCategory>> getFavoriteCategories(String userId);
  
  /// Get products by category for user
  Future<List<FavoriteProduct>> getProductsByCategory({
    required String userId,
    required String categoryId,
  });
  
  /// Add favorite product
  Future<void> addFavoriteProduct({
    required String userId,
    required FavoriteProduct product,
  });
}

/// Implementations for the history local data source that uses
/// real-time data from local database (Hive)
class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  // In a real implementation, this would use Hive or another local database
  // For now, we'll store data in memory with some initial sample data
  final Map<String, List<ScanHistoryItem>> _scanHistoryData = {};
  final Map<String, List<FavoriteProduct>> _favoritesData = {};
  final Map<String, List<FavoriteCategory>> _categoriesData = {};
  
  /// Create history local data source implementation
  HistoryLocalDataSourceImpl() {
    // Initialize with sample data
    _initializeSampleData();
  }
  
  void _initializeSampleData() {
    final sampleUserId = 'current_user_id';
    
    // Sample products
    final product1 = Product(
      name: 'CeraVe Moisturizing Cream',
      brand: 'CeraVe',
      barcode: '3337875597357',
      ingredients: [
        'Aqua/Water',
        'Glycerin',
        'Cetearyl Alcohol',
        'Caprylic/Capric Triglyceride',
        'Cetyl Alcohol',
        'Ceteareth-20',
        'Petrolatum',
        'Ceramide NP',
        'Ceramide AP',
        'Ceramide EOP',
      ],
      price: 18.99,
      size: '19 oz',
      type: 'Moisturizer',
      skinType: 'All skin types',
    );
    
    final product2 = Product(
      name: 'The Ordinary Niacinamide 10% + Zinc 1%',
      brand: 'The Ordinary',
      barcode: '5060524510498',
      ingredients: [
        'Aqua/Water',
        'Niacinamide',
        'Pentylene Glycol',
        'Zinc PCA',
        'Dimethyl Isosorbide',
        'Tamarindus Indica Seed Gum',
        'Xanthan Gum',
        'Isoceteth-20',
        'Ethoxydiglycol',
        'Phenoxyethanol',
        'Chlorphenesin',
      ],
      price: 5.90,
      size: '30ml',
      type: 'Serum',
      skinType: 'Oily, Acne-prone',
    );
    
    final product3 = Product(
      name: 'La Roche-Posay Effaclar Duo+ SPF 30',
      brand: 'La Roche-Posay',
      barcode: '3433422408159',
      ingredients: [
        'Aqua/Water',
        'Homosalate',
        'Octocrylene',
        'Glycerin',
        'Butyl Methoxydibenzoylmethane',
        'Ethylhexyl Triazone',
        'Niacinamide',
        'Silica',
        'Propanediol',
        'Isopropyl Lauroyl Sarcosinate',
      ],
      price: 31.99,
      size: '40ml',
      type: 'Moisturizer with SPF',
      skinType: 'Oily, Acne-prone',
    );
    
    // Sample conflicts
    final conflict1 = IngredientConflict(
      ingredientName: 'Cetyl Alcohol',
      description: 'May cause irritation for people with very sensitive skin or cetyl alcohol allergy',
      severity: ConflictSeverity.low,
      source: 'Journal of Dermatological Science',
      doi: '10.1016/j.jdermsci.2019.01.002',
    );
    
    final conflict2 = IngredientConflict(
      ingredientName: 'Isoceteth-20',
      description: 'May cause irritation in some individuals and potentially disrupt the skin barrier',
      severity: ConflictSeverity.medium,
      source: 'International Journal of Toxicology',
      doi: '10.1177/1091581809359545',
      recommendedAlternative: 'Polysorbate 20',
    );
    
    // Sample scan history items
    final scanItem1 = ScanHistoryItem(
      id: 'scan_1',
      product: product1,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['moisturizer', 'ceramides', 'winter'],
      isFavorite: true,
      conflicts: [conflict1],
      scanType: ScanHistoryItemType.barcode,
      safetyScore: 90,
    );
    
    final scanItem2 = ScanHistoryItem(
      id: 'scan_2',
      product: product2,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Felt a bit sticky on my skin, but reduced redness after a week of use',
      tags: ['serum', 'niacinamide', 'acne'],
      isFavorite: false,
      conflicts: [conflict2],
      scanType: ScanHistoryItemType.camera,
      safetyScore: 75,
    );
    
    final scanItem3 = ScanHistoryItem(
      id: 'scan_3',
      product: product3,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      notes: 'Good for summer, feels lightweight',
      tags: ['sunscreen', 'moisturizer', 'summer'],
      isFavorite: true,
      conflicts: [],
      scanType: ScanHistoryItemType.manual,
      safetyScore: 100,
    );
    
    // Sample favorite products
    final favoriteProduct1 = FavoriteProduct(
      id: 'fav_1',
      product: product1,
      userRating: 4.5,
      notes: 'My holy grail moisturizer, especially in winter',
      tags: ['holy grail', 'repurchase', 'winter'],
      categoryIds: ['moisturizers'],
      addedAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    );
    
    final favoriteProduct2 = FavoriteProduct(
      id: 'fav_2',
      product: product3,
      userRating: 4.0,
      notes: 'Great for summer, provides enough SPF for daily use',
      tags: ['summer', 'spf', 'daily'],
      categoryIds: ['sunscreens', 'moisturizers'],
      addedAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    );
    
    // Sample categories (using predefined defaults)
    final categories = DefaultCategories.getAll();
    
    // Add data to storage
    _scanHistoryData[sampleUserId] = [scanItem1, scanItem2, scanItem3];
    _favoritesData[sampleUserId] = [favoriteProduct1, favoriteProduct2];
    _categoriesData[sampleUserId] = categories;
  }
  
  @override
  Future<List<ScanHistoryItem>> getScanHistory(String userId) async {
    return Future.value(_scanHistoryData[userId] ?? []);
  }
  
  @override
  Future<List<ScanHistoryItem>> getFavoritedScans(String userId) async {
    final allScans = _scanHistoryData[userId] ?? [];
    return Future.value(allScans.where((scan) => scan.isFavorite).toList());
  }
  
  @override
  Future<List<ScanHistoryItem>> searchScanHistory({
    required String userId,
    required String query,
    bool favoritesOnly = false,
  }) async {
    final allScans = favoritesOnly
        ? await getFavoritedScans(userId)
        : await getScanHistory(userId);
    
    if (query.isEmpty) {
      return allScans;
    }
    
    final normalizedQuery = query.toLowerCase();
    return allScans.where((scan) {
      final product = scan.product;
      
      return product.name.toLowerCase().contains(normalizedQuery) ||
          (product.brand?.toLowerCase().contains(normalizedQuery) ?? false) ||
          product.ingredients.any((i) => i.toLowerCase().contains(normalizedQuery)) ||
          scan.tags.any((t) => t.toLowerCase().contains(normalizedQuery)) ||
          (scan.notes?.toLowerCase().contains(normalizedQuery) ?? false);
    }).toList();
  }
  
  @override
  Future<void> addScanHistoryItem({
    required String userId,
    required ScanHistoryItem item,
  }) async {
    final userHistory = _scanHistoryData[userId] ?? [];
    userHistory.add(item);
    _scanHistoryData[userId] = userHistory;
    return Future.value();
  }
  
  @override
  Future<void> toggleFavoriteStatus({
    required String userId,
    required String id,
    required bool isFavorite,
  }) async {
    final userHistory = _scanHistoryData[userId] ?? [];
    final itemIndex = userHistory.indexWhere((item) => item.id == id);
    
    if (itemIndex >= 0) {
      final item = userHistory[itemIndex];
      final updatedItem = item.copyWith(isFavorite: isFavorite);
      userHistory[itemIndex] = updatedItem;
      _scanHistoryData[userId] = userHistory;
    }
    
    return Future.value();
  }
  
  @override
  Future<List<FavoriteProduct>> getFavoriteProducts(String userId) async {
    return Future.value(_favoritesData[userId] ?? []);
  }
  
  @override
  Future<List<FavoriteCategory>> getFavoriteCategories(String userId) async {
    return Future.value(_categoriesData[userId] ?? DefaultCategories.getAll());
  }
  
  @override
  Future<List<FavoriteProduct>> getProductsByCategory({
    required String userId,
    required String categoryId,
  }) async {
    final allFavorites = _favoritesData[userId] ?? [];
    
    return Future.value(
      allFavorites.where((fav) => fav.categoryIds.contains(categoryId)).toList(),
    );
  }
  
  @override
  Future<void> addFavoriteProduct({
    required String userId,
    required FavoriteProduct product,
  }) async {
    final userFavorites = _favoritesData[userId] ?? [];
    
    // Check if product already exists
    final existingIndex = userFavorites.indexWhere((p) => p.id == product.id);
    
    if (existingIndex >= 0) {
      // Update existing product
      userFavorites[existingIndex] = product;
    } else {
      // Add new product
      userFavorites.add(product);
    }
    
    _favoritesData[userId] = userFavorites;
    return Future.value();
  }
}