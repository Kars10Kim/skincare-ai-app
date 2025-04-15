import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../utils/exceptions.dart';
import '../entities/recognized_product.dart';

/// Repository for product recognition
abstract class ProductRepository {
  /// Current state of the repository
  ProductRecognitionState get state;
  
  /// Stream of state changes
  Stream<ProductRecognitionState> get stateStream;
  
  /// Recognize a product from an image using the most reliable method
  Future<RecognitionResult> recognizeProduct(File image);
  
  /// Recognize a product from a barcode image
  Future<RecognitionResult> recognizeFromBarcode(File image);
  
  /// Recognize a product from ingredient text in an image
  Future<RecognitionResult> recognizeFromIngredients(File image);
  
  /// Get a product by barcode from the database
  Future<RecognizedProduct?> getProductByBarcode(String barcode);
  
  /// Retry the last failed recognition
  Future<RecognitionResult> retryLastRecognition();
  
  /// Clear the current recognition state
  void clearRecognition();
  
  /// Dispose resources
  void dispose();
}

/// State of product recognition
class ProductRecognitionState {
  /// Whether recognition is in progress
  final bool isRecognizing;
  
  /// Last recognition result
  final RecognitionResult? lastResult;
  
  /// Last recognition error
  final RecognitionException? error;
  
  /// Last image processed
  final File? lastImage;
  
  /// Create a product recognition state
  const ProductRecognitionState({
    this.isRecognizing = false,
    this.lastResult,
    this.error,
    this.lastImage,
  });
  
  /// Create an initial state
  factory ProductRecognitionState.initial() {
    return const ProductRecognitionState();
  }
  
  /// Create a loading state
  factory ProductRecognitionState.loading(File image) {
    return ProductRecognitionState(
      isRecognizing: true,
      lastImage: image,
    );
  }
  
  /// Create a success state
  factory ProductRecognitionState.success(RecognitionResult result, File image) {
    return ProductRecognitionState(
      isRecognizing: false,
      lastResult: result,
      lastImage: image,
    );
  }
  
  /// Create an error state
  factory ProductRecognitionState.error(
    RecognitionException error,
    File image,
  ) {
    return ProductRecognitionState(
      isRecognizing: false,
      error: error,
      lastImage: image,
    );
  }
  
  /// Create a copy of this state with the given fields replaced
  ProductRecognitionState copyWith({
    bool? isRecognizing,
    RecognitionResult? lastResult,
    RecognitionException? error,
    File? lastImage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return ProductRecognitionState(
      isRecognizing: isRecognizing ?? this.isRecognizing,
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
      error: clearError ? null : (error ?? this.error),
      lastImage: lastImage ?? this.lastImage,
    );
  }
}