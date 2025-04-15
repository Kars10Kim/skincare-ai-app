import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/scan_history_item.dart';
import '../cubit/product_recognition_cubit.dart';
import '../cubit/product_recognition_state.dart';
import '../widgets/scan_overlay.dart';
import '../widgets/scan_result_card.dart';
import '../widgets/barcode_scanner_view.dart';
import '../widgets/text_recognition_view.dart';
import '../widgets/ingredients_preview.dart';

/// Screen for product recognition
class ProductRecognitionScreen extends StatefulWidget {
  /// Initial tab to show
  final ScanType initialTab;
  
  /// Initial image for image tab
  final dynamic initialImage;
  
  /// Create a product recognition screen
  const ProductRecognitionScreen({
    Key? key,
    this.initialTab = ScanType.barcode,
    this.initialImage,
  }) : super(key: key);

  @override
  State<ProductRecognitionScreen> createState() => _ProductRecognitionScreenState();
}

class _ProductRecognitionScreenState extends State<ProductRecognitionScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  String? _extractedText;
  
  @override
  void initState() {
    super.initState();
    
    // Set device orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    // Initialize tab controller
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _getScanTypeIndex(widget.initialTab),
    );
    
    // Handle initial image if provided
    if (widget.initialImage != null) {
      if (widget.initialImage is XFile) {
        _pickedImage = widget.initialImage as XFile;
      } else if (widget.initialImage is File) {
        _pickedImage = XFile((widget.initialImage as File).path);
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processPickedImage();
      });
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    
    // Reset device orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    super.dispose();
  }
  
  /// Get index of scan type
  int _getScanTypeIndex(ScanType type) {
    switch (type) {
      case ScanType.barcode:
        return 0;
      case ScanType.image:
        return 1;
      case ScanType.text:
        return 2;
    }
  }
  
  /// Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image == null) return;
      
      setState(() {
        _pickedImage = image;
        _extractedText = null;
      });
      
      _processPickedImage();
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }
  
  /// Process picked image
  Future<void> _processPickedImage() async {
    if (_pickedImage == null) return;
    
    final cubit = context.read<ProductRecognitionCubit>();
    
    // Process the image based on current tab
    if (_tabController.index == 1) { // Image tab
      await cubit.processImage(_pickedImage!);
    } else if (_tabController.index == 2) { // Text tab
      await cubit.extractTextFromImage(_pickedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductRecognitionCubit, ProductRecognitionState>(
      listener: (context, state) {
        // Handle state changes
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!.displayMessage),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  // Retry the last action
                  final cubit = context.read<ProductRecognitionCubit>();
                  cubit.retry();
                },
              ),
            ),
          );
        }
        
        // Update extracted text
        if (state.extractedText != null && state.extractedText != _extractedText) {
          setState(() {
            _extractedText = state.extractedText;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              // Tab content
              _buildTabContent(context, state),
              
              // Scan overlay
              ScanOverlay(
                tabController: _tabController,
                isLoading: state.isLoading,
                hasResult: state.scan != null,
                onTabChanged: (index) {
                  _tabController.animateTo(index);
                },
                onClose: () => Navigator.of(context).pop(),
              ),
              
              // Results
              if (state.scan != null)
                _buildResults(context, state),
            ],
          ),
        );
      },
    );
  }
  
  /// Build tab content
  Widget _buildTabContent(BuildContext context, ProductRecognitionState state) {
    return TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Barcode scanner tab
        BarcodeScannerView(
          onBarcodeDetected: (barcode) {
            // Process barcode
            final cubit = context.read<ProductRecognitionCubit>();
            cubit.processBarcode(barcode);
          },
        ),
        
        // Image scan tab
        _buildImageScanView(context, state),
        
        // Text recognition tab
        TextRecognitionView(
          initialText: _extractedText,
          onTextExtracted: (text) {
            // Process extracted text
            final cubit = context.read<ProductRecognitionCubit>();
            cubit.processText(text);
          },
          onPickImage: _pickImage,
        ),
      ],
    );
  }
  
  /// Build image scan view
  Widget _buildImageScanView(BuildContext context, ProductRecognitionState state) {
    return Stack(
      children: [
        // Background
        Container(
          color: Colors.black,
          child: Center(
            child: _pickedImage != null
                ? Image.file(
                    File(_pickedImage!.path),
                    fit: BoxFit.contain,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_search,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Scan Product Image',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Take a picture or select one from your gallery',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Select Image'),
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
          ),
        ),
        
        // Preview of extracted ingredients if any
        if (_pickedImage != null && state.extractedIngredients != null && state.extractedIngredients!.isNotEmpty)
          Positioned(
            bottom: 120,
            left: 16,
            right: 16,
            child: IngredientsPreview(
              ingredients: state.extractedIngredients!,
              onProcess: () {
                // Analyze the extracted ingredients
                final cubit = context.read<ProductRecognitionCubit>();
                cubit.analyzeIngredients(state.extractedIngredients!);
              },
            ),
          ),
      ],
    );
  }
  
  /// Build results view
  Widget _buildResults(BuildContext context, ProductRecognitionState state) {
    if (state.scan == null) return const SizedBox.shrink();
    
    // Get bottom padding for safe area
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: bottomPadding > 0 ? bottomPadding : 16,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Scan result card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ScanResultCard(
                scan: state.scan!,
                conflicts: state.conflicts,
                onViewDetails: () {
                  // Navigate to product details
                  Navigator.of(context).pushReplacementNamed(
                    '/product',
                    arguments: state.scan!.barcode,
                  );
                },
                onAddToFavorites: () {
                  // Add to favorites
                  final cubit = context.read<ProductRecognitionCubit>();
                  cubit.toggleFavorite();
                },
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        // Navigate to product details
                        Navigator.of(context).pushReplacementNamed(
                          '/product',
                          arguments: state.scan!.barcode,
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}