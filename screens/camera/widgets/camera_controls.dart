import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../utils/constants.dart';
import '../../../widgets/camera/gallery_access_button.dart';

/// Controls for camera operations
class CameraControls extends StatelessWidget {
  /// Callback for capture button
  final VoidCallback onCapture;
  
  /// Callback for switching camera
  final VoidCallback? onSwitchCamera;
  
  /// Callback for toggling flash
  final VoidCallback? onToggleFlash;
  
  /// Callback for accessing gallery
  final VoidCallback? onGalleryAccess;
  
  /// Current flash mode
  final FlashMode flashMode;
  
  /// Whether processing is in progress
  final bool isProcessing;
  
  /// Creates a camera controls widget
  const CameraControls({
    Key? key,
    required this.onCapture,
    this.onSwitchCamera,
    this.onToggleFlash,
    this.onGalleryAccess,
    required this.flashMode,
    this.isProcessing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Flash toggle button
          _buildFlashButton(),
          
          // Gallery access button
          _buildGalleryButton(),
          
          // Capture button
          _buildCaptureButton(),
          
          // Switch camera button
          _buildSwitchCameraButton(),
        ],
      ),
    );
  }
  
  /// Builds the gallery access button
  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: !isProcessing ? onGalleryAccess : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black38,
        ),
        child: const Icon(
          Icons.photo_library_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
  
  /// Builds the flash toggle button
  Widget _buildFlashButton() {
    IconData flashIcon;
    Color iconColor;
    
    switch (flashMode) {
      case FlashMode.off:
        flashIcon = Icons.flash_off;
        iconColor = Colors.white;
        break;
      case FlashMode.auto:
        flashIcon = Icons.flash_auto;
        iconColor = Colors.yellow;
        break;
      case FlashMode.always:
        flashIcon = Icons.flash_on;
        iconColor = Colors.yellow;
        break;
      case FlashMode.torch:
        flashIcon = Icons.highlight;
        iconColor = Colors.yellow;
        break;
    }
    
    return IconButton(
      onPressed: !isProcessing ? onToggleFlash : null,
      icon: Icon(flashIcon, color: iconColor, size: 28),
      style: IconButton.styleFrom(
        backgroundColor: Colors.black38,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
  
  /// Builds the capture button
  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: !isProcessing ? onCapture : null,
      child: Container(
        width: 72,
        height: 72,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isProcessing 
                ? AppColors.disabledColor 
                : AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
  
  /// Builds the switch camera button
  Widget _buildSwitchCameraButton() {
    return IconButton(
      onPressed: !isProcessing ? onSwitchCamera : null,
      icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 28),
      style: IconButton.styleFrom(
        backgroundColor: Colors.black38,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}