import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/personalized_recommendation.dart';
import '../../domain/entities/product_analysis.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../../../profile/domain/entities/user_profile.dart';

/// Implementation of recommendation repository
class RecommendationRepositoryImpl implements RecommendationRepository {
  /// Box name for saved recommendations
  static const String _savedRecommendationsBox = 'saved_recommendations';
  
  /// Box name for product database
  static const String _productsBox = 'products_database';
  
  /// Box for saved recommendations
  final Box _savedRecommendations;
  
  /// Box for product database
  final Box _products;
  
  /// Create recommendation repository implementation
  RecommendationRepositoryImpl({
    Box? savedRecommendations,
    Box? products,
  }) : _savedRecommendations = savedRecommendations ?? Hive.box(_savedRecommendationsBox),
       _products = products ?? Hive.box(_productsBox);
  
  /// Initialize the repository
  static Future<void> initialize() async {
    try {
      await Hive.openBox(_savedRecommendationsBox);
      await Hive.openBox(_productsBox);
    } catch (e) {
      debugPrint('Error initializing recommendation repository: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<PersonalizedRecommendation>> generateRecommendations({
    required UserProfile userProfile,
    required ProductAnalysis currentProduct,
    int limit = 5,
  }) async {
    try {
      // Get all products from the database
      final allProducts = _products.values.toList();
      final recommendations = <PersonalizedRecommendation>[];
      
      // Skip the current product if it has a barcode and exists in the database
      if (currentProduct.scanData.barcode != null) {
        allProducts.removeWhere((product) => 
          product['barcode'] == currentProduct.scanData.barcode);
      }
      
      // Score each product based on user profile and current product analysis
      final scoredProducts = <Map<String, dynamic>>[];
      
      for (final product in allProducts) {
        final score = _calculateMatchScore(
          product: product,
          userProfile: userProfile,
          currentAnalysis: currentProduct,
        );
        
        scoredProducts.add({
          'product': product,
          'score': score,
          'matchReasons': _getMatchReasons(
            product: product,
            userProfile: userProfile,
            currentAnalysis: currentProduct,
          ),
        });
      }
      
      // Sort by score (descending)
      scoredProducts.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
      
      // Convert top products to recommendations
      for (final scoredProduct in scoredProducts.take(limit)) {
        final product = scoredProduct['product'] as Map<dynamic, dynamic>;
        final score = scoredProduct['score'] as int;
        final matchReasons = scoredProduct['matchReasons'] as List<MatchReason>;
        
        // Determine recommendation type
        final recommendationType = _determineRecommendationType(
          product: product,
          currentAnalysis: currentProduct,
        );
        
        // Create recommendation
        final recommendation = PersonalizedRecommendation(
          productName: product['name'],
          brand: product['brand'],
          imageUrl: product['imageUrl'],
          barcode: product['barcode'],
          description: product['description'] ?? 'No description available',
          keyIngredients: List<String>.from(product['keyIngredients'] ?? []),
          type: recommendationType,
          matchReasons: matchReasons,
          safetyScore: product['safetyScore'] ?? 70,
          strength: score > 100 ? 100 : score,
          isSaved: _savedRecommendations.containsKey(product['barcode']),
        );
        
        recommendations.add(recommendation);
      }
      
      return recommendations;
    } catch (e) {
      debugPrint('Error generating recommendations: $e');
      return [];
    }
  }
  
  @override
  Future<List<PersonalizedRecommendation>> getSavedRecommendations() async {
    try {
      final savedIds = _savedRecommendations.keys.toList();
      final recommendations = <PersonalizedRecommendation>[];
      
      for (final id in savedIds) {
        final savedData = _savedRecommendations.get(id);
        
        if (savedData != null) {
          recommendations.add(_mapToRecommendation(savedData));
        }
      }
      
      // Sort by timestamp (descending)
      recommendations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return recommendations;
    } catch (e) {
      debugPrint('Error getting saved recommendations: $e');
      return [];
    }
  }
  
  @override
  Future<void> saveRecommendation(PersonalizedRecommendation recommendation) async {
    try {
      await _savedRecommendations.put(
        recommendation.id,
        _recommendationToMap(recommendation.copyWith(isSaved: true)),
      );
    } catch (e) {
      debugPrint('Error saving recommendation: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteRecommendation(String id) async {
    try {
      if (_savedRecommendations.containsKey(id)) {
        await _savedRecommendations.delete(id);
      }
    } catch (e) {
      debugPrint('Error deleting recommendation: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<PersonalizedRecommendation>> getAlternativesForIngredient({
    required String ingredientName,
    required UserProfile userProfile,
    int limit = 5,
  }) async {
    try {
      // Get all products from the database
      final allProducts = _products.values.toList();
      
      // Filter products that don't contain the specified ingredient
      final filteredProducts = allProducts.where((product) {
        final ingredients = List<String>.from(product['ingredients'] ?? []);
        return !ingredients.any((ingredient) => 
          ingredient.toLowerCase() == ingredientName.toLowerCase());
      }).toList();
      
      // Score each product based on user profile
      final scoredProducts = <Map<String, dynamic>>[];
      
      for (final product in filteredProducts) {
        final score = _calculateUserProfileMatchScore(
          product: product,
          userProfile: userProfile,
        );
        
        scoredProducts.add({
          'product': product,
          'score': score,
          'matchReasons': _getUserProfileMatchReasons(
            product: product,
            userProfile: userProfile,
          ),
        });
      }
      
      // Sort by score (descending)
      scoredProducts.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
      
      // Convert top products to recommendations
      final recommendations = <PersonalizedRecommendation>[];
      
      for (final scoredProduct in scoredProducts.take(limit)) {
        final product = scoredProduct['product'] as Map<dynamic, dynamic>;
        final score = scoredProduct['score'] as int;
        final matchReasons = scoredProduct['matchReasons'] as List<MatchReason>;
        
        // Create recommendation
        final recommendation = PersonalizedRecommendation(
          productName: product['name'],
          brand: product['brand'],
          imageUrl: product['imageUrl'],
          barcode: product['barcode'],
          description: product['description'] ?? 'No description available',
          keyIngredients: List<String>.from(product['keyIngredients'] ?? []),
          type: RecommendationType.alternativeProduct,
          matchReasons: matchReasons,
          safetyScore: product['safetyScore'] ?? 70,
          strength: score > 100 ? 100 : score,
          isSaved: _savedRecommendations.containsKey(product['barcode']),
        );
        
        recommendations.add(recommendation);
      }
      
      return recommendations;
    } catch (e) {
      debugPrint('Error getting alternatives for ingredient: $e');
      return [];
    }
  }
  
  @override
  void dispose() {
    // No need to dispose of anything here as Hive boxes are closed by Hive
  }
  
  /// Calculate match score for a product
  int _calculateMatchScore({
    required Map<dynamic, dynamic> product,
    required UserProfile userProfile,
    required ProductAnalysis currentAnalysis,
  }) {
    // Start with base score
    int score = 50;
    
    // Add points for user profile match
    score += _calculateUserProfileMatchScore(
      product: product,
      userProfile: userProfile,
    );
    
    // Add points for safety improvement
    final productSafetyScore = product['safetyScore'] ?? 50;
    final currentSafetyScore = currentAnalysis.safetyScore.overall;
    
    if (productSafetyScore > currentSafetyScore) {
      // Add points for the amount of improvement
      score += ((productSafetyScore - currentSafetyScore) / 5).round();
    }
    
    // Add points for fewer ingredients (simpler formula)
    final productIngredients = List<String>.from(product['ingredients'] ?? []);
    final currentIngredients = currentAnalysis.scanData.ingredients;
    
    if (productIngredients.length < currentIngredients.length) {
      score += 5;
    }
    
    // Add points for category match
    final productCategory = product['category'];
    final currentCategory = currentAnalysis.scanData.productName;
    
    if (productCategory != null && 
        currentCategory != null &&
        productCategory.toString().toLowerCase() == 
        currentCategory.toString().toLowerCase()) {
      score += 10;
    }
    
    return score;
  }
  
  /// Calculate user profile match score
  int _calculateUserProfileMatchScore({
    required Map<dynamic, dynamic> product,
    required UserProfile userProfile,
  }) {
    int score = 0;
    
    // Check skin type match
    final productSkinTypes = List<String>.from(product['suitableSkinTypes'] ?? []);
    
    if (productSkinTypes.any((type) => 
        type.toLowerCase() == _skinTypeToString(userProfile.skinType).toLowerCase())) {
      score += 15;
    }
    
    // Check for preferred ingredients
    final productIngredients = List<String>.from(product['ingredients'] ?? []);
    
    for (final preferred in userProfile.preferredIngredients) {
      if (productIngredients.any((ingredient) => 
          ingredient.toLowerCase().contains(preferred.toLowerCase()))) {
        score += 5;
      }
    }
    
    // Check for avoided ingredients (negative points)
    for (final avoided in userProfile.avoidedIngredients) {
      if (productIngredients.any((ingredient) => 
          ingredient.toLowerCase().contains(avoided.toLowerCase()))) {
        score -= 10;
      }
    }
    
    // Check for allergens (heavy negative points)
    for (final allergen in userProfile.allergies) {
      if (productIngredients.any((ingredient) => 
          ingredient.toLowerCase().contains(allergen.toLowerCase()))) {
        score -= 30;
      }
    }
    
    // Check for addressing skin concerns
    final productConcerns = List<String>.from(product['addressesConcerns'] ?? []);
    
    for (final concern in userProfile.skinConcerns) {
      if (productConcerns.any((productConcern) => 
          productConcern.toLowerCase().contains(concern.toLowerCase()))) {
        score += 10;
      }
    }
    
    return score;
  }
  
  /// Get match reasons for a product
  List<MatchReason> _getMatchReasons({
    required Map<dynamic, dynamic> product,
    required UserProfile userProfile,
    required ProductAnalysis currentAnalysis,
  }) {
    final reasons = <MatchReason>[];
    
    // Check for user profile match reasons
    reasons.addAll(_getUserProfileMatchReasons(
      product: product,
      userProfile: userProfile,
    ));
    
    // Check for safety improvement
    final productSafetyScore = product['safetyScore'] ?? 50;
    final currentSafetyScore = currentAnalysis.safetyScore.overall;
    
    if (productSafetyScore > currentSafetyScore + 10) {
      reasons.add(MatchReason.scientificEvidence);
    }
    
    // Check for good value
    if (product['isPopular'] == true) {
      reasons.add(MatchReason.highlyRated);
    }
    
    // Check for good price
    if (product['isGoodValue'] == true) {
      reasons.add(MatchReason.goodValue);
    }
    
    return reasons;
  }
  
  /// Get user profile match reasons
  List<MatchReason> _getUserProfileMatchReasons({
    required Map<dynamic, dynamic> product,
    required UserProfile userProfile,
  }) {
    final reasons = <MatchReason>[];
    
    // Check skin type match
    final productSkinTypes = List<String>.from(product['suitableSkinTypes'] ?? []);
    
    if (productSkinTypes.any((type) => 
        type.toLowerCase() == _skinTypeToString(userProfile.skinType).toLowerCase())) {
      reasons.add(MatchReason.skinType);
    }
    
    // Check for preferred ingredients
    final productIngredients = List<String>.from(product['ingredients'] ?? []);
    
    for (final preferred in userProfile.preferredIngredients) {
      if (productIngredients.any((ingredient) => 
          ingredient.toLowerCase().contains(preferred.toLowerCase()))) {
        reasons.add(MatchReason.preferredIngredients);
        break;
      }
    }
    
    // Check for avoiding allergens
    bool avoidsAllAllergens = true;
    
    for (final allergen in userProfile.allergies) {
      if (productIngredients.any((ingredient) => 
          ingredient.toLowerCase().contains(allergen.toLowerCase()))) {
        avoidsAllAllergens = false;
        break;
      }
    }
    
    if (avoidsAllAllergens && userProfile.allergies.isNotEmpty) {
      reasons.add(MatchReason.avoidsAllergies);
    }
    
    // Check for addressing skin concerns
    final productConcerns = List<String>.from(product['addressesConcerns'] ?? []);
    
    for (final concern in userProfile.skinConcerns) {
      if (productConcerns.any((productConcern) => 
          productConcern.toLowerCase().contains(concern.toLowerCase()))) {
        reasons.add(MatchReason.avoidsConcerns);
        break;
      }
    }
    
    return reasons;
  }
  
  /// Determine recommendation type
  RecommendationType _determineRecommendationType({
    required Map<dynamic, dynamic> product,
    required ProductAnalysis currentAnalysis,
  }) {
    // Check if product is a safer option
    final productSafetyScore = product['safetyScore'] ?? 50;
    final currentSafetyScore = currentAnalysis.safetyScore.overall;
    
    if (productSafetyScore > currentSafetyScore + 15) {
      return RecommendationType.saferOption;
    }
    
    // Check if product has simpler ingredients
    final productIngredients = List<String>.from(product['ingredients'] ?? []);
    final currentIngredients = currentAnalysis.scanData.ingredients;
    
    if (productIngredients.length < currentIngredients.length * 0.7) {
      return RecommendationType.simpleIngredients;
    }
    
    // Check for category match
    final productCategory = product['category'];
    final currentCategory = currentAnalysis.scanData.productName;
    
    if (productCategory != null && 
        currentCategory != null &&
        productCategory.toString().toLowerCase() == 
        currentCategory.toString().toLowerCase()) {
      return RecommendationType.sameCategory;
    }
    
    // Check for specific concern
    final productConcerns = List<String>.from(product['addressesConcerns'] ?? []);
    
    if (productConcerns.isNotEmpty) {
      return RecommendationType.forConcern;
    }
    
    // Default to alternative product
    return RecommendationType.alternativeProduct;
  }
  
  /// Map data to recommendation
  PersonalizedRecommendation _mapToRecommendation(Map<dynamic, dynamic> data) {
    return PersonalizedRecommendation(
      id: data['id'],
      productName: data['productName'],
      brand: data['brand'],
      imageUrl: data['imageUrl'],
      barcode: data['barcode'],
      description: data['description'],
      keyIngredients: List<String>.from(data['keyIngredients']),
      type: RecommendationType.values[data['type']],
      matchReasons: (data['matchReasons'] as List)
          .map((reason) => MatchReason.values[reason])
          .toList(),
      safetyScore: data['safetyScore'],
      strength: data['strength'],
      isSaved: data['isSaved'] ?? false,
      timestamp: DateTime.parse(data['timestamp']),
    );
  }
  
  /// Map recommendation to data
  Map<String, dynamic> _recommendationToMap(PersonalizedRecommendation recommendation) {
    return {
      'id': recommendation.id,
      'productName': recommendation.productName,
      'brand': recommendation.brand,
      'imageUrl': recommendation.imageUrl,
      'barcode': recommendation.barcode,
      'description': recommendation.description,
      'keyIngredients': recommendation.keyIngredients,
      'type': recommendation.type.index,
      'matchReasons': recommendation.matchReasons.map((reason) => reason.index).toList(),
      'safetyScore': recommendation.safetyScore,
      'strength': recommendation.strength,
      'isSaved': recommendation.isSaved,
      'timestamp': recommendation.timestamp.toIso8601String(),
    };
  }
  
  /// Convert skin type to string
  String _skinTypeToString(SkinType type) {
    switch (type) {
      case SkinType.dry:
        return 'dry';
      case SkinType.oily:
        return 'oily';
      case SkinType.combination:
        return 'combination';
      case SkinType.sensitive:
        return 'sensitive';
      case SkinType.normal:
        return 'normal';
    }
  }
}