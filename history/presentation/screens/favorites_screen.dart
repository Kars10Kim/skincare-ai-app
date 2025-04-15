import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/favorite_product.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';
import '../widgets/empty_state.dart';
import 'favorite_detail_screen.dart';

/// Favorites screen
class FavoritesScreen extends StatefulWidget {
  /// Create favorites screen
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoritesCubit _favoritesCubit;
  
  @override
  void initState() {
    super.initState();
    _favoritesCubit = sl<FavoritesCubit>();
    _favoritesCubit.loadFavorites();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _favoritesCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearchDialog,
            ),
          ],
        ),
        body: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesInitial || state is FavoritesLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is FavoritesError) {
              return Center(
                child: Text(state.message),
              );
            } else if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.favorite_border,
                  title: 'No Favorites Yet',
                  message: 'Products you add to favorites will appear here. '
                      'Favorite products by tapping the heart icon when viewing a product.',
                );
              }
              
              return Column(
                children: [
                  _buildCategoryTabs(context, state),
                  Expanded(
                    child: _buildFavoritesList(context, state),
                  ),
                ],
              );
            }
            
            return const Center(
              child: Text('Unknown state'),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildCategoryTabs(BuildContext context, FavoritesLoaded state) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.categories.length + 1, // +1 for 'All' tab
        itemBuilder: (context, index) {
          // First tab is "All"
          if (index == 0) {
            return _buildCategoryTab(
              context,
              'All',
              null,
              state.selectedCategoryId == null,
            );
          }
          
          // Other tabs are categories
          final category = state.categories[index - 1];
          return _buildCategoryTab(
            context,
            category.name,
            category.id,
            state.selectedCategoryId == category.id,
            HexColor(category.color),
          );
        },
      ),
    );
  }
  
  Widget _buildCategoryTab(
    BuildContext context,
    String name,
    String? categoryId,
    bool isSelected, [
    Color? color,
  ]) {
    return GestureDetector(
      onTap: () => _favoritesCubit.selectCategory(categoryId),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? Theme.of(context).primaryColor).withOpacity(0.1)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? Theme.of(context).primaryColor).withOpacity(0.5)
                : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              color: isSelected
                  ? (color ?? Theme.of(context).primaryColor)
                  : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFavoritesList(BuildContext context, FavoritesLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.favorites.length,
      itemBuilder: (context, index) {
        final favorite = state.favorites[index];
        return _buildFavoriteCard(context, favorite);
      },
    );
  }
  
  Widget _buildFavoriteCard(BuildContext context, FavoriteProduct favorite) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToDetail(context, favorite),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: favorite.product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          favorite.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey[400],
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.grey[400],
                      ),
              ),
              const SizedBox(width: 16),
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorite.product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (favorite.product.brand != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        favorite.product.brand!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final rating = favorite.userRating ?? 0;
                          return Icon(
                            index < rating.floor()
                                ? Icons.star
                                : (index < rating && index >= rating.floor())
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          favorite.userRating != null
                              ? favorite.userRating!.toStringAsFixed(1)
                              : 'Not rated',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Categories
                    SizedBox(
                      height: 24,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...favorite.categoryIds.map((categoryId) {
                            // Find category from its ID
                            final category = _getCategoryById(categoryId);
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: HexColor(category.color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: HexColor(category.color).withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: HexColor(category.color),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_note),
                    onPressed: () => _navigateToDetail(context, favorite),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _showDeleteConfirmation(context, favorite),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  FavoriteCategory _getCategoryById(String categoryId) {
    if (_favoritesCubit.state is FavoritesLoaded) {
      final state = _favoritesCubit.state as FavoritesLoaded;
      final category = state.categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => DefaultCategories.uncategorized,
      );
      return category;
    }
    return DefaultCategories.uncategorized;
  }
  
  void _navigateToDetail(BuildContext context, FavoriteProduct favorite) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FavoriteDetailScreen(favorite: favorite),
      ),
    );
  }
  
  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final controller = TextEditingController();
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Favorites',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Product name, brand, ingredient, etc.',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => controller.clear(),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _favoritesCubit.searchFavorites(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search Tips',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    TextButton(
                      onPressed: () {
                        final value = controller.text.trim();
                        if (value.isNotEmpty) {
                          _favoritesCubit.searchFavorites(value);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('SEARCH'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSearchTip('Moisturizer', () {
                      controller.text = 'Moisturizer';
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }),
                    _buildSearchTip('CeraVe', () {
                      controller.text = 'CeraVe';
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }),
                    _buildSearchTip('Hyaluronic Acid', () {
                      controller.text = 'Hyaluronic Acid';
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }),
                    _buildSearchTip('5-star', () {
                      controller.text = '5-star';
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSearchTip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, FavoriteProduct favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Favorites?'),
        content: Text(
          'Are you sure you want to remove "${favorite.product.name}" from your favorites?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              _favoritesCubit.removeFromFavorites(favorite.id);
              Navigator.of(context).pop();
            },
            child: const Text('REMOVE'),
          ),
        ],
      ),
    );
  }
}