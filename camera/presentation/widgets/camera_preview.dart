import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/camera_utils.dart';
import 'camera_web_fallback.dart';

/// Camera preview widget with controls
class CameraPreview extends StatefulWidget {
  /// Callback when an image is captured
  final Function(XFile)? onCapture;
  
  /// How to fit the camera preview
  final BoxFit fit;
  
  /// Whether to enable pinch to zoom
  final bool enablePinchZoom;
  
  /// Whether to show camera controls
  final bool showControls;
  
  /// Whether to use the front camera
  final bool useFrontCamera;
  
  /// Create a camera preview
  const CameraPreview({
    Key? key,
    this.onCapture,
    this.fit = BoxFit.cover,
    this.enablePinchZoom = false,
    this.showControls = true,
    this.useFrontCamera = false,
  }) : super(key: key);

  @override
  State<CameraPreview> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _initialized = false;
  bool _takingPicture = false;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(CameraPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.useFrontCamera != oldWidget.useFrontCamera) {
      _disposeCamera();
      _initializeCamera();
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize the camera
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    
    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }
  
  /// Initialize the camera
  Future<void> _initializeCamera() async {
    if (kIsWeb) {
      // Web uses a different camera implementation
      setState(() {
        _initialized = true;
      });
      return;
    }
    
    try {
      final CameraDescription? camera = widget.useFrontCamera
          ? await CameraUtils.getFrontCamera()
          : await CameraUtils.getBackCamera();
            
      if (camera == null) {
        setState(() {
          _initialized = false;
        });
        return;
      }
      
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await controller.initialize();
      
      // Get zoom range
      if (controller.value.isInitialized) {
        _minAvailableZoom = await controller.getMinZoomLevel();
        _maxAvailableZoom = await controller.getMaxZoomLevel();
        
        // Some devices have a narrow zoom range, so we adjust the max
        if (_maxAvailableZoom - _minAvailableZoom < 1.0) {
          _maxAvailableZoom = _minAvailableZoom + 1.0;
        }
        
        // Limit max zoom to prevent extreme values
        _maxAvailableZoom = _maxAvailableZoom.clamp(1.0, 5.0);
        
        setState(() {
          _controller = controller;
          _initialized = true;
          _currentZoom = _minAvailableZoom;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      setState(() {
        _initialized = false;
      });
    }
  }
  
  /// Dispose of the camera controller
  void _disposeCamera() {
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }
  
  /// Handle scale start for zoom
  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoom = _currentZoom;
  }
  
  /// Handle scale update for zoom
  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // Don't zoom if pinch-to-zoom is disabled
    if (!widget.enablePinchZoom) return;
    
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    // Calculate new zoom level
    final newZoom = (_baseZoom * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);
        
    // Only update if change is significant
    if ((newZoom - _currentZoom).abs() > 0.05) {
      _currentZoom = newZoom;
      await _controller?.setZoomLevel(newZoom);
      setState(() {});
    }
  }
  
  /// Take a picture
  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _takingPicture) {
      return;
    }
    
    setState(() {
      _takingPicture = true;
    });
    
    try {
      final XFile file = await _controller!.takePicture();
      
      if (widget.onCapture != null) {
        widget.onCapture!(file);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    } finally {
      if (mounted) {
        setState(() {
          _takingPicture = false;
        });
      }
    }
  }
  
  /// Toggle between front and back camera
  void _toggleCamera() {
    final newUseFrontCamera = !widget.useFrontCamera;
    
    // This will trigger didUpdateWidget
    (context as Element).markNeedsBuild();
    
    // Cannot directly access widget's callback, so use the parent context
    final parentContext = (context as Element).findRenderObject()?.attached ?? false
        ? context
        : null;
    
    if (parentContext != null && parentContext is StatefulElement) {
      final stateful = parentContext;
      final state = stateful.state;
      
      // Check if parent has a method to toggle camera
      if (state is State && state.widget is StatefulWidget) {
        // Call the toggle camera method if it exists
        try {
          if (state.mounted) {
            state.setState(() {
              // Update state in parent
            });
          }
        } catch (e) {
          debugPrint('Error toggling camera: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use web fallback for web platform
    if (kIsWeb) {
      return CameraWebFallback(
        onCapture: widget.onCapture,
        fit: widget.fit,
        showControls: widget.showControls,
      );
    }
    
    // Show loading if not initialized
    if (!_initialized || _controller == null || !_controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          FittedBox(
            fit: widget.fit,
            child: SizedBox(
              width: _controller!.value.previewSize!.height,
              height: _controller!.value.previewSize!.width,
              child: kIsWeb
                  ? const SizedBox() // Web rendering handled separately
                  : ClipRect(
                      child: RotatedBox(
                        quarterTurns: Platform.isAndroid ? 1 : 0,
                        child: CameraPreview(_controller!),
                      ),
                    ),
            ),
          ),
          
          // Camera controls
          if (widget.showControls)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Flash toggle
                  IconButton(
                    icon: Icon(
                      _controller!.value.flashMode == FlashMode.off
                          ? Icons.flash_off
                          : Icons.flash_on,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () async {
                      final newMode = _controller!.value.flashMode == FlashMode.off
                          ? FlashMode.torch
                          : FlashMode.off;
                      await _controller!.setFlashMode(newMode);
                      setState(() {});
                    },
                  ),
                  
                  // Capture button
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: _takingPicture
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                    ),
                  ),
                  
                  // Camera flip
                  IconButton(
                    icon: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _toggleCamera,
                  ),
                ],
              ),
            ),
            
          // Zoom indicator
          if (widget.enablePinchZoom && _currentZoom > _minAvailableZoom + 0.1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentZoom.toStringAsFixed(1)}x',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}