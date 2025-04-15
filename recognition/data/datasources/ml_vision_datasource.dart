import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/entities/recognized_product.dart';
import '../../utils/exceptions.dart';

/// Data source for ML-based product recognition
abstract class MLDataSource {
  /// Recognize a product from an image using ML
  Future<MLRecognitionResult> recognizeProduct(File image);
  
  /// Extract text from an image
  Future<String> extractText(File image);
  
  /// Parse ingredients from text
  Future<List<String>> parseIngredients(String text);
}

/// Implementation of the ML data source using Google ML Kit
class MLVisionDataSource implements MLDataSource {
  /// The text recognizer
  final TextRecognizer _textRecognizer;
  
  /// External API client for product database queries
  // final ProductApiClient _apiClient;
  
  /// Create an ML vision data source
  MLVisionDataSource({
    TextRecognizer? textRecognizer,
    // ProductApiClient? apiClient,
  }) : _textRecognizer = textRecognizer ?? 
            TextRecognizer(script: TextRecognitionScript.latin);
            // _apiClient = apiClient ?? ProductApiClient();
  
  @override
  Future<MLRecognitionResult> recognizeProduct(File image) async {
    try {
      // Extract text from the image
      final text = await extractText(image);
      if (text.isEmpty) {
        return MLRecognitionResult.empty();
      }
      
      // Parse ingredients from the text
      final ingredients = await parseIngredients(text);
      if (ingredients.isEmpty) {
        return MLRecognitionResult.empty();
      }
      
      // Find product matches based on ingredients
      final productMatches = await _findProductMatches(ingredients);
      return MLRecognitionResult(probableMatches: productMatches);
    } catch (e) {
      if (e is MLRecognitionException) {
        rethrow;
      }
      throw MLRecognitionException('unknown', e.toString());
    }
  }
  
  @override
  Future<String> extractText(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } on Exception catch (e) {
      throw MLRecognitionException('text_recognition_failed', e.toString());
    }
  }
  
  @override
  Future<List<String>> parseIngredients(String text) async {
    // Extract ingredients list using pattern recognition
    
    // Common patterns for ingredients lists
    final patterns = [
      // Looking for "Ingredients:" followed by a list
      RegExp(r'ingredients:?\s*(.+)', caseSensitive: false),
      // Looking for "INCI:" followed by a list (International Nomenclature of Cosmetic Ingredients)
      RegExp(r'inci:?\s*(.+)', caseSensitive: false),
      // Sometimes ingredients are after "Contains:" or "Composition:"
      RegExp(r'(contains|composition):?\s*(.+)', caseSensitive: false),
    ];
    
    String? ingredientText;
    
    // Try to find ingredients section
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        // Get the capturing group with the ingredients
        ingredientText = match.group(match.groupCount);
        break;
      }
    }
    
    // If no clear ingredients section found, use the entire text
    ingredientText ??= text;
    
    // Split the ingredients by common separators
    final rawIngredients = ingredientText
        .split(RegExp(r'[,;/\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    // Further clean and filter ingredients
    final cleanedIngredients = _cleanIngredientsList(rawIngredients);
    return cleanedIngredients;
  }
  
  /// Clean and filter the ingredients list
  List<String> _cleanIngredientsList(List<String> rawIngredients) {
    final cleaned = <String>[];
    
    for (var ingredient in rawIngredients) {
      // Remove any trailing dots, asterisks, etc.
      ingredient = ingredient.replaceAll(RegExp(r'[.*•]$'), '').trim();
      
      // Remove percentage indicators (e.g., "Water (75%)" -> "Water")
      ingredient = ingredient.replaceAll(RegExp(r'\s*\(\d+\.?\d*\s*%\)'), '');
      
      // Skip if too short (likely noise) or too long (likely not a single ingredient)
      if (ingredient.length < 3 || ingredient.length > 50) continue;
      
      // Skip common non-ingredient words
      if (_isNonIngredientWord(ingredient)) continue;
      
      // Add to cleaned list if not already present
      if (!cleaned.contains(ingredient)) {
        cleaned.add(ingredient);
      }
    }
    
    return cleaned;
  }
  
  /// Check if a string is likely not an ingredient
  bool _isNonIngredientWord(String word) {
    final nonIngredientWords = [
      'and', 'contains', 'may', 'the', 'ingredients', 'caution', 'warning',
      'use', 'directions', 'apply', 'store', 'keep', 'avoid', 'if', 'for',
      'contact', 'eyes', 'discontinue', 'occurs', 'see', 'physician',
      'made', 'in', 'product', 'please', 'read', 'labels'
    ];
    
    return nonIngredientWords.contains(word.toLowerCase());
  }
  
  /// Find product matches based on ingredients
  Future<List<RecognizedProduct>> _findProductMatches(List<String> ingredients) async {
    // This would typically query a product database with the ingredients
    // For now, we'll return a placeholder product
    
    // TODO: Replace with actual API implementation
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay
    
    // Create a dummy product for testing
    // In a real implementation, this would query a database
    final product = RecognizedProduct.fromMLVision(
      id: 'ml_${math.Random().nextInt(1000)}',
      name: 'Recognized Skincare Product',
      brand: 'Detected Brand',
      ingredients: ingredients,
      confidenceScore: 0.85,
    );
    
    return [product];
  }
  
  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}

/// Mock implementation of the ML data source for testing or web
class MockMLDataSource implements MLDataSource {
  @override
  Future<MLRecognitionResult> recognizeProduct(File image) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // For testing purposes, create a mock product
    final product = RecognizedProduct.fromMLVision(
      id: 'mock_product_1',
      name: 'Example Skin Cream',
      brand: 'Test Brand',
      description: 'A moisturizing cream with hydrating ingredients',
      imageUrl: 'https://example.com/images/skin_cream.jpg',
      ingredients: [
        'Water',
        'Glycerin',
        'Cetearyl Alcohol',
        'Caprylic/Capric Triglyceride',
        'Cetyl Alcohol',
        'Butylene Glycol',
        'Sodium Hyaluronate',
        'Tocopherol',
      ],
      confidenceScore: 0.75,
    );
    
    return MLRecognitionResult(probableMatches: [product]);
  }
  
  @override
  Future<String> extractText(File image) async {
    // Return mock ingredient text
    return 'INGREDIENTS: Water, Glycerin, Cetearyl Alcohol, Caprylic/Capric Triglyceride, Cetyl Alcohol, Butylene Glycol, Sodium Hyaluronate, Tocopherol';
  }
  
  @override
  Future<List<String>> parseIngredients(String text) async {
    // Split by commas and clean
    return text
        .replaceAll('INGREDIENTS:', '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}