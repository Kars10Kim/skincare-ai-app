import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/camera_models.dart';
import '../utils/error_handling.dart';

/// A web-specific fallback for camera functionality
/// This is used in the Replit environment and browser
class WebCameraFallback extends StatefulWidget {
  /// Callback when an image is captured
  final Function(CameraImageResult result) onImageCaptured;
  
  /// Create a web camera fallback
  const WebCameraFallback({
    Key? key,
    required this.onImageCaptured,
  }) : super(key: key);
  
  @override
  State<WebCameraFallback> createState() => _WebCameraFallbackState();
}

class _WebCameraFallbackState extends State<WebCameraFallback> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          alignment: Alignment.center,
          color: Colors.grey.shade200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.camera_alt,
                size: 100,
                color: Colors.grey,
              ),
              if (_isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _buildActionButton(
              'Simulate Barcode',
              Icons.qr_code,
              Colors.blue,
              _simulateBarcodeScan,
            ),
            _buildActionButton(
              'Simulate Photo',
              Icons.photo_camera,
              Colors.green,
              _simulatePhotoCapture,
            ),
            _buildActionButton(
              'Upload Photo',
              Icons.upload_file,
              Colors.purple,
              _simulatePhotoUpload,
            ),
          ],
        ),
      ],
    );
  }
  
  /// Build an action button for the web fallback
  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onPressed: _isLoading ? null : onPressed,
    );
  }
  
  /// Simulate a barcode scan
  Future<void> _simulateBarcodeScan() async {
    _setLoading(true);
    
    try {
      // Show a fake barcode scan dialog
      final String? barcode = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return _buildBarcodeInputDialog(context);
        },
      );
      
      if (barcode != null && barcode.isNotEmpty) {
        // Create a sample image for demonstration
        final sampleImageData = await _createSampleImage();
        final tempFile = XFile.fromData(
          sampleImageData,
          name: 'sample_barcode.jpg',
          mimeType: 'image/jpeg',
        );
        
        // Notify the parent widget
        widget.onImageCaptured(
          CameraImageResult(
            imageFile: tempFile,
            barcode: barcode,
            source: CameraSource.web,
          ),
        );
      }
    } catch (e) {
      // Show error dialog
      CameraError.unknown
          .showAlert(context);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Build a dialog for simulating barcode input
  Widget _buildBarcodeInputDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    return AlertDialog(
      title: const Text('Simulate Barcode Scan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter a barcode number to simulate scanning:',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Barcode',
              hintText: 'e.g., 8901234567890',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Scan'),
          onPressed: () {
            Navigator.of(context).pop(controller.text);
          },
        ),
      ],
    );
  }
  
  /// Simulate capturing a photo
  Future<void> _simulatePhotoCapture() async {
    _setLoading(true);
    
    try {
      // Create a sample image for demonstration
      final sampleImageData = await _createSampleImage();
      final tempFile = XFile.fromData(
        sampleImageData,
        name: 'sample_photo.jpg',
        mimeType: 'image/jpeg',
      );
      
      // Notify the parent widget
      widget.onImageCaptured(
        CameraImageResult(
          imageFile: tempFile,
          source: CameraSource.web,
        ),
      );
    } catch (e) {
      // Show error dialog
      CameraError.unknown
          .showAlert(context);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Simulate uploading a photo
  Future<void> _simulatePhotoUpload() async {
    _setLoading(true);
    
    try {
      // Show a fake image selection dialog
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Simulate Photo Upload'),
            content: const Text(
              'In a real mobile app, this would open your photo gallery.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              ElevatedButton(
                child: const Text('Continue'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
      
      if (confirmed == true) {
        // Create a sample image for demonstration
        final sampleImageData = await _createSampleImage();
        final tempFile = XFile.fromData(
          sampleImageData,
          name: 'uploaded_photo.jpg',
          mimeType: 'image/jpeg',
        );
        
        // Notify the parent widget
        widget.onImageCaptured(
          CameraImageResult(
            imageFile: tempFile,
            source: CameraSource.gallery,
          ),
        );
      }
    } catch (e) {
      // Show error dialog
      CameraError.unknown
          .showAlert(context);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Create a sample image for demo purposes
  Future<Uint8List> _createSampleImage() async {
    // This is just a base64-encoded small empty image for demonstration
    const String base64Image = 
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
    return base64Decode(base64Image);
  }
  
  /// Set loading state
  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }
}