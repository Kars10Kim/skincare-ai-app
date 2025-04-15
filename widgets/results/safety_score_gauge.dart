import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../utils/accessibility.dart';

/// A widget for displaying a product safety score as a gauge/dial indicator
class SafetyScoreGauge extends StatefulWidget {
  /// The safety score (0-100)
  final int score;
  
  /// The size of the gauge
  final double size;
  
  /// Whether to animate the gauge
  final bool animate;
  
  /// Duration of the animation
  final Duration animationDuration;
  
  /// Whether to show the score label
  final bool showLabel;
  
  /// Background color of the gauge
  final Color? backgroundColor;
  
  /// Create a safety score gauge
  const SafetyScoreGauge({
    Key? key,
    required this.score,
    this.size = 150,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.showLabel = true,
    this.backgroundColor,
  }) : super(key: key);
  
  @override
  State<SafetyScoreGauge> createState() => _SafetyScoreGaugeState();
}

class _SafetyScoreGaugeState extends State<SafetyScoreGauge>
    with SingleTickerProviderStateMixin {
  /// Animation controller for the gauge
  late AnimationController _controller;
  
  /// Animation for the gauge value
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    
    // Create the animation
    _animation = Tween<double>(
      begin: 0,
      end: widget.score.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));
    
    // Start animation if enabled
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(SafetyScoreGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update animation if score changed
    if (widget.score != oldWidget.score) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.score.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuart,
      ));
      
      if (widget.animate) {
        _controller.forward(from: 0);
      } else {
        _controller.value = 1.0;
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final accessibilitySettings = context.accessibilitySettings;
    
    // Use a simplified gauge for reduced motion or screen readers
    if (accessibilitySettings.reducedMotion || accessibilitySettings.screenReaderActive) {
      return _buildSimplifiedScore(context);
    }
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ?? Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  // Gauge painter
                  CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _GaugePainter(
                      score: _animation.value.toInt(),
                      size: widget.size,
                      highContrastMode: accessibilitySettings.highContrast,
                    ),
                  ),
                  
                  // Score text
                  Text(
                    '${_animation.value.toInt()}',
                    style: TextStyle(
                      fontSize: widget.size * 0.2,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(_animation.value.toInt()),
                    ),
                  ),
                ],
              ),
            ),
            
            // Score label
            if (widget.showLabel) ...[
              const SizedBox(height: 8),
              Text(
                'Safety Score',
                style: TextStyle(
                  fontSize: widget.size * 0.09,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getScoreLabel(_animation.value.toInt()),
                style: TextStyle(
                  fontSize: widget.size * 0.08,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(_animation.value.toInt()),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
  
  /// Build a simplified score display for accessibility
  Widget _buildSimplifiedScore(BuildContext context) {
    final scoreColor = _getScoreColor(widget.score);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: widget.size * 0.8,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: scoreColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(widget.size * 0.1),
            border: Border.all(color: scoreColor, width: 2),
          ),
          child: Column(
            children: [
              Text(
                'Safety Score',
                style: TextStyle(
                  fontSize: widget.size * 0.09,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.score}',
                    style: TextStyle(
                      fontSize: widget.size * 0.25,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    '/100',
                    style: TextStyle(
                      fontSize: widget.size * 0.12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getScoreLabel(widget.score),
                style: TextStyle(
                  fontSize: widget.size * 0.08,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Get color for score value
  Color _getScoreColor(int score) {
    if (score >= 80) {
      return Colors.green.shade700;
    } else if (score >= 60) {
      return Colors.orange.shade700;
    } else {
      return Colors.red.shade700;
    }
  }
  
  /// Get descriptive label for score
  String _getScoreLabel(int score) {
    if (score >= 90) {
      return 'Excellent';
    } else if (score >= 80) {
      return 'Very Good';
    } else if (score >= 70) {
      return 'Good';
    } else if (score >= 60) {
      return 'Fair';
    } else if (score >= 40) {
      return 'Poor';
    } else {
      return 'Very Poor';
    }
  }
}

/// Custom painter for the gauge
class _GaugePainter extends CustomPainter {
  /// The safety score (0-100)
  final int score;
  
  /// Size of the gauge
  final double size;
  
  /// Whether to use high contrast colors
  final bool highContrastMode;
  
  /// Create a gauge painter
  _GaugePainter({
    required this.score,
    required this.size,
    this.highContrastMode = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Constants
    const double startAngle = 150 * (math.pi / 180); // 150 degrees in radians
    const double endAngle = 30 * (math.pi / 180);    // 30 degrees in radians
    const double sweepAngle = 2 * math.pi - (startAngle - endAngle);
    
    // Colors
    final List<Color> gradientColors = highContrastMode 
        ? [
            Colors.red.shade900,
            Colors.orange.shade900,
            Colors.green.shade900,
          ]
        : [
            Colors.red.shade400,
            Colors.orange.shade400,
            Colors.green.shade400,
          ];
    
    // Calculate current sweep based on score
    final currentSweep = (score / 100) * sweepAngle;
    
    // Center and radius
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4; // 80% of the width
    
    // Draw the background arc (gray)
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04 // 8% of the width
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );
    
    // Create the gradient for the score arc
    final scoreGradient = SweepGradient(
      colors: gradientColors,
      stops: const [0.0, 0.5, 1.0],
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      transform: GradientRotation(startAngle),
    );
    
    // Draw the score arc
    final scorePaint = Paint()
      ..shader = scoreGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06 // 12% of the width
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      currentSweep,
      false,
      scorePaint,
    );
    
    // Draw tick marks
    _drawTickMarks(canvas, center, radius, size.width);
    
    // Draw the needle
    _drawNeedle(canvas, center, radius, score, size.width);
  }
  
  /// Draw tick marks around the gauge
  void _drawTickMarks(Canvas canvas, Offset center, double radius, double width) {
    const int majorTicks = 5; // Number of major ticks
    const int minorTicksPerMajor = 4; // Number of minor ticks between major ticks
    const double startAngle = 150 * (math.pi / 180);
    const double endAngle = 30 * (math.pi / 180);
    final double sweepAngle = 2 * math.pi - (startAngle - endAngle);
    
    // Major ticks (with numbers)
    for (int i = 0; i <= majorTicks; i++) {
      final tickAngle = startAngle + (i / majorTicks) * sweepAngle;
      final tickValue = (i * (100 / majorTicks)).round();
      
      // Draw tick mark
      final outerPoint = Offset(
        center.dx + (radius + width * 0.05) * math.cos(tickAngle),
        center.dy + (radius + width * 0.05) * math.sin(tickAngle),
      );
      final innerPoint = Offset(
        center.dx + (radius - width * 0.05) * math.cos(tickAngle),
        center.dy + (radius - width * 0.05) * math.sin(tickAngle),
      );
      
      canvas.drawLine(
        innerPoint,
        outerPoint,
        Paint()
          ..color = Colors.grey.shade700
          ..strokeWidth = width * 0.01
          ..strokeCap = StrokeCap.round,
      );
      
      // Draw tick value text
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$tickValue',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: width * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      // Position text outside the tick mark
      final textPoint = Offset(
        center.dx + (radius + width * 0.12) * math.cos(tickAngle) - textPainter.width / 2,
        center.dy + (radius + width * 0.12) * math.sin(tickAngle) - textPainter.height / 2,
      );
      
      textPainter.paint(canvas, textPoint);
    }
    
    // Minor ticks
    final totalMinorTicks = majorTicks * minorTicksPerMajor;
    for (int i = 0; i < totalMinorTicks; i++) {
      // Skip positions where major ticks are located
      if (i % minorTicksPerMajor == 0) continue;
      
      final tickAngle = startAngle + (i / totalMinorTicks) * sweepAngle;
      
      // Draw tick mark
      final outerPoint = Offset(
        center.dx + radius * math.cos(tickAngle),
        center.dy + radius * math.sin(tickAngle),
      );
      final innerPoint = Offset(
        center.dx + (radius - width * 0.03) * math.cos(tickAngle),
        center.dy + (radius - width * 0.03) * math.sin(tickAngle),
      );
      
      canvas.drawLine(
        innerPoint,
        outerPoint,
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = width * 0.005
          ..strokeCap = StrokeCap.round,
      );
    }
  }
  
  /// Draw the gauge needle
  void _drawNeedle(Canvas canvas, Offset center, double radius, int score, double width) {
    // Calculate angle based on score
    const double startAngle = 150 * (math.pi / 180);
    const double endAngle = 30 * (math.pi / 180);
    const double sweepAngle = 2 * math.pi - (startAngle - endAngle);
    
    final needleAngle = startAngle + (score / 100) * sweepAngle;
    final needleLength = radius * 0.8;
    
    // Calculate needle points
    final needleTip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );
    
    // Draw the needle
    final needlePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = width * 0.02
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(center, needleTip, needlePaint);
    
    // Draw the center circle
    final centerPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(center, width * 0.03, centerPaint);
  }
  
  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.score != score ||
           oldDelegate.size != size ||
           oldDelegate.highContrastMode != highContrastMode;
  }
}