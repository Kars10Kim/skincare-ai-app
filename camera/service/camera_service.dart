import 'dart:io';
import 'package:camera/camera.dart';
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/camera_models.dart';
import '../utils/error_handling.dart';
import '../../../services/memory/memory_analyzable.dart';
import '../../../services/memory/memory_pressure_handler.dart';

/// Service for camera-related operations
class CameraService implements MemoryAnalyzable {
  /// Image picker for gallery access
  final ImagePicker _picker;
  
  /// Camera controller
  CameraController? _controller;
  
  /// Available cameras
  List<CameraDescription> _cameras = [];
  
  /// Barcode scanner
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  
  /// Text recognizer
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  /// Current flash mode
  FlashMode _flashMode = FlashMode.auto;
  
  /// Whether the service is initialized
  bool _isInitialized = false;
  
  /// Whether resources have been released due to memory pressure
  bool _hasReleasedResources = false;
  
  /// Create a camera service
  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker() {
    // Register for memory pressure events
    registerMemoryPressureCallback();
  }
  
  /// Get whether the service is initialized
  bool get isInitialized => _isInitialized;
  
  /// Get the camera controller
  CameraController? get controller => _controller;
  
  /// Get the current flash mode
  FlashMode get flashMode => _flashMode;
  
  /// Initialize the camera service
  Future<void> initialize([CameraOptions? options]) async {
    if (_isInitialized) {
      // Already initialized, dispose first
      await dispose();
    }
    
    try {
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        throw CameraCaptureException(
          'No cameras available',
          CameraError.noCamera,
        );
      }
      
      // Use back camera by default
      final cameraToUse = options?.camera ?? 
                          _cameras.firstWhere(
                            (camera) => camera.lensDirection == CameraLensDirection.back,
                            orElse: () => _cameras.first,
                          );
      
      // Create controller
      _controller = CameraController(
        cameraToUse,
        options?.resolution ?? ResolutionPreset.high,
        enableAudio: options?.enableAudio ?? false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      // Initialize controller
      await _controller!.initialize();
      
      // Set initial flash mode
      await _controller!.setFlashMode(_flashMode);
      
      _isInitialized = true;
    } on CameraException catch (e) {
      throw CameraCaptureException(
        'Failed to initialize camera: ${e.description}',
        CameraError.initializationFailed,
      );
    } catch (e) {
      if (e is CameraCaptureException) {
        rethrow;
      }
      throw CameraCaptureException(
        'Failed to initialize camera: $e',
        CameraError.initializationFailed,
      );
    }
  }
  
  /// Change the flash mode
  Future<void> toggleFlash() async {
    if (!_isInitialized || _controller == null) {
      throw CameraCaptureException(
        'Camera not initialized',
        CameraError.initializationFailed,
      );
    }
    
    try {
      // Cycle through flash modes
      _flashMode = _flashMode == FlashMode.off 
          ? FlashMode.auto 
          : _flashMode == FlashMode.auto 
              ? FlashMode.always 
              : FlashMode.off;
      
      await _controller!.setFlashMode(_flashMode);
    } on CameraException catch (e) {
      throw CameraCaptureException(
        'Failed to toggle flash: ${e.description}',
        CameraError.unknown,
      );
    }
  }
  
  /// Take a picture
  Future<CameraImageResult> captureImage() async {
    if (!_isInitialized || _controller == null) {
      throw CameraCaptureException(
        'Camera not initialized',
        CameraError.initializationFailed,
      );
    }
    
    try {
      // Take picture
      final XFile file = await _controller!.takePicture();
      
      // Extract EXIF metadata
      Map<String, dynamic>? metadata;
      try {
        final exifData = await readExifFromFile(File(file.path));
        metadata = exifData.map((key, value) => MapEntry(key.toString(), value.toString()));
      } catch (e) {
        debugPrint('Error reading EXIF data: $e');
        // Continue without metadata
      }
      
      // Try to scan barcode
      String? barcode;
      try {
        barcode = await _scanBarcode(file.path);
      } catch (e) {
        debugPrint('Error scanning barcode: $e');
        // Continue without barcode
      }
      
      // Try to recognize text
      String? extractedText;
      try {
        extractedText = await _recognizeText(file.path);
      } catch (e) {
        debugPrint('Error recognizing text: $e');
        // Continue without text
      }
      
      return CameraImageResult(
        imageFile: file,
        barcode: barcode,
        extractedText: extractedText,
        source: CameraSource.camera,
        metadata: metadata,
      );
    } on CameraException catch (e) {
      throw CameraCaptureException(
        'Failed to capture image: ${e.description}',
        CameraError.captureFailed,
      );
    }
  }
  
  /// Get images from gallery
  Future<List<CameraImageResult>> getGalleryImages() async {
    try {
      // Pick multiple images from gallery
      final photos = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 80,
      );
      
      if (photos.isEmpty) {
        return [];
      }
      
      // Process each image (up to 10 max)
      final imagesToProcess = photos.take(10).toList();
      
      return await Future.wait(
        imagesToProcess.map((photo) async {
          // Try to scan barcode
          String? barcode;
          try {
            barcode = await _scanBarcode(photo.path);
          } catch (e) {
            debugPrint('Error scanning barcode: $e');
            // Continue without barcode
          }
          
          // Try to recognize text
          String? extractedText;
          try {
            extractedText = await _recognizeText(photo.path);
          } catch (e) {
            debugPrint('Error recognizing text: $e');
            // Continue without text
          }
          
          // Extract EXIF metadata
          Map<String, dynamic>? metadata;
          try {
            final exifData = await readExifFromFile(File(photo.path));
            metadata = exifData.map((key, value) => MapEntry(key.toString(), value.toString()));
          } catch (e) {
            debugPrint('Error reading EXIF data: $e');
            // Continue without metadata
          }
          
          return CameraImageResult(
            imageFile: photo,
            barcode: barcode,
            extractedText: extractedText,
            source: CameraSource.gallery,
            metadata: metadata,
          );
        }),
      );
    } catch (e) {
      throw CameraCaptureException(
        'Failed to load images from gallery: $e',
        CameraError.galleryLoadFailed,
      );
    }
  }
  
  /// Scan barcode from image
  Future<String?> _scanBarcode(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final barcodes = await _barcodeScanner.processImage(inputImage);
      
      if (barcodes.isEmpty) {
        return null;
      }
      
      // Return the first barcode value
      return barcodes.first.rawValue;
    } catch (e) {
      throw BarcodeScanException('Failed to scan barcode: $e');
    }
  }
  
  /// Recognize text from image
  Future<String?> _recognizeText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isEmpty) {
        return null;
      }
      
      return recognizedText.text;
    } catch (e) {
      throw TextRecognitionException('Failed to recognize text: $e');
    }
  }
  
  /// Dispose of resources
  Future<void> dispose() async {
    // Unregister from memory pressure events
    unregisterMemoryPressureCallback();
    
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    
    await _barcodeScanner.close();
    await _textRecognizer.close();
    
    _isInitialized = false;
    _hasReleasedResources = false;
  }
  
  /// Handle memory pressure
  @override
  Future<int> handleMemoryPressure(MemoryPressureLevel level) async {
    // Don't do anything for low memory pressure
    if (level == MemoryPressureLevel.none) {
      return 0;
    }
    
    int estimatedFreed = 0;
    
    // If critical or moderate memory pressure and camera is initialized
    if (level == MemoryPressureLevel.critical || 
        (level == MemoryPressureLevel.moderate && _isInitialized)) {
      
      debugPrint('CameraService: Releasing resources due to memory pressure: $level');
      
      // Store current state before releasing
      final wasInitialized = _isInitialized;
      
      // Release camera resources (biggest memory consumer)
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
        estimatedFreed += 15 * 1024 * 1024; // ~15MB for camera
      }
      
      // For critical memory pressure, release all resources
      if (level == MemoryPressureLevel.critical) {
        await _barcodeScanner.close();
        await _textRecognizer.close();
        estimatedFreed += 10 * 1024 * 1024; // ~10MB for ML models
      }
      
      // Mark that we've released resources and service needs reinitialization
      _isInitialized = false;
      _hasReleasedResources = wasInitialized;
      
      debugPrint('CameraService: Released ~${estimatedFreed ~/ (1024 * 1024)}MB memory');
    }
    
    return estimatedFreed;
  }
  
  /// Get the estimated memory usage of this service
  @override
  int getEstimatedMemoryUsage() {
    int estimatedUsage = 0;
    
    // Base memory usage
    estimatedUsage += 1 * 1024 * 1024; // 1MB base
    
    // Camera controller
    if (_controller != null && _isInitialized) {
      estimatedUsage += 15 * 1024 * 1024; // ~15MB for active camera
    }
    
    // ML models
    estimatedUsage += 10 * 1024 * 1024; // ~10MB for ML models
    
    return estimatedUsage;
  }
  
  /// Check if resources have been released due to memory pressure
  @override
  bool get hasReleasedResources => _hasReleasedResources;
  
  /// Reinitialize resources after memory pressure
  @override
  Future<void> reinitializeResources() async {
    if (!_hasReleasedResources) {
      return;
    }
    
    debugPrint('CameraService: Reinitializing resources');
    
    try {
      await initialize();
      _hasReleasedResources = false;
    } catch (e) {
      debugPrint('Error reinitializing camera resources: $e');
    }
  }
  
  /// Switch between cameras (front/back)
  Future<void> switchCamera() async {
    if (!_isInitialized || _controller == null) {
      throw CameraCaptureException(
        'Camera not initialized',
        CameraError.initializationFailed,
      );
    }
    
    if (_cameras.length < 2) {
      // Only one camera available
      return;
    }
    
    try {
      // Get current camera
      final currentCameraDescription = _controller!.description;
      
      // Find the other camera
      final CameraDescription newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection != currentCameraDescription.lensDirection,
        orElse: () => _cameras.first,
      );
      
      if (newCamera == currentCameraDescription) {
        // No other camera available
        return;
      }
      
      // Store current flash mode
      final currentFlashMode = _flashMode;
      
      // Dispose of current controller
      await _controller!.dispose();
      
      // Create new controller
      _controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      // Initialize new controller
      await _controller!.initialize();
      
      // Restore flash mode
      await _controller!.setFlashMode(currentFlashMode);
    } on CameraException catch (e) {
      throw CameraCaptureException(
        'Failed to switch camera: ${e.description}',
        CameraError.initializationFailed,
      );
    }
  }
}