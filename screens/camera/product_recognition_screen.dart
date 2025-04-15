import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/database_provider.dart';
import '../../services/vision_api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/dialogs/api_key_dialog.dart';
import '../results/product_result_screen.dart';

/// Screen for product recognition using camera or gallery images
class ProductRecognitionScreen extends StatefulWidget {
  const ProductRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<ProductRecognitionScreen> createState() => _ProductRecognitionScreenState();
}

class _ProductRecognitionScreenState extends State<ProductRecognitionScreen> {
  final ImagePicker _picker = ImagePicker();
  final VisionApiService _visionApiService = VisionApiService();
  
  bool _isLoading = false;
  String _statusMessage = '';
  File? _selectedImage;
  Map<String, dynamic>? _recognitionResults;

  @override
  void initState() {
    super.initState();
    // Check if we have the API key, if not ask for it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkApiKey();
    });
  }

  /// Check if the Google Vision API key is configured
  Future<void> _checkApiKey() async {
    if (AppConstants.googleVisionApiKey.isEmpty) {
      await ApiKeyDialog.show(
        context: context,
        apiName: 'Google Vision',
        description: 'To enable product recognition from photos, please enter your Google Vision API key.',
        onSubmit: (String key) {
          AppConstants.googleVisionApiKey = key;
          // In a real app, you would save this to secure storage
        },
      );
    }
  }

  /// Take a photo with the camera
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxHeight: 1200,
        maxWidth: 1200,
        imageQuality: 90,
      );

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
          _recognitionResults = null;
          _statusMessage = '';
        });
        
        await _processImage(photo);
      }
    } catch (e) {
      _setErrorState('Failed to capture photo: $e');
    }
  }

  /// Select an image from the gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1200,
        maxWidth: 1200,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _recognitionResults = null;
          _statusMessage = '';
        });
        
        await _processImage(image);
      }
    } catch (e) {
      _setErrorState('Failed to pick image: $e');
    }
  }

  /// Process the selected image for product recognition
  Future<void> _processImage(XFile imageFile) async {
    // Check if API key is available
    if (AppConstants.googleVisionApiKey.isEmpty) {
      await _checkApiKey();
      // If still empty after dialog, abort
      if (AppConstants.googleVisionApiKey.isEmpty) {
        _setErrorState('API key required for product recognition');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Analyzing image...';
    });

    try {
      final results = await _visionApiService.processProductImage(imageFile);
      
      setState(() {
        _isLoading = false;
        _recognitionResults = results;
        
        if (results['productName'] != null || results['brandName'] != null) {
          _statusMessage = 'Product detected! Review the details below.';
        } else {
          _statusMessage = 'No product identified. Try taking a clearer photo or manually enter product details.';
        }
      });
    } catch (e) {
      debugPrint('Image processing error: $e');
      if (e is NetworkException) {
        _setErrorState('Network error. Check your connection and try again.');
      } else if (e is VisionApiException) {
        _setErrorState('Unable to analyze image. Try taking a clearer photo.');
      } else {
        _setErrorState('Failed to process image. Please try again.');
      }
      
      // Fallback to manual input option
      _showManualInputDialog();
    }
  }

  /// Set error state with the provided message
  void _setErrorState(String message) {
    setState(() {
      _isLoading = false;
      _statusMessage = message;
    });
  }

  /// Create a product from the recognition results
  Future<void> _createProduct() async {
    if (_recognitionResults == null) return;
    
    final productName = _recognitionResults!['productName'] as String?;
    final brandName = _recognitionResults!['brandName'] as String?;
    
    if (productName == null && brandName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot create product: No name or brand detected')),
      );
      return;
    }
    
    // Generate a temporary barcode (in a real app, you'd verify this doesn't conflict)
    final tempBarcode = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Create minimal product
    final product = Product(
      barcode: tempBarcode,
      name: productName ?? 'Unknown Product',
      brand: brandName,
      ingredients: [], // Empty initially, will be filled in next screen
    );
    
    // Navigate to result screen for further editing
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductResultScreen(
          product: product,
          imageFile: _selectedImage,
          isNewScan: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Recognition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview section
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                alignment: Alignment.center,
                child: _isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(_statusMessage),
                        ],
                      )
                    : _selectedImage != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (_statusMessage.isNotEmpty)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      _statusMessage,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_enhance,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Take a photo or select an image to identify the product',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
              ),
            ),

            // Recognition results section
            if (_recognitionResults != null && !_isLoading) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recognition Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Product Name
                      if (_recognitionResults!['productName'] != null) ...[
                        const Text(
                          'Product Name:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _recognitionResults!['productName'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      // Brand Name
                      if (_recognitionResults!['brandName'] != null) ...[
                        const Text(
                          'Brand:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _recognitionResults!['brandName'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      // Potential Ingredients
                      if ((_recognitionResults!['potentialIngredients'] as List).isNotEmpty) ...[
                        const Text(
                          'Potential Ingredients:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          height: 80,
                          child: ListView(
                            children: [
                              for (final ingredient in _recognitionResults!['potentialIngredients'] as List)
                                Text(
                                  '• $ingredient',
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Create Product Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _createProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Create Product'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Camera and gallery buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}