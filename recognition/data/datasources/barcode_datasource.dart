import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../domain/entities/recognized_product.dart';
import '../../utils/exceptions.dart';

/// Data source for scanning barcodes
abstract class BarcodeDataSource {
  /// Scan a barcode from an image
  Future<BarcodeResult> scanBarcode(String imagePath);
  
  /// Validate a barcode format
  bool isValidBarcode(String? barcode);
}

/// Implementation of the barcode data source
class BarcodeDataSourceImpl implements BarcodeDataSource {
  /// The barcode scanner
  final BarcodeScanner _scanner;
  
  /// Create a barcode data source
  BarcodeDataSourceImpl() : _scanner = BarcodeScanner();
  
  @override
  Future<BarcodeResult> scanBarcode(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final barcodes = await _scanner.processImage(inputImage);
      
      if (barcodes.isEmpty) {
        return BarcodeResult.invalid();
      }
      
      // Get the first valid barcode
      for (final barcode in barcodes) {
        final rawValue = barcode.rawValue;
        if (isValidBarcode(rawValue)) {
          return BarcodeResult.valid(
            rawValue!,
            barcode.format.name,
          );
        }
      }
      
      // No valid barcodes found
      return BarcodeResult.invalid();
    } on PlatformException catch (e) {
      throw BarcodeScanException(e.code, e.message);
    } catch (e) {
      throw BarcodeScanException('unknown', e.toString());
    }
  }
  
  @override
  bool isValidBarcode(String? barcode) {
    if (barcode == null || barcode.isEmpty) {
      return false;
    }
    
    // Most common product barcodes are 8, 12, 13, or 14 digits
    // EAN-8, UPC-A, EAN-13, GTIN-14
    if (RegExp(r'^\d{8}$|^\d{12}$|^\d{13}$|^\d{14}$').hasMatch(barcode)) {
      return _validateCheckDigit(barcode);
    }
    
    // Other valid formats like ISBN-13 (starts with 978 or 979)
    if (barcode.length == 13 && 
        (barcode.startsWith('978') || barcode.startsWith('979'))) {
      return _validateCheckDigit(barcode);
    }
    
    // QR codes and other formats may be valid for specific applications
    // Add additional validation as needed
    
    return false;
  }
  
  /// Validate the check digit for EAN/UPC/GTIN barcodes
  bool _validateCheckDigit(String barcode) {
    try {
      final digits = barcode.split('').map(int.parse).toList();
      final checkDigit = digits.removeLast();
      
      int sum = 0;
      for (int i = 0; i < digits.length; i++) {
        sum += (i % 2 == digits.length % 2) ? digits[i] * 3 : digits[i];
      }
      
      final calculatedCheckDigit = (10 - (sum % 10)) % 10;
      return checkDigit == calculatedCheckDigit;
    } catch (e) {
      return false;
    }
  }
  
  /// Dispose resources
  void dispose() {
    _scanner.close();
  }
}

/// Mock implementation of the barcode data source for testing or web
class MockBarcodeDataSource implements BarcodeDataSource {
  @override
  Future<BarcodeResult> scanBarcode(String imagePath) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // For testing purposes, return a valid barcode for specific test images
    if (imagePath.contains('test_valid_barcode')) {
      return BarcodeResult.valid('5901234123457', 'EAN-13');
    }
    
    // Otherwise return invalid
    return BarcodeResult.invalid();
  }
  
  @override
  bool isValidBarcode(String? barcode) {
    if (barcode == null || barcode.isEmpty) {
      return false;
    }
    
    // Basic validation for testing
    return RegExp(r'^\d{8}$|^\d{12}$|^\d{13}$|^\d{14}$').hasMatch(barcode);
  }
}