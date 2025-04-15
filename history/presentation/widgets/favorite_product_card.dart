import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../domain/entities/favorite_product.dart';
import '../screens/favorites_screen.dart';

/// Favorite product card
class FavoriteProductCard extends StatelessWidget {
  /// Favorite product
  final FavoriteProduct favorite;
  
  /// Category (optional, if viewing within a category)
  final FavoriteCategory? category;
  
  /// Callback when the card is tapped
  final VoidCallback onTap;
  
  /// Callback when the product is rated
  final void Function(double) onRate;
  
  /// Callback when a tag is added
  final void Function(String) onAddTag;
  
  /// Callback when a tag is removed
  final void Function(String) onRemoveTag;
  
  /// Callback when notes are updated
  final void Function(String?) onUpdateNotes;
  
  /// Callback when the product is added to a category
  final void Function(String) onAddToCategory;
  
  /// Callback when the product is removed from a category
  final void Function(String) onRemoveFromCategory;
  
  /// Create favorite product card
  const FavoriteProductCard({
    Key? key,
    required this.favorite,
    this.category,
    required this.onTap,
    required this.onRate,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onUpdateNotes,
    required this.onAddToCategory,
    required this.onRemoveFromCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(context),
                  const SizedBox(height: 12),
                  _buildRating(context),
                  const SizedBox(height: 12),
                  if (favorite.notes != null && favorite.notes!.isNotEmpty) ...[
                    _buildNotes(context),
                    const SizedBox(height: 12),
                  ],
                  _buildCategories(context),
                  const SizedBox(height: 12),
                  _buildFooter(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    // If in a category view, use the category color
    final color = category != null 
        ? HexColor(category!.color)
        : Theme.of(context).primaryColor;
    
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Added ${_getTimeAgo(favorite.addedAt)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit_notes') {
                _showEditNotesDialog(context);
              } else if (value == 'add_tag') {
                _showAddTagDialog(context);
              } else if (value == 'add_to_category') {
                _showAddToCategoryDialog(context);
              } else if (value == 'remove_from_category' && category != null) {
                onRemoveFromCategory(category!.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit_notes',
                child: Row(
                  children: [
                    Icon(Icons.note_add),
                    SizedBox(width: 8),
                    Text('Edit Notes'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_tag',
                child: Row(
                  children: [
                    Icon(Icons.tag),
                    SizedBox(width: 8),
                    Text('Add Tag'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_to_category',
                child: Row(
                  children: [
                    Icon(Icons.category),
                    SizedBox(width: 8),
                    Text('Add to Category'),
                  ],
                ),
              ),
              if (category != null)
                PopupMenuItem(
                  value: 'remove_from_category',
                  child: Row(
                    children: [
                      const Icon(Icons.remove_circle),
                      const SizedBox(width: 8),
                      Text('Remove from ${category!.name}'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProductInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (favorite.product.imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              favorite.product.imageUrl!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                favorite.product.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (favorite.product.brand != null) ...[
                const SizedBox(height: 4),
                Text(
                  favorite.product.brand!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              if (favorite.product.price != null) ...[
                Text(
                  '\$${favorite.product.price!.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRating(BuildContext context) {
    return Row(
      children: [
        RatingBar.builder(
          initialRating: favorite.userRating ?? 0,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 24,
          unratedColor: Colors.grey[300],
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: onRate,
        ),
        const SizedBox(width: 8),
        Text(
          favorite.userRating != null
              ? favorite.userRating!.toStringAsFixed(1)
              : 'Not rated',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
  
  Widget _buildNotes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.note, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                'Notes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            favorite.notes!,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategories(BuildContext context) {
    if (favorite.categoryIds.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final categoryId in favorite.categoryIds)
          _buildCategoryChip(context, categoryId),
      ],
    );
  }
  
  Widget _buildCategoryChip(BuildContext context, String categoryId) {
    // In a real app, you would look up the category by ID from a repository
    // For simplicity, we'll use a default category if not provided
    final chipCategory = category != null && category!.id == categoryId
        ? category!
        : _getDefaultCategoryById(categoryId);
    
    final color = HexColor(chipCategory.color);
    
    return Chip(
      label: Text(chipCategory.name),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.5)),
      labelStyle: TextStyle(color: color),
      deleteIcon: Icon(
        Icons.cancel,
        size: 16,
        color: color,
      ),
      onDeleted: () => onRemoveFromCategory(categoryId),
    );
  }
  
  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        if (favorite.tags.isNotEmpty) ...[
          const Icon(Icons.tag, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: favorite.tags.map((tag) {
                return Chip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Text(tag),
                  labelStyle: const TextStyle(fontSize: 12),
                  deleteIcon: const Icon(Icons.cancel, size: 12),
                  onDeleted: () => onRemoveTag(tag),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ),
        ] else ...[
          const Spacer(),
        ],
        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ],
    );
  }
  
  void _showEditNotesDialog(BuildContext context) {
    final notesController = TextEditingController(text: favorite.notes);
    
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
              onUpdateNotes(notes.isEmpty ? null : notes);
              Navigator.of(context).pop();
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
  
  void _showAddTagDialog(BuildContext context) {
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
              children: favorite.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.cancel, size: 16),
                  onDeleted: () {
                    onRemoveTag(tag);
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
                onAddTag(tag);
                Navigator.of(context).pop();
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }
  
  void _showAddToCategoryDialog(BuildContext context) {
    // In a real app, you would fetch categories from a repository
    // For simplicity, we'll use the default categories
    final categories = DefaultCategories.getAll();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final category in categories)
              CheckboxListTile(
                title: Text(category.name),
                value: favorite.categoryIds.contains(category.id),
                onChanged: (value) {
                  if (value == true) {
                    onAddToCategory(category.id);
                  } else {
                    onRemoveFromCategory(category.id);
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