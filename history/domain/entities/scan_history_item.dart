import 'package:equatable/equatable.dart';

/// Product model
class Product extends Equatable {
  /// Product id
  final String id;
  
  /// Product name
  final String name;
  
  /// Product brand
  final String? brand;
  
  /// Product category
  final String? category;
  
  /// Product ingredients list
  final List<String> ingredients;
  
  /// Product barcode
  final String? barcode;
  
  /// Product image url
  final String? imageUrl;
  
  /// Create Product
  const Product({
    required this.id,
    required this.name,
    this.brand,
    this.category,
    required this.ingredients,
    this.barcode,
    this.imageUrl,
  });
  
  @override
  List<Object?> get props => [id, name, brand, category, ingredients, barcode, imageUrl];
}

/// Ingredient conflict model
class IngredientConflict extends Equatable {
  /// First ingredient name
  final String ingredient1;
  
  /// Second ingredient name
  final String ingredient2;
  
  /// Conflict severity (1-5)
  final int severity;
  
  /// Conflict description
  final String description;
  
  /// Scientific source
  final String? source;
  
  /// Create ingredient conflict
  const IngredientConflict({
    required this.ingredient1,
    required this.ingredient2,
    required this.severity,
    required this.description,
    this.source,
  });
  
  @override
  List<Object?> get props => [ingredient1, ingredient2, severity, description, source];
}

/// Scan history item type
enum ScanHistoryItemType {
  /// Scanned with camera
  camera,
  
  /// Scanned barcode
  barcode,
  
  /// Manually entered
  manual,
}

/// Scan history item model
class ScanHistoryItem extends Equatable {
  /// Scan item id
  final String id;
  
  /// Scanned product
  final Product product;
  
  /// Scan timestamp
  final DateTime timestamp;
  
  /// Scan type
  final ScanHistoryItemType scanType;
  
  /// Whether the product is favorited
  final bool isFavorite;
  
  /// List of detected ingredient conflicts
  final List<IngredientConflict> conflicts;
  
  /// Safety score (0-100)
  final int safetyScore;
  
  /// User notes
  final String? notes;
  
  /// User tags
  final List<String> tags;
  
  /// Highest conflict severity
  int get highestConflictSeverity {
    if (conflicts.isEmpty) return 0;
    return conflicts.map((c) => c.severity).reduce((a, b) => a > b ? a : b);
  }
  
  /// Create scan history item
  const ScanHistoryItem({
    required this.id,
    required this.product,
    required this.timestamp,
    required this.scanType,
    this.isFavorite = false,
    this.conflicts = const [],
    required this.safetyScore,
    this.notes,
    this.tags = const [],
  });
  
  /// Copy with new values
  ScanHistoryItem copyWith({
    String? id,
    Product? product,
    DateTime? timestamp,
    ScanHistoryItemType? scanType,
    bool? isFavorite,
    List<IngredientConflict>? conflicts,
    int? safetyScore,
    String? notes,
    List<String>? tags,
  }) {
    return ScanHistoryItem(
      id: id ?? this.id,
      product: product ?? this.product,
      timestamp: timestamp ?? this.timestamp,
      scanType: scanType ?? this.scanType,
      isFavorite: isFavorite ?? this.isFavorite,
      conflicts: conflicts ?? this.conflicts,
      safetyScore: safetyScore ?? this.safetyScore,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }
  
  @override
  List<Object?> get props => [
    id, 
    product, 
    timestamp, 
    scanType, 
    isFavorite, 
    conflicts, 
    safetyScore, 
    notes,
    tags,
  ];
}