class ApiConstants {
  // Base API URL
  static const String baseUrl = 'http://localhost:5000'; // In production, change to actual URL
  
  // API Endpoints
  static const String productsEndpoint = '/api/products';
  static const String scanHistoryEndpoint = '/api/scan_history';
  static const String userPreferencesEndpoint = '/api/user_preferences';
  static const String ingredientsEndpoint = '/api/ingredients';
  static const String ingredientConflictsEndpoint = '/api/ingredients/check-conflicts';
  
  // External API for product data (OpenFoodFacts)
  static const String openFoodFactsApi = 'https://world.openfoodfacts.org/api/v0/product/';
}