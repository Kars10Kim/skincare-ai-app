import '../repositories/favorites_repository.dart';

/// Remove favorite use case
class RemoveFavoriteUseCase {
  /// Favorites repository
  final FavoritesRepository repository;
  
  /// Create remove favorite use case
  const RemoveFavoriteUseCase({required this.repository});
  
  /// Execute use case
  Future<void> call(String favoriteId) async {
    return await repository.removeFromFavorites(favoriteId);
  }
}