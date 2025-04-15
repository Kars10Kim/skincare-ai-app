import 'dart:convert';
import 'product_model.dart';

/// Model for tracking product scans in the user's history
class ScanHistory {
  /// Unique identifier 
  final int? id;
  
  /// User ID to associate scan with a user
  final int? userId;
  
  /// Barcode of the scanned product
  final String productBarcode;
  
  /// Date and time when product was scanned
  final DateTime scanDate;
  
  /// Optional notes from the user
  final String? notes;
  
  /// Detected conflicts in JSON format
  final String? conflictsDetected;
  
  /// Whether user marked this as a favorite
  final bool favorite;
  
  /// Associated product data if available
  final Product? product;
  
  /// Constructor for creating scan history
  ScanHistory({
    this.id,
    this.userId,
    required this.productBarcode,
    required this.scanDate,
    this.notes,
    this.conflictsDetected,
    this.favorite = false,
    this.product,
  });
  
  /// Create scan history from JSON
  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    // Handle product if it's included in response (join)
    Product? product;
    if (json['product'] != null) {
      if (json['product'] is Map<String, dynamic>) {
        product = Product.fromJson(json['product']);
      }
    }
    
    return ScanHistory(
      id: json['id'],
      userId: json['userId'] ?? json['user_id'],
      productBarcode: json['productBarcode'] ?? json['product_barcode'],
      scanDate: json['scanDate'] != null || json['scan_date'] != null
          ? DateTime.parse(json['scanDate'] ?? json['scan_date'])
          : DateTime.now(),
      notes: json['notes'],
      conflictsDetected: json['conflictsDetected'] ?? json['conflicts_detected'],
      favorite: json['favorite'] ?? false,
      product: product,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      'productBarcode': productBarcode,
      'scanDate': scanDate.toIso8601String(),
      if (notes != null) 'notes': notes,
      if (conflictsDetected != null) 'conflictsDetected': conflictsDetected,
      'favorite': favorite,
    };
  }
  
  /// Get parsed conflicts if available
  Map<String, dynamic>? get conflicts {
    if (conflictsDetected == null || conflictsDetected!.isEmpty) {
      return null;
    }
    
    try {
      return json.decode(conflictsDetected!) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing conflicts: $e');
      return null;
    }
  }
  
  /// Creates a copy with modified fields
  ScanHistory copyWith({
    int? id,
    int? userId,
    String? productBarcode,
    DateTime? scanDate,
    String? notes,
    String? conflictsDetected,
    bool? favorite,
    Product? product,
  }) {
    return ScanHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productBarcode: productBarcode ?? this.productBarcode,
      scanDate: scanDate ?? this.scanDate,
      notes: notes ?? this.notes,
      conflictsDetected: conflictsDetected ?? this.conflictsDetected,
      favorite: favorite ?? this.favorite,
      product: product ?? this.product,
    );
  }
}