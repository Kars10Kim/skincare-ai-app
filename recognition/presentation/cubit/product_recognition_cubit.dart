import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/scan_error.dart';
import '../../domain/entities/scan_history_item.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../utils/ingredient_parser.dart';
import 'product_recognition_state.dart';

/// Cubit for product recognition feature
class ProductRecognitionCubit extends Cubit<ProductRecognitionState> {
  /// Scan repository
  final ScanRepository repository;
  
  /// Text recognizer for extracting text from images
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  /// Create product recognition cubit
  ProductRecognitionCubit({
    required this.repository,
  }) : super(ProductRecognitionState.initial());
  
  @override
  Future<void> close() async {
    await _textRecognizer.close();
    super.close();
  }
  
  /// Process a detected barcode
  Future<void> processBarcode(String barcode) async {
    if (state.isLoading) return;
    
    emit(state.copyWith(
      isLoading: true,
      barcode: barcode,
      lastAction: 'processBarcode',
    ));
    
    try {
      final scan = await repository.scanBarcode(barcode);
      
      // Get ingredient conflicts if available
      List<String>? conflicts;
      if (scan.ingredients != null && scan.ingredients!.isNotEmpty) {
        conflicts = await repository.analyzeIngredientConflicts(
          scan.ingredients!,
        );
      }
      
      emit(state.copyWith(
        isLoading: false,
        scan: scan,
        conflicts: conflicts,
      ));
    } catch (e) {
      emit(ProductRecognitionState.error(
        ScanError.unknown(e),
        lastAction: 'processBarcode',
      ));
    }
  }
  
  /// Process an image for ingredients
  Future<void> processImage(XFile image) async {
    if (state.isLoading) return;
    
    emit(state.copyWith(
      isLoading: true,
      image: image,
      lastAction: 'processImage',
    ));
    
    try {
      // Extract text from image first
      final text = await _extractTextFromImage(image);
      
      // Extract ingredients from text
      final ingredients = IngredientParser.extractIngredients(text);
      
      if (ingredients.isEmpty) {
        emit(state.copyWith(
          isLoading: false,
          extractedText: text,
          error: ScanError.recognition(
            'No ingredients found in the image. Try a clearer image or manually enter the ingredients.'
          ),
        ));
        return;
      }
      
      emit(state.copyWith(
        isLoading: false,
        extractedText: text,
        extractedIngredients: ingredients,
      ));
    } catch (e) {
      emit(ProductRecognitionState.error(
        ScanError.unknown(e),
        lastAction: 'processImage',
      ));
    }
  }
  
  /// Extract text from an image
  Future<String> _extractTextFromImage(XFile image) async {
    // Read image as input image
    final inputImage = InputImage.fromFilePath(image.path);
    
    // Process the image
    final recognizedText = await _textRecognizer.processImage(inputImage);
    
    return recognizedText.text;
  }
  
  /// Extract text from an image for the text tab
  Future<void> extractTextFromImage(XFile image) async {
    if (state.isLoading) return;
    
    emit(state.copyWith(
      isLoading: true,
      image: image,
      lastAction: 'extractTextFromImage',
    ));
    
    try {
      final text = await _extractTextFromImage(image);
      
      emit(state.copyWith(
        isLoading: false,
        extractedText: text,
      ));
    } catch (e) {
      emit(ProductRecognitionState.error(
        ScanError.recognition('Failed to extract text from image: $e'),
        lastAction: 'extractTextFromImage',
      ));
    }
  }
  
  /// Process manually entered text
  Future<void> processText(String text) async {
    if (state.isLoading) return;
    
    emit(state.copyWith(
      isLoading: true,
      extractedText: text,
      lastAction: 'processText',
    ));
    
    try {
      // Extract ingredients
      final ingredients = IngredientParser.extractIngredients(text);
      
      if (ingredients.isEmpty) {
        emit(state.copyWith(
          isLoading: false,
          error: ScanError.validation(
            'No ingredients found in the text. Please check the format and try again.'
          ),
        ));
        return;
      }
      
      // Create scan result
      final scan = ScanHistoryItem(
        barcode: 'text_scan_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Text Scan',
        ingredients: ingredients,
        timestamp: DateTime.now(),
        scanType: ScanType.text,
      );
      
      // Save to history
      await repository.addScanToHistory(scan);
      
      // Get conflicts
      final conflicts = await repository.analyzeIngredientConflicts(ingredients);
      
      emit(state.copyWith(
        isLoading: false,
        scan: scan,
        extractedIngredients: ingredients,
        conflicts: conflicts,
      ));
    } catch (e) {
      emit(ProductRecognitionState.error(
        ScanError.unknown(e),
        lastAction: 'processText',
      ));
    }
  }
  
  /// Analyze extracted ingredients
  Future<void> analyzeIngredients(List<String> ingredients) async {
    if (state.isLoading) return;
    
    emit(state.copyWith(
      isLoading: true,
      lastAction: 'analyzeIngredients',
    ));
    
    try {
      // Create scan result
      final scan = ScanHistoryItem(
        barcode: 'image_scan_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Image Scan',
        ingredients: ingredients,
        timestamp: DateTime.now(),
        scanType: ScanType.image,
      );
      
      // Save to history
      await repository.addScanToHistory(scan);
      
      // Get conflicts
      final conflicts = await repository.analyzeIngredientConflicts(ingredients);
      
      emit(state.copyWith(
        isLoading: false,
        scan: scan,
        conflicts: conflicts,
      ));
    } catch (e) {
      emit(ProductRecognitionState.error(
        ScanError.unknown(e),
        lastAction: 'analyzeIngredients',
      ));
    }
  }
  
  /// Toggle favorite status of current scan
  Future<void> toggleFavorite() async {
    if (state.scan == null) return;
    
    try {
      final updatedScan = state.scan!.copyWith(
        isFavorite: !state.scan!.isFavorite,
      );
      
      // Update in repository
      await repository.updateScan(updatedScan);
      
      emit(state.copyWith(scan: updatedScan));
    } catch (e) {
      emit(state.copyWith(
        error: ScanError.unknown(e),
      ));
    }
  }
  
  /// Retry the last action
  Future<void> retry() async {
    emit(state.clearError());
    
    final lastAction = state.lastAction;
    if (lastAction == null) return;
    
    switch (lastAction) {
      case 'processBarcode':
        if (state.barcode != null) {
          await processBarcode(state.barcode!);
        }
        break;
        
      case 'processImage':
        if (state.image != null) {
          await processImage(state.image!);
        }
        break;
        
      case 'extractTextFromImage':
        if (state.image != null) {
          await extractTextFromImage(state.image!);
        }
        break;
        
      case 'processText':
        if (state.extractedText != null) {
          await processText(state.extractedText!);
        }
        break;
        
      case 'analyzeIngredients':
        if (state.extractedIngredients != null) {
          await analyzeIngredients(state.extractedIngredients!);
        }
        break;
    }
  }
}