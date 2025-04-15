import 'package:uuid/uuid.dart';

/// Recommendation type
enum RecommendationType {
  /// Alternative product
  alternativeProduct,
  
  /// Product in the same category
  sameCategory,
  
  /// Product for specific concern
  forConcern,
  
  /// Product with better safety score
  saferOption,
  
  /// Product with simplified ingredients
  simpleIngredients,
}

/// Match reason
enum MatchReason {
  /// Matches user's skin type
  skinType,
  
  /// Contains user's preferred ingredients
  preferredIngredients,
  
  /// Avoids user's concerns
  avoidsConcerns,
  
  /// Avoids user's allergies
  avoidsAllergies,
  
  /// Highly rated by other users
  highlyRated,
  
  /// Based on scientific research
  scientificEvidence,
  
  /// Good value for price
  goodValue,
}

/// Personalized recommendation
class PersonalizedRecommendation {
  /// Recommendation ID
  final String id;
  
  /// Product name
  final String productName;
  
  /// Product brand
  final String brand;
  
  /// Product image URL
  final String? imageUrl;
  
  /// Product barcode
  final String? barcode;
  
  /// Brief description of the product
  final String description;
  
  /// Key ingredients
  final List<String> keyIngredients;
  
  /// Recommendation type
  final RecommendationType type;
  
  /// Match reasons
  final List<MatchReason> matchReasons;
  
  /// Safety score (0-100)
  final int safetyScore;
  
  /// Recommendation strength (0-100)
  final int strength;
  
  /// Whether this recommendation is saved
  final bool isSaved;
  
  /// Recommendation timestamp
  final DateTime timestamp;
  
  /// Create personalized recommendation
  PersonalizedRecommendation({
    String? id,
    required this.productName,
    required this.brand,
    this.imageUrl,
    this.barcode,
    required this.description,
    required this.keyIngredients,
    required this.type,
    required this.matchReasons,
    required this.safetyScore,
    required this.strength,
    this.isSaved = false,
    DateTime? timestamp,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();
  
  /// Create copy of personalized recommendation with modified fields
  PersonalizedRecommendation copyWith({
    String? id,
    String? productName,
    String? brand,
    String? imageUrl,
    String? barcode,
    String? description,
    List<String>? keyIngredients,
    RecommendationType? type,
    List<MatchReason>? matchReasons,
    int? safetyScore,
    int? strength,
    bool? isSaved,
    DateTime? timestamp,
  }) {
    return PersonalizedRecommendation(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      keyIngredients: keyIngredients ?? this.keyIngredients,
      type: type ?? this.type,
      matchReasons: matchReasons ?? this.matchReasons,
      safetyScore: safetyScore ?? this.safetyScore,
      strength: strength ?? this.strength,
      isSaved: isSaved ?? this.isSaved,
      timestamp: timestamp ?? this.timestamp,
    );
  }
  
  /// Get recommendation type as string
  String getTypeText() {
    switch (type) {
      case RecommendationType.alternativeProduct:
        return 'Alternative Product';
      case RecommendationType.sameCategory:
        return 'Similar Product';
      case RecommendationType.forConcern:
        return 'For Your Concerns';
      case RecommendationType.saferOption:
        return 'Safer Option';
      case RecommendationType.simpleIngredients:
        return 'Simplified Formula';
    }
  }
  
  /// Get match reasons as strings
  List<String> getMatchReasonTexts() {
    return matchReasons.map((reason) {
      switch (reason) {
        case MatchReason.skinType:
          return 'Matches your skin type';
        case MatchReason.preferredIngredients:
          return 'Contains ingredients you prefer';
        case MatchReason.avoidsConcerns:
          return 'Addresses your skin concerns';
        case MatchReason.avoidsAllergies:
          return 'Free from your allergens';
        case MatchReason.highlyRated:
          return 'Highly rated by users';
        case MatchReason.scientificEvidence:
          return 'Backed by research';
        case MatchReason.goodValue:
          return 'Good value for price';
      }
    }).toList();
  }
  
  /// Get safety rating as string
  String get safetyRating {
    if (safetyScore >= 80) {
      return 'Very Safe';
    } else if (safetyScore >= 60) {
      return 'Mostly Safe';
    } else if (safetyScore >= 40) {
      return 'Moderate Risk';
    } else if (safetyScore >= 20) {
      return 'High Risk';
    } else {
      return 'Very Unsafe';
    }
  }
  
  /// Get match quality as string
  String get matchQuality {
    if (strength >= 80) {
      return 'Excellent Match';
    } else if (strength >= 60) {
      return 'Good Match';
    } else if (strength >= 40) {
      return 'Fair Match';
    } else {
      return 'Basic Match';
    }
  }
}