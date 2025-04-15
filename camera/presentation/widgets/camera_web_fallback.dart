import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

/// Camera implementation for web platforms
class CameraWebFallback extends StatefulWidget {
  /// Callback when an image is captured
  final Function(XFile)? onCapture;
  
  /// How to fit the preview
  final BoxFit fit;
  
  /// Whether to show camera controls
  final bool showControls;
  
  /// Create a camera web fallback
  const CameraWebFallback({
    Key? key,
    this.onCapture,
    this.fit = BoxFit.cover,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<CameraWebFallback> createState() => _CameraWebFallbackState();
}

class _CameraWebFallbackState extends State<CameraWebFallback> {
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;
  final String _viewId = 'webcam-view-${DateTime.now().millisecondsSinceEpoch}';
  bool _cameraInitialized = false;
  bool _accessDenied = false;
  bool _takingPicture = false;
  
  @override
  void initState() {
    super.initState();
    _initializeWebCamera();
  }
  
  @override
  void dispose() {
    _disposeWebCamera();
    super.dispose();
  }
  
  /// Initialize the web camera
  Future<void> _initializeWebCamera() async {
    if (_videoElement != null) return;
    
    final videoElement = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.objectFit = 'cover'
      ..style.width = '100%'
      ..style.height = '100%';
    
    // Register the view in web
    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => videoElement,
    );
    
    _videoElement = videoElement;
    
    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': 'environment',
          'width': {'ideal': 1920},
          'height': {'ideal': 1080},
        },
        'audio': false,
      });
      
      if (stream != null) {
        _mediaStream = stream;
        _videoElement!.srcObject = _mediaStream;
        
        setState(() {
          _cameraInitialized = true;
          _accessDenied = false;
        });
      }
    } catch (e) {
      print('Error initializing web camera: $e');
      setState(() {
        _accessDenied = true;
      });
    }
  }
  
  /// Dispose of the web camera
  void _disposeWebCamera() {
    if (_mediaStream != null) {
      _mediaStream!.getTracks().forEach((track) {
        track.stop();
      });
    }
    
    _videoElement?.srcObject = null;
    _videoElement = null;
    _mediaStream = null;
  }
  
  /// Take a picture using the webcam
  Future<void> _takePictureWeb() async {
    if (_videoElement == null || _mediaStream == null || _takingPicture) {
      return;
    }
    
    setState(() {
      _takingPicture = true;
    });
    
    try {
      // Create a canvas to capture the video frame
      final canvasElement = html.CanvasElement(
        width: _videoElement!.videoWidth,
        height: _videoElement!.videoHeight,
      );
      
      // Draw the current video frame to the canvas
      canvasElement.context2D.drawImage(_videoElement!, 0, 0);
      
      // Convert the canvas to a data URL
      final dataUrl = canvasElement.toDataUrl('image/jpeg');
      
      // Convert to blob
      final blob = await _dataURLToBlob(dataUrl);
      
      // Create XFile from blob
      final file = XFile(
        dataUrl,
        bytes: await _blobToBytes(blob),
        name: 'webcam_capture_${DateTime.now().millisecondsSinceEpoch}.jpg',
        mimeType: 'image/jpeg',
      );
      
      if (widget.onCapture != null) {
        widget.onCapture!(file);
      }
    } catch (e) {
      print('Error taking picture on web: $e');
    } finally {
      if (mounted) {
        setState(() {
          _takingPicture = false;
        });
      }
    }
  }
  
  /// Use image picker as fallback
  Future<void> _useImagePickerFallback() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null && widget.onCapture != null) {
        widget.onCapture!(image);
      }
    } catch (e) {
      print('Error using image picker: $e');
    }
  }
  
  /// Convert data URL to blob
  Future<html.Blob> _dataURLToBlob(String dataUrl) async {
    final uri = Uri.parse(dataUrl);
    final completer = Completer<html.Blob>();
    
    if (!uri.isScheme('data')) {
      throw Exception('Invalid data URL');
    }
    
    // Parse data URL
    final mimeMatch = RegExp(r'^data:(.*?);base64,').firstMatch(dataUrl);
    if (mimeMatch == null) {
      throw Exception('Invalid data URL format');
    }
    
    final mime = mimeMatch.group(1) ?? 'image/jpeg';
    final base64 = dataUrl.substring(mimeMatch.end);
    
    // Decode base64
    final binary = base64Decode(base64);
    
    // Convert to blob
    final blob = html.Blob([binary], mime);
    completer.complete(blob);
    
    return completer.future;
  }
  
  /// Convert blob to bytes
  Future<Uint8List> _blobToBytes(html.Blob blob) async {
    final completer = Completer<Uint8List>();
    final reader = html.FileReader();
    
    reader.onLoad.listen((_) {
      final result = reader.result as dynamic;
      if (result is Uint8List) {
        completer.complete(result);
      } else if (result is String) {
        // Convert base64 to bytes if needed
        completer.complete(base64Decode(result));
      } else {
        completer.completeError('Unknown result type: ${result.runtimeType}');
      }
    });
    
    reader.onError.listen((error) {
      completer.completeError('Error reading blob: $error');
    });
    
    reader.readAsArrayBuffer(blob);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (_accessDenied) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.white70,
              ),
              const SizedBox(height: 16),
              Text(
                'Camera access denied',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enable camera access in your browser settings',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _useImagePickerFallback,
                child: const Text('Use Image Picker Instead'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!_cameraInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // HtmlElementView for the camera preview
        HtmlElementView(viewType: _viewId),
        
        // Camera controls
        if (widget.showControls)
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePictureWeb,
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
            ),
          ),
      ],
    );
  }
}