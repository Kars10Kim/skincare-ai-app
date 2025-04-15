import 'package:equatable/equatable.dart';

import 'scan_history_item.dart';

/// Favorite category
enum FavoriteCategory {
  /// General favorites
  general,
  
  /// Moisturizers
  moisturizers,
  
  /// Cleansers
  cleansers,
  
  /// Serums
  serums,
  
  /// Sunscreens
  sunscreens,
  
  /// Treatments
  treatments,
  
  /// Other products
  other,
}

/// Extension for favorite category display names
extension FavoriteCategoryExtension on FavoriteCategory {
  /// Get display name
  String get displayName {
    switch (this) {
      case FavoriteCategory.general:
        return 'General';
      case FavoriteCategory.moisturizers:
        return 'Moisturizers';
      case FavoriteCategory.cleansers:
        return 'Cleansers';
      case FavoriteCategory.serums:
        return 'Serums';
      case FavoriteCategory.sunscreens:
        return 'Sunscreens';
      case FavoriteCategory.treatments:
        return 'Treatments';
      case FavoriteCategory.other:
        return 'Other';
    }
  }
  
  /// Get icon data name
  String get iconName {
    switch (this) {
      case FavoriteCategory.general:
        return 'favorite';
      case FavoriteCategory.moisturizers:
        return 'water_drop';
      case FavoriteCategory.cleansers:
        return 'wash';
      case FavoriteCategory.serums:
        return 'science';
      case FavoriteCategory.sunscreens:
        return 'wb_sunny';
      case FavoriteCategory.treatments:
        return 'healing';
      case FavoriteCategory.other:
        return 'category';
    }
  }
}

/// Favorite product model
class FavoriteProduct extends Equatable {
  /// Favorite id
  final String id;
  
  /// Related product
  final Product product;
  
  /// Timestamp when added to favorites
  final DateTime addedDate;
  
  /// Product category
  final FavoriteCategory category;
  
  /// Notes about the product
  final String? notes;
  
  /// Tags for the product
  final List<String> tags;
  
  /// Create favorite product
  const FavoriteProduct({
    required this.id,
    required this.product,
    required this.addedDate,
    this.category = FavoriteCategory.general,
    this.notes,
    this.tags = const [],
  });
  
  /// Copy with new values
  FavoriteProduct copyWith({
    String? id,
    Product? product,
    DateTime? addedDate,
    FavoriteCategory? category,
    String? notes,
    List<String>? tags,
  }) {
    return FavoriteProduct(
      id: id ?? this.id,
      product: product ?? this.product,
      addedDate: addedDate ?? this.addedDate,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    product,
    addedDate,
    category,
    notes,
    tags,
  ];
}