import '../localization/app_localizations.dart';

/// Extension to add product recognition localizations to AppLocalizations
extension ProductRecognitionLocalizations on AppLocalizations {
  /// Product recognition screen title
  String get productRecognition => 'Product Recognition';
  
  /// Barcode tab title
  String get barcode => 'Barcode';
  
  /// Ingredients tab title
  String get ingredients => 'Ingredients';
  
  /// Clear image tooltip
  String get clearImage => 'Clear Image';
  
  /// Processing image text
  String get processingImage => 'Processing Image...';
  
  /// Take barcode photo text
  String get takeBarcodePhoto => 'Take a photo of the product barcode';
  
  /// Take ingredients photo text
  String get takeIngredientsPhoto => 'Take a photo of the ingredients list';
  
  /// Camera button text
  String get camera => 'Camera';
  
  /// Gallery button text
  String get gallery => 'Gallery';
  
  /// Scan barcode instructions
  String get scanBarcodeInstructions => 'Position the barcode within the frame';
  
  /// Scan ingredients instructions
  String get scanIngredientsInstructions => 'Position the ingredients list within the frame';
  
  /// No ingredients found text
  String get noIngredientsFound => 'No ingredients found in the image';
  
  /// Invalid barcode text
  String get invalidBarcode => 'Invalid or unrecognized barcode';
  
  /// Product not found text
  String get productNotFound => 'Product not found in database';
  
  /// Network error text
  String get networkError => 'Network error. Check your connection';
  
  /// Unknown error text
  String get unknownError => 'Unknown error occurred';
  
  /// Try again button text
  String get tryAgain => 'Try Again';
  
  /// Manual entry button text
  String get manualEntry => 'Manual Entry';
  
  /// Cancel button text
  String get cancel => 'Cancel';
  
  /// Save button text
  String get save => 'Save';
}