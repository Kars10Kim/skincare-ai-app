import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../localization/app_localizations.dart';
import '../features/recognition/domain/entities/recognized_product.dart';
import '../features/recognition/domain/repositories/product_repository.dart';
import '../features/recognition/presentation/widgets/recognition_result_card.dart';
import '../features/recognition/presentation/widgets/scan_overlay.dart';
import '../features/recognition/utils/error_recovery.dart';
import '../utils/accessibility.dart';

/// Screen for product recognition
class ProductRecognitionScreen extends StatefulWidget {
  /// Create a product recognition screen
  const ProductRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<ProductRecognitionScreen> createState() => _ProductRecognitionScreenState();
}

class _ProductRecognitionScreenState extends State<ProductRecognitionScreen>
    with TickerProviderStateMixin {
  /// Selected image for recognition
  File? _selectedImage;
  
  /// Whether an image is being processed
  bool _isProcessing = false;
  
  /// Animation controller for scan line
  late AnimationController _scanLineController;
  
  /// Animation for scan line
  late Animation<double> _scanLineAnimation;
  
  /// Current scan mode
  ScanOverlayType _scanMode = ScanOverlayType.barcode;
  
  /// Controller for tab view
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Initialize scan line animation
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanLineController,
        curve: Curves.easeInOut,
      ),
    );
    
    _scanLineController.repeat(reverse: true);
  }
  
  /// Handle tab change
  void _handleTabChange() {
    if (_tabController.index == 0) {
      setState(() {
        _scanMode = ScanOverlayType.barcode;
      });
    } else {
      setState(() {
        _scanMode = ScanOverlayType.ingredients;
      });
    }
  }
  
  @override
  void dispose() {
    _scanLineController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  /// Select image from camera
  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 90,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      
      _processImage();
    }
  }
  
  /// Select image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 90,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      
      _processImage();
    }
  }
  
  /// Process the selected image
  Future<void> _processImage() async {
    if (_selectedImage == null) return;
    
    final repository = Provider.of<ProductRepository>(context, listen: false);
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Process the image based on the current scan mode
      if (_scanMode == ScanOverlayType.barcode) {
        await repository.recognizeFromBarcode(_selectedImage!);
      } else {
        await repository.recognizeFromIngredients(_selectedImage!);
      }
    } catch (e) {
      if (mounted) {
        // Handle error and show recovery options
        final retry = await RecognitionErrorHandler.handleError(context, e);
        
        if (retry && mounted) {
          // Retry with the same image
          _processImage();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
  /// Clear the selected image and recognition results
  void _clearImage() {
    final repository = Provider.of<ProductRepository>(context, listen: false);
    repository.clearRecognition();
    
    setState(() {
      _selectedImage = null;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.productRecognition),
        elevation: 0,
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearImage,
              tooltip: localizations.clearImage,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.qr_code),
              text: localizations.barcode,
            ),
            Tab(
              icon: const Icon(Icons.text_fields),
              text: localizations.ingredients,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildBody(theme, localizations),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme, localizations),
    );
  }
  
  /// Build the main body
  Widget _buildBody(ThemeData theme, AppLocalizations localizations) {
    final repository = Provider.of<ProductRepository>(context);
    
    return Consumer<ProductRepository>(
      builder: (context, repository, _) {
        final state = repository.state;
        
        return Stack(
          children: [
            // Background or camera preview
            _selectedImage == null
                ? _buildCameraPlaceholder(theme, localizations)
                : _buildImagePreview(),
            
            // Scan overlay
            if (_selectedImage != null && !state.isRecognizing)
              ScanOverlay(
                type: _scanMode,
                scanLineAnimation: _scanLineAnimation.value,
                primaryColor: theme.colorScheme.primary,
                instructions: _scanMode == ScanOverlayType.barcode
                    ? localizations.scanBarcodeInstructions
                    : localizations.scanIngredientsInstructions,
              ),
            
            // Processing indicator
            if (state.isRecognizing)
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        localizations.processingImage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  /// Build the camera placeholder when no image is selected
  Widget _buildCameraPlaceholder(ThemeData theme, AppLocalizations localizations) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              _scanMode == ScanOverlayType.barcode
                  ? localizations.takeBarcodePhoto
                  : localizations.takeIngredientsPhoto,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the image preview when an image is selected
  Widget _buildImagePreview() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
  
  /// Build the bottom bar
  Widget _buildBottomBar(ThemeData theme, AppLocalizations localizations) {
    final repository = Provider.of<ProductRepository>(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Recognition result
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: repository.state.lastResult?.success == true
                ? RecognitionResultCard(
                    product: repository.state.lastResult?.product,
                    onRetry: _processImage,
                  )
                : const SizedBox.shrink(),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera button
                ElevatedButton.icon(
                  onPressed: !_isProcessing ? _takePicture : null,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(localizations.camera),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                
                // Gallery button
                OutlinedButton.icon(
                  onPressed: !_isProcessing ? _pickImage : null,
                  icon: const Icon(Icons.photo_library),
                  label: Text(localizations.gallery),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}