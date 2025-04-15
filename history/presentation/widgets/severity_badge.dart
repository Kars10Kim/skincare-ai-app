import 'package:flutter/material.dart';

/// Severity badge for conflict indication
class SeverityBadge extends StatelessWidget {
  /// Severity level (0-5)
  final int severity;
  
  /// Whether to show the severity label
  final bool showLabel;
  
  /// Badge size
  final double size;
  
  /// Create severity badge
  const SeverityBadge({
    Key? key,
    required this.severity,
    this.showLabel = false,
    this.size = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If severity is 0, don't show anything
    if (severity == 0) {
      return showLabel
          ? _buildLabelOnly(context, 'Safe')
          : const SizedBox.shrink();
    }
    
    final color = _getSeverityColor();
    final label = _getSeverityLabel();
    
    if (!showLabel) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: severity > 0 
              ? Text(
                  severity.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size / 2,
                  ),
                )
              : null,
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size * 0.75,
            height: size * 0.75,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: severity > 0 
                  ? Text(
                      severity.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: size * 0.4,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Get the severity color
  Color _getSeverityColor() {
    switch (severity) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  /// Get the severity label
  String _getSeverityLabel() {
    switch (severity) {
      case 0:
        return 'Safe';
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Severe';
      default:
        return 'Unknown';
    }
  }
  
  /// Build label only
  Widget _buildLabelOnly(BuildContext context, String label) {
    final color = _getSeverityColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}