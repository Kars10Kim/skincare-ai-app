import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Represents the result of a recognition operation
/// This could be either from a barcode scan or ML vision recognition
class RecognitionResult extends Equatable {
  /// Whether the recognition was successful
  final bool success;
  
  /// The error message if the recognition failed
  final String? errorMessage;
  
  /// The recognized product if the recognition was successful
  final RecognizedProduct? product;
  
  /// Create a recognition result
  const RecognitionResult({
    required this.success,
    this.errorMessage,
    this.product,
  });
  
  /// Create a success result
  factory RecognitionResult.success(RecognizedProduct product) {
    return RecognitionResult(
      success: true,
      product: product,
    );
  }
  
  /// Create a failure result
  factory RecognitionResult.failure(String message) {
    return RecognitionResult(
      success: false,
      errorMessage: message,
    );
  }
  
  @override
  List<Object?> get props => [success, errorMessage, product];
}

/// Represents a recognized product
class RecognizedProduct extends Equatable {
  /// The product ID (barcode or internal ID)
  final String id;
  
  /// The product name
  final String name;
  
  /// The product brand
  final String? brand;
  
  /// The product description
  final String? description;
  
  /// The product image URL
  final String? imageUrl;
  
  /// The product ingredients
  final List<String> ingredients;
  
  /// The recognition method used to identify this product
  final RecognitionMethod recognitionMethod;
  
  /// The confidence score of the recognition (0.0 - 1.0)
  final double confidenceScore;
  
  /// Create a recognized product
  const RecognizedProduct({
    required this.id,
    required this.name,
    this.brand,
    this.description,
    this.imageUrl,
    required this.ingredients,
    required this.recognitionMethod,
    required this.confidenceScore,
  });
  
  /// Create a recognized product from a barcode result
  factory RecognizedProduct.fromBarcode({
    required String barcode,
    required String name,
    String? brand,
    String? description,
    String? imageUrl,
    required List<String> ingredients,
  }) {
    return RecognizedProduct(
      id: barcode,
      name: name,
      brand: brand,
      description: description,
      imageUrl: imageUrl,
      ingredients: ingredients,
      recognitionMethod: RecognitionMethod.barcode,
      confidenceScore: 1.0, // Barcode matches are exact
    );
  }
  
  /// Create a recognized product from ML recognition
  factory RecognizedProduct.fromMLVision({
    required String id,
    required String name,
    String? brand,
    String? description,
    String? imageUrl,
    required List<String> ingredients,
    required double confidenceScore,
  }) {
    return RecognizedProduct(
      id: id,
      name: name,
      brand: brand,
      description: description,
      imageUrl: imageUrl,
      ingredients: ingredients,
      recognitionMethod: RecognitionMethod.mlVision,
      confidenceScore: confidenceScore,
    );
  }
  
  /// Create a copy of this product with the given fields replaced
  RecognizedProduct copyWith({
    String? id,
    String? name,
    String? brand,
    String? description,
    String? imageUrl,
    List<String>? ingredients,
    RecognitionMethod? recognitionMethod,
    double? confidenceScore,
  }) {
    return RecognizedProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      recognitionMethod: recognitionMethod ?? this.recognitionMethod,
      confidenceScore: confidenceScore ?? this.confidenceScore,
    );
  }
  
  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'recognitionMethod': recognitionMethod.toString(),
      'confidenceScore': confidenceScore,
    };
  }
  
  /// Create from a map
  factory RecognizedProduct.fromMap(Map<String, dynamic> map) {
    return RecognizedProduct(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String?,
      description: map['description'] as String?,
      imageUrl: map['imageUrl'] as String?,
      ingredients: List<String>.from(map['ingredients'] as List),
      recognitionMethod: RecognitionMethod.values.firstWhere(
        (method) => method.toString() == map['recognitionMethod'],
        orElse: () => RecognitionMethod.unknown,
      ),
      confidenceScore: map['confidenceScore'] as double,
    );
  }
  
  /// Convert to JSON
  String toJson() => json.encode(toMap());
  
  /// Create from JSON
  factory RecognizedProduct.fromJson(String source) => 
      RecognizedProduct.fromMap(json.decode(source) as Map<String, dynamic>);
      
  @override
  List<Object?> get props => [
    id,
    name,
    brand,
    description,
    imageUrl,
    ingredients,
    recognitionMethod,
    confidenceScore,
  ];
  
  /// Create a debug string representation
  @override
  String toString() {
    return 'RecognizedProduct(id: $id, name: $name, brand: $brand, '
        'recognitionMethod: $recognitionMethod, '
        'confidenceScore: $confidenceScore)';
  }
}

/// The method used to recognize a product
enum RecognitionMethod {
  /// Recognized using a barcode scan
  barcode,
  
  /// Recognized using ML vision (text recognition)
  mlVision,
  
  /// Recognized using a combination of methods
  hybrid,
  
  /// Recognized using an unknown method
  unknown
}

/// Result of a barcode scan operation
class BarcodeResult extends Equatable {
  /// The raw barcode value
  final String? rawValue;
  
  /// The barcode format
  final String? format;
  
  /// Whether the barcode is valid
  final bool isValid;
  
  /// Create a barcode result
  const BarcodeResult({
    this.rawValue,
    this.format,
    required this.isValid,
  });
  
  /// Create a valid barcode result
  factory BarcodeResult.valid(String value, [String? format]) {
    return BarcodeResult(
      rawValue: value,
      format: format,
      isValid: true,
    );
  }
  
  /// Create an invalid barcode result
  factory BarcodeResult.invalid() {
    return const BarcodeResult(
      isValid: false,
    );
  }
  
  @override
  List<Object?> get props => [rawValue, format, isValid];
}

/// Result of an ML recognition operation
class MLRecognitionResult extends Equatable {
  /// The probable product matches
  final List<RecognizedProduct> probableMatches;
  
  /// Whether any matches were found
  bool get hasMatches => probableMatches.isNotEmpty;
  
  /// Get the best match
  RecognizedProduct? get bestMatch => 
      hasMatches ? probableMatches.first : null;
  
  /// Create an ML recognition result
  const MLRecognitionResult({
    required this.probableMatches,
  });
  
  /// Create an empty result
  factory MLRecognitionResult.empty() {
    return const MLRecognitionResult(probableMatches: []);
  }
  
  @override
  List<Object?> get props => [probableMatches];
}