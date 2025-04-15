/// Utility for parsing ingredients from text
class IngredientParser {
  /// Common ingredient list markers
  static final List<String> _ingredientMarkers = [
    'ingredients:',
    'ingredients',
    'inci:',
    'inci',
    'contains:',
    'contains',
    'composition:',
    'composition',
  ];
  
  /// Words that typically aren't ingredients
  static final List<String> _nonIngredientWords = [
    'may',
    'contain',
    'contains',
    'might',
    'including',
    'included',
    'also',
    'with',
    'without',
    'free',
    'from',
    'made',
    'manufactured',
    'produced',
    'ingredients',
    'inci',
    'composition',
    'and',
    'the',
    'warning',
    'warnings',
    'caution',
    'cautions',
    'directions',
    'how',
    'to',
    'use',
    'apply',
    'application',
  ];
  
  /// Symbols to replace with commas
  static final List<String> _separatorSymbols = [
    '•',
    '·',
    '*',
    '|',
    ';',
    '/',
    '\\',
    '+',
    '#',
    '=',
    '>',
    '<',
    '~',
    '`',
    '.',
  ];
  
  /// Extract ingredients from text
  static List<String> extractIngredients(String text) {
    if (text.isEmpty) return [];
    
    // Normalize text (lowercase, remove extra whitespace)
    String normalizedText = text.toLowerCase().trim();
    
    // Replace newlines with spaces
    normalizedText = normalizedText.replaceAll(RegExp(r'\n+'), ' ');
    
    // Find ingredient section
    String ingredientSection = _findIngredientSection(normalizedText);
    if (ingredientSection.isEmpty) {
      // If no dedicated section found, use the entire text
      ingredientSection = normalizedText;
    }
    
    // Replace common separator symbols with commas
    for (final symbol in _separatorSymbols) {
      ingredientSection = ingredientSection.replaceAll(symbol, ',');
    }
    
    // Split by commas
    List<String> potentialIngredients = ingredientSection
        .split(',')
        .where((item) => item.trim().isNotEmpty)
        .map((item) => item.trim())
        .toList();
    
    // Filter out non-ingredients and clean
    List<String> ingredients = [];
    for (final ingredient in potentialIngredients) {
      // Skip very short items
      if (ingredient.length < 3) continue;
      
      // Skip non-ingredient words
      bool isNonIngredient = false;
      for (final word in _nonIngredientWords) {
        if (ingredient == word) {
          isNonIngredient = true;
          break;
        }
      }
      if (isNonIngredient) continue;
      
      // Clean the ingredient name
      final cleanedIngredient = _cleanIngredientName(ingredient);
      if (cleanedIngredient.isNotEmpty) {
        ingredients.add(cleanedIngredient);
      }
    }
    
    // Remove duplicates and sort
    return ingredients.toSet().toList()..sort();
  }
  
  /// Find the ingredients section of text
  static String _findIngredientSection(String text) {
    int startIndex = -1;
    
    // Look for ingredient markers
    for (final marker in _ingredientMarkers) {
      final index = text.indexOf(marker);
      if (index != -1) {
        startIndex = index + marker.length;
        break;
      }
    }
    
    if (startIndex == -1) {
      return '';
    }
    
    // Limit to the first section that appears to be ingredients
    // Look for the end of the ingredient list
    int endIndex = text.length;
    final List<String> endMarkers = [
      'directions:',
      'directions',
      'how to use:',
      'how to use',
      'caution:',
      'caution',
      'warning:',
      'warning',
      'made in',
      'manufactured',
      'expiration',
      'expiry',
      'barcode:',
      'storage:',
      'store',
    ];
    
    for (final marker in endMarkers) {
      final index = text.indexOf(marker, startIndex);
      if (index != -1 && index < endIndex) {
        endIndex = index;
      }
    }
    
    return text.substring(startIndex, endIndex).trim();
  }
  
  /// Clean an ingredient name
  static String _cleanIngredientName(String ingredient) {
    // Remove parenthetical content
    String cleaned = ingredient.replaceAll(RegExp(r'\(.*?\)'), '').trim();
    
    // Remove leading/trailing punctuation
    cleaned = cleaned.replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '').trim();
    
    // Remove numbers at the end (often percentages)
    cleaned = cleaned.replaceAll(RegExp(r'\s+\d+\.?\d*\%?$'), '').trim();
    
    return cleaned;
  }
}