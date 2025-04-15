import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../utils/exceptions.dart';

/// Class for handling camera-related permissions
class CameraPermissions {
  /// Check if the app has camera access
  static Future<bool> get hasCameraAccess async {
    // On web, permissions are handled differently by the browser
    if (kIsWeb) return true;
    
    final status = await Permission.camera.status;
    
    if (status.isPermanentlyDenied) {
      throw const PermissionDeniedException(
        'camera',
        'Camera access permanently denied. Please enable in settings.',
      );
    }
    
    return status.isGranted;
  }
  
  /// Request camera permission
  static Future<bool> requestCameraAccess() async {
    // On web, permissions are handled differently by the browser
    if (kIsWeb) return true;
    
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  /// Check if the app has gallery/photo access
  static Future<bool> get hasGalleryAccess async {
    // On web, permissions are handled differently by the browser
    if (kIsWeb) return true;
    
    final status = await Permission.photos.status;
    
    if (status.isPermanentlyDenied) {
      throw const PermissionDeniedException(
        'photos',
        'Photo library access permanently denied. Please enable in settings.',
      );
    }
    
    return status.isGranted;
  }
  
  /// Request gallery/photo permission
  static Future<bool> requestGalleryAccess() async {
    // On web, permissions are handled differently by the browser
    if (kIsWeb) return true;
    
    final status = await Permission.photos.request();
    return status.isGranted;
  }
  
  /// Check if both camera and gallery permissions are granted
  static Future<bool> get hasAllPermissions async {
    if (kIsWeb) return true;
    
    final cameraGranted = await hasCameraAccess;
    final galleryGranted = await hasGalleryAccess;
    
    return cameraGranted && galleryGranted;
  }
  
  /// Request all required permissions
  static Future<bool> requestAllPermissions() async {
    if (kIsWeb) return true;
    
    final cameraGranted = await requestCameraAccess();
    final galleryGranted = await requestGalleryAccess();
    
    return cameraGranted && galleryGranted;
  }
}