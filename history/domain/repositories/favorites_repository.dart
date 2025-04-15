import '../entities/favorite_product.dart';

/// Favorites repository interface
abstract class FavoritesRepository {
  /// Get all favorite products
  Future<List<FavoriteProduct>> getFavorites();
  
  /// Get favorites by category
  Future<List<FavoriteProduct>> getFavoritesByCategory(FavoriteCategory category);
  
  /// Add a product to favorites
  Future<FavoriteProduct> addToFavorites(FavoriteProduct favorite);
  
  /// Remove a product from favorites
  Future<void> removeFromFavorites(String favoriteId);
  
  /// Update favorite category
  Future<FavoriteProduct> updateFavoriteCategory(String favoriteId, FavoriteCategory category);
  
  /// Update favorite notes
  Future<FavoriteProduct> updateFavoriteNotes(String favoriteId, String? notes);
  
  /// Add tags to a favorite
  Future<FavoriteProduct> addTagsToFavorite(String favoriteId, List<String> tags);
  
  /// Remove a tag from a favorite
  Future<FavoriteProduct> removeTagFromFavorite(String favoriteId, String tag);
}