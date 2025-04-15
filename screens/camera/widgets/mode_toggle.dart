import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';

/// Widget for toggling between camera modes
class ModeToggle extends StatelessWidget {
  /// Current camera mode
  final CameraMode currentMode;
  
  /// Callback for mode changes
  final Function(CameraMode) onChanged;
  
  /// Creates a mode toggle widget
  const ModeToggle({
    Key? key,
    required this.currentMode,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleButton(
                label: 'Barcode',
                icon: Icons.qr_code_scanner,
                isSelected: currentMode == CameraMode.BARCODE,
                onTap: () => onChanged(CameraMode.BARCODE),
              ),
              _buildToggleButton(
                label: 'Ingredients',
                icon: Icons.text_fields,
                isSelected: currentMode == CameraMode.TEXT,
                onTap: () => onChanged(CameraMode.TEXT),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Builds a single toggle button
  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}