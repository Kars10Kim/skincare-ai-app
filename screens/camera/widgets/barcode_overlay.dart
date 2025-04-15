import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

/// Overlay widget for barcode scanning mode
class BarcodeOverlay extends StatelessWidget {
  /// Creates a barcode overlay widget
  const BarcodeOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const scanAreaSize = 250.0;
    
    return Stack(
      children: [
        // Semi-transparent background
        Container(
          color: Colors.black54,
        ),
        
        // Cutout for scan area
        Center(
          child: Container(
            width: scanAreaSize,
            height: scanAreaSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryColor,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCorner(position: CornerPosition.topLeft),
                    _buildCorner(position: CornerPosition.topRight),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCorner(position: CornerPosition.bottomLeft),
                    _buildCorner(position: CornerPosition.bottomRight),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Guidance text
        Positioned(
          bottom: size.height * 0.15,
          left: 0,
          right: 0,
          child: const Center(
            child: Text(
              'Position barcode within frame',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 3,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Builds a corner decoration
  Widget _buildCorner({required CornerPosition position}) {
    final isTop = position == CornerPosition.topLeft || 
                  position == CornerPosition.topRight;
    final isLeft = position == CornerPosition.topLeft || 
                   position == CornerPosition.bottomLeft;
    
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: AppColors.primaryColor, width: 5) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: AppColors.primaryColor, width: 5) : BorderSide.none,
          left: isLeft ? const BorderSide(color: AppColors.primaryColor, width: 5) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: AppColors.primaryColor, width: 5) : BorderSide.none,
        ),
      ),
    );
  }
}

/// Position of corner decoration
enum CornerPosition {
  /// Top-left corner
  topLeft,
  
  /// Top-right corner
  topRight,
  
  /// Bottom-left corner
  bottomLeft,
  
  /// Bottom-right corner
  bottomRight,
}