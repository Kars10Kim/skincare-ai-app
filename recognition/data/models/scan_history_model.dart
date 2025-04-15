import 'package:hive/hive.dart';

import '../../domain/entities/scan_history_item.dart';

part 'scan_history_model.g.dart';

/// Hive type IDs
@HiveType(typeId: 1)
enum HiveScanType {
  @HiveField(0)
  barcode,
  @HiveField(1)
  image,
  @HiveField(2)
  text,
}

/// Scan history item model for Hive
@HiveType(typeId: 0)
class ScanHistoryModel extends HiveObject {
  @HiveField(0)
  final String barcode;
  
  @HiveField(1)
  final String? name;
  
  @HiveField(2)
  final String? brand;
  
  @HiveField(3)
  final String? imageUrl;
  
  @HiveField(4)
  final List<String>? ingredients;
  
  @HiveField(5)
  final DateTime timestamp;
  
  @HiveField(6)
  final String? notes;
  
  @HiveField(7)
  final bool isFavorite;
  
  @HiveField(8)
  final HiveScanType scanType;
  
  @HiveField(9)
  final Map<String, dynamic>? additionalData;
  
  /// Create a scan history model
  ScanHistoryModel({
    required this.barcode,
    this.name,
    this.brand,
    this.imageUrl,
    this.ingredients,
    required this.timestamp,
    this.notes,
    this.isFavorite = false,
    required this.scanType,
    this.additionalData,
  });
  
  /// Create from entity
  factory ScanHistoryModel.fromEntity(ScanHistoryItem entity) {
    return ScanHistoryModel(
      barcode: entity.barcode,
      name: entity.name,
      brand: entity.brand,
      imageUrl: entity.imageUrl,
      ingredients: entity.ingredients,
      timestamp: entity.timestamp,
      notes: entity.notes,
      isFavorite: entity.isFavorite,
      scanType: _mapScanTypeToHive(entity.scanType),
      additionalData: entity.additionalData,
    );
  }
  
  /// Convert to entity
  ScanHistoryItem toEntity() {
    return ScanHistoryItem(
      barcode: barcode,
      name: name,
      brand: brand,
      imageUrl: imageUrl,
      ingredients: ingredients,
      timestamp: timestamp,
      notes: notes,
      isFavorite: isFavorite,
      scanType: _mapHiveToScanType(scanType),
      additionalData: additionalData,
    );
  }
  
  /// Map ScanType to HiveScanType
  static HiveScanType _mapScanTypeToHive(ScanType type) {
    switch (type) {
      case ScanType.barcode:
        return HiveScanType.barcode;
      case ScanType.image:
        return HiveScanType.image;
      case ScanType.text:
        return HiveScanType.text;
    }
  }
  
  /// Map HiveScanType to ScanType
  static ScanType _mapHiveToScanType(HiveScanType type) {
    switch (type) {
      case HiveScanType.barcode:
        return ScanType.barcode;
      case HiveScanType.image:
        return ScanType.image;
      case HiveScanType.text:
        return ScanType.text;
    }
  }
}