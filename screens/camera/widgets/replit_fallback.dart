import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../models/product_model.dart';
import 'package:provider/provider.dart';
import '../../../providers/camera_provider.dart';

/// Fallback for camera preview on web (Replit)
class CameraFallback extends StatelessWidget {
  /// Callback for capture button
  final VoidCallback onCapture;
  
  /// Creates a camera fallback widget
  const CameraFallback({
    Key? key,
    required this.onCapture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Camera placeholder
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryColor),
            ),
            child: Stack(
              children: [
                // Placeholder image
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Camera preview',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Not available in web preview',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Overlay based on current mode
                Consumer<CameraProvider>(
                  builder: (context, provider, child) {
                    return Opacity(
                      opacity: 0.3,
                      child: provider.mode == CameraMode.BARCODE
                          ? Center(
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primaryColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          : Center(
                              child: Container(
                                width: 220,
                                height: 180,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                  ),
                                  itemCount: 9,
                                  itemBuilder: (_, __) => Container(
                                    margin: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primaryColor.withOpacity(0.5),
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Simulation buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => _simulateBarcodeScan(context),
                icon: const Icon(Icons.qr_code),
                label: const Text('Simulate Barcode Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  minimumSize: const Size(240, 48),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _simulateTextRecognition(context),
                icon: const Icon(Icons.text_fields),
                label: const Text('Simulate Text Recognition'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  minimumSize: const Size(240, 48),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Simulate barcode scanning with sample data
  void _simulateBarcodeScan(BuildContext context) {
    final provider = Provider.of<CameraProvider>(context, listen: false);
    
    // Create a simulated product for testing
    final product = Product(
      barcode: '12345678910',
      name: 'Hydrating Facial Cleanser',
      ingredients: [
        'Water',
        'Glycerin',
        'Cetearyl Alcohol',
        'Niacinamide',
        'Ceramide NP',
        'Ceramide AP',
        'Ceramide EOP',
        'Hyaluronic Acid',
        'Phenoxyethanol',
      ],
    );
    
    // Update provider with the simulated product
    // This would normally be done by the processImage method
    provider.setSimulatedProduct(product);
    
    // Call the capture callback to continue the flow
    onCapture();
  }
  
  /// Simulate text recognition with sample data
  void _simulateTextRecognition(BuildContext context) {
    final provider = Provider.of<CameraProvider>(context, listen: false);
    
    // Create a simulated product for testing
    final product = Product(
      barcode: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Ingredients List',
      ingredients: [
        'Aqua',
        'Glycerin',
        'Butylene Glycol',
        'Sodium Hyaluronate',
        'Niacinamide',
        'Panthenol',
        'Allantoin',
        'Carbomer',
        'Ethylhexylglycerin',
        'Disodium EDTA',
      ],
    );
    
    // Update provider with the simulated product
    // This would normally be done by the processImage method
    provider.setSimulatedProduct(product);
    
    // Call the capture callback to continue the flow
    onCapture();
  }
}