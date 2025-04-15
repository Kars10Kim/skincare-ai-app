import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/scan_error.dart';
import '../../domain/entities/scan_history_item.dart';

/// State for product recognition screen
class ProductRecognitionState extends Equatable {
  /// Is loading
  final bool isLoading;
  
  /// Detected barcode
  final String? barcode;
  
  /// Current image
  final XFile? image;
  
  /// Extracted text from image
  final String? extractedText;
  
  /// Extracted ingredients
  final List<String>? extractedIngredients;
  
  /// Scan result
  final ScanHistoryItem? scan;
  
  /// Detected conflicts
  final List<String>? conflicts;
  
  /// Error
  final ScanError? error;
  
  /// Last successful action
  final String? lastAction;
  
  /// Create product recognition state
  const ProductRecognitionState({
    this.isLoading = false,
    this.barcode,
    this.image,
    this.extractedText,
    this.extractedIngredients,
    this.scan,
    this.conflicts,
    this.error,
    this.lastAction,
  });
  
  /// Initial state
  factory ProductRecognitionState.initial() {
    return const ProductRecognitionState();
  }
  
  /// Loading state
  factory ProductRecognitionState.loading() {
    return const ProductRecognitionState(isLoading: true);
  }
  
  /// Error state
  factory ProductRecognitionState.error(ScanError error, {String? lastAction}) {
    return ProductRecognitionState(
      error: error,
      lastAction: lastAction,
    );
  }
  
  /// Copy with new values
  ProductRecognitionState copyWith({
    bool? isLoading,
    String? barcode,
    XFile? image,
    String? extractedText,
    List<String>? extractedIngredients,
    ScanHistoryItem? scan,
    List<String>? conflicts,
    ScanError? error,
    String? lastAction,
  }) {
    return ProductRecognitionState(
      isLoading: isLoading ?? this.isLoading,
      barcode: barcode ?? this.barcode,
      image: image ?? this.image,
      extractedText: extractedText ?? this.extractedText,
      extractedIngredients: extractedIngredients ?? this.extractedIngredients,
      scan: scan ?? this.scan,
      conflicts: conflicts ?? this.conflicts,
      error: error,
      lastAction: lastAction ?? this.lastAction,
    );
  }
  
  /// Clear error
  ProductRecognitionState clearError() {
    return copyWith(error: null);
  }
  
  @override
  List<Object?> get props => [
    isLoading,
    barcode,
    image,
    extractedText,
    extractedIngredients,
    scan,
    conflicts,
    error,
    lastAction,
  ];
}