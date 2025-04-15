import 'dart:io';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/services/service_locator.dart';
import '../features/camera/service/camera_service.dart';
import '../utils/ui_performance.dart';

/// Scanning modes for the camera
enum ScanMode {
  /// Barcode scanning mode
  barcode,

  /// Ingredients text scanning mode
  ingredients,
}

/// Provider for camera functionality
class CameraProvider extends ChangeNotifier {
  /// Available cameras
  List<CameraDescription>? _cameras;

  /// Selected camera index
  int _selectedCameraIndex = 0;

  /// Controller for camera
  CameraController? _controller;

  /// Whether the camera is initialized
  bool _isInitialized = false;

  /// Whether the camera is in the process of loading
  bool _isLoading = false;

  /// Whether the camera is processing an image
  bool _isProcessing = false;

  /// Current scan mode
  ScanMode _scanMode = ScanMode.barcode;

  /// Current flash mode
  FlashMode _flashMode = FlashMode.auto;

  /// Error message
  String? _error;

  /// Barcode scanner
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  /// Text recognizer
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Whether a request to initialize the camera is pending
  bool _pendingInitialization = false;

  /// Create camera provider
  CameraProvider() {
    _loadCameras();
  }

  /// Load available cameras
  Future<void> _loadCameras() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get available cameras
      _cameras = await availableCameras();

      // Default to back camera if available
      _selectedCameraIndex = _findBackCamera();

      // Clear error if any
      _error = null;
    } catch (e) {
      _error = 'Failed to find cameras: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Find the back camera index
  int _findBackCamera() {
    // If no cameras, return 0
    if (_cameras == null || _cameras!.isEmpty) return 0;

    // Find back camera
    for (int i = 0; i < _cameras!.length; i++) {
      if (_cameras![i].lensDirection == CameraLensDirection.back) {
        return i;
      }
    }

    // Default to first camera
    return 0;
  }

  /// Initialize the camera
  Future<void> initializeCamera() async {
    // Check if already initialized or loading
    if (_isInitialized || _isLoading || _pendingInitialization) return;

    _pendingInitialization = true;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      UIPerformance.startMeasure('CameraInitialization');

      // Check permission
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Camera permission not granted');
      }

      // If no cameras found, try to load them
      if (_cameras == null || _cameras!.isEmpty) {
        await _loadCameras();

        // Check if cameras available after loading
        if (_cameras == null || _cameras!.isEmpty) {
          throw Exception('No cameras available');
        }
      }

      // Initialize controller
      // Dispose existing controller if any
      await _controller?.dispose();

      _controller = CameraController(
        _cameras![_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Initialize controller
      await _controller!.initialize();

      // Set flash mode
      await _controller!.setFlashMode(_flashMode);

      // Set initialized
      _isInitialized = true;
      _error = null;
    } on CameraException catch (e) {
      _error = 'Camera error: ${e.description}';
      _isInitialized = false;
    } catch (e) {
      _error = 'Failed to initialize camera: $e';
      _isInitialized = false;
    } finally {
      _isLoading = false;
      _pendingInitialization = false;
      UIPerformance.endMeasure('CameraInitialization');
      notifyListeners();
    }
  }

  /// Take a picture
  Future<File?> takePicture() async {
    UIPerformance.startMeasure('TakePicture');

    if (_controller == null || !_isInitialized) {
      _error = 'Camera not initialized';
      notifyListeners();
      UIPerformance.endMeasure('TakePicture');
      return null;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      // Take picture
      final XFile picture = await _controller!.takePicture();

      // Return picture as File
      return File(picture.path);
    } catch (e) {
      _error = 'Failed to take picture: $e';
      debugPrint(_error);
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
      UIPerformance.endMeasure('TakePicture');
    }
  }

  /// Process image for barcodes
  Future<List<Barcode>> processImageForBarcodes(File imageFile) async {
    UIPerformance.startMeasure('ProcessBarcode');

    _isProcessing = true;
    notifyListeners();

    try {
      // Create input image
      final inputImage = InputImage.fromFile(imageFile);

      // Process image
      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

      return barcodes;
    } catch (e) {
      _error = 'Failed to process barcode: $e';
      debugPrint(_error);
      return [];
    } finally {
      _isProcessing = false;
      notifyListeners();
      UIPerformance.endMeasure('ProcessBarcode');
    }
  }

  /// Process image for text
  Future<RecognizedText> processImageForText(File imageFile) async {
    UIPerformance.startMeasure('ProcessText');

    _isProcessing = true;
    notifyListeners();

    try {
      // Create input image
      final inputImage = InputImage.fromFile(imageFile);

      // Process image
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      return recognizedText;
    } catch (e) {
      _error = 'Failed to process text: $e';
      debugPrint(_error);
      return const RecognizedText(text: '');
    } finally {
      _isProcessing = false;
      notifyListeners();
      UIPerformance.endMeasure('ProcessText');
    }
  }

  /// Toggle camera flash mode
  Future<void> toggleFlashMode() async {
    if (_controller == null || !_isInitialized) return;

    try {
      // Toggle flash mode
      switch (_flashMode) {
        case FlashMode.off:
          _flashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          _flashMode = FlashMode.always;
          break;
        case FlashMode.always:
          _flashMode = FlashMode.torch;
          break;
        case FlashMode.torch:
          _flashMode = FlashMode.off;
          break;
      }

      // Set flash mode
      await _controller!.setFlashMode(_flashMode);

      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle flash mode: $e';
      debugPrint(_error);
    }
  }

  /// Switch camera
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2 || !_isInitialized) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Dispose current controller
      await _controller?.dispose();

      // Toggle camera index
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;

      // Reinitialize
      await initializeCamera();
    } catch (e) {
      _error = 'Failed to switch camera: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle between barcode and ingredients scanning mode
  void toggleScanMode() {
    _scanMode = _scanMode == ScanMode.barcode
        ? ScanMode.ingredients
        : ScanMode.barcode;
    notifyListeners();
  }

  /// Reset error
  void resetError() {
    _error = null;
    notifyListeners();
  }

  /// Get error message
  String? get error => _error;

  /// Get controller
  CameraController? get controller => _controller;

  /// Whether camera is initialized
  bool get isInitialized => _isInitialized;

  /// Whether camera is loading
  bool get isLoading => _isLoading;

  /// Whether camera is processing
  bool get isProcessing => _isProcessing;

  /// Get current scan mode
  ScanMode get scanMode => _scanMode;

  /// Get current flash mode
  FlashMode get flashMode => _flashMode;

  @override
  void dispose() {
    // Dispose controllers and recognizers
    _controller?.dispose();
    _barcodeScanner.close();
    _textRecognizer.close();
    super.dispose();
  }
}