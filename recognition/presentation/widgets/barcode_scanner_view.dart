import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Barcode scanner view
class BarcodeScannerView extends StatefulWidget {
  /// Callback when barcode is detected
  final Function(String) onBarcodeDetected;
  
  /// Create barcode scanner view
  const BarcodeScannerView({
    Key? key,
    required this.onBarcodeDetected,
  }) : super(key: key);

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> with WidgetsBindingObserver {
  /// Camera controller
  CameraController? _cameraController;
  
  /// Available cameras
  List<CameraDescription>? _cameras;
  
  /// Barcode scanner
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  
  /// Is scanning
  bool _isScanning = false;
  
  /// Is processing
  bool _isProcessing = false;
  
  /// Detected barcode
  String? _detectedBarcode;
  
  /// Last scan time
  DateTime? _lastScanTime;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize the camera
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }
  
  /// Initialize camera
  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      if (_cameras == null) {
        _cameras = await availableCameras();
      }
      
      if (_cameras == null || _cameras!.isEmpty) {
        return;
      }
      
      // Get back camera
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );
      
      // Initialize camera controller
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await _cameraController!.initialize();
      
      if (!mounted) return;
      
      setState(() {});
      
      // Start scanning
      await _startScanning();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }
  
  /// Start scanning for barcodes
  Future<void> _startScanning() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    if (_isScanning) return;
    
    _isScanning = true;
    
    try {
      await _cameraController!.startImageStream(_processImage);
    } catch (e) {
      _isScanning = false;
      debugPrint('Error starting image stream: $e');
    }
  }
  
  /// Process camera image
  void _processImage(CameraImage image) async {
    if (_isProcessing) return;
    
    _isProcessing = true;
    
    try {
      // Check if we've already detected a barcode recently
      if (_detectedBarcode != null) {
        final now = DateTime.now();
        if (_lastScanTime != null && now.difference(_lastScanTime!).inSeconds < 3) {
          // Skip processing if we detected a barcode in the last 3 seconds
          _isProcessing = false;
          return;
        }
      }
      
      // Convert image to InputImage for ML Kit
      final inputImage = _convertCameraImageToInputImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }
      
      // Process the image
      final barcodes = await _barcodeScanner.processImage(inputImage);
      
      // Process detected barcodes
      if (barcodes.isNotEmpty) {
        for (final barcode in barcodes) {
          final value = barcode.rawValue;
          if (value != null && value.isNotEmpty) {
            _detectedBarcode = value;
            _lastScanTime = DateTime.now();
            
            // Stop image stream
            await _cameraController?.stopImageStream();
            _isScanning = false;
            
            // Notify listener
            widget.onBarcodeDetected(value);
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  /// Convert camera image to input image
  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    if (_cameraController == null) return null;
    
    final camera = _cameraController!.description;
    
    // Get image rotation
    final rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    
    if (rotation == null) return null;
    
    // Get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    
    if (format == null) return null;
    
    // Get plane data
    final List<InputImagePlaneMetadata> planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height ?? 0,
          width: plane.width ?? 0,
        );
      },
    ).toList();
    
    // Create input image
    final inputImageData = InputImageData(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      imageRotation: rotation,
      inputImageFormat: format,
      planeData: planeData,
    );
    
    // Create input image
    final inputImage = InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      inputImageData: inputImageData,
    );
    
    return inputImage;
  }
  
  /// Concatenate image planes
  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    
    return allBytes.done().buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: Center(
            child: CameraPreview(_cameraController!),
          ),
        ),
        
        // Scan overlay
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: BarcodeScannerOverlay(),
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for barcode scanner overlay
class BarcodeScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // Size of the scan area
    final scanAreaSize = width * 0.7;
    
    // Calculate positions
    final left = (width - scanAreaSize) / 2;
    final top = (height - scanAreaSize) / 2;
    final right = left + scanAreaSize;
    final bottom = top + scanAreaSize;
    
    // Draw semi-transparent background
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    // Draw the background with a cutout for the scan area
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRect(Rect.fromLTRB(left, top, right, bottom))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(backgroundPath, backgroundPaint);
    
    // Draw scan area border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    canvas.drawRect(
      Rect.fromLTRB(left, top, right, bottom),
      borderPaint,
    );
    
    // Draw corner indicators
    final cornerLength = scanAreaSize * 0.1;
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    
    // Top-left corner
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);
    
    // Top-right corner
    canvas.drawLine(Offset(right - cornerLength, top), Offset(right, top), cornerPaint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerLength), cornerPaint);
    
    // Bottom-left corner
    canvas.drawLine(Offset(left, bottom - cornerLength), Offset(left, bottom), cornerPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left + cornerLength, bottom), cornerPaint);
    
    // Bottom-right corner
    canvas.drawLine(Offset(right - cornerLength, bottom), Offset(right, bottom), cornerPaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerLength), cornerPaint);
    
    // Draw scan line
    final scanLinePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw helper text
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
    
    final textSpan = TextSpan(
      text: 'Align barcode within box',
      style: textStyle,
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout(minWidth: 0, maxWidth: width);
    
    final textX = (width - textPainter.width) / 2;
    final textY = bottom + 40;
    
    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}