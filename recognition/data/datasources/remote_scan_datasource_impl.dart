import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/scan_error.dart';
import '../../domain/entities/scan_history_item.dart';
import '../../utils/ingredient_parser.dart';
import 'remote_scan_datasource.dart';

/// Implementation of remote scan data source
class RemoteScanDataSourceImpl implements RemoteScanDataSource {
  /// HTTP client
  final http.Client _client;
  
  /// Base URL
  final String _baseUrl;
  
  /// Create remote scan data source
  RemoteScanDataSourceImpl({
    http.Client? client,
    String? baseUrl,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? 'https://api.example.com/api';
  
  @override
  Future<ScanHistoryItem> getProductByBarcode(String barcode) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/products/$barcode'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        return ScanHistoryItem(
          barcode: barcode,
          name: data['name'],
          brand: data['brand'],
          imageUrl: data['image_url'],
          ingredients: data['ingredients'] != null
              ? List<String>.from(data['ingredients'])
              : null,
          timestamp: DateTime.now(),
          scanType: ScanType.barcode,
        );
      } else {
        throw ScanError.network(
          'Failed to fetch product data: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error getting product by barcode: $e');
      
      // For now, return a dummy product
      // In a real app, this would throw an error
      return ScanHistoryItem(
        barcode: barcode,
        name: 'Unknown Product',
        timestamp: DateTime.now(),
        scanType: ScanType.barcode,
      );
    }
  }
  
  @override
  Future<ScanHistoryItem> extractIngredientsFromImage(dynamic image) async {
    try {
      // In a real app, this would send the image to a server for processing
      // For now, just return a dummy scan
      return ScanHistoryItem(
        barcode: 'image_scan_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Image Scan',
        ingredients: [
          'Water',
          'Glycerin',
          'Niacinamide',
          'Sodium Hyaluronate',
        ],
        timestamp: DateTime.now(),
        scanType: ScanType.image,
      );
    } catch (e) {
      debugPrint('Error extracting ingredients from image: $e');
      rethrow;
    }
  }
  
  @override
  Future<ScanHistoryItem> extractIngredientsFromText(String text) async {
    try {
      // Extract ingredients using local utility
      final ingredients = IngredientParser.extractIngredients(text);
      
      return ScanHistoryItem(
        barcode: 'text_scan_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Text Scan',
        ingredients: ingredients,
        timestamp: DateTime.now(),
        scanType: ScanType.text,
      );
    } catch (e) {
      debugPrint('Error extracting ingredients from text: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> addScanToHistory(ScanHistoryItem scan) async {
    // In a real app, this would send the scan to a server
    // For now, do nothing
  }
  
  @override
  Future<void> updateScan(ScanHistoryItem scan) async {
    // In a real app, this would update the scan on the server
    // For now, do nothing
  }
  
  @override
  Future<void> deleteScan(String barcode) async {
    // In a real app, this would delete the scan from the server
    // For now, do nothing
  }
  
  @override
  Future<void> clearScanHistory() async {
    // In a real app, this would clear the scan history on the server
    // For now, do nothing
  }
  
  @override
  Future<List<String>> analyzeIngredientConflicts(List<String> ingredients) async {
    try {
      // In a real app, this would send the ingredients to a server for analysis
      // For now, just return a sample set of conflicts
      final sampleConflicts = [
        'Niacinamide',
        'Retinol',
        'Salicylic Acid',
      ];
      
      return ingredients
          .where((ingredient) => 
              sampleConflicts.contains(ingredient))
          .toList();
    } catch (e) {
      debugPrint('Error analyzing ingredient conflicts: $e');
      return [];
    }
  }
  
  @override
  void dispose() {
    _client.close();
  }
}