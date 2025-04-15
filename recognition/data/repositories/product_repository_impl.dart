import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/recognized_product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../utils/exceptions.dart';
import '../datasources/barcode_datasource.dart';
import '../datasources/ml_vision_datasource.dart';

/// Implementation of the product repository
class ProductRepositoryImpl implements ProductRepository {
  /// The barcode data source
  final BarcodeDataSource _barcodeDataSource;
  
  /// The ML data source
  final MLDataSource _mlDataSource;
  
  /// Current state
  ProductRecognitionState _state = ProductRecognitionState.initial();
  
  /// State controller
  final _stateController = StreamController<ProductRecognitionState>.broadcast();
  
  /// Create a product repository
  ProductRepositoryImpl({
    required BarcodeDataSource barcodeDataSource,
    required MLDataSource mlDataSource,
  }) : _barcodeDataSource = barcodeDataSource,
       _mlDataSource = mlDataSource;
       
  @override
  ProductRecognitionState get state => _state;
  
  @override
  Stream<ProductRecognitionState> get stateStream => _stateController.stream;
  
  /// Update the state
  void _updateState(ProductRecognitionState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  @override
  Future<RecognitionResult> recognizeProduct(File image) async {
    // First try barcode recognition as it's more reliable
    try {
      return await _barcodeFirstAttempt(image);
    } catch (e) {
      // If barcode recognition fails, try ML recognition
      return await _mlFallback(image);
    }
  }
  
  /// Try barcode recognition first
  Future<RecognitionResult> _barcodeFirstAttempt(File image) async {
    _updateState(ProductRecognitionState.loading(image));
    
    try {
      // Check for internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw OfflineException();
      }
      
      final result = await recognizeFromBarcode(image);
      _updateState(ProductRecognitionState.success(result, image));
      return result;
    } on RecognitionException catch (e) {
      _updateState(ProductRecognitionState.error(e, image));
      rethrow;
    }
  }
  
  /// Fallback to ML recognition
  Future<RecognitionResult> _mlFallback(File image) async {
    _updateState(ProductRecognitionState.loading(image));
    
    try {
      final result = await recognizeFromIngredients(image);
      _updateState(ProductRecognitionState.success(result, image));
      return result;
    } on RecognitionException catch (e) {
      _updateState(ProductRecognitionState.error(e, image));
      rethrow;
    }
  }
  
  @override
  Future<RecognitionResult> recognizeFromBarcode(File image) async {
    try {
      final barcodeResult = await _barcodeDataSource.scanBarcode(image.path);
      
      if (!barcodeResult.isValid || barcodeResult.rawValue == null) {
        return RecognitionResult.failure('No valid barcode found');
      }
      
      // Try to get the product from the database
      final product = await getProductByBarcode(barcodeResult.rawValue!);
      
      if (product == null) {
        return RecognitionResult.failure(
          'Product with barcode ${barcodeResult.rawValue} not found'
        );
      }
      
      return RecognitionResult.success(product);
    } on BarcodeScanException catch (e) {
      return RecognitionResult.failure(e.message);
    } catch (e) {
      return RecognitionResult.failure('Barcode recognition failed: $e');
    }
  }
  
  @override
  Future<RecognitionResult> recognizeFromIngredients(File image) async {
    try {
      final mlResult = await _mlDataSource.recognizeProduct(image);
      
      if (!mlResult.hasMatches) {
        return RecognitionResult.failure('No products found matching the ingredients');
      }
      
      return RecognitionResult.success(mlResult.bestMatch!);
    } on MLRecognitionException catch (e) {
      return RecognitionResult.failure(e.message);
    } catch (e) {
      return RecognitionResult.failure('Ingredient recognition failed: $e');
    }
  }
  
  @override
  Future<RecognizedProduct?> getProductByBarcode(String barcode) async {
    // TODO: Implement actual product database lookup
    
    // For testing purposes, return a mock product for specific barcodes
    if (barcode == '5901234123457') {
      return RecognizedProduct.fromBarcode(
        barcode: barcode,
        name: 'Example Moisturizer',
        brand: 'SkinCare Brand',
        description: 'A hydrating moisturizer for all skin types',
        ingredients: [
          'Water',
          'Glycerin',
          'Cetearyl Alcohol',
          'Ceteareth-20',
          'Caprylic/Capric Triglyceride',
          'Butylene Glycol',
          'Dimethicone',
          'Sodium Hyaluronate',
          'Tocopherol',
          'Panthenol',
          'Allantoin',
          'Disodium EDTA',
          'Phenoxyethanol',
          'Ethylhexylglycerin',
        ],
      );
    }
    
    // For other barcodes, return null (product not found)
    return null;
  }
  
  @override
  Future<RecognitionResult> retryLastRecognition() async {
    final lastImage = _state.lastImage;
    if (lastImage == null) {
      return RecognitionResult.failure('No previous scan to retry');
    }
    
    return recognizeProduct(lastImage);
  }
  
  @override
  void clearRecognition() {
    _updateState(ProductRecognitionState.initial());
  }
  
  @override
  void dispose() {
    _stateController.close();
  }
}