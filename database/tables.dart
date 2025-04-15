import 'package:drift/drift.dart';

// Table for skincare products
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().withLength(min: 1, max: 50)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get brand => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get ingredients => text()(); // Comma-separated list of ingredients
  BoolColumn get hasConflicts => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {barcode};
}

// Table for scan history
class ScanHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get productBarcode => text().references(Products, #barcode)();
  DateTimeColumn get scanDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
  TextColumn get conflictsDetected => text().nullable()(); // JSON string of conflicts
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  
  @override
  List<String> get customConstraints => ['UNIQUE (product_barcode, scan_date)'];
}

// Table for user preferences
class UserPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get skinType => text()(); // dry, oily, combination, sensitive, normal
  TextColumn get skinConcerns => text()(); // JSON string of skin concerns
  TextColumn get allergies => text()(); // JSON string of allergies
  TextColumn get preferredBrands => text().nullable()(); // JSON string of preferred brands
  TextColumn get avoidIngredients => text().nullable()(); // JSON string of ingredients to avoid
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Table for ingredients
class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()(); // e.g., 'acid', 'vitamin', 'moisturizer'
  TextColumn get benefits => text().nullable()(); // JSON string of benefits
  TextColumn get concerns => text().nullable()(); // JSON string of potential concerns
  
  @override
  Set<Column> get primaryKey => {id};
}

// Table for ingredient conflicts
class IngredientConflicts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ingredientId => integer().references(Ingredients, #id)();
  IntColumn get conflictingIngredientId => integer().references(Ingredients, #id)();
  TextColumn get severity => text()(); // low, medium, high
  TextColumn get description => text()();
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<String> get customConstraints => [
    'UNIQUE (ingredient_id, conflicting_ingredient_id)'
  ];
}