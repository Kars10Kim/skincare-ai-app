import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/favorite_product.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';
import '../screens/favorites_screen.dart';

/// Favorite detail screen
class FavoriteDetailScreen extends StatefulWidget {
  /// Favorite product
  final FavoriteProduct favorite;
  
  /// Create favorite detail screen
  const FavoriteDetailScreen({
    Key? key,
    required this.favorite,
  }) : super(key: key);

  @override
  State<FavoriteDetailScreen> createState() => _FavoriteDetailScreenState();
}

class _FavoriteDetailScreenState extends State<FavoriteDetailScreen> {
  late final FavoritesCubit _favoritesCubit;
  late FavoriteProduct _favorite;
  
  @override
  void initState() {
    super.initState();
    _favoritesCubit = sl<FavoritesCubit>();
    _favorite = widget.favorite;
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _favoritesCubit,
      child: BlocListener<FavoritesCubit, FavoritesState>(
        listener: (context, state) {
          if (state is FavoritesOperationSuccess && state.product != null) {
            if (state.product!.id == _favorite.id) {
              setState(() {
                _favorite = state.product!;
              });
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is FavoritesOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Product Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_note),
                onPressed: _showEditNotesDialog,
              ),
              IconButton(
                icon: const Icon(Icons.category),
                onPressed: _showManageCategoriesDialog,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(context),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingSection(context),
                      const Divider(height: 32),
                      _buildDetailsSection(context),
                      const Divider(height: 32),
                      _buildIngredientsSection(context),
                      const Divider(height: 32),
                      _buildNotesSection(context),
                      const Divider(height: 32),
                      _buildCategoriesSection(context),
                      const Divider(height: 32),
                      _buildTagsSection(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      color: Colors.grey[200],
      child: _favorite.product.imageUrl != null
          ? Image.network(
              _favorite.product.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Image not available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No image available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildRatingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _favorite.product.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_favorite.product.brand != null) ...[
          const SizedBox(height: 4),
          Text(
            _favorite.product.brand!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Your Rating',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Text(
              _favorite.userRating != null
                  ? '${_favorite.userRating!.toStringAsFixed(1)}/5.0'
                  : 'Not rated',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RatingBar.builder(
          initialRating: _favorite.userRating ?? 0,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 40,
          unratedColor: Colors.grey[300],
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            _favoritesCubit.rateProduct(_favorite.id, rating);
          },
        ),
        const SizedBox(height: 16),
        if (_favorite.product.price != null) ...[
          Row(
            children: [
              Text(
                'Price',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '\$${_favorite.product.price!.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
  
  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildDetailItem(
          context,
          'Added to Favorites',
          _getTimeAgo(_favorite.addedAt),
          Icons.calendar_today,
        ),
        _buildDetailItem(
          context,
          'Last Updated',
          _getTimeAgo(_favorite.updatedAt),
          Icons.update,
        ),
        if (_favorite.product.size != null)
          _buildDetailItem(
            context,
            'Size',
            _favorite.product.size!,
            Icons.straighten,
          ),
        if (_favorite.product.type != null)
          _buildDetailItem(
            context,
            'Product Type',
            _favorite.product.type!,
            Icons.category,
          ),
        if (_favorite.product.skinType != null)
          _buildDetailItem(
            context,
            'Skin Type',
            _favorite.product.skinType!,
            Icons.face,
          ),
      ],
    );
  }
  
  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildIngredientsSection(BuildContext context) {
    final ingredients = _favorite.product.ingredients;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (ingredients.isEmpty)
          const Text('No ingredients information available.'),
        for (final ingredient in ingredients)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(ingredient),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildNotesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              onPressed: _showEditNotesDialog,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_favorite.notes == null || _favorite.notes!.isEmpty)
          Text(
            'No notes added yet. Tap "Edit" to add notes about this product.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_favorite.notes!),
          ),
      ],
    );
  }
  
  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Manage'),
              onPressed: _showManageCategoriesDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_favorite.categoryIds.isEmpty)
          Text(
            'Not added to any categories yet.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _favorite.categoryIds.map((categoryId) {
              // In a real app, get the category from a repository
              final category = _getDefaultCategoryById(categoryId);
              final color = HexColor(category.color);
              
              return Chip(
                label: Text(category.name),
                backgroundColor: color.withOpacity(0.1),
                side: BorderSide(color: color.withOpacity(0.5)),
                labelStyle: TextStyle(color: color),
                deleteIcon: Icon(
                  Icons.cancel,
                  size: 16,
                  color: color,
                ),
                onDeleted: () {
                  _favoritesCubit.removeProductFromCategory(_favorite.id, categoryId);
                },
              );
            }).toList(),
          ),
      ],
    );
  }
  
  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              onPressed: _showAddTagDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_favorite.tags.isEmpty)
          Text(
            'No tags added yet.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _favorite.tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.cancel, size: 16),
                onDeleted: () {
                  _favoritesCubit.removeTag(_favorite.id, tag);
                },
              );
            }).toList(),
          ),
      ],
    );
  }
  
  void _showEditNotesDialog() {
    final notesController = TextEditingController(text: _favorite.notes);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Notes'),
        content: TextField(
          controller: notesController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter notes about this product...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final notes = notesController.text.trim();
              _favoritesCubit.updateNotes(_favorite.id, notes.isEmpty ? null : notes);
              Navigator.of(context).pop();
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
  
  void _showAddTagDialog() {
    final tagController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: tagController,
              decoration: const InputDecoration(
                hintText: 'Enter a tag',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Tags',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _favorite.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.cancel, size: 16),
                  onDeleted: () {
                    _favoritesCubit.removeTag(_favorite.id, tag);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final tag = tagController.text.trim();
              if (tag.isNotEmpty) {
                _favoritesCubit.addTag(_favorite.id, tag);
                Navigator.of(context).pop();
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }
  
  void _showManageCategoriesDialog() {
    // In a real app, you would fetch categories from a repository
    // For simplicity, we'll use the default categories
    final categories = DefaultCategories.getAll();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Categories'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final category in categories)
              CheckboxListTile(
                title: Text(category.name),
                value: _favorite.categoryIds.contains(category.id),
                onChanged: (value) {
                  if (value == true) {
                    _favoritesCubit.addProductToCategory(_favorite.id, category.id);
                  } else {
                    _favoritesCubit.removeProductFromCategory(_favorite.id, category.id);
                  }
                  Navigator.of(context).pop();
                },
                secondary: CircleAvatar(
                  backgroundColor: HexColor(category.color),
                  radius: 12,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
  
  FavoriteCategory _getDefaultCategoryById(String categoryId) {
    // In a real app, you would look up the category by ID from a repository
    // For simplicity, we'll use a default category
    final defaultCategories = DefaultCategories.getAll();
    
    return defaultCategories.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => DefaultCategories.uncategorized,
    );
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}