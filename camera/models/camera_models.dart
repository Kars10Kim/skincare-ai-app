import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Enum representing the camera mode
enum CameraMode {
  /// Mode for scanning text
  text,
  
  /// Mode for scanning barcodes
  barcode,
  
  /// Mode for taking regular photos
  photo
}

/// Enum representing the source of an image
enum CameraSource {
  /// Image from the camera
  camera,
  
  /// Image from the gallery
  gallery,
  
  /// Image from the web (for Replit web fallback)
  web
}

/// Represents the result of a camera capture operation
class CameraImageResult {
  /// The image file
  final XFile imageFile;
  
  /// The barcode value (if detected)
  final String? barcode;
  
  /// The extracted text (if detected)
  final String? extractedText;
  
  /// Source of the image (camera, gallery, web)
  final CameraSource source;
  
  /// Dimensions of the image
  final Size? dimensions;
  
  /// EXIF metadata
  final Map<String, dynamic>? metadata;
  
  /// Create a camera image result
  CameraImageResult({
    required this.imageFile,
    this.barcode,
    this.extractedText,
    required this.source,
    this.dimensions,
    this.metadata,
  });
  
  /// Convert to File
  File get file => File(imageFile.path);
  
  /// Whether the image contains a barcode
  bool get hasBarcode => barcode != null && barcode!.isNotEmpty;
  
  /// Whether the image contains extracted text
  bool get hasText => extractedText != null && extractedText!.isNotEmpty;
  
  /// Whether we're running on the web
  static bool get isWeb => kIsWeb;
}

/// Represents camera initialization options
class CameraOptions {
  /// Which camera to use
  final CameraDescription? camera;
  
  /// Resolution preset
  final ResolutionPreset resolution;
  
  /// Whether to enable audio
  final bool enableAudio;
  
  /// Create camera options
  const CameraOptions({
    this.camera,
    this.resolution = ResolutionPreset.high,
    this.enableAudio = false,
  });
}

/// Size class to represent dimensions
class Size {
  /// Width dimension
  final double width;
  
  /// Height dimension
  final double height;
  
  /// Create a size with width and height
  const Size(this.width, this.height);
  
  /// Get the aspect ratio
  double get aspectRatio => width / height;
  
  @override
  String toString() => 'Size($width x $height)';
}