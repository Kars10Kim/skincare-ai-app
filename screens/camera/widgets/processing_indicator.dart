import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

/// Loading indicator for camera processing
class ProcessingIndicator extends StatelessWidget {
  /// Creates a processing indicator overlay
  const ProcessingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                strokeWidth: 5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Processing image...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
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
            const SizedBox(height: 8),
            const Text(
              'Please wait',
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
    );
  }
}