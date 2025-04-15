import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

part 'schema.g.dart';

// Tables with conflict tracking
class ScannedProducts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().unique()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get skinType => text().nullable()();
  TextColumn get ingredientJson => text()(); // Stores serialized ingredients
  
  // Sync control fields
  DateTimeColumn get localModified => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get serverModified => dateTime().nullable()();
  TextColumn get conflictFlag => text().withDefault(const Constant(''))(); // 'local'|'server'|''
}

// For storing individual ingredients
class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get category => text()();
  TextColumn get propertiesJson => text().nullable()(); // Stores serialized properties
  
  // Sync control fields
  DateTimeColumn get localModified => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get serverModified => dateTime().nullable()();
  TextColumn get conflictFlag => text().withDefault(const Constant(''))();
}

// For storing ingredient conflicts
class IngredientConflicts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ingredientA => text()();
  TextColumn get ingredientB => text()();
  TextColumn get reason => text()();
  TextColumn get severity => text()(); // mild|moderate|severe|critical
  TextColumn get recommendation => text()();
  TextColumn get studiesJson => text().nullable()(); // Stores serialized study references
  
  // Sync control fields
  DateTimeColumn get localModified => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get serverModified => dateTime().nullable()();
  TextColumn get conflictFlag => text().withDefault(const Constant(''))();
  
  // Compound unique constraint
  @override
  List<Set<Column>> get uniqueKeys => [
    {ingredientA, ingredientB},
  ];
}

// For storing user preferences
class UserPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().unique()();
  TextColumn get preferencesJson => text()(); // Stores serialized preferences
  BoolColumn get onboardingCompleted => boolean().withDefault(const Constant(false))();
  
  // Sync control fields
  DateTimeColumn get localModified => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get serverModified => dateTime().nullable()();
  TextColumn get conflictFlag => text().withDefault(const Constant(''))();
}

// For storing scan history
class ScanHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text()();
  DateTimeColumn get scanDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get userId => text().nullable()(); // Optional user ID for authenticated users
  
  // Sync control fields
  DateTimeColumn get localModified => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get serverModified => dateTime().nullable()();
  TextColumn get conflictFlag => text().withDefault(const Constant(''))();
}

// Many-to-many relationship between products and ingredients
class ProductIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer()();
  IntColumn get ingredientId => integer()();
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {productId, ingredientId},
  ];
}

// Enum for conflict resolution
enum ConflictResolution {
  local,
  server,
  merge
}