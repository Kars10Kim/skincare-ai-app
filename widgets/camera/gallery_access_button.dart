import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../providers/camera_provider.dart';
import '../../utils/accessibility.dart';
import '../../utils/animations.dart';
import '../../screens/results/results_screen.dart';

/// Button for accessing gallery photos
class GalleryAccessButton extends StatefulWidget {
  /// Maximum number of images to show
  final int maxImages;
  
  /// Whether to show a label
  final bool showLabel;
  
  /// Icon size
  final double iconSize;
  
  /// Create a gallery access button
  const GalleryAccessButton({
    Key? key,
    this.maxImages = 10,
    this.showLabel = true,
    this.iconSize = 28,
  }) : super(key: key);
  
  @override
  State<GalleryAccessButton> createState() => _GalleryAccessButtonState();
}

class _GalleryAccessButtonState extends State<GalleryAccessButton> with AccessibilitySupport {
  /// Image picker
  final _picker = ImagePicker();
  
  /// Whether loading recent photos
  bool _isLoading = false;
  
  /// Whether gallery permission is granted
  bool? _galleryPermissionGranted;
  
  /// Handle gallery selection
  Future<void> _handleGallerySelection() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Check if permission is granted
      if (_galleryPermissionGranted == null) {
        final status = await Permission.photos.request();
        _galleryPermissionGranted = status.isGranted;
        
        if (!_galleryPermissionGranted!) {
          _showPermissionDeniedDialog();
          return;
        }
      }
      
      // Pick image from gallery
      final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
      final ScanMode scanMode = cameraProvider.scanMode;
      
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );
      
      if (pickedFile == null) {
        return;
      }
      
      // Convert XFile to File
      final file = File(pickedFile.path);
      
      if (scanMode == ScanMode.barcode) {
        // Process for barcode
        final barcodes = await cameraProvider.processImageForBarcodes(file);
        
        if (barcodes.isEmpty) {
          _showNoBarcodeFoundDialog();
          return;
        }
        
        // Get barcode value
        final barcode = barcodes.first.rawValue;
        if (barcode == null) {
          _showNoBarcodeFoundDialog();
          return;
        }
        
        // Navigate to results
        if (!mounted) return;
        
        Navigator.push(
          context,
          AccessiblePageRoute(
            child: ResultsScreen(
              productId: barcode,
              isBarcodeScan: true,
            ),
          ),
        );
      } else {
        // Process for ingredients text
        final recognizedText = await cameraProvider.processImageForText(file);
        
        // If no text found, show error
        if (recognizedText.text.isEmpty) {
          _showNoTextFoundDialog();
          return;
        }
        
        // Navigate to results
        if (!mounted) return;
        
        Navigator.push(
          context,
          AccessiblePageRoute(
            child: ResultsScreen(
              productId: recognizedText.text,
              isBarcodeScan: false,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error selecting from gallery: $e');
      _showErrorDialog();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  /// Show permission denied dialog
  void _showPermissionDeniedDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).permissionDeniedTitle),
        content: Text(AppLocalizations.of(context).galleryPermissionDenied),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).buttonCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(AppLocalizations.of(context).buttonOpenSettings),
          ),
        ],
      ),
    );
  }
  
  /// Show no barcode found dialog
  void _showNoBarcodeFoundDialog() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).errorBarcodeNotFound),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Show no text found dialog
  void _showNoTextFoundDialog() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).errorTextRecognition),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Show error dialog
  void _showErrorDialog() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).errorUnknown),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final localizations = AppLocalizations.of(context);
    
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gallery button
          Container(
            height: widget.iconSize * 1.5,
            width: widget.iconSize * 1.5,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : _handleGallerySelection,
                customBorder: const CircleBorder(),
                splashColor: primaryColor.withOpacity(0.3),
                highlightColor: primaryColor.withOpacity(0.1),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          width: widget.iconSize * 0.7,
                          height: widget.iconSize * 0.7,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        )
                      : Icon(
                          Icons.photo_library,
                          color: theme.colorScheme.onSurface,
                          size: widget.iconSize,
                        ),
                ),
              ),
            ),
          ),
          
          // Label
          if (widget.showLabel) ...[
            const SizedBox(height: 4),
            Text(
              localizations.galleryButton,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}