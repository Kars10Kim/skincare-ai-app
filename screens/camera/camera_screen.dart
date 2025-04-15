import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../providers/camera_provider.dart';
import '../../utils/accessibility.dart';
import '../../utils/animations.dart';
import '../../utils/memory_management.dart';
import '../../utils/ui_performance.dart';
import '../../widgets/animated_components.dart';
import '../../widgets/loading/loading_state_widget.dart';
import '../../widgets/skincare_icons.dart';
import '../results/results_screen.dart';

/// Camera screen for scanning
class CameraScreen extends StatefulWidget {
  /// Create camera screen
  const CameraScreen({Key? key}) : super(key: key);
  
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, AutoDisposeMixin, AccessibilitySupport, SingleTickerProviderStateMixin {
  /// Camera provider
  late CameraProvider _cameraProvider;
  
  /// Whether manual barcode input dialog is shown
  bool _showingDialog = false;
  
  /// Animation controller for scan line
  late AnimationController _scanLineController;
  
  /// Current camera scan mode
  ScanMode get _scanMode => _cameraProvider.scanMode;
  
  /// Get instructions for current scan mode
  String _getInstructions(AppLocalizations localizations) {
    return _scanMode == ScanMode.barcode
        ? localizations.cameraBarcodeInstructions
        : localizations.cameraIngredientsInstructions;
  }
  
  @override
  void initState() {
    super.initState();
    
    // Initialize scan line animation controller
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scanLineController.repeat(reverse: true);
    
    // Register animation controller to be disposed
    addDisposable(_scanLineController);
    
    // Add observer for app lifecycle
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize camera after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get camera provider
    _cameraProvider = Provider.of<CameraProvider>(context);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes for camera
    if (_cameraProvider.controller == null) return;
    
    // Resume camera when app is resumed
    if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
    
    // Pause camera when app is paused
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _pauseCamera();
    }
  }
  
  /// Initialize the camera
  Future<void> _initializeCamera() async {
    if (_cameraProvider.isInitialized) return;
    await _cameraProvider.initializeCamera();
    
    // Lock orientation
    if (!mounted) return;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
  
  /// Pause camera
  void _pauseCamera() {
    try {
      if (_cameraProvider.controller?.value.isInitialized ?? false) {
        _cameraProvider.controller?.pausePreview();
      }
    } catch (e) {
      print('Error pausing camera: $e');
    }
  }
  
  /// Resume camera
  void _resumeCamera() {
    if (_cameraProvider.controller?.value.isInitialized ?? false) {
      _cameraProvider.controller?.resumePreview();
    }
  }
  
  /// Take picture and process
  Future<void> _takePicture() async {
    UIPerformance.startMeasure('TakePicture');
    
    try {
      // Take picture
      final file = await _cameraProvider.takePicture();
      if (file == null) return;
      
      if (!mounted) return;
      
      if (_scanMode == ScanMode.barcode) {
        // Process barcode
        final barcodes = await _cameraProvider.processImageForBarcodes(file);
        
        // If no barcodes found, show error
        if (barcodes.isEmpty) {
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).errorBarcodeNotFound,
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        
        // Get barcode value
        final barcode = barcodes.first.rawValue;
        if (barcode == null) return;
        
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
        // Process ingredients text
        final recognizedText = await _cameraProvider.processImageForText(file);
        
        // If no text found, show error
        if (recognizedText.text.isEmpty) {
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).errorTextRecognition,
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
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
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).errorUnknown,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      UIPerformance.endMeasure('TakePicture');
    }
  }
  
  /// Show manual barcode input dialog
  Future<void> _showManualBarcodeInputDialog() async {
    if (_showingDialog) return;
    
    _showingDialog = true;
    _pauseCamera();
    
    final controller = TextEditingController();
    addDisposable(controller);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    final barcode = await showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: GlassmorphicCard(
          backgroundColor: Colors.white.withOpacity(0.9),
          borderColor: primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          blur: 10,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title with icon
                Row(
                  children: [
                    Icon(
                      Icons.qr_code,
                      color: primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Enter Barcode',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Input field with animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '123456789012',
                        prefixIcon: Icon(Icons.numbers, color: primaryColor),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          Navigator.pop(context, value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          Navigator.pop(context, controller.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Scan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    _showingDialog = false;
    _resumeCamera();
    
    if (barcode == null || barcode.isEmpty) return;
    
    // Navigate to results
    if (!mounted) return;
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Processing barcode...'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Navigate with transition
    Navigator.push(
      context,
      AccessiblePageTransition(
        page: ResultsScreen(
          productId: barcode,
          isBarcodeScan: true,
        ),
        slideDirection: SlideDirection.fromRight,
      ),
    );
  }
  
  /// Retry camera initialization
  void _retryInitialization() {
    _initializeCamera();
  }
  
  /// Handle selecting image from gallery
  Future<void> _handleGallerySelection() async {
    UIPerformance.startMeasure('GallerySelection');
    
    try {
      // Pause camera preview
      _pauseCamera();
      
      // Check for gallery permission
      final status = await Permission.photos.request();
      if (status != PermissionStatus.granted) {
        _showPermissionDeniedDialog();
        return;
      }
      
      // Pick image from gallery
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );
      
      if (pickedFile == null) {
        _resumeCamera();
        return;
      }
      
      // Convert XFile to File
      final file = File(pickedFile.path);
      
      if (_scanMode == ScanMode.barcode) {
        // Process barcode
        final barcodes = await _cameraProvider.processImageForBarcodes(file);
        
        // If no barcodes found, show error
        if (barcodes.isEmpty) {
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).errorBarcodeNotFound,
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _resumeCamera();
          return;
        }
        
        // Get barcode value
        final barcode = barcodes.first.rawValue;
        if (barcode == null) {
          _resumeCamera();
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
        // Process ingredients text
        final recognizedText = await _cameraProvider.processImageForText(file);
        
        // If no text found, show error
        if (recognizedText.text.isEmpty) {
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).errorTextRecognition,
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _resumeCamera();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorUnknown,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _resumeCamera();
    } finally {
      UIPerformance.endMeasure('GallerySelection');
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
            onPressed: () {
              Navigator.pop(context);
              _resumeCamera();
            },
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
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _scanMode == ScanMode.barcode
              ? localizations.cameraScanBarcode
              : localizations.cameraScanIngredients,
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Camera preview
          Expanded(
            child: _buildCameraPreview(context, localizations, theme),
          ),
          
          // Camera controls
          _buildControls(context, localizations, theme),
        ],
      ),
    );
  }
  
  /// Build camera preview
  Widget _buildCameraPreview(
    BuildContext context,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    final primaryColor = theme.colorScheme.primary;
    
    if (_cameraProvider.isLoading) {
      return LoadingStateWidget(
        isLoading: true,
        type: LoadingStateType.spinner,
        message: localizations.cameraScanningMessage,
      );
    }
    
    if (_cameraProvider.error != null) {
      return GlassmorphicCard(
        backgroundColor: Colors.white.withOpacity(0.95),
        borderColor: Colors.red.shade300.withOpacity(0.3),
        blur: 0,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.5 + (0.5 * value),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Error message with animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _cameraProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Action buttons with staggered animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _retryInitialization,
                        icon: const Icon(Icons.refresh),
                        label: Text(localizations.buttonTryAgain),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_scanMode == ScanMode.barcode) ...[
                        OutlinedButton.icon(
                          onPressed: _showManualBarcodeInputDialog,
                          icon: const Icon(Icons.keyboard),
                          label: const Text('Enter Barcode Manually'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (!_cameraProvider.isInitialized || 
        _cameraProvider.controller == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Text(
                'Initializing camera...',
                style: TextStyle(
                  fontSize: 16,
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    if (_cameraProvider.isProcessing) {
      return Container(
        color: Colors.black45,
        child: Center(
          child: GlassmorphicCard(
            backgroundColor: Colors.white.withOpacity(0.1),
            borderColor: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
            blur: 10,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Custom progress indicator with animation
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          value: null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Processing message
                  Text(
                    localizations.cameraProcessing,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    _scanMode == ScanMode.barcode
                      ? 'Analyzing barcode...'
                      : 'Extracting ingredients...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return Stack(
      children: [
        // Camera preview with animation
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: child,
            );
          },
          child: Positioned.fill(
            child: ClipRRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraProvider.controller!.value.previewSize!.height,
                  height: _cameraProvider.controller!.value.previewSize!.width,
                  child: CameraPreview(_cameraProvider.controller!),
                ),
              ),
            ),
          ),
        ),
        
        // Scanner overlay with animated border
        Positioned.fill(
          child: _buildScannerOverlay(context, localizations, theme),
        ),
        
        // Scan instructions with glassmorphism
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, -20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _scanMode == ScanMode.barcode
                              ? Icons.qr_code_scanner
                              : Icons.text_fields,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getInstructions(localizations),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Scan indicator animation for barcode mode
        if (_scanMode == ScanMode.barcode)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _scanLineController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ScanLinePainter(
                      color: primaryColor,
                      animationValue: _scanLineController.value,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
  
  /// Build scanner overlay
  Widget _buildScannerOverlay(
    BuildContext context,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return CustomPaint(
      painter: ScannerOverlayPainter(
        scanMode: _scanMode,
        borderColor: theme.primaryColor,
      ),
    );
  }
  
  /// Build camera controls
  Widget _buildControls(
    BuildContext context,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    final primaryColor = theme.colorScheme.primary;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        children: [
          // Scan mode selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Barcode scan mode
                _buildScanModeOption(
                  localizations.cameraBarcodeScanMode,
                  ScanMode.barcode,
                  Icons.qr_code_scanner,
                  primaryColor,
                  theme,
                ),
                
                const SizedBox(width: 8),
                
                // Ingredients scan mode
                _buildScanModeOption(
                  localizations.cameraIngredientScanMode,
                  ScanMode.ingredients,
                  Icons.text_fields,
                  primaryColor,
                  theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Camera controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Flash toggle with animation
              _buildFlashToggle(primaryColor),
              
              // Gallery access button
              _buildGalleryButton(primaryColor),
              
              // Capture button with pulsating animation
              _buildCaptureButton(primaryColor),
              
              // Manual barcode button
              _buildManualBarcodeButton(primaryColor),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build scan mode option
  Widget _buildScanModeOption(
    String title,
    ScanMode mode,
    IconData icon,
    Color primaryColor,
    ThemeData theme,
  ) {
    final isSelected = _scanMode == mode;
    
    return GestureDetector(
      onTap: () {
        if (_scanMode != mode) {
          _cameraProvider.toggleScanMode();
          // Add haptic feedback
          HapticFeedback.selectionClick();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build gallery access button
  Widget _buildGalleryButton(Color primaryColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(-10 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: _isButtonEnabled() ? _handleGallerySelection : null,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(
                  Icons.photo_library_rounded,
                  color: primaryColor,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build flash toggle button
  Widget _buildFlashToggle(Color primaryColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(-20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                _cameraProvider.toggleFlashMode();
                // Add haptic feedback
                HapticFeedback.lightImpact();
              },
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(
                  _getFlashIcon(),
                  color: primaryColor,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build capture button with animation
  Widget _buildCaptureButton(Color primaryColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _isButtonEnabled() ? () {
          _takePicture();
          // Add haptic feedback
          HapticFeedback.mediumImpact();
        } : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsating background animation
            if (_isButtonEnabled())
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                builder: (context, value, _) {
                  return RepaintBoundary(
                    child: CustomPaint(
                      painter: PulsatingCirclePainter(
                        color: primaryColor.withOpacity(0.3 * (1 - value)),
                        radius: 48 + (15 * value),
                      ),
                    ),
                  );
                },
              ),
            
            // Capture button
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isButtonEnabled()
                    ? primaryColor
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 5,
                ),
                boxShadow: _isButtonEnabled() ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build manual barcode button
  Widget _buildManualBarcodeButton(Color primaryColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: _scanMode == ScanMode.barcode 
        ? Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Material(
                color: Colors.white,
                child: InkWell(
                  onTap: _showManualBarcodeInputDialog,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(
                      Icons.keyboard,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          )
        : SizedBox(width: 56, height: 56),
    );
  }
  
  /// Get icon for current flash mode
  IconData _getFlashIcon() {
    switch (_cameraProvider.flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.torch:
        return Icons.flashlight_on;
      case FlashMode.always:
        return Icons.flash_on;
    }
  }
  
  /// Check if camera button is enabled
  bool _isButtonEnabled() {
    return _cameraProvider.isInitialized && 
        !_cameraProvider.isLoading && 
        !_cameraProvider.isProcessing;
  }
  
  @override
  void dispose() {
    // Remove observer for app lifecycle
    WidgetsBinding.instance.removeObserver(this);
    
    // Unlock orientation
    SystemChrome.setPreferredOrientations([]);
    
    super.dispose();
  }
}

/// Scan line painter for barcode scanning animation
class ScanLinePainter extends CustomPainter {
  /// Color of the scan line
  final Color color;
  
  /// Current animation value
  final double animationValue;
  
  /// Create scan line painter
  ScanLinePainter({
    required this.color,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the position of the scan line
    // This will move the line up and down within the cutout area
    final double lineY = size.height * 0.5 - 60 + (120 * animationValue);
    
    // Create gradient for the scan line
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.transparent,
        color.withOpacity(0.8),
        color,
        color,
        color.withOpacity(0.8),
        Colors.transparent,
      ],
      stops: const [0.0, 0.15, 0.3, 0.7, 0.85, 1.0],
    );
    
    // Calculate rect for scan line
    final scanLineRect = Rect.fromLTWH(
      size.width * 0.1,  // 10% from left
      lineY - 1.5,       // Line height is 3.0
      size.width * 0.8,  // 80% of screen width
      3.0,               // Line thickness
    );
    
    // Create paint for scan line
    final linePaint = Paint()
      ..shader = gradient.createShader(scanLineRect)
      ..style = PaintingStyle.fill;
    
    // Draw scan line
    canvas.drawRect(scanLineRect, linePaint);
    
    // Draw glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      
    canvas.drawRect(
      Rect.fromLTWH(
        scanLineRect.left,
        scanLineRect.top - 2,
        scanLineRect.width,
        scanLineRect.height + 4,
      ),
      glowPaint,
    );
  }
  
  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) {
    return color != oldDelegate.color || 
           animationValue != oldDelegate.animationValue;
  }
}

/// Pulsating circle painter for the capture button
class PulsatingCirclePainter extends CustomPainter {
  /// Color of the circle
  final Color color;
  
  /// Radius of the circle
  final double radius;
  
  /// Create pulsating circle painter
  PulsatingCirclePainter({
    required this.color,
    required this.radius,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(PulsatingCirclePainter oldDelegate) {
    return color != oldDelegate.color || radius != oldDelegate.radius;
  }
}

/// Scanner overlay painter
class ScannerOverlayPainter extends CustomPainter {
  /// Current scan mode
  final ScanMode scanMode;
  
  /// Border color
  final Color borderColor;
  
  /// Create scanner overlay painter
  ScannerOverlayPainter({
    required this.scanMode,
    required this.borderColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    
    // Draw overlay with cutout
    if (scanMode == ScanMode.barcode) {
      // Barcode scanning overlay
      _drawBarcodeOverlay(canvas, size, paint);
    } else {
      // Ingredients scanning overlay
      _drawIngredientsOverlay(canvas, size, paint);
    }
  }
  
  /// Draw barcode scanning overlay
  void _drawBarcodeOverlay(Canvas canvas, Size size, Paint paint) {
    // Calculate cutout size (smaller rectangle)
    final cutoutWidth = size.width * 0.8;
    final cutoutHeight = size.height * 0.2;
    final cutoutLeft = (size.width - cutoutWidth) / 2;
    final cutoutTop = (size.height - cutoutHeight) / 2;
    
    // Draw overlay with cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutWidth, cutoutHeight));
    
    canvas.drawPath(path, paint);
    
    // Draw cutout border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawRect(
      Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutWidth, cutoutHeight),
      borderPaint,
    );
    
    // Draw corner markers
    final cornerSize = 20.0;
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    // Top-left corner
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop),
      Offset(cutoutLeft + cornerSize, cutoutTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop),
      Offset(cutoutLeft, cutoutTop + cornerSize),
      cornerPaint,
    );
    
    // Top-right corner
    canvas.drawLine(
      Offset(cutoutLeft + cutoutWidth, cutoutTop),
      Offset(cutoutLeft + cutoutWidth - cornerSize, cutoutTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutoutLeft + cutoutWidth, cutoutTop),
      Offset(cutoutLeft + cutoutWidth, cutoutTop + cornerSize),
      cornerPaint,
    );
    
    // Bottom-left corner
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop + cutoutHeight),
      Offset(cutoutLeft + cornerSize, cutoutTop + cutoutHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop + cutoutHeight),
      Offset(cutoutLeft, cutoutTop + cutoutHeight - cornerSize),
      cornerPaint,
    );
    
    // Bottom-right corner
    canvas.drawLine(
      Offset(cutoutLeft + cutoutWidth, cutoutTop + cutoutHeight),
      Offset(cutoutLeft + cutoutWidth - cornerSize, cutoutTop + cutoutHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutoutLeft + cutoutWidth, cutoutTop + cutoutHeight),
      Offset(cutoutLeft + cutoutWidth, cutoutTop + cutoutHeight - cornerSize),
      cornerPaint,
    );
  }
  
  /// Draw ingredients scanning overlay
  void _drawIngredientsOverlay(Canvas canvas, Size size, Paint paint) {
    // Calculate cutout size (larger rectangle)
    final cutoutWidth = size.width * 0.8;
    final cutoutHeight = size.height * 0.5;
    final cutoutLeft = (size.width - cutoutWidth) / 2;
    final cutoutTop = (size.height - cutoutHeight) / 2;
    
    // Draw overlay with cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutWidth, cutoutHeight));
    
    canvas.drawPath(path, paint);
    
    // Draw cutout border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawRect(
      Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutWidth, cutoutHeight),
      borderPaint,
    );
    
    // Draw horizontal lines inside the cutout
    final linePaint = Paint()
      ..color = borderColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    final lineSpacing = cutoutHeight / 6;
    for (var i = 1; i < 6; i++) {
      final y = cutoutTop + (lineSpacing * i);
      canvas.drawLine(
        Offset(cutoutLeft, y),
        Offset(cutoutLeft + cutoutWidth, y),
        linePaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) {
    return scanMode != oldDelegate.scanMode || 
        borderColor != oldDelegate.borderColor;
  }
}