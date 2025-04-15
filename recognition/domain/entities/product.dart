import 'package:equatable/equatable.dart';

/// Product
class Product extends Equatable {
  /// Product name
  final String name;
  
  /// Product brand (optional)
  final String? brand;
  
  /// Product barcode (optional)
  final String? barcode;
  
  /// Product image URL (optional)
  final String? imageUrl;
  
  /// Product ingredients
  final List<String> ingredients;
  
  /// Product price (optional)
  final double? price;
  
  /// Product size/volume (optional)
  final String? size;
  
  /// Product type (optional, e.g. "cleanser", "moisturizer")
  final String? type;
  
  /// Suitable skin types (optional)
  final String? skinType;
  
  /// Create product
  const Product({
    required this.name,
    this.brand,
    this.barcode,
    this.imageUrl,
    required this.ingredients,
    this.price,
    this.size,
    this.type,
    this.skinType,
  });
  
  @override
  List<Object?> get props => [
    name,
    brand,
    barcode,
    imageUrl,
    ingredients,
    price,
    size,
    type,
    skinType,
  ];
  
  /// Create copy with modified fields
  Product copyWith({
    String? name,
    String? brand,
    String? barcode,
    String? imageUrl,
    List<String>? ingredients,
    double? price,
    String? size,
    String? type,
    String? skinType,
  }) {
    return Product(
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      price: price ?? this.price,
      size: size ?? this.size,
      type: type ?? this.type,
      skinType: skinType ?? this.skinType,
    );
  }
}