import '../conflict/conflict_model.dart';

/// Model for a skincare product
class Product {
  /// Unique identifier for the product
  final String id;
  
  /// Barcode identifier for the product
  final String barcode;
  
  /// Name of the product
  final String name;
  
  /// Brand of the product
  final String brand;
  
  /// List of ingredients
  final List<String> ingredients;
  
  /// List of identified conflicts
  final List<Conflict> conflicts;
  
  /// Product safety score (0-100)
  final int safetyScore;
  
  /// Product image URL
  final String? imageUrl;
  
  /// Product description
  final String? description;
  
  /// Product category
  final String? category;
  
  /// Product subcategory
  final String? subcategory;
  
  /// Average rating (0-5)
  final double? rating;
  
  /// Number of ratings
  final int? ratingCount;
  
  /// Product price
  final double? price;
  
  /// Price currency
  final String? currency;
  
  /// Size/volume of the product
  final String? size;
  
  /// Whether the product is discontinued
  final bool isDiscontinued;
  
  /// Data source for this product
  final String? source;
  
  /// When the product data was last updated
  final DateTime? lastUpdated;
  
  /// Create a product
  const Product({
    required this.id,
    required this.barcode,
    required this.name,
    required this.brand,
    required this.ingredients,
    this.conflicts = const [],
    required this.safetyScore,
    this.imageUrl,
    this.description,
    this.category,
    this.subcategory,
    this.rating,
    this.ratingCount,
    this.price,
    this.currency,
    this.size,
    this.isDiscontinued = false,
    this.source,
    this.lastUpdated,
  });
  
  /// Create from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      ingredients: (json['ingredients'] as List).cast<String>(),
      conflicts: json['conflicts'] != null
          ? (json['conflicts'] as List)
              .map((c) => Conflict.fromJson(c as Map<String, dynamic>))
              .toList()
          : [],
      safetyScore: json['safetyScore'] as int,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
      rating: json['rating'] as double?,
      ratingCount: json['ratingCount'] as int?,
      price: json['price'] as double?,
      currency: json['currency'] as String?,
      size: json['size'] as String?,
      isDiscontinued: json['isDiscontinued'] as bool? ?? false,
      source: json['source'] as String?,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'ingredients': ingredients,
      'conflicts': conflicts.map((c) => c.toJson()).toList(),
      'safetyScore': safetyScore,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'rating': rating,
      'ratingCount': ratingCount,
      'price': price,
      'currency': currency,
      'size': size,
      'isDiscontinued': isDiscontinued,
      'source': source,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
  
  /// Create a copy with updated values
  Product copyWith({
    String? id,
    String? barcode,
    String? name,
    String? brand,
    List<String>? ingredients,
    List<Conflict>? conflicts,
    int? safetyScore,
    String? imageUrl,
    String? description,
    String? category,
    String? subcategory,
    double? rating,
    int? ratingCount,
    double? price,
    String? currency,
    String? size,
    bool? isDiscontinued,
    String? source,
    DateTime? lastUpdated,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      ingredients: ingredients ?? this.ingredients,
      conflicts: conflicts ?? this.conflicts,
      safetyScore: safetyScore ?? this.safetyScore,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      size: size ?? this.size,
      isDiscontinued: isDiscontinued ?? this.isDiscontinued,
      source: source ?? this.source,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}