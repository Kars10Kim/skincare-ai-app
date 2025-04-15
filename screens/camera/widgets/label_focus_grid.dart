import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

/// Focus grid overlay for ingredient label scanning
class LabelFocusGrid extends StatelessWidget {
  /// Creates a label focus grid overlay
  const LabelFocusGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Semi-transparent background
        Container(
          color: Colors.black38,
        ),
        
        // Focus area with grid
        Center(
          child: Container(
            width: size.width * 0.85,
            height: size.height * 0.5,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return _buildGridCell();
              },
            ),
          ),
        ),
        
        // Guidance text
        Positioned(
          bottom: size.height * 0.15,
          left: 0,
          right: 0,
          child: const Center(
            child: Column(
              children: [
                Text(
                  'Align ingredients label within frame',
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
                SizedBox(height: 8),
                Text(
                  'Hold steady for best results',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// Builds a cell in the focus grid
  Widget _buildGridCell() {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
    );
  }
}