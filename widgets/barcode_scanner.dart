import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:skincare_scanner/constants/api_constants.dart';
import 'package:skincare_scanner/models/product_model.dart';
import 'package:skincare_scanner/providers/product_provider.dart';
import 'package:skincare_scanner/providers/user_provider.dart';
import 'package:skincare_scanner/utils/analytics_service.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String) onBarcodeDetected;
  final double zoomLevel;
  final double brightness;
  final bool isAutoFocus;
  final bool isMultiScanMode;
  final Function(bool) onStabilizationChanged;

  const BarcodeScannerWidget({
    Key? key,
    required this.onBarcodeDetected,
    this.zoomLevel = 1.0,
    this.brightness = 0.5,
    this.isAutoFocus = true,
    this.isMultiScanMode = false,
    required this.onStabilizationChanged,
  }) : super(key: key);

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> with WidgetsBindingObserver {
  // Camera controller and scanner
  CameraController? _controller;
  BarcodeDetector? _barcodeDetector;
  List<CameraDescription>? _cameras;
  bool _isDetecting = false;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  Timer? _debounceTimer;
  Set<String> _processedBarcodes = {};
  
  // UI related
  bool _isFlashlightOn = false;
  double _zoomLevel = 1.0;
  final double _minZoom = 1.0;
  final double _maxZoom = 5.0;
  
  // Constants for API calls
  final String apiUrl = ApiConstants.baseUrl;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupBarcodeScanner();
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _barcodeDetector?.close();
    _stopCamera();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    
    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      _setupBarcodeScanner();
    }
  }
  
  // Check if we're running on a mobile device or in the Replit environment
  bool get isSimulated => kIsWeb || !(Platform.isAndroid || Platform.isIOS);
  
  // Setup barcode scanner and camera
  Future<void> _setupBarcodeScanner() async {
    // MOBILE-ONLY: Initialize the barcode detector
    _barcodeDetector = FirebaseVision.instance.barcodeDetector(
      BarcodeDetectorOptions(
        barcodeFormats: BarcodeFormat.all,
      ),
    );
    
    if (!isSimulated) {
      await _initializeCamera();
    }
  }
  
  // MOBILE-ONLY: Initialize the camera
  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw CameraException('No cameras available', 'No cameras found on device');
      }
      
      // Use the first back camera by default
      CameraDescription? backCamera;
      for (var camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.back) {
          backCamera = camera;
          break;
        }
      }
      
      if (backCamera == null) {
        backCamera = _cameras!.first;
      }
      
      // Create camera controller
      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      // Initialize controller
      await _controller!.initialize();
      
      // Start image stream for barcode detection
      await _controller!.startImageStream(_processCameraImage);
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      // Show an error message to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }
  
  // MOBILE-ONLY: Process camera images for barcode detection
  void _processCameraImage(CameraImage image) {
    if (_isDetecting) return;
    
    _isDetecting = true;
    
    try {
      FirebaseVisionImageMetadata metadata = FirebaseVisionImageMetadata(
        rawFormat: image.format.raw,
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: Platform.isAndroid 
          ? FirebaseVisionImageRotation.rotation90
          : FirebaseVisionImageRotation.rotation0,
        planeData: image.planes.map((plane) {
          return FirebaseVisionImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        }).toList(),
      );
      
      _detectBarcodes(FirebaseVisionImage.fromBytes(
        image.planes[0].bytes,
        metadata,
      ));
    } catch (e) {
      debugPrint('Error processing camera image: $e');
    } finally {
      _isDetecting = false;
    }
  }
  
  // MOBILE-ONLY: Detect barcodes in the image
  Future<void> _detectBarcodes(FirebaseVisionImage image) async {
    if (_barcodeDetector == null) return;
    
    try {
      List<Barcode> barcodes = await _barcodeDetector!.detectInImage(image);
      
      for (Barcode barcode in barcodes) {
        if (barcode.rawValue != null &&
            barcode.rawValue!.isNotEmpty &&
            !_processedBarcodes.contains(barcode.rawValue)) {
          _debounceBarcodeScan(barcode.rawValue!);
          break;
        }
      }
    } catch (e) {
      debugPrint('Error detecting barcodes: $e');
    }
  }
  
  // Debounce barcode scanning to prevent multiple scans of the same code
  void _debounceBarcodeScan(String barcode) {
    _debounceTimer?.cancel();
    
    if (_isProcessing) return;
    
    _debounceTimer = Timer(const Duration(milliseconds: 2000), () {
      _handleScan(barcode);
    });
  }
  
  // Handle the scanned barcode
  Future<void> _handleScan(String barcode) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _processedBarcodes.add(barcode);
    });
    
    // Show loading indicator
    _showLoadingDialog();
    
    try {
      // Log scan event for analytics
      AnalyticsService.logEvent('barcode_scanned', {'barcode': barcode});
      
      // Get user info from provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.id ?? 'anonymous';
      
      // Fetch product information
      final productResponse = await http.get(
        Uri.parse('$apiUrl/api/products?barcode=$barcode'),
        headers: {'Authorization': 'Bearer ${userProvider.authToken}'},
      );
      
      if (!mounted) return;
      
      // Handle response
      if (productResponse.statusCode == 200) {
        // Product found
        final productData = json.decode(productResponse.body);
        final product = Product.fromJson(productData);
        
        // Save to scan history in PostgreSQL via API
        await http.post(
          Uri.parse('$apiUrl/api/scan_history'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${userProvider.authToken}',
          },
          body: jsonEncode({
            'user_id': userId, 
            'product_barcode': product.barcode,
          }),
        );
        
        // Update product provider
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        productProvider.setCurrentProduct(product);
        
        // Navigate to results page
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushNamed('/product_details');
      } else if (productResponse.statusCode == 404) {
        // Product not found
        Navigator.of(context).pop(); // Close loading dialog
        
        _showProductNotFoundDialog(barcode);
      } else {
        // Other error
        Navigator.of(context).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching product: ${productResponse.statusCode}')),
        );
      }
    } catch (e) {
      // Handle network or other errors
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing barcode: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  // Show loading dialog while processing barcode
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading product information...'),
            ],
          ),
        );
      },
    );
  }
  
  // Show dialog when product is not found
  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Product Not Found'),
          content: const Text(
            'This product is not in our database yet. Would you like to add it manually?'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(
                  '/add_product',
                  arguments: {'barcode': barcode},
                );
              },
              child: const Text('Add Product'),
            ),
          ],
        );
      },
    );
  }
  
  // Stop camera
  Future<void> _stopCamera() async {
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
      await _controller!.dispose();
      _controller = null;
    }
    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
      });
    }
  }
  
  // Toggle flashlight
  Future<void> _toggleFlashlight() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    try {
      if (_isFlashlightOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      
      setState(() {
        _isFlashlightOn = !_isFlashlightOn;
      });
    } catch (e) {
      debugPrint('Error toggling flashlight: $e');
    }
  }
  
  // Handle zoom
  Future<void> _handleZoom(double delta) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    try {
      double newZoom = _zoomLevel + delta;
      newZoom = newZoom.clamp(_minZoom, _maxZoom);
      
      if (newZoom != _zoomLevel) {
        await _controller!.setZoomLevel(newZoom);
        setState(() {
          _zoomLevel = newZoom;
        });
      }
    } catch (e) {
      debugPrint('Error handling zoom: $e');
    }
  }
  
  // REPLIT-MOCK: Mock scanner for web preview
  Widget _buildMockScanner() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://www.qr-code-generator.com/wp-content/themes/qr/images/products/barcode_generator_preview.jpg',
                  width: 250,
                  height: 150,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, size: 100);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Barcode Scanner Preview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This is a mock scanner for web preview',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _handleScan('3600541225183'), // Test barcode (L'Oreal product)
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Simulate Scan'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _handleScan('8992695127204'), // Another test barcode (Beauty product)
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Simulate Another Product'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => _handleScan('1234567890123'), // Unknown product
            icon: const Icon(Icons.new_releases),
            label: const Text('Simulate New Product'),
          ),
        ],
      ),
    );
  }
  
  // Build scanner UI
  Widget _buildScannerUI() {
    if (isSimulated) {
      return _buildMockScanner();
    }
    
    if (!_isCameraInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing camera...'),
          ],
        ),
      );
    }
    
    return Stack(
      children: [
        // Camera preview
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.previewSize!.height,
              height: _controller!.value.previewSize!.width,
              child: CameraPreview(_controller!),
            ),
          ),
        ),
        
        // Scan overlay
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        // Controls
        Positioned(
          bottom: 30,
          right: 30,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flashlight toggle
              FloatingActionButton(
                heroTag: 'flashlight',
                mini: true,
                onPressed: _toggleFlashlight,
                backgroundColor: _isFlashlightOn ? Colors.amber : Colors.white,
                child: Icon(
                  _isFlashlightOn ? Icons.flash_on : Icons.flash_off,
                  color: _isFlashlightOn ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Zoom in
              FloatingActionButton(
                heroTag: 'zoomIn',
                mini: true,
                onPressed: () => _handleZoom(0.5),
                backgroundColor: Colors.white,
                child: const Icon(Icons.zoom_in, color: Colors.black),
              ),
              const SizedBox(height: 8),
              // Zoom out
              FloatingActionButton(
                heroTag: 'zoomOut',
                mini: true,
                onPressed: () => _handleZoom(-0.5),
                backgroundColor: Colors.white,
                child: const Icon(Icons.zoom_out, color: Colors.black),
              ),
            ],
          ),
        ),
        
        // Scanning indicator at the top
        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Position barcode in the frame to scan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        if (!isSimulated && details.scale != 1.0) {
          _handleZoom(details.scale > 1.0 ? 0.02 : -0.02);
        }
      },
      child: _buildScannerUI(),
    );
  }
}

/* 
Expected Mobile UI:

+----------------------------------------------+
|                                              |
|                                              |
|                                              |
|             +------------------+             |
|             |                  |             |
|             |  Camera Preview  |             |
|             |                  |             |
|             |                  |             |
|             +------------------+             |
|                                              |
|                                              |
|                                              |
|                                       (o)    |
|                                       (o)    |
|                                       (o)    |
+----------------------------------------------+

API Testing with cURL:

# Fetch product by barcode
curl -X GET "http://localhost:5000/api/products?barcode=3600541225183" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Add scan to history
curl -X POST "http://localhost:5000/api/scan_history" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"user_id": "user123", "product_barcode": "3600541225183"}'

# Check ingredient conflicts
curl -X POST "http://localhost:5000/api/ingredients/check-conflicts" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"ingredients": ["Retinol", "Vitamin C"]}'
*/