/// Model representing a skincare product
class Product {
  /// Product barcode
  final String barcode;
  
  /// Product name
  final String name;
  
  /// Product ingredients
  final List<String> ingredients;
  
  /// Product brand (optional)
  final String? brand;
  
  /// Product image URL (optional)
  final String? imageUrl;
  
  /// Creates a product model
  const Product({
    required this.barcode,
    required this.name,
    required this.ingredients,
    this.brand,
    this.imageUrl,
  });
  
  /// Creates a copy of this product with the given fields replaced
  Product copyWith({
    String? barcode,
    String? name,
    List<String>? ingredients,
    String? brand,
    String? imageUrl,
  }) {
    return Product(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
  
  /// Creates a product from a JSON map
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      brand: json['brand'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
  
  /// Converts product to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'ingredients': ingredients,
      'brand': brand,
      'imageUrl': imageUrl,
    };
  }
  
  @override
  String toString() {
    return 'Product(barcode: $barcode, name: $name, ingredients: ${ingredients.length} items)';
  }
}