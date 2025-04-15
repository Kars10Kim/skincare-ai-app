import 'package:flutter/material.dart';

enum ScanMode { barcode, label }

class ScanOverlay extends StatefulWidget {
  final ScanMode mode;
  
  const ScanOverlay({
    Key? key, 
    this.mode = ScanMode.barcode,
  }) : super(key: key);

  @override
  ScanOverlayState createState() => ScanOverlayState();
}

class ScanOverlayState extends State<ScanOverlay> {
  late ScanMode _currentMode;
  
  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
  }
  
  void updateScanMode(ScanMode newMode) {
    if (_currentMode != newMode) {
      setState(() {
        _currentMode = newMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _currentMode == ScanMode.barcode
          ? BarcodeScanOverlayPainter()
          : LabelScanOverlayPainter(),
    );
  }
}

class BarcodeScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2);
    
    // Calculate a more mobile-friendly scan area
    // Square scan region adjusted based on device aspect ratio
    final aspectRatio = height / width;
    final scanSize = aspectRatio > 2
        ? width * 0.75 // For taller phones
        : width * 0.72; // For standard phones
        
    final scanRect = Rect.fromCenter(
      center: center,
      width: scanSize,
      height: scanSize,
    );
    
    // Background overlay with gradient
    final backgroundPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withOpacity(0.45),
          Colors.black.withOpacity(0.6),
        ],
        center: Alignment.center,
        radius: 1.5,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;
    
    // Draw full canvas background
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), backgroundPaint);
    
    // Cutout the scan region
    canvas.drawRect(
      scanRect,
      Paint()..blendMode = BlendMode.clear,
    );
    
    // Draw outer glow effect for better visibility
    final glowPaint = Paint()
      ..color = Colors.teal.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
    canvas.drawRect(
      scanRect.inflate(2), // Slightly larger for glow effect
      glowPaint,
    );
    
    // Draw corner markers with improved visibility
    final cornerPaint = Paint()
      ..color = Colors.teal.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    final cornerLength = scanSize * 0.12; // Longer for better visibility
    
    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.top + cornerLength)
        ..lineTo(scanRect.left, scanRect.top)
        ..lineTo(scanRect.left + cornerLength, scanRect.top),
      cornerPaint,
    );
    
    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - cornerLength, scanRect.top)
        ..lineTo(scanRect.right, scanRect.top)
        ..lineTo(scanRect.right, scanRect.top + cornerLength),
      cornerPaint,
    );
    
    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.bottom - cornerLength)
        ..lineTo(scanRect.left, scanRect.bottom)
        ..lineTo(scanRect.left + cornerLength, scanRect.bottom),
      cornerPaint,
    );
    
    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - cornerLength, scanRect.bottom)
        ..lineTo(scanRect.right, scanRect.bottom)
        ..lineTo(scanRect.right, scanRect.bottom - cornerLength),
      cornerPaint,
    );
    
    // Draw animated scan line with enhanced visibility
    final scanLinePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.teal.shade300.withOpacity(0.6),
          Colors.teal.shade400,
          Colors.teal.shade300.withOpacity(0.6),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTRB(
        scanRect.left, 0, scanRect.right, 0
      ))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    
    final scanLineY = scanRect.top + (scanRect.height * 0.5);
    canvas.drawLine(
      Offset(scanRect.left + 4, scanLineY),
      Offset(scanRect.right - 4, scanLineY),
      scanLinePaint,
    );
    
    // Draw crosshair in center for better alignment guidance
    final crosshairPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    final crosshairSize = scanSize * 0.05;
    
    // Horizontal crosshair line
    canvas.drawLine(
      Offset(center.dx - crosshairSize, center.dy),
      Offset(center.dx + crosshairSize, center.dy),
      crosshairPaint,
    );
    
    // Vertical crosshair line
    canvas.drawLine(
      Offset(center.dx, center.dy - crosshairSize),
      Offset(center.dx, center.dy + crosshairSize),
      crosshairPaint,
    );
    
    // Scan instruction text with better visibility
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Align barcode within frame',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              blurRadius: 8,
              color: Colors.black,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout(maxWidth: width * 0.9);
    
    // Position text with safe area consideration
    final bottomSafeArea = height - scanRect.bottom;
    final textY = bottomSafeArea < 100 
        ? scanRect.bottom + (bottomSafeArea * 0.5) // For phones with limited bottom space
        : scanRect.bottom + 40;
        
    textPainter.paint(
      canvas,
      Offset((width - textPainter.width) / 2, textY),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class LabelScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2);
    
    // Adjust for mobile screens: ensure the scan area is large enough to 
    // capture ingredient labels but not too large for small screens
    final scanWidth = width * 0.88; // Slightly wider
    
    // Calculate height based on screen aspect ratio to ensure it works on all devices
    final aspectRatio = height / width;
    final scanHeight = aspectRatio > 2 
        ? height * 0.55 // For taller phones
        : height * 0.65; // For standard phones
        
    final scanRect = Rect.fromCenter(
      center: center,
      width: scanWidth,
      height: scanHeight,
    );
    
    // Background overlay with gradient for better visibility
    final backgroundPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withOpacity(0.45),
          Colors.black.withOpacity(0.6),
        ],
        center: Alignment.center,
        radius: 1.5,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;
    
    // Draw full canvas background
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), backgroundPaint);
    
    // Cutout the scan region
    canvas.drawRect(
      scanRect,
      Paint()..blendMode = BlendMode.clear,
    );
    
    // Draw outer glow effect for better visibility on light backgrounds
    final glowPaint = Paint()
      ..color = Colors.teal.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
    canvas.drawRect(
      scanRect.inflate(2), // Slightly larger for glow effect
      glowPaint,
    );
    
    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRect(scanRect, borderPaint);
    
    // Draw corner markers with brighter color for better visibility
    final cornerPaint = Paint()
      ..color = Colors.teal.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    
    final cornerLength = scanWidth * 0.07; // Longer corner markers for clarity
    
    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.top + cornerLength)
        ..lineTo(scanRect.left, scanRect.top)
        ..lineTo(scanRect.left + cornerLength, scanRect.top),
      cornerPaint,
    );
    
    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - cornerLength, scanRect.top)
        ..lineTo(scanRect.right, scanRect.top)
        ..lineTo(scanRect.right, scanRect.top + cornerLength),
      cornerPaint,
    );
    
    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.bottom - cornerLength)
        ..lineTo(scanRect.left, scanRect.bottom)
        ..lineTo(scanRect.left + cornerLength, scanRect.bottom),
      cornerPaint,
    );
    
    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - cornerLength, scanRect.bottom)
        ..lineTo(scanRect.right, scanRect.bottom)
        ..lineTo(scanRect.right, scanRect.bottom - cornerLength),
      cornerPaint,
    );
    
    // Add guide lines inside the scan area
    final guideLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    // Horizontal thirds
    final third1 = scanRect.top + scanRect.height / 3;
    final third2 = scanRect.top + (scanRect.height * 2 / 3);
    
    canvas.drawLine(
      Offset(scanRect.left + 10, third1),
      Offset(scanRect.right - 10, third1),
      guideLinePaint,
    );
    
    canvas.drawLine(
      Offset(scanRect.left + 10, third2),
      Offset(scanRect.right - 10, third2),
      guideLinePaint,
    );
    
    // Scan instruction text with better visibility
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Align ingredients label within frame',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              blurRadius: 8,
              color: Colors.black,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout(maxWidth: width * 0.9);
    
    // Position text with safe area consideration
    final bottomSafeArea = height - scanRect.bottom;
    final textY = bottomSafeArea < 100 
        ? scanRect.bottom + (bottomSafeArea * 0.5) // For phones with limited bottom space
        : scanRect.bottom + 40;
        
    textPainter.paint(
      canvas,
      Offset((width - textPainter.width) / 2, textY),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}