import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_provider.dart';
import '../../utils/constants.dart';
import '../../utils/memory_management.dart';
import '../../services/error_handler.dart';
import '../../services/service_locator.dart';

/// Camera overlay that displays scanning animation and guides
class CameraOverlay extends StatefulWidget {
  /// Creates a camera overlay
  const CameraOverlay({Key? key}) : super(key: key);

  @override
  State<CameraOverlay> createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay> 
    with AutoDisposeMixin<CameraOverlay>, SingleTickerProviderStateMixin {
  /// Animation controller for the scanning line
  late final AnimationController _animationController;
  
  /// Animation for the scanning line's vertical position
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // Create the animation with a curve
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Add to the dispose bag to ensure proper disposal
    addDisposable(_animationController);
    
    // Start the animation and make it repeat
    _animationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    try {
      final provider = Provider.of<CameraProvider>(context);
      final scanMode = provider.scanMode;
      
      return Stack(
        children: [
          // Scanning frame overlay
          if (scanMode == ScanMode.barcode)
            _buildBarcodeOverlay(context)
          else
            _buildLabelOverlay(context),
          
          // Instructions text
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: Colors.black.withOpacity(0.4),
              child: Text(
                scanMode == ScanMode.barcode
                    ? 'Position the barcode within the frame'
                    : 'Position the ingredients label within the frame',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    } catch (e, stackTrace) {
      // Handle any errors that occur during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getIt<ErrorHandler>().handleError(
          'Camera overlay error: $e',
          stackTrace,
          context: context,
        );
      });
      
      // Return an empty container as a fallback
      return Container();
    }
  }
  
  /// Builds the barcode scanning overlay
  Widget _buildBarcodeOverlay(BuildContext context) {
    return Center(
      child: Container(
        width: 280,
        height: 170,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Corner indicators
            Positioned(
              top: 0,
              left: 0,
              child: _buildCornerIndicator(),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _buildCornerIndicator(rightAlign: true),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: _buildCornerIndicator(bottomAlign: true),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildCornerIndicator(rightAlign: true, bottomAlign: true),
            ),
            
            // Scanning line animation
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Positioned(
                  left: 10,
                  right: 10,
                  top: 10 + (_scanAnimation.value * (150 - 10)), // Animate from top to bottom
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.6),
                          blurRadius: 8.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Builds the label scanning overlay
  Widget _buildLabelOverlay(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 240,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.secondaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner indicators
            Positioned(
              top: 0,
              left: 0,
              child: _buildCornerIndicator(color: AppColors.secondaryColor),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _buildCornerIndicator(rightAlign: true, color: AppColors.secondaryColor),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: _buildCornerIndicator(bottomAlign: true, color: AppColors.secondaryColor),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildCornerIndicator(rightAlign: true, bottomAlign: true, color: AppColors.secondaryColor),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Builds a corner indicator for the scanning frame
  Widget _buildCornerIndicator({
    bool rightAlign = false,
    bool bottomAlign = false,
    Color color = AppColors.primaryColor,
  }) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: CornerPainter(
          rightAlign: rightAlign,
          bottomAlign: bottomAlign,
          color: color,
        ),
      ),
    );
  }
}

/// Custom painter to draw corner indicators
class CornerPainter extends CustomPainter {
  /// Whether to align to the right
  final bool rightAlign;
  
  /// Whether to align to the bottom
  final bool bottomAlign;
  
  /// Color of the corner indicator
  final Color color;
  
  /// Creates a corner painter
  CornerPainter({
    this.rightAlign = false,
    this.bottomAlign = false,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final path = Path();
    if (!rightAlign && !bottomAlign) {
      // Top-left corner
      path.moveTo(0, 10);
      path.lineTo(0, 0);
      path.lineTo(10, 0);
    } else if (rightAlign && !bottomAlign) {
      // Top-right corner
      path.moveTo(size.width - 10, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, 10);
    } else if (!rightAlign && bottomAlign) {
      // Bottom-left corner
      path.moveTo(0, size.height - 10);
      path.lineTo(0, size.height);
      path.lineTo(10, size.height);
    } else {
      // Bottom-right corner
      path.moveTo(size.width - 10, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, size.height - 10);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}