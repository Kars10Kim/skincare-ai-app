import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../models/product/product_model.dart';
import '../services/sync_service.dart';
import '../services/worker_service.dart';
import '../services/sync_queue_service.dart';
import '../services/error_handler.dart';
import '../services/connectivity_service.dart';
import '../services/service_locator.dart';

/// Repository for scan operations
class ScanRepository {
  /// Database instance
  final AppDatabase _database;
  
  /// Sync service
  final SyncService _syncService;
  
  /// UUID generator
  final _uuid = const Uuid();
  
  /// Creates a scan repository
  ScanRepository(this._database, this._syncService);
  
  /// Get all scans
  Future<List<ProductAnalysisResult>> getAllScans() async {
    final scans = await _database.getAllScans();
    return _mapScansToAnalysisResults(scans);
  }
  
  /// Get a scan by ID
  Future<ProductAnalysisResult?> getScanById(String id) async {
    final scan = await _database.getScanById(id);
    if (scan == null) {
      return null;
    }
    
    return _mapScanToAnalysisResult(scan);
  }
  
  /// Get a product by barcode from local database
  Future<ProductAnalysisResult?> getProductByBarcode(String barcode) async {
    final product = await _database.getProductByBarcode(barcode);
    if (product == null) {
      return null;
    }
    
    // Find the most recent scan for this product
    final scans = await _database.getAllScans();
    final productScans = scans.where((s) => s.productId == product.id).toList();
    
    if (productScans.isEmpty) {
      // If no scan exists, create a minimal result
      return ProductAnalysisResult(
        product: Product(
          id: product.id,
          barcode: product.barcode,
          name: product.name,
          brand: product.brand,
          imageUrl: product.imageUrl,
          ingredients: product.ingredients.split(','),
          description: product.description,
        ),
        conflicts: [],
        safetyScore: 0,
      );
    }
    
    // Return the most recent scan result
    final latestScan = productScans.reduce(
      (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
    );
    
    return _mapScanToAnalysisResult(latestScan);
  }
  
  /// Save a scan
  Future<ProductAnalysisResult> saveScan(ProductAnalysisResult result) async {
    final scanId = _uuid.v4();
    final timestamp = DateTime.now();
    
    try {
      // Save product first using worker isolation for database operation
      await getIt<WorkerService>().runTask<Product, void>(
        _isolatedSaveProduct,
        result.product,
      );
    
      // Then save the scan
      final scanCompanion = ScansCompanion(
        id: Value(scanId),
        productId: Value(result.product.id),
        safetyScore: Value(result.safetyScore),
        analysisResults: Value(_serializeAnalysisData(result)),
        timestamp: Value(timestamp),
        isSynced: const Value(false),
        userId: const Value(null), // TODO: Add user ID when auth is implemented
      );
    
      await _database.insertOrUpdateScan(scanCompanion);
    
      // Create sync operation
      final syncData = _createScanSyncData(scanId, result);
    
      // Add to sync queue using connectivity-aware queue service
      if (getIt<ConnectivityService>().isConnected) {
        // If online, use traditional sync
        await _syncService.queueScanSync(scanId, syncData);
      } else {
        // If offline, queue for later sync
        await getIt<SyncQueueService>().addOperation(
          SyncOperation(
            type: SyncOperationType.create,
            entityType: 'scan',
            entityId: scanId,
            data: syncData,
            timestamp: timestamp,
          ),
        );
      }
    } catch (e, stackTrace) {
      // Use centralized error handling
      await getIt<ErrorHandler>().handleError(
        'Failed to save scan: $e', 
        stackTrace,
      );
      rethrow;
    }
    
    return result;
  }
  
  /// Isolate function to save a product
  static Future<void> _isolatedSaveProduct(Product product) async {
    // This would be implemented to directly use a database connection
    // For now, it's a placeholder for demonstration
    // In a real implementation, you would inject the database connection
    return;
  }
  
  /// Delete a scan
  Future<bool> deleteScan(String id) async {
    try {
      final result = await _database.deleteScan(id);
      
      // Add to sync queue based on connectivity
      if (getIt<ConnectivityService>().isConnected) {
        // If online, use traditional sync
        await _syncService.queueScanDeletion(id);
      } else {
        // If offline, queue for later sync
        await getIt<SyncQueueService>().addOperation(
          SyncOperation(
            type: SyncOperationType.delete,
            entityType: 'scan',
            entityId: id,
            data: {'id': id},
          ),
        );
      }
      
      return result > 0;
    } catch (e, stackTrace) {
      // Use centralized error handling
      await getIt<ErrorHandler>().handleError(
        'Failed to delete scan: $e', 
        stackTrace,
      );
      return false;
    }
  }
  
  /// Save an ingredient analysis for offline use
  Future<void> saveIngredientAnalysis(
    String ingredientText,
    ProductAnalysisResult result,
  ) async {
    final scanId = _uuid.v4();
    final timestamp = DateTime.now();
    
    try {
      // Process ingredients in background worker
      final processedIngredients = await getIt<WorkerService>().analyzeIngredients(
        result.product.ingredients,
      );
      
      // Save the product if available using worker isolation
      if (result.product.id.isNotEmpty) {
        await getIt<WorkerService>().runTask<Product, void>(
          _isolatedSaveProduct,
          result.product,
        );
      }
      
      // Save the scan
      final scanCompanion = ScansCompanion(
        id: Value(scanId),
        productId: Value(result.product.id.isEmpty ? null : result.product.id),
        rawText: Value(ingredientText),
        safetyScore: Value(result.safetyScore),
        analysisResults: Value(_serializeAnalysisData(result)),
        timestamp: Value(timestamp),
        isSynced: const Value(false),
        userId: const Value(null), // TODO: Add user ID when auth is implemented
      );
      
      await _database.insertOrUpdateScan(scanCompanion);
      
      // Create sync data with processed ingredients included
      final syncData = _createScanSyncData(
        scanId, 
        result, 
        ingredientText: ingredientText,
      );
      
      // Merge processed ingredient data
      syncData['processed_ingredients'] = processedIngredients;
      
      // Add to sync queue based on connectivity
      if (getIt<ConnectivityService>().isConnected) {
        // If online, use traditional sync
        await _syncService.queueScanSync(scanId, syncData);
      } else {
        // If offline, queue for later sync
        await getIt<SyncQueueService>().addOperation(
          SyncOperation(
            type: SyncOperationType.create,
            entityType: 'scan',
            entityId: scanId,
            data: syncData,
            timestamp: timestamp,
          ),
        );
      }
    } catch (e, stackTrace) {
      // Use centralized error handling
      await getIt<ErrorHandler>().handleError(
        'Failed to save ingredient analysis: $e', 
        stackTrace,
      );
      rethrow;
    }
  }
  
  /// Save a product to the database
  Future<void> _saveProduct(Product product) async {
    final productCompanion = ProductsCompanion(
      id: Value(product.id),
      barcode: Value(product.barcode),
      name: Value(product.name),
      brand: Value(product.brand),
      imageUrl: Value(product.imageUrl),
      ingredients: Value(product.ingredients.join(',')),
      description: Value(product.description),
      updatedAt: Value(DateTime.now()),
    );
    
    await _database.insertOrUpdateProduct(productCompanion);
  }
  
  /// Map database scans to product analysis results
  List<ProductAnalysisResult> _mapScansToAnalysisResults(List<Scan> scans) {
    return scans.map(_mapScanToAnalysisResult).toList();
  }
  
  /// Map a single database scan to a product analysis result
  ProductAnalysisResult _mapScanToAnalysisResult(Scan scan) {
    if (scan.analysisResults == null) {
      // Create a minimal result if no analysis data
      return ProductAnalysisResult(
        product: Product(
          id: scan.productId ?? '',
          barcode: '',
          name: 'Unknown Product',
          brand: 'Unknown Brand',
          ingredients: scan.rawText?.split(',') ?? [],
        ),
        conflicts: [],
        safetyScore: scan.safetyScore ?? 0,
      );
    }
    
    // Parse the analysis results
    final analysisData = jsonDecode(scan.analysisResults!);
    return ProductAnalysisResult.fromJson(analysisData);
  }
  
  /// Serialize analysis data for storage
  String _serializeAnalysisData(ProductAnalysisResult result) {
    return jsonEncode(result.toJson());
  }
  
  /// Create sync data for a scan
  Map<String, dynamic> _createScanSyncData(
    String scanId,
    ProductAnalysisResult result, {
    String? ingredientText,
  }) {
    return {
      'id': scanId,
      'product_id': result.product.id,
      'raw_text': ingredientText,
      'safety_score': result.safetyScore,
      'conflicts': result.conflicts.map((c) => c.toJson()).toList(),
      'allergen_matches': result.allergenMatches,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// Process text from an image using worker isolation
  Future<List<String>> processImageTextForIngredients(String imagePath) async {
    try {
      // Process the image text in a background isolate
      final ingredients = await getIt<WorkerService>().processImageForIngredients(imagePath);
      return ingredients;
    } catch (e, stackTrace) {
      await getIt<ErrorHandler>().handleError(
        'Failed to process image: $e', 
        stackTrace,
      );
      return [];
    }
  }
  
  /// Detect ingredient conflicts in the background
  Future<List<Map<String, dynamic>>> detectIngredientConflicts(
    List<String> ingredients,
    List<String> userAllergens,
  ) async {
    try {
      // Process conflicts in a background isolate
      return await getIt<WorkerService>().detectConflicts(ingredients, userAllergens);
    } catch (e, stackTrace) {
      await getIt<ErrorHandler>().handleError(
        'Failed to detect conflicts: $e', 
        stackTrace,
      );
      return [];
    }
  }
  
  /// Calculate safety score in the background
  Future<int> calculateSafetyScore(
    List<String> ingredients,
    List<Map<String, dynamic>> conflicts,
    List<String> userAllergens,
  ) async {
    try {
      // Calculate score in a background isolate
      return await getIt<WorkerService>().calculateSafetyScore(
        ingredients,
        conflicts,
        userAllergens,
      );
    } catch (e, stackTrace) {
      await getIt<ErrorHandler>().handleError(
        'Failed to calculate safety score: $e', 
        stackTrace,
      );
      return 50; // Default middle score on error
    }
  }
}