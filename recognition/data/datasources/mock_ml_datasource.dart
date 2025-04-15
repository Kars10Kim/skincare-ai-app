import 'dart:io';

import '../../domain/entities/recognized_product.dart';
import '../../utils/exceptions.dart';
import 'ml_vision_datasource.dart';

/// Mock implementation of ML Vision Data Source for web or testing
///
/// This is used for environments where the ML Kit text recognition isn't available,
/// such as web or during testing.
class MockMLDataSource implements MLDataSource {
  /// Mock extraction with a few predefined product matches
  @override
  Future<MLRecognitionResult> recognizeProduct(File imageFile) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Return mock product from the predefined list
    // Only choose a mock product 70% of the time to simulate recognition failures
    if (_mockProducts.isNotEmpty && _shouldRecognize()) {
      final mockProduct = _getRandomProduct();
      return MLRecognitionResult(
        probableMatches: [mockProduct],
        rawText: 'Ingredients: ${mockProduct.ingredients.join(', ')}',
      );
    }
    
    // Return empty result to simulate recognition failure
    return const MLRecognitionResult(
      probableMatches: [],
      rawText: '',
    );
  }

  /// Mock text extraction
  @override
  Future<String> extractText(File imageFile) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (_shouldRecognize()) {
      final mockProduct = _getRandomProduct();
      return 'Ingredients: ${mockProduct.ingredients.join(', ')}';
    }
    
    throw MLRecognitionException('Text extraction failed');
  }

  /// Mock ingredients parsing
  @override
  Future<List<String>> parseIngredients(String text) async {
    // If the text actually contains "ingredients:", parse it
    if (text.toLowerCase().contains('ingredients:')) {
      final startIndex = text.toLowerCase().indexOf('ingredients:') + 'ingredients:'.length;
      final ingredientsText = text.substring(startIndex).trim();
      return ingredientsText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e.length > 1 && 
                !['and', 'or', 'with', 'without'].contains(e.toLowerCase()))
          .toList();
    }
    
    return [];
  }
  
  /// Simulate recognition with 70% success rate
  bool _shouldRecognize() {
    return DateTime.now().millisecondsSinceEpoch % 10 < 7;
  }
  
  /// Get a random product from the mock products list
  RecognizedProduct _getRandomProduct() {
    final randomIndex = DateTime.now().millisecondsSinceEpoch % _mockProducts.length;
    return _mockProducts[randomIndex];
  }
  
  /// List of mock product data
  static final List<RecognizedProduct> _mockProducts = [
    RecognizedProduct(
      name: 'Daily Moisturizer SPF 30',
      brand: 'CeraVe',
      ingredients: [
        'Water',
        'Glycerin',
        'Niacinamide',
        'Dimethicone',
        'Ceramide NP',
        'Ceramide AP',
        'Ceramide EOP',
        'Carbomer',
        'Sodium Hyaluronate',
        'Tocopherol',
        'Phytosphingosine',
        'Xanthan Gum',
        'Ethylhexylglycerin',
        'Adenosine',
        'Phenoxyethanol',
      ],
      barcode: '123456789012',
      matchConfidence: 85,
    ),
    RecognizedProduct(
      name: 'Hydrating Facial Cleanser',
      brand: 'La Roche-Posay',
      ingredients: [
        'Aqua',
        'Glycerin',
        'Propanediol',
        'Ceramide NP',
        'Niacinamide',
        'Sodium Cocoyl Isethionate',
        'Panthenol',
        'Tocopherol',
        'Allantoin',
        'Xanthan Gum',
        'Cetearyl Alcohol',
        'Carbomer',
        'Sodium Hyaluronate',
        'Phenoxyethanol',
      ],
      barcode: '987654321098',
      matchConfidence: 92,
    ),
    RecognizedProduct(
      name: 'AHA 30% + BHA 2% Peeling Solution',
      brand: 'The Ordinary',
      ingredients: [
        'Glycolic Acid',
        'Water',
        'Aloe Barbadensis Leaf Water',
        'Sodium Hydroxide',
        'Dextrin',
        'Propanediol',
        'Cocamidopropyl Dimethylamine',
        'Salicylic Acid',
        'Potassium Citrate',
        'Lactic Acid',
        'Tartaric Acid',
        'Sodium Hyaluronate Crosspolymer',
        'Phenoxyethanol',
        'Chlorphenesin',
      ],
      barcode: '543216789012',
      matchConfidence: 78,
    ),
  ];
}