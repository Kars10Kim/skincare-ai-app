import '../../domain/entities/favorite_product.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/local_history_datasource.dart';

/// Favorites repository implementation
class FavoritesRepositoryImpl implements FavoritesRepository {
  /// Local data source
  final LocalHistoryDataSource localDataSource;
  
  /// Create favorites repository implementation
  const FavoritesRepositoryImpl({required this.localDataSource});
  
  @override
  Future<List<FavoriteProduct>> getFavorites() async {
    return await localDataSource.getFavorites();
  }
  
  @override
  Future<List<FavoriteProduct>> getFavoritesByCategory(FavoriteCategory category) async {
    return await localDataSource.getFavoritesByCategory(category);
  }
  
  @override
  Future<FavoriteProduct> addToFavorites(FavoriteProduct favorite) async {
    return await localDataSource.addToFavorites(favorite);
  }
  
  @override
  Future<void> removeFromFavorites(String favoriteId) async {
    await localDataSource.removeFromFavorites(favoriteId);
  }
  
  @override
  Future<FavoriteProduct> updateFavoriteCategory(String favoriteId, FavoriteCategory category) async {
    return await localDataSource.updateFavoriteCategory(favoriteId, category);
  }
  
  @override
  Future<FavoriteProduct> updateFavoriteNotes(String favoriteId, String? notes) async {
    return await localDataSource.updateFavoriteNotes(favoriteId, notes);
  }
  
  @override
  Future<FavoriteProduct> addTagsToFavorite(String favoriteId, List<String> tags) async {
    // This would require extending the data source, but for now we'll
    // get the favorite, add the tags, and then update it
    final favorites = await localDataSource.getFavorites();
    final favorite = favorites.firstWhere((f) => f.id == favoriteId);
    
    final updatedTags = [...favorite.tags, ...tags].toSet().toList();
    final updatedFavorite = favorite.copyWith(tags: updatedTags);
    
    return await localDataSource.addToFavorites(updatedFavorite);
  }
  
  @override
  Future<FavoriteProduct> removeTagFromFavorite(String favoriteId, String tag) async {
    // This would require extending the data source, but for now we'll
    // get the favorite, remove the tag, and then update it
    final favorites = await localDataSource.getFavorites();
    final favorite = favorites.firstWhere((f) => f.id == favoriteId);
    
    final updatedTags = favorite.tags.where((t) => t != tag).toList();
    final updatedFavorite = favorite.copyWith(tags: updatedTags);
    
    return await localDataSource.addToFavorites(updatedFavorite);
  }
}