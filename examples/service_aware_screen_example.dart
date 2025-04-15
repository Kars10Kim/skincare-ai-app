import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../core/services/service_locator.dart';
import '../core/services/individual_services/camera_service.dart';
import '../widgets/service_aware_widget.dart';

/// Example screen demonstrating the ServiceAwareWidget
/// 
/// This screen shows how to:
/// - Properly initialize services when needed
/// - Handle lifecycle events
/// - Release resources when not in use
/// - Respond to connectivity changes
class CameraExampleScreen extends StatefulWidget {
  const CameraExampleScreen({Key? key}) : super(key: key);

  @override
  State<CameraExampleScreen> createState() => _CameraExampleScreenState();
}

class _CameraExampleScreenState extends State<CameraExampleScreen> {
  CameraService? _cameraService;
  bool _loading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  
  /// Initialize the camera service
  Future<void> _initializeCamera() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });
    
    try {
      // Get the camera service through the service locator
      _cameraService = await ServiceLocator.instance.get<CameraService>();
      
      // Initialize the camera hardware
      await _cameraService!.setupCamera();
      
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Camera initialization failed: $e';
        });
      }
    }
  }
  
  /// Take a picture
  Future<void> _takePicture() async {
    if (_cameraService == null || !_cameraService!.isInitialized) {
      return;
    }
    
    try {
      final result = await _cameraService!.captureImage();
      
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image captured: ${result.imageFile.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    // Release the camera when the screen is disposed
    _cameraService?.releaseCamera();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () async {
              if (_cameraService != null && _cameraService!.isInitialized) {
                await _cameraService!.toggleFlash();
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: ServiceAwareWidget(
        // Show connectivity status
        showConnectivity: true,
        
        // Track analytics for this screen
        trackInAnalytics: true,
        screenName: 'camera_example_screen',
        
        child: _buildContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
  
  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_cameraService == null || _cameraService!.controller == null) {
      return const Center(
        child: Text('Camera not initialized'),
      );
    }
    
    return AspectRatio(
      aspectRatio: _cameraService!.controller!.value.aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          CameraPreview(_cameraService!.controller!),
          
          // Overlay with camera controls
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.switch_camera),
                  color: Colors.white,
                  onPressed: () async {
                    await _cameraService!.switchCamera();
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: Icon(
                    _cameraService!.flashMode == FlashMode.off
                        ? Icons.flash_off
                        : _cameraService!.flashMode == FlashMode.auto
                            ? Icons.flash_auto
                            : Icons.flash_on,
                  ),
                  color: Colors.white,
                  onPressed: () async {
                    await _cameraService!.toggleFlash();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}