import 'package:equatable/equatable.dart';

/// Skin type enum
enum SkinType {
  /// Normal skin type
  normal('Normal'),
  
  /// Dry skin type
  dry('Dry'),
  
  /// Oily skin type
  oily('Oily'),
  
  /// Combination skin type
  combination('Combination');
  
  /// Display name of skin type
  final String displayName;
  
  /// Create a skin type
  const SkinType(this.displayName);
  
  /// Get a skin type from a string
  static SkinType fromString(String value) {
    return SkinType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SkinType.normal,
    );
  }
}

/// Skin sensitivity level
enum SensitivityLevel {
  /// Not sensitive
  none('Not Sensitive'),
  
  /// Slightly sensitive
  mild('Slightly Sensitive'),
  
  /// Moderately sensitive
  moderate('Moderately Sensitive'),
  
  /// Very sensitive
  high('Very Sensitive');
  
  /// Display name of sensitivity level
  final String displayName;
  
  /// Create a sensitivity level
  const SensitivityLevel(this.displayName);
  
  /// Get a sensitivity level from a string
  static SensitivityLevel fromString(String value) {
    return SensitivityLevel.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SensitivityLevel.none,
    );
  }
}

/// Climate type
enum Climate {
  /// Dry climate
  dry('Dry'),
  
  /// Humid climate
  humid('Humid'),
  
  /// Temperate climate
  temperate('Temperate'),
  
  /// Cold climate
  cold('Cold'),
  
  /// Hot climate
  hot('Hot');
  
  /// Display name of climate
  final String displayName;
  
  /// Create a climate
  const Climate(this.displayName);
  
  /// Get a climate from a string
  static Climate fromString(String value) {
    return Climate.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Climate.temperate,
    );
  }
}

/// Skin concern
enum SkinConcern {
  /// Acne
  acne('Acne'),
  
  /// Aging
  aging('Aging'),
  
  /// Dryness
  dryness('Dryness'),
  
  /// Hyperpigmentation
  hyperpigmentation('Hyperpigmentation'),
  
  /// Redness
  redness('Redness'),
  
  /// Texture
  texture('Texture'),
  
  /// Oil control
  oilControl('Oil Control'),
  
  /// Dark circles
  darkCircles('Dark Circles'),
  
  /// Puffiness
  puffiness('Puffiness'),
  
  /// Pores
  pores('Pores'),
  
  /// Sun damage
  sunDamage('Sun Damage'),
  
  /// Dullness
  dullness('Dullness'),
  
  /// Fine lines
  fineLines('Fine Lines'),
  
  /// Firmness
  firmness('Firmness'),
  
  /// Elasticity
  elasticity('Elasticity'),
  
  /// Brightening
  brightening('Brightening'),
  
  /// None specified
  none('None');
  
  /// Display name of skin concern
  final String displayName;
  
  /// Create a skin concern
  const SkinConcern(this.displayName);
  
  /// Get a skin concern from a string
  static SkinConcern fromString(String value) {
    return SkinConcern.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SkinConcern.none,
    );
  }
}

/// Known allergies
enum KnownAllergy {
  /// Fragrance
  fragrance('Fragrance'),
  
  /// Essential oils
  essentialOils('Essential Oils'),
  
  /// Alcohol
  alcohol('Alcohol'),
  
  /// Sulfates
  sulfates('Sulfates'),
  
  /// Parabens
  parabens('Parabens'),
  
  /// Retinoids
  retinoids('Retinoids'),
  
  /// Lanolin
  lanolin('Lanolin'),
  
  /// Formaldehyde
  formaldehyde('Formaldehyde'),
  
  /// Salicylic acid
  salicylicAcid('Salicylic Acid'),
  
  /// Benzoyl peroxide
  benzoylPeroxide('Benzoyl Peroxide'),
  
  /// Vitamin C
  vitaminC('Vitamin C'),
  
  /// Oils
  oils('Oils'),
  
  /// None specified
  none('None');
  
  /// Display name of allergy
  final String displayName;
  
  /// Create an allergy
  const KnownAllergy(this.displayName);
  
  /// Get an allergy from a string
  static KnownAllergy fromString(String value) {
    return KnownAllergy.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => KnownAllergy.none,
    );
  }
}

/// Skin profile with user's skin details
class SkinProfile extends Equatable {
  /// Skin type
  final SkinType skinType;
  
  /// Sensitivity level
  final SensitivityLevel sensitivityLevel;
  
  /// Climate where the user lives
  final Climate climate;
  
  /// Primary skin concerns
  final List<SkinConcern> concerns;
  
  /// Known ingredient allergies or sensitivities
  final List<KnownAllergy> allergies;
  
  /// Additional notes
  final String? notes;
  
  /// Created timestamp
  final DateTime createdAt;
  
  /// Last updated timestamp
  final DateTime updatedAt;
  
  /// Create a skin profile
  const SkinProfile({
    this.skinType = SkinType.normal,
    this.sensitivityLevel = SensitivityLevel.none,
    this.climate = Climate.temperate,
    this.concerns = const [],
    this.allergies = const [],
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();
  
  /// Create a copy with new values
  SkinProfile copyWith({
    SkinType? skinType,
    SensitivityLevel? sensitivityLevel,
    Climate? climate,
    List<SkinConcern>? concerns,
    List<KnownAllergy>? allergies,
    String? notes,
    DateTime? updatedAt,
  }) {
    return SkinProfile(
      skinType: skinType ?? this.skinType,
      sensitivityLevel: sensitivityLevel ?? this.sensitivityLevel,
      climate: climate ?? this.climate,
      concerns: concerns ?? this.concerns,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'skinType': skinType.name,
      'sensitivityLevel': sensitivityLevel.name,
      'climate': climate.name,
      'concerns': concerns.map((concern) => concern.name).toList(),
      'allergies': allergies.map((allergy) => allergy.name).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  /// Create from JSON
  factory SkinProfile.fromJson(Map<String, dynamic> json) {
    return SkinProfile(
      skinType: SkinType.fromString(json['skinType'] ?? ''),
      sensitivityLevel: SensitivityLevel.fromString(json['sensitivityLevel'] ?? ''),
      climate: Climate.fromString(json['climate'] ?? ''),
      concerns: (json['concerns'] as List<dynamic>?)
          ?.map((concern) => SkinConcern.fromString(concern))
          .toList() ?? [],
      allergies: (json['allergies'] as List<dynamic>?)
          ?.map((allergy) => KnownAllergy.fromString(allergy))
          .toList() ?? [],
      notes: json['notes'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
  
  @override
  List<Object?> get props => [
    skinType,
    sensitivityLevel,
    climate,
    concerns,
    allergies,
    notes,
    createdAt,
    updatedAt,
  ];
  
  @override
  String toString() {
    return 'SkinProfile{'
        'skinType: $skinType, '
        'sensitivityLevel: $sensitivityLevel, '
        'climate: $climate, '
        'concerns: $concerns, '
        'allergies: $allergies, '
        'notes: $notes, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        '}';
  }
}