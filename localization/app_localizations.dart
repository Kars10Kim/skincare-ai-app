import 'package:flutter/material.dart';

/// App localizations class
class AppLocalizations {
  /// Locale for current instance
  final Locale locale;
  
  /// Create app localizations
  const AppLocalizations(this.locale);
  
  /// Get localizations for current context
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('en', 'US'));
  }
  
  /// Generic localized strings
  
  /// Loading message
  String get loading => 'Loading...';
  
  /// Unknown error message
  String get errorUnknown => 'An unknown error occurred.';
  
  /// No internet connection message
  String get errorNoConnection => 'No internet connection.';
  
  /// Try again button
  String get buttonTryAgain => 'Try Again';
  
  /// Save button
  String get buttonSave => 'Save';
  
  /// Cancel button
  String get buttonCancel => 'Cancel';
  
  /// Done button
  String get buttonDone => 'Done';
  
  /// Next button
  String get buttonNext => 'Next';
  
  /// Previous button
  String get buttonPrevious => 'Previous';
  
  /// Results screen specific strings
  
  /// Results screen title
  String get resultsTitle => 'Results';
  
  /// Results loading product message
  String get resultsLoadingProduct => 'Loading product details...';
  
  /// Results safety score
  String get resultsSafetyScore => 'Safety Score:';
  
  /// Results ingredients analysis
  String get resultsIngredientsAnalysis => 'Ingredients Analysis';
  
  /// Results conflicts
  String get resultsConflicts => 'Potential Conflicts';
  
  /// Results no conflicts
  String get resultsNoConflicts => 'No conflicts found in this product for your skin type.';
  
  /// Results save to history
  String get resultsSaveToHistory => 'Save to History';
  
  /// Results show alternatives
  String get resultsShowAlternatives => 'Show Alternatives';
  
  /// Recommendations screen specific strings
  
  /// Recommendations screen title
  String get recommendationsTitle => 'Recommended Products';
  
  /// Recommendations loading message
  String get recommendationsLoading => 'Finding recommendations for you...';
  
  /// No recommendations message
  String get recommendationsNone => 'No recommendations available.';
  
  /// Favorites specific strings
  
  /// Favorites screen title
  String get favoritesTitle => 'Favorites';
  
  /// No favorites message
  String get favoritesNone => 'You haven\'t saved any favorites yet.';
  
  /// Removed from favorites message
  String get favoritesRemoved => 'Removed from favorites.';
  
  /// Added to favorites message
  String get favoritesAdded => 'Added to favorites.';
  
  /// Scan history specific strings
  
  /// Scan history screen title
  String get scanHistoryTitle => 'Scan History';
  
  /// No scan history message
  String get scanHistoryNone => 'Your scan history is empty.';
  
  /// Clear scan history button
  String get scanHistoryClear => 'Clear History';
  
  /// Scan history cleared message
  String get scanHistoryCleared => 'Scan history cleared.';
  
  /// Settings specific strings
  
  /// Settings screen title
  String get settingsTitle => 'Settings';
  
  /// Settings skin profile section
  String get settingsSkinProfile => 'Skin Profile';
  
  /// Settings appearance section
  String get settingsAppearance => 'Appearance';
  
  /// Settings notifications section
  String get settingsNotifications => 'Notifications';
  
  /// Settings about section
  String get settingsAbout => 'About';
  
  /// Settings help section
  String get settingsHelp => 'Help & Support';
  
  /// Settings privacy section
  String get settingsPrivacy => 'Privacy & Data';
  
  /// Settings sign out button
  String get settingsSignOut => 'Sign Out';
  
  /// Camera specific strings
  
  /// Camera permission needed message
  String get cameraPermissionNeeded => 'Camera permission is required to scan products.';
  
  /// Camera permission denied message
  String get cameraPermissionDenied => 'Camera permission denied. Please enable camera access in settings.';
  
  /// Camera scan barcode message
  String get cameraScanBarcode => 'Align the barcode within the frame';
  
  /// Camera scan ingredients message
  String get cameraScanIngredients => 'Point camera at the ingredients list';
  
  /// Camera capture button
  String get cameraCapture => 'Capture';
  
  /// Camera switch mode button
  String get cameraSwitchMode => 'Switch Mode';
  
  /// Camera flash button
  String get cameraFlash => 'Flash';
  
  /// Ingredient specific strings
  
  /// Ingredient details title
  String get ingredientDetailsTitle => 'Ingredient Details';
  
  /// Ingredient safety label
  String get ingredientSafety => 'Safety:';
  
  /// Ingredient function label
  String get ingredientFunction => 'Function:';
  
  /// Ingredient concerns label
  String get ingredientConcerns => 'Potential Concerns:';
  
  /// Ingredient sources label
  String get ingredientSources => 'Sources:';
}