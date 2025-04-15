import '../../../history/presentation/cubit/favorites_state.dart';
import '../repositories/favorites_repository.dart';

/// Get favorite categories use case
class GetFavoriteCategories {
  /// Favorites repository
  final FavoritesRepository repository;
  
  /// Create get favorite categories use case
  GetFavoriteCategories(this.repository);
  
  /// Execute use case
  Future<List<FavoriteCategory>> call({required String userId}) {
    return repository.getFavoriteCategories(userId: userId);
  }
}