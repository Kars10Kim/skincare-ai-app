import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../database/database_provider.dart';
import '../database/app_database.dart';

// Provider for user preferences
class UserPreferencesProvider extends ChangeNotifier {
  final DatabaseProvider _databaseProvider;
  
  // User preferences
  String _skinType = 'normal';
  List<String> _skinConcerns = [];
  List<String> _allergies = [];
  List<String>? _preferredBrands = [];
  List<String>? _avoidIngredients = [];
  
  // Loading states
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isInitialized = false;
  
  // Constructor
  UserPreferencesProvider(this._databaseProvider) {
    _loadPreferences();
  }
  
  // Getters
  String get skinType => _skinType;
  List<String> get skinConcerns => _skinConcerns;
  List<String> get allergies => _allergies;
  List<String>? get preferredBrands => _preferredBrands;
  List<String>? get avoidIngredients => _avoidIngredients;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  
  // Load preferences from database
  Future<void> _loadPreferences() async {
    try {
      _setLoading(true);
      
      final prefs = await _databaseProvider.getUserPreferences();
      
      if (prefs != null) {
        _skinType = prefs.skinType;
        _skinConcerns = _jsonToList(prefs.skinConcerns);
        _allergies = _jsonToList(prefs.allergies);
        _preferredBrands = _jsonToList(prefs.preferredBrands);
        _avoidIngredients = _jsonToList(prefs.avoidIngredients);
        _isInitialized = true;
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('Error loading preferences: ${e.toString()}');
    }
  }
  
  // Save preferences to database
  Future<void> savePreferences({
    required String skinType,
    required List<String> skinConcerns,
    required List<String> allergies,
    List<String>? preferredBrands,
    List<String>? avoidIngredients,
  }) async {
    try {
      _setLoading(true);
      
      await _databaseProvider.saveUserPreferences(
        skinType: skinType,
        skinConcerns: skinConcerns,
        allergies: allergies,
        preferredBrands: preferredBrands,
        avoidIngredients: avoidIngredients,
      );
      
      // Update local state
      _skinType = skinType;
      _skinConcerns = skinConcerns;
      _allergies = allergies;
      _preferredBrands = preferredBrands;
      _avoidIngredients = avoidIngredients;
      _isInitialized = true;
      
      _setLoading(false);
    } catch (e) {
      _setError('Error saving preferences: ${e.toString()}');
    }
  }
  
  // Check if an ingredient might cause allergy
  bool isAllergicToIngredient(String ingredientName) {
    final normIngredient = ingredientName.toLowerCase().trim();
    return _allergies.any((allergy) => 
        normIngredient.contains(allergy.toLowerCase()) || 
        allergy.toLowerCase().contains(normIngredient));
  }
  
  // Check if a product is from preferred brands
  bool isPreferredBrand(String? brandName) {
    if (brandName == null || brandName.isEmpty || _preferredBrands == null || _preferredBrands!.isEmpty) {
      return false;
    }
    
    final normBrand = brandName.toLowerCase().trim();
    return _preferredBrands!.any((brand) => 
        normBrand.contains(brand.toLowerCase()) || 
        brand.toLowerCase().contains(normBrand));
  }
  
  // Check if a product contains ingredients to avoid
  List<String> getIngredientsToAvoid(List<String> ingredients) {
    if (_avoidIngredients == null || _avoidIngredients!.isEmpty) {
      return [];
    }
    
    final result = <String>[];
    
    for (final ingredient in ingredients) {
      final normIngredient = ingredient.toLowerCase().trim();
      
      for (final avoid in _avoidIngredients!) {
        final normAvoid = avoid.toLowerCase().trim();
        
        if (normIngredient.contains(normAvoid) || normAvoid.contains(normIngredient)) {
          result.add(ingredient);
          break;
        }
      }
    }
    
    return result;
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _clearError();
    }
    notifyListeners();
  }
  
  void _setError(String message) {
    _isLoading = false;
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }
  
  // Convert JSON string to List<String>
  List<String> _jsonToList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => item.toString()).toList();
    } catch (e) {
      print('Error parsing JSON: $e');
      return [];
    }
  }
}