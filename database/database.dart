import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/product_model.dart';
import '../models/scan_history_model.dart';
import '../models/user_preferences_model.dart';
import 'dart:convert';

part 'database.g.dart';

/// Table definition for scanned products
class ProductsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().unique()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get ingredients => text()();
  TextColumn get category => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get skinType => text().nullable()();
  BoolColumn get hasConflicts => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get localModified => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get serverModified => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Table definition for scan history
class ScanHistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get productBarcode => text().references(ProductsTable, #barcode)();
  IntColumn get userId => integer().nullable()();
  DateTimeColumn get scanDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
  TextColumn get conflictsDetected => text().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get localModified => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get serverModified => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Table definition for user preferences
class UserPreferencesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().nullable()();
  TextColumn get skinType => text()();
  TextColumn get skinConcerns => text()();
  TextColumn get allergies => text()();
  TextColumn get preferredBrands => text().nullable()();
  TextColumn get avoidIngredients => text().nullable()();
  BoolColumn get onboardingCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Table definition for ingredient conflicts
class IngredientConflictsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ingredient => text()();
  TextColumn get conflictingIngredient => text()();
  TextColumn get severity => text()();
  TextColumn get description => text()();
  TextColumn get reference => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Database class that ties all tables together
@DriftDatabase(tables: [
  ProductsTable,
  ScanHistoryTable,
  UserPreferencesTable,
  IngredientConflictsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle database migrations
      },
    );
  }
  
  // Product methods
  
  /// Get product by barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    final query = select(productsTable)..where((p) => p.barcode.equals(barcode));
    final result = await query.getSingleOrNull();
    
    if (result == null) {
      return null;
    }
    
    return _convertDbProductToModel(result);
  }
  
  /// Save product to database
  Future<void> saveProduct(Product product) async {
    await into(productsTable).insertOnConflictUpdate(
      ProductsTableCompanion.insert(
        barcode: product.barcode,
        name: product.name,
        brand: Value(product.brand),
        imageUrl: Value(product.imageUrl),
        ingredients: json.encode(product.ingredients),
        category: Value(product.category),
        description: Value(product.description),
        skinType: Value(product.skinType),
        hasConflicts: Value(product.hasConflicts),
        createdAt: Value(product.createdAt ?? DateTime.now()),
        localModified: DateTime.now(),
        serverModified: const Value(null),
        syncStatus: const Value('local'),
      ),
    );
  }
  
  /// Get all products
  Future<List<Product>> getAllProducts() async {
    final results = await select(productsTable).get();
    return results.map(_convertDbProductToModel).toList();
  }
  
  // Scan history methods
  
  /// Get favorite scans from history
  Future<List<ScanHistory>> getFavorites(int limit) async {
    try {
      final query = select(scanHistoryTable)
        ..where((tbl) => tbl.favorite.equals(true))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.scanDate)])
        ..limit(limit);
      
      final results = await query.get();
      List<ScanHistory> favorites = [];
      
      for (final dbScan in results) {
        // Get associated product
        final product = await getProductByBarcode(dbScan.productBarcode);
        
        favorites.add(_convertDbScanToModel(dbScan, product));
      }
      
      return favorites;
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }
  
  /// Get scan history with optional limit
  Future<List<ScanHistory>> getScanHistory(int limit) async {
    final query = select(scanHistoryTable)
      ..orderBy([(t) => OrderingTerm.desc(t.scanDate)])
      ..limit(limit);
    
    final results = await query.get();
    List<ScanHistory> history = [];
    
    for (final dbScan in results) {
      // Get associated product
      final product = await getProductByBarcode(dbScan.productBarcode);
      
      history.add(_convertDbScanToModel(dbScan, product));
    }
    
    return history;
  }
  
  /// Toggle favorite status for a scan
  Future<ScanHistory?> toggleFavorite(int scanId) async {
    try {
      // Get current scan
      final scan = await (select(scanHistoryTable)..where((t) => t.id.equals(scanId))).getSingleOrNull();
      
      if (scan == null) {
        print('Scan not found with ID: $scanId');
        return null;
      }
      
      // Toggle favorite status
      final updatedFavorite = !scan.favorite;
      
      // Update in database
      await (update(scanHistoryTable)..where((t) => t.id.equals(scanId))).write(
        ScanHistoryTableCompanion(
          favorite: Value(updatedFavorite),
          localModified: Value(DateTime.now()),
          syncStatus: const Value('local'),
        ),
      );
      
      // Get updated scan
      final updated = await (select(scanHistoryTable)..where((t) => t.id.equals(scanId))).getSingle();
      final product = await getProductByBarcode(updated.productBarcode);
      
      return _convertDbScanToModel(updated, product);
    } catch (e) {
      print('Error toggling favorite: $e');
      return null;
    }
  }
  
  /// Save scan history entry
  Future<ScanHistory?> saveScanHistory(ScanHistory scan) async {
    // First make sure the product exists in the database
    if (scan.product != null) {
      await saveProduct(scan.product!);
    }
    
    // Insert scan history
    final id = await into(scanHistoryTable).insert(
      ScanHistoryTableCompanion.insert(
        productBarcode: scan.productBarcode,
        userId: Value(scan.userId),
        scanDate: scan.scanDate,
        notes: Value(scan.notes),
        conflictsDetected: Value(scan.conflictsDetected),
        favorite: Value(scan.favorite),
        localModified: DateTime.now(),
        serverModified: const Value(null),
        syncStatus: const Value('local'),
      ),
    );
    
    // Get the saved scan
    final saved = await (select(scanHistoryTable)..where((t) => t.id.equals(id))).getSingle();
    
    // Return with product included
    return _convertDbScanToModel(saved, scan.product);
  }
  
  // User preferences methods
  
  /// Get user preferences
  Future<UserPreferences?> getUserPreferences() async {
    try {
      final query = select(userPreferencesTable);
      final result = await query.getSingleOrNull();
      
      if (result == null) {
        return null;
      }
      
      return _convertDbPreferencesToModel(result);
    } catch (e) {
      print('Error getting user preferences: $e');
      return null;
    }
  }
  
  /// Save user preferences
  Future<UserPreferences?> saveUserPreferences(UserPreferences preferences) async {
    try {
      // Check if preferences already exist
      final existingPrefs = await getUserPreferences();
      int id;
      
      if (existingPrefs != null) {
        // Update existing
        await update(userPreferencesTable).replace(
          UserPreferencesTableCompanion(
            id: Value(existingPrefs.id!),
            userId: Value(preferences.userId),
            skinType: Value(preferences.skinType),
            skinConcerns: Value(json.encode(preferences.skinConcerns)),
            allergies: Value(json.encode(preferences.allergies)),
            preferredBrands: Value(preferences.preferredBrands != null 
                ? json.encode(preferences.preferredBrands)
                : null),
            avoidIngredients: Value(preferences.avoidIngredients != null 
                ? json.encode(preferences.avoidIngredients)
                : null),
            onboardingCompleted: Value(preferences.onboardingCompleted),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value('local'),
          ),
        );
        id = existingPrefs.id!;
      } else {
        // Insert new
        id = await into(userPreferencesTable).insert(
          UserPreferencesTableCompanion.insert(
            userId: Value(preferences.userId),
            skinType: preferences.skinType,
            skinConcerns: json.encode(preferences.skinConcerns),
            allergies: json.encode(preferences.allergies),
            preferredBrands: Value(preferences.preferredBrands != null 
                ? json.encode(preferences.preferredBrands)
                : null),
            avoidIngredients: Value(preferences.avoidIngredients != null 
                ? json.encode(preferences.avoidIngredients)
                : null),
            onboardingCompleted: Value(preferences.onboardingCompleted),
            updatedAt: DateTime.now(),
            syncStatus: const Value('local'),
          ),
        );
      }
      
      // Return saved preferences
      final saved = await (select(userPreferencesTable)..where((t) => t.id.equals(id))).getSingle();
      return _convertDbPreferencesToModel(saved);
    } catch (e) {
      print('Error saving user preferences: $e');
      return null;
    }
  }
  
  // Helper methods
  
  /// Convert database product to model
  Product _convertDbProductToModel(ProductsTableData data) {
    List<String> ingredientsList = [];
    
    try {
      final decoded = json.decode(data.ingredients);
      if (decoded is List) {
        ingredientsList = decoded.map((item) => item.toString()).toList();
      } else {
        // If not a list, parse as comma-separated string
        ingredientsList = data.ingredients.split(',').map((s) => s.trim()).toList();
      }
    } catch (e) {
      // If parsing fails, use as is
      ingredientsList = [data.ingredients];
    }
    
    return Product(
      id: data.id,
      barcode: data.barcode,
      name: data.name,
      brand: data.brand,
      imageUrl: data.imageUrl,
      ingredients: ingredientsList,
      category: data.category,
      description: data.description,
      skinType: data.skinType,
      hasConflicts: data.hasConflicts,
      createdAt: data.createdAt,
    );
  }
  
  /// Convert database scan to model
  ScanHistory _convertDbScanToModel(ScanHistoryTableData data, Product? product) {
    return ScanHistory(
      id: data.id,
      userId: data.userId,
      productBarcode: data.productBarcode,
      scanDate: data.scanDate,
      notes: data.notes,
      conflictsDetected: data.conflictsDetected,
      favorite: data.favorite,
      product: product,
    );
  }
  
  /// Convert database preferences to model
  UserPreferences _convertDbPreferencesToModel(UserPreferencesTableData data) {
    List<String> skinConcerns = [];
    List<String> allergies = [];
    List<String>? preferredBrands;
    List<String>? avoidIngredients;
    
    try {
      skinConcerns = (json.decode(data.skinConcerns) as List)
          .map((item) => item.toString())
          .toList();
      
      allergies = (json.decode(data.allergies) as List)
          .map((item) => item.toString())
          .toList();
      
      if (data.preferredBrands != null) {
        preferredBrands = (json.decode(data.preferredBrands!) as List)
            .map((item) => item.toString())
            .toList();
      }
      
      if (data.avoidIngredients != null) {
        avoidIngredients = (json.decode(data.avoidIngredients!) as List)
            .map((item) => item.toString())
            .toList();
      }
    } catch (e) {
      print('Error parsing preferences: $e');
    }
    
    return UserPreferences(
      id: data.id,
      userId: data.userId,
      skinType: data.skinType,
      skinConcerns: skinConcerns,
      allergies: allergies,
      preferredBrands: preferredBrands,
      avoidIngredients: avoidIngredients,
      onboardingCompleted: data.onboardingCompleted,
      updatedAt: data.updatedAt,
    );
  }
}

/// Open a connection to the database
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'skinscan.sqlite'));
    return NativeDatabase(file);
  });
}