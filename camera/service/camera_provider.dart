import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'camera_service.dart';

/// Provider for the camera service
class CameraProvider extends ChangeNotifier {
  /// Camera service instance
  final CameraService _service;
  
  /// Create a camera provider
  CameraProvider({CameraService? service}) : _service = service ?? CameraService();
  
  /// Get the camera service
  CameraService get service => _service;
  
  /// Initialize the camera service
  Future<void> initialize() async {
    await _service.initialize();
    notifyListeners();
  }
  
  /// Dispose of resources
  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
  
  /// Factory method to create a provider
  static CameraProvider create() => CameraProvider();
  
  /// Extension method to get the camera provider from a build context
  static CameraProvider of(BuildContext context) => 
      Provider.of<CameraProvider>(context, listen: false);
}