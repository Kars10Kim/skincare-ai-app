/// Product model representing a skincare product
class Product {
  /// Unique identifier for the product (could be a barcode)
  final String id;
  
  /// Product name
  final String name;
  
  /// Brand name
  final String brand;
  
  /// URL to the product image (may be null)
  final String? imageUrl;
  
  /// List of ingredients
  final List<String> ingredients;
  
  /// Safety score (0-100)
  final int safetyScore;
  
  /// Create a product
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    this.imageUrl,
    required this.ingredients,
    required this.safetyScore,
  });
  
  /// Create a product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      imageUrl: json['imageUrl'] as String?,
      ingredients: List<String>.from(json['ingredients'] as List),
      safetyScore: json['safetyScore'] as int,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'safetyScore': safetyScore,
    };
  }
}