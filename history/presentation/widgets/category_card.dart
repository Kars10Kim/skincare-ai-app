import 'package:flutter/material.dart';

import '../../domain/entities/favorite_product.dart';
import '../screens/favorites_screen.dart';

/// Category card widget
class CategoryCard extends StatelessWidget {
  /// Category
  final FavoriteCategory category;
  
  /// Callback when the card is tapped
  final VoidCallback onTap;
  
  /// Callback when the edit button is tapped
  final VoidCallback onEdit;
  
  /// Callback when the delete button is tapped
  final VoidCallback onDelete;
  
  /// Create category card
  const CategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = HexColor(category.color);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -20,
              right: -20,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: color.withOpacity(0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: color,
                        radius: 16,
                        child: const Icon(Icons.category, color: Colors.white, size: 16),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit();
                          } else if (value == 'delete') {
                            onDelete();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color.computeLuminance() > 0.5 ? Colors.black : color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.arrow_forward, size: 16),
                      const SizedBox(width: 4),
                      const Text('View Products'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}