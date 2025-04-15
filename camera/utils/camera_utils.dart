import 'dart:io';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Utilities for camera functionality
class CameraUtils {
  /// Available cameras
  static List<CameraDescription>? _cameras;
  
  /// Device info plugin
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  
  /// Initialize cameras
  static Future<List<CameraDescription>> initCameras() async {
    if (_cameras != null) return _cameras!;
    
    try {
      _cameras = await availableCameras();
      return _cameras!;
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
      return [];
    }
  }
  
  /// Check if a camera is available
  static Future<bool> hasCamera() async {
    if (kIsWeb) {
      // Special handling for web
      try {
        final cameras = await initCameras();
        return cameras.isNotEmpty;
      } catch (e) {
        return false;
      }
    } else {
      // Detect if running on an emulator
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        final isEmulator = !androidInfo.isPhysicalDevice;
        if (isEmulator) {
          // Some emulators don't have cameras
          return false;
        }
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        final isEmulator = !iosInfo.isPhysicalDevice;
        if (isEmulator) {
          // iOS simulators don't have cameras
          return false;
        }
      }
      
      try {
        final cameras = await initCameras();
        return cameras.isNotEmpty;
      } catch (e) {
        return false;
      }
    }
  }
  
  /// Get back camera if available
  static Future<CameraDescription?> getBackCamera() async {
    final cameras = await initCameras();
    if (cameras.isEmpty) return null;
    
    // Find back camera
    try {
      return cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    } catch (e) {
      // If back camera not found, return the first camera
      return cameras.first;
    }
  }
  
  /// Get front camera if available
  static Future<CameraDescription?> getFrontCamera() async {
    final cameras = await initCameras();
    if (cameras.isEmpty) return null;
    
    // Find front camera
    try {
      return cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } catch (e) {
      // If front camera not found, return null
      return null;
    }
  }
}