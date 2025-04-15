import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/accessibility.dart';
import '../../../utils/auto_dispose_mixin.dart';
import '../models/camera_models.dart';
import '../service/camera_service.dart';
import '../utils/error_handling.dart';
import '../utils/permissions.dart';
import '../web/web_camera_fallback.dart';

/// Screen for camera functionality
class CameraScreen extends StatefulWidget {
  /// Whether to start in barcode mode
  final bool initialBarcodeMode;
  
  /// Callback when a result is captured
  final Function(CameraImageResult result)? onResultCaptured;
  
  /// Create a camera screen
  const CameraScreen({
    Key? key,
    this.initialBarcodeMode = true,
    this.onResultCaptured,
  }) : super(key: key);
  
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, AutoDisposeMixin, AccessibilitySupport {
  // Camera service
  late final CameraService _cameraService;
  
  // Current camera mode
  late CameraMode _mode;
  
  // UI state
  bool _isInitializing = true;
  bool _hasError = false;
  CameraError? _error;
  bool _isCameraPermissionGranted = false;
  bool _isCapturing = false;
  bool _isFlashAvailable = false;
  
  @override
  void initState() {
    super.initState();
    
    // Set initial mode
    _mode = widget.initialBarcodeMode ? CameraMode.barcode : CameraMode.photo;
    
    // Register as an observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // Get camera service from provider or create one
    _cameraService = Provider.of<CameraService>(context, listen: false);
    
    // Initialize camera
    _initializeCamera();
  }
  
  @override
  void didUpdateWidget(CameraScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update mode if needed
    if (widget.initialBarcodeMode != oldWidget.initialBarcodeMode) {
      setState(() {
        _mode = widget.initialBarcodeMode ? CameraMode.barcode : CameraMode.photo;
      });
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? controller = _cameraService.controller;
    
    // App state changed before controller was initialized
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    
    // Handle app lifecycle state changes
    if (state == AppLifecycleState.inactive) {
      // App inactive: dispose camera controller
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      // App resumed: reinitialize camera
      _initializeCamera();
    }
  }
  
  /// Initialize the camera
  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _hasError = false;
      _error = null;
    });
    
    try {
      // Check and request camera permission
      _isCameraPermissionGranted = await CameraPermissions.requestCameraAccess();
      
      if (!_isCameraPermissionGranted) {
        setState(() {
          _hasError = true;
          _error = CameraError.permissionDenied;
          _isInitializing = false;
        });
        return;
      }
      
      // Initialize camera service
      await _cameraService.initialize();
      
      // Check if flash is available
      _isFlashAvailable = _cameraService.controller?.value.flashMode != null;
    } catch (e) {
      debugPrint('Failed to initialize camera: $e');
      setState(() {
        _hasError = true;
        _error = e is CameraCaptureException
            ? CameraError.values.firstWhere(
                (error) => error.code == e.error.code,
                orElse: () => CameraError.unknown,
              )
            : CameraError.initializationFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }
  
  /// Dispose of the camera
  Future<void> _disposeCamera() async {
    try {
      await _cameraService.dispose();
    } catch (e) {
      debugPrint('Error disposing camera: $e');
    }
  }
  
  /// Handle image capture
  Future<void> _handleCapture() async {
    if (_isCapturing) {
      return;
    }
    
    setState(() {
      _isCapturing = true;
    });
    
    try {
      // Capture image
      final result = await _cameraService.captureImage();
      
      // Handle captured image
      if (widget.onResultCaptured != null) {
        widget.onResultCaptured!(result);
      }
      
      // Go back to previous screen if result captured successfully
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
      
      // Show error
      if (mounted) {
        final error = e is CameraCaptureException
            ? e.error
            : CameraError.captureFailed;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.userMessage),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }
  
  /// Handle gallery image selection
  Future<void> _handleGallerySelection() async {
    try {
      // Check and request gallery permission
      final hasPermission = await CameraPermissions.requestGalleryAccess();
      
      if (!hasPermission) {
        if (mounted) {
          CameraError.galleryAccessDenied.showAlert(context);
        }
        return;
      }
      
      // Get images from gallery
      final images = await _cameraService.getGalleryImages();
      
      if (images.isEmpty) {
        return;
      }
      
      // Handle the first selected image
      if (widget.onResultCaptured != null) {
        widget.onResultCaptured!(images.first);
      }
      
      // Go back to previous screen with result
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context, images.first);
      }
    } catch (e) {
      debugPrint('Error selecting from gallery: $e');
      
      // Show error
      if (mounted) {
        final error = e is CameraCaptureException
            ? e.error
            : CameraError.galleryLoadFailed;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.userMessage),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  /// Toggle flash mode
  Future<void> _toggleFlash() async {
    try {
      await _cameraService.toggleFlash();
      
      // Update UI
      setState(() {});
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }
  
  /// Toggle camera mode
  void _toggleCameraMode() {
    setState(() {
      // Cycle through modes
      switch (_mode) {
        case CameraMode.photo:
          _mode = CameraMode.barcode;
          break;
        case CameraMode.barcode:
          _mode = CameraMode.text;
          break;
        case CameraMode.text:
          _mode = CameraMode.photo;
          break;
      }
    });
  }
  
  /// Switch between front and back cameras
  Future<void> _switchCamera() async {
    setState(() {
      _isInitializing = true;
    });
    
    try {
      await _cameraService.switchCamera();
    } catch (e) {
      debugPrint('Error switching camera: $e');
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to switch camera'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }
  
  /// Handle web fallback image capture
  void _handleWebImageCaptured(CameraImageResult result) {
    if (widget.onResultCaptured != null) {
      widget.onResultCaptured!(result);
    }
    
    // Go back to previous screen with result
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }
  
  /// Build the main content
  Widget _buildContent() {
    // For web, use the web fallback
    if (kIsWeb) {
      return WebCameraFallback(
        onImageCaptured: _handleWebImageCaptured,
      );
    }
    
    // If there's an error, show the error screen
    if (_hasError) {
      return _buildErrorScreen();
    }
    
    // If initializing, show loading screen
    if (_isInitializing) {
      return _buildLoadingScreen();
    }
    
    // If camera permission not granted, show permission screen
    if (!_isCameraPermissionGranted) {
      return _buildPermissionScreen();
    }
    
    // Show camera preview
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        _buildCameraPreview(),
        
        // Camera controls overlay
        Positioned.fill(
          child: _buildCameraControls(),
        ),
      ],
    );
  }
  
  /// Build error screen
  Widget _buildErrorScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _error?.userMessage ?? 'An unknown error occurred',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build loading screen
  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
  
  /// Build permission screen
  Widget _buildPermissionScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Camera permission is required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Grant Permission'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build camera preview
  Widget _buildCameraPreview() {
    final controller = _cameraService.controller;
    
    if (controller == null) {
      return const SizedBox.expand(
        child: ColoredBox(color: Colors.black),
      );
    }
    
    // Get screen size
    final size = MediaQuery.of(context).size;
    
    // Get camera preview size
    final previewSize = controller.value.previewSize;
    
    if (previewSize == null) {
      return const SizedBox.expand(
        child: ColoredBox(color: Colors.black),
      );
    }
    
    // Calculate scaling ratio
    final screenRatio = size.width / size.height;
    final previewRatio = previewSize.width / previewSize.height;
    
    // Calculate scale factor
    final scale = screenRatio < previewRatio
        ? size.height / previewSize.height
        : size.width / previewSize.width;
    
    return SizedBox.expand(
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewSize.width,
            height: previewSize.height,
            child: controller.buildPreview(),
          ),
        ),
      ),
    );
  }
  
  /// Build camera controls overlay
  Widget _buildCameraControls() {
    return Column(
      children: [
        // Top controls
        _buildTopControls(),
        
        // Spacer
        const Spacer(),
        
        // Bottom controls
        _buildBottomControls(),
      ],
    );
  }
  
  /// Build top controls
  Widget _buildTopControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          
          // Mode indicator
          _buildModeIndicator(),
          
          // Flash button (if available)
          _isFlashAvailable
              ? IconButton(
                  icon: Icon(
                    _getCameraFlashIcon(),
                    color: Colors.white,
                  ),
                  onPressed: _toggleFlash,
                )
              : const SizedBox(width: 48),
        ],
      ),
    );
  }
  
  /// Get the appropriate icon for the current flash mode
  IconData _getCameraFlashIcon() {
    if (_cameraService.controller == null) {
      return Icons.flash_off;
    }
    
    switch (_cameraService.flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
      case FlashMode.torch:
        return Icons.flash_on;
    }
  }
  
  /// Build mode indicator
  Widget _buildModeIndicator() {
    String label;
    IconData icon;
    
    switch (_mode) {
      case CameraMode.photo:
        label = 'Photo Mode';
        icon = Icons.photo_camera;
        break;
      case CameraMode.barcode:
        label = 'Barcode Mode';
        icon = Icons.qr_code_scanner;
        break;
      case CameraMode.text:
        label = 'Text Mode';
        icon = Icons.text_fields;
        break;
    }
    
    return GestureDetector(
      onTap: _toggleCameraMode,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build bottom controls
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          _buildControlButton(
            Icons.photo_library,
            'Gallery',
            _handleGallerySelection,
          ),
          
          // Capture button
          _buildCaptureButton(),
          
          // Switch camera button
          _buildControlButton(
            Icons.flip_camera_ios,
            'Switch',
            _switchCamera,
          ),
        ],
      ),
    );
  }
  
  /// Build a control button
  Widget _buildControlButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: _isCapturing ? null : onPressed,
          iconSize: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  /// Build capture button
  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isCapturing ? null : _handleCapture,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: _isCapturing
              ? const CircularProgressIndicator(color: Colors.white)
              : Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }
}