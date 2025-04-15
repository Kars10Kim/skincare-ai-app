/// Onboarding status enum
enum OnboardingStatus {
  /// Not started
  notStarted,
  
  /// In progress
  inProgress,
  
  /// Completed successfully
  success,
  
  /// Failed
  failed,
}

/// Onboarding step enum
enum OnboardingStep {
  /// Welcome
  welcome,
  
  /// Skin type selection
  skinType,
  
  /// Skin concerns selection
  concerns,
  
  /// Allergens selection
  allergens,
  
  /// Authentication prompt
  authPrompt,
}

/// Skin type enum
enum SkinType {
  /// Normal skin
  normal,
  
  /// Dry skin
  dry,
  
  /// Oily skin
  oily,
  
  /// Combination skin
  combination,
  
  /// Sensitive skin
  sensitive,
}

/// Extension for skin type display data
extension SkinTypeExtension on SkinType {
  /// Get the display name for this skin type
  String get displayName {
    switch (this) {
      case SkinType.normal:
        return 'Normal';
      case SkinType.dry:
        return 'Dry';
      case SkinType.oily:
        return 'Oily';
      case SkinType.combination:
        return 'Combination';
      case SkinType.sensitive:
        return 'Sensitive';
    }
  }
  
  /// Get the description for this skin type
  String get description {
    switch (this) {
      case SkinType.normal:
        return 'Well-balanced skin that\'s neither too oily nor too dry';
      case SkinType.dry:
        return 'Skin that feels tight, rough, and may flake or crack';
      case SkinType.oily:
        return 'Skin that looks shiny and feels greasy, especially in the T-zone';
      case SkinType.combination:
        return 'Oily in some areas (usually T-zone) and dry or normal in others';
      case SkinType.sensitive:
        return 'Skin that easily reacts with redness, itching, or burning';
    }
  }
}

/// Skin concern enum
enum SkinConcern {
  /// Acne and breakouts
  acne,
  
  /// Signs of aging
  aging,
  
  /// Hyperpigmentation
  hyperpigmentation,
  
  /// Redness
  redness,
  
  /// Dryness
  dryness,
  
  /// Uneven texture
  unevenTexture,
}

/// Extension for skin concern display data
extension SkinConcernExtension on SkinConcern {
  /// Get the display name for this skin concern
  String get displayName {
    switch (this) {
      case SkinConcern.acne:
        return 'Acne';
      case SkinConcern.aging:
        return 'Aging';
      case SkinConcern.hyperpigmentation:
        return 'Dark Spots';
      case SkinConcern.redness:
        return 'Redness';
      case SkinConcern.dryness:
        return 'Dryness';
      case SkinConcern.unevenTexture:
        return 'Texture';
    }
  }
  
  /// Get the description for this skin concern
  String get description {
    switch (this) {
      case SkinConcern.acne:
        return 'Breakouts, clogged pores, and blemishes';
      case SkinConcern.aging:
        return 'Fine lines, wrinkles, and loss of elasticity';
      case SkinConcern.hyperpigmentation:
        return 'Dark spots, uneven skin tone, and sun damage';
      case SkinConcern.redness:
        return 'Persistent redness, irritation, or rosacea';
      case SkinConcern.dryness:
        return 'Flakiness, tightness, and lack of moisture';
      case SkinConcern.unevenTexture:
        return 'Rough texture, large pores, or bumpy skin';
    }
  }
}

/// Scan mode enum
enum ScanMode {
  /// Barcode scanning
  barcode,
  
  /// Ingredient label scanning
  label,
}

/// Onboarding data model
class OnboardingData {
  /// Selected skin type
  final SkinType? skinType;
  
  /// Selected skin concerns
  final List<SkinConcern> selectedConcerns;
  
  /// Selected allergens
  final List<String> selectedAllergens;
  
  /// Creates onboarding data
  OnboardingData({
    this.skinType,
    List<SkinConcern>? selectedConcerns,
    List<String>? selectedAllergens,
  })  : selectedConcerns = selectedConcerns ?? [],
        selectedAllergens = selectedAllergens ?? [];
  
  /// Creates a copy of this data with the given fields replaced
  OnboardingData copyWith({
    SkinType? skinType,
    List<SkinConcern>? selectedConcerns,
    List<String>? selectedAllergens,
  }) {
    return OnboardingData(
      skinType: skinType ?? this.skinType,
      selectedConcerns: selectedConcerns ?? this.selectedConcerns,
      selectedAllergens: selectedAllergens ?? this.selectedAllergens,
    );
  }
}