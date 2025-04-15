import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Products table
class Products extends Table {
  /// Product ID
  TextColumn get id => text()();
  
  /// Product barcode
  TextColumn get barcode => text()();
  
  /// Product name
  TextColumn get name => text()();
  
  /// Product brand
  TextColumn get brand => text()();
  
  /// Product image URL
  TextColumn get imageUrl => text().nullable()();
  
  /// Product ingredients
  TextColumn get ingredients => text()();
  
  /// Product description
  TextColumn get description => text().nullable()();
  
  /// Last updated timestamp
  DateTimeColumn get updatedAt => dateTime()();
  
  /// Set primary key
  @override
  Set<Column> get primaryKey => {id};
}

/// Scans table
class Scans extends Table {
  /// Scan ID
  TextColumn get id => text()();
  
  /// Product ID
  TextColumn get productId => text().nullable()();
  
  /// Raw scan text (when no product match)
  TextColumn get rawText => text().nullable()();
  
  /// Safety score
  IntColumn get safetyScore => integer().nullable()();
  
  /// Analysis results
  TextColumn get analysisResults => text().nullable()();
  
  /// Scan timestamp
  DateTimeColumn get timestamp => dateTime()();
  
  /// Is this scan synced to server
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  
  /// User ID
  TextColumn get userId => text().nullable()();
  
  /// Set primary key
  @override
  Set<Column> get primaryKey => {id};
}

/// Sync operations table
class SyncOperations extends Table {
  /// Operation ID
  TextColumn get id => text()();
  
  /// Entity type
  TextColumn get entityType => text()();
  
  /// Entity ID
  TextColumn get entityId => text()();
  
  /// Operation type (0=create, 1=update, 2=delete)
  IntColumn get operationType => integer()();
  
  /// Operation data
  TextColumn get data => text()();
  
  /// Status (0=pending, 1=in_progress, 2=completed, 3=failed)
  IntColumn get status => integer()();
  
  /// Created timestamp
  DateTimeColumn get createdAt => dateTime()();
  
  /// Updated timestamp
  DateTimeColumn get updatedAt => dateTime()();
  
  /// Error message
  TextColumn get errorMessage => text().nullable()();
  
  /// Retry count
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  
  /// Set primary key
  @override
  Set<Column> get primaryKey => {id};
}

/// User preferences table
class UserPreferences extends Table {
  /// User ID
  TextColumn get userId => text()();
  
  /// Skin type
  IntColumn get skinType => integer().nullable()();
  
  /// Skin concerns
  TextColumn get skinConcerns => text()();
  
  /// Allergens
  TextColumn get allergens => text()();
  
  /// Updated timestamp
  DateTimeColumn get updatedAt => dateTime()();
  
  /// Set primary key
  @override
  Set<Column> get primaryKey => {userId};
}

/// Ingredients table
class Ingredients extends Table {
  /// Ingredient ID
  TextColumn get id => text()();
  
  /// Ingredient name
  TextColumn get name => text()();
  
  /// Description
  TextColumn get description => text().nullable()();
  
  /// Function
  TextColumn get function => text().nullable()();
  
  /// INCI name
  TextColumn get inciName => text().nullable()();
  
  /// EWG score
  IntColumn get ewgScore => integer().nullable()();
  
  /// Categories
  TextColumn get categories => text()();
  
  /// Potential issues
  TextColumn get potentialIssues => text()();
  
  /// Last updated timestamp
  DateTimeColumn get updatedAt => dateTime()();
  
  /// Set primary key
  @override
  Set<Column> get primaryKey => {id};
}

/// Ingredient conflicts table
class IngredientConflicts extends Table {
  /// Conflict ID
  TextColumn get id => text()();
  
  /// First ingredient
  TextColumn get ingredient1 => text()();
  
  /// Second ingredient
  TextColumn get ingredient2 => text()();
  
  /// Severity
  IntColumn get severity => integer()();
  
  /// Description
  TextColumn get description => text()();
  
  /// Recommendation
  TextColumn get recommendation => text().nullable()();
  
  /// Scientific references
  TextColumn get scientificReferences => text()();
  
  /// Last updated timestamp
  DateTimeColumn get updatedAt => dateTime()();
  
  /// Set primary key
  @override
  Set<Column> get primaryKey => {id};
}

/// Application database
@DriftDatabase(
  tables: [
    Products,
    Scans,
    SyncOperations,
    UserPreferences,
    Ingredients,
    IngredientConflicts,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Creates the application database
  AppDatabase() : super(_openConnection());
  
  /// Database schema version
  @override
  int get schemaVersion => 1;
  
  /// Database migration
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations
      },
    );
  }
  
  // Products CRUD operations
  
  /// Get all products
  Future<List<Product>> getAllProducts() => select(products).get();
  
  /// Get product by ID
  Future<Product?> getProductById(String id) =>
      (select(products)..where((p) => p.id.equals(id))).getSingleOrNull();
  
  /// Get product by barcode
  Future<Product?> getProductByBarcode(String barcode) =>
      (select(products)..where((p) => p.barcode.equals(barcode))).getSingleOrNull();
  
  /// Insert or update a product
  Future<int> insertOrUpdateProduct(ProductsCompanion product) =>
      into(products).insertOnConflictUpdate(product);
  
  /// Delete a product
  Future<int> deleteProduct(String id) =>
      (delete(products)..where((p) => p.id.equals(id))).go();
  
  // Scans CRUD operations
  
  /// Get all scans
  Future<List<Scan>> getAllScans() =>
      (select(scans)..orderBy([(s) => OrderingTerm(expression: s.timestamp, mode: OrderingMode.desc)])).get();
  
  /// Get scan by ID
  Future<Scan?> getScanById(String id) =>
      (select(scans)..where((s) => s.id.equals(id))).getSingleOrNull();
  
  /// Insert or update a scan
  Future<int> insertOrUpdateScan(ScansCompanion scan) =>
      into(scans).insertOnConflictUpdate(scan);
  
  /// Delete a scan
  Future<int> deleteScan(String id) =>
      (delete(scans)..where((s) => s.id.equals(id))).go();
  
  /// Get unsynced scans
  Future<List<Scan>> getUnsyncedScans() =>
      (select(scans)..where((s) => s.isSynced.equals(false))).get();
  
  /// Mark scan as synced
  Future<bool> markScanSynced(String id) {
    return transaction(() async {
      final result = await (update(scans)..where((s) => s.id.equals(id)))
          .write(const ScansCompanion(isSynced: Value(true)));
      return result > 0;
    });
  }
  
  // Sync operations
  
  /// Get all pending sync operations
  Future<List<SyncOperation>> getPendingSyncOperations() =>
      (select(syncOperations)
        ..where((s) => s.status.equals(0))
        ..orderBy([(s) => OrderingTerm(expression: s.createdAt)]))
      .get();
  
  /// Insert a sync operation
  Future<int> insertSyncOperation(SyncOperationsCompanion operation) =>
      into(syncOperations).insert(operation);
  
  /// Update a sync operation
  Future<bool> updateSyncOperation(SyncOperationsCompanion operation) {
    return transaction(() async {
      final result = await (update(syncOperations)
        ..where((s) => s.id.equals(operation.id.value)))
        .write(operation);
      return result > 0;
    });
  }
  
  /// Delete a sync operation
  Future<int> deleteSyncOperation(String id) =>
      (delete(syncOperations)..where((s) => s.id.equals(id))).go();
  
  // Favorites operations
  
  /// Get favorite scans
  Future<List<ScanHistory>> getFavorites(int limit) {
    return (select(scanHistory)
      ..where((s) => s.favorite.equals(true))
      ..orderBy([(s) => OrderingTerm(expression: s.scanDate, mode: OrderingMode.desc)])
      ..limit(limit))
      .get();
  }
  
  /// Toggle favorite status for a scan
  Future<ScanHistory?> toggleFavorite(int scanId) async {
    return transaction(() async {
      final scan = await (select(scanHistory)..where((s) => s.id.equals(scanId))).getSingleOrNull();
      
      if (scan == null) return null;
      
      final newStatus = !scan.favorite;
      
      await (update(scanHistory)..where((s) => s.id.equals(scanId)))
          .write(ScanHistoryCompanion(favorite: Value(newStatus)));
      
      return (await (select(scanHistory)..where((s) => s.id.equals(scanId))).getSingle());
    });
  }
  
  // User preferences
  
  /// Get user preferences
  Future<UserPreference?> getUserPreferences(String userId) =>
      (select(userPreferences)..where((p) => p.userId.equals(userId))).getSingleOrNull();
  
  /// Save user preferences
  Future<int> saveUserPreferences(UserPreferencesCompanion preferences) =>
      into(userPreferences).insertOnConflictUpdate(preferences);
}

/// Open the database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'skincare_app.sqlite'));
    return NativeDatabase(file);
  });
}