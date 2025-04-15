import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../services/connectivity_service.dart';
import '../utils/exceptions.dart';

/// Repository for managing ingredient data
class IngredientRepository {
  /// API base URL for ingredient data
  final String _apiBaseUrl;
  
  /// Local database service for cached ingredients
  final dynamic _localDatabase;
  
  /// Connectivity service for handling offline mode
  final ConnectivityService _connectivityService;
  
  /// Cache of ingredients and their properties
  final Map<String, Map<String, dynamic>> _ingredientCache = {};
  
  /// Cache of ingredient conflicts
  final Map<String, Map<String, dynamic>> _conflictCache = {};
  
  /// Default constructor
  IngredientRepository({
    required String apiBaseUrl,
    required dynamic localDatabase,
    required ConnectivityService connectivityService,
  }) : _apiBaseUrl = apiBaseUrl,
       _localDatabase = localDatabase,
       _connectivityService = connectivityService;
  
  /// Initialize the repository with local ingredient data
  Future<void> initialize() async {
    try {
      // Load local ingredient data from assets
      await _loadLocalIngredientData();
    } catch (e) {
      debugPrint('Error initializing ingredient repository: $e');
    }
  }
  
  /// Load local ingredient data from assets
  Future<void> _loadLocalIngredientData() async {
    try {
      // Load ingredient data from a local JSON file in assets
      final String jsonData = await rootBundle.loadString('assets/data/ingredients.json');
      final Map<String, dynamic> data = jsonDecode(jsonData);
      
      // Process ingredients
      final ingredients = data['ingredients'] as List;
      for (final ingredient in ingredients) {
        final ingData = ingredient as Map<String, dynamic>;
        final name = ingData['name'] as String;
        _ingredientCache[name.toLowerCase()] = ingData;
      }
      
      // Process conflicts
      if (data.containsKey('conflicts')) {
        final conflicts = data['conflicts'] as List;
        for (final conflict in conflicts) {
          final confData = conflict as Map<String, dynamic>;
          final ingredients = confData['ingredients'] as List;
          if (ingredients.length >= 2) {
            // Create a unique key for the conflict pair
            final key = '${ingredients[0].toLowerCase()}:${ingredients[1].toLowerCase()}';
            _conflictCache[key] = confData;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading local ingredient data: $e');
    }
  }
  
  /// Get ingredient data by name
  Future<Map<String, dynamic>> getIngredientByName(String name) async {
    // Check cache first
    final normalizedName = name.toLowerCase().trim();
    if (_ingredientCache.containsKey(normalizedName)) {
      return _ingredientCache[normalizedName]!;
    }
    
    try {
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        // Try to get from local database when offline
        final localData = await _getIngredientFromLocalDb(normalizedName);
        if (localData.isNotEmpty) {
          return localData;
        }
        
        throw ConnectivityException(
          'Cannot retrieve ingredient data while offline',
        );
      }
      
      // Otherwise fetch from API
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/ingredients/$normalizedName'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Cache the result
        _ingredientCache[normalizedName] = data;
        
        // Also save to local database for offline use
        await _saveIngredientToLocalDb(normalizedName, data);
        
        return data;
      } else if (response.statusCode == 404) {
        // Ingredient not found
        return {};
      } else {
        throw Exception('Failed to load ingredient data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting ingredient by name: $e');
      // Return empty map if not found
      return {};
    }
  }
  
  /// Get conflict between two ingredients
  Future<Map<String, dynamic>?> getConflictBetween(
    String ingredient1,
    String ingredient2,
  ) async {
    // Normalize names
    final ing1 = ingredient1.toLowerCase().trim();
    final ing2 = ingredient2.toLowerCase().trim();
    
    // Create keys for both possible orderings
    final key1 = '$ing1:$ing2';
    final key2 = '$ing2:$ing1';
    
    // Check cache first
    if (_conflictCache.containsKey(key1)) {
      return _conflictCache[key1];
    } else if (_conflictCache.containsKey(key2)) {
      return _conflictCache[key2];
    }
    
    try {
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        // Try to get from local database when offline
        final localData = await _getConflictFromLocalDb(ing1, ing2);
        if (localData.isNotEmpty) {
          return localData;
        }
        
        // If we're offline and don't have the data, return null
        return null;
      }
      
      // Otherwise fetch from API
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/conflicts?ingredients=$ing1,$ing2'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // If conflict exists
        if (data.containsKey('exists') && data['exists'] == true) {
          final conflictData = data['conflict'] as Map<String, dynamic>;
          
          // Cache the result
          _conflictCache[key1] = conflictData;
          
          // Also save to local database for offline use
          await _saveConflictToLocalDb(ing1, ing2, conflictData);
          
          return conflictData;
        } else {
          // No conflict exists
          return null;
        }
      } else {
        throw Exception('Failed to check ingredient conflict: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error checking conflict between ingredients: $e');
      // Return null if error
      return null;
    }
  }
  
  /// Parse ingredient text from scanned text
  Future<List<String>> parseIngredientText(String text) async {
    // Simple implementation for parsing ingredient text
    final List<String> result = [];
    
    // Split by common separators
    final parts = text
        .replaceAll(';', ',')
        .replaceAll('•', ',')
        .replaceAll('\n', ',')
        .split(',');
    
    for (var part in parts) {
      part = part.trim();
      if (part.isNotEmpty) {
        result.add(part);
      }
    }
    
    // Try to validate each ingredient against known ingredients
    final validatedIngredients = <String>[];
    for (final ingredient in result) {
      final data = await getIngredientByName(ingredient);
      if (data.isNotEmpty) {
        // Use the canonical name if available
        validatedIngredients.add(data['name'] as String? ?? ingredient);
      } else {
        // Keep the original for now
        validatedIngredients.add(ingredient);
      }
    }
    
    return validatedIngredients;
  }
  
  /// Get ingredient from local database
  Future<Map<String, dynamic>> _getIngredientFromLocalDb(String name) async {
    // Implementation would depend on the local database solution
    // This is a placeholder
    return {};
  }
  
  /// Save ingredient to local database
  Future<void> _saveIngredientToLocalDb(
    String name,
    Map<String, dynamic> data,
  ) async {
    // Implementation would depend on the local database solution
    // This is a placeholder
  }
  
  /// Get conflict from local database
  Future<Map<String, dynamic>> _getConflictFromLocalDb(
    String ingredient1,
    String ingredient2,
  ) async {
    // Implementation would depend on the local database solution
    // This is a placeholder
    return {};
  }
  
  /// Save conflict to local database
  Future<void> _saveConflictToLocalDb(
    String ingredient1,
    String ingredient2,
    Map<String, dynamic> data,
  ) async {
    // Implementation would depend on the local database solution
    // This is a placeholder
  }
  
  /// Search ingredients by name
  Future<List<Map<String, dynamic>>> searchIngredients(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    final normalizedQuery = query.toLowerCase().trim();
    final results = <Map<String, dynamic>>[];
    
    // First search in cache
    for (final entry in _ingredientCache.entries) {
      if (entry.key.contains(normalizedQuery)) {
        results.add(entry.value);
      }
      
      // Limit to first 20 results
      if (results.length >= 20) {
        break;
      }
    }
    
    // If we have enough results from cache, return them
    if (results.length >= 5) {
      return results;
    }
    
    try {
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        // If we're offline, just return what we have from cache
        return results;
      }
      
      // Otherwise fetch from API
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/ingredients/search?q=$normalizedQuery'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        
        // Process results
        for (final item in data) {
          final ingredient = item as Map<String, dynamic>;
          final name = ingredient['name'] as String;
          
          // Cache the result
          _ingredientCache[name.toLowerCase()] = ingredient;
          
          // Add to results if not already there
          if (!results.any((r) => r['name'] == name)) {
            results.add(ingredient);
          }
          
          // Limit to first 20 results
          if (results.length >= 20) {
            break;
          }
        }
        
        return results;
      } else {
        throw Exception('Failed to search ingredients: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching ingredients: $e');
      // Return whatever we have from cache
      return results;
    }
  }
  
  /// Get ingredients by category
  Future<List<Map<String, dynamic>>> getIngredientsByCategory(
    String category,
  ) async {
    try {
      // Check connectivity
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        // Try to get from local database when offline
        // This is a placeholder
        return [];
      }
      
      // Fetch from API
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/ingredients/category/$category'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        
        // Process results
        final results = <Map<String, dynamic>>[];
        for (final item in data) {
          final ingredient = item as Map<String, dynamic>;
          final name = ingredient['name'] as String;
          
          // Cache the result
          _ingredientCache[name.toLowerCase()] = ingredient;
          
          results.add(ingredient);
        }
        
        return results;
      } else {
        throw Exception('Failed to get ingredients by category: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting ingredients by category: $e');
      return [];
    }
  }
}