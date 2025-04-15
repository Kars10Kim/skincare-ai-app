import '../entities/favorite_product.dart';
import '../repositories/favorites_repository.dart';

/// Add favorite use case
class AddFavoriteUseCase {
  /// Favorites repository
  final FavoritesRepository repository;
  
  /// Create add favorite use case
  const AddFavoriteUseCase({required this.repository});
  
  /// Execute use case
  Future<FavoriteProduct> call(FavoriteProduct favorite) async {
    return await repository.addToFavorites(favorite);
  }
}