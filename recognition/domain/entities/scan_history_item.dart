import 'package:uuid/uuid.dart';

/// Source of the scan
enum ScanSource {
  /// Barcode scan
  barcode,
  
  /// Manual ingredient entry
  manual,
  
  /// OCR from image
  imageCaptured,
  
  /// Text recognition
  textRecognition,
  
  /// Search result
  search,
}

/// Scan history item
class ScanHistoryItem {
  /// Scan ID
  final String id;
  
  /// Product name
  final String? productName;
  
  /// Product brand
  final String? brand;
  
  /// Product barcode
  final String? barcode;
  
  /// Product image path
  final String? imagePath;
  
  /// Raw ingredients text
  final String? rawIngredientsText;
  
  /// Parsed ingredients list
  final List<String> ingredients;
  
  /// Source of scan
  final ScanSource source;
  
  /// Timestamp of scan
  final DateTime timestamp;
  
  /// Whether the scan has been analyzed
  final bool isAnalyzed;
  
  /// Create scan history item
  ScanHistoryItem({
    String? id,
    this.productName,
    this.brand,
    this.barcode,
    this.imagePath,
    this.rawIngredientsText,
    required this.ingredients,
    required this.source,
    DateTime? timestamp,
    this.isAnalyzed = false,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();
  
  /// Create copy of scan history item with modified fields
  ScanHistoryItem copyWith({
    String? id,
    String? productName,
    String? brand,
    String? barcode,
    String? imagePath,
    String? rawIngredientsText,
    List<String>? ingredients,
    ScanSource? source,
    DateTime? timestamp,
    bool? isAnalyzed,
  }) {
    return ScanHistoryItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      imagePath: imagePath ?? this.imagePath,
      rawIngredientsText: rawIngredientsText ?? this.rawIngredientsText,
      ingredients: ingredients ?? this.ingredients,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
      isAnalyzed: isAnalyzed ?? this.isAnalyzed,
    );
  }
  
  /// Check if scan has a barcode
  bool get hasBarcode => barcode != null && barcode!.isNotEmpty;
  
  /// Check if scan has an image
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  
  /// Get display name (product name or "Unknown Product")
  String get displayName => productName ?? 'Unknown Product';
  
  /// Get ingredient count
  int get ingredientCount => ingredients.length;
  
  /// Get source as string
  String getSourceText() {
    switch (source) {
      case ScanSource.barcode:
        return 'Barcode Scan';
      case ScanSource.manual:
        return 'Manual Entry';
      case ScanSource.imageCaptured:
        return 'Image Scan';
      case ScanSource.textRecognition:
        return 'Text Recognition';
      case ScanSource.search:
        return 'Search Result';
    }
  }
}