import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/onboarding_model.dart';
import '../../providers/camera_provider.dart';
import '../../utils/constants.dart';
import '../../utils/memory_management.dart';
import '../../services/error_handler.dart';
import '../../services/service_locator.dart';

/// Widget to toggle between barcode and label scanning modes
class ScanModeSelector extends StatefulWidget {
  /// Creates a scan mode selector
  const ScanModeSelector({Key? key}) : super(key: key);

  @override
  State<ScanModeSelector> createState() => _ScanModeSelectorState();
}

class _ScanModeSelectorState extends State<ScanModeSelector> with AutoDisposeMixin<ScanModeSelector> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CameraProvider>(context);
    final scanMode = provider.scanMode;
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            context,
            'Barcode',
            Icons.qr_code_scanner,
            ScanMode.barcode,
            scanMode == ScanMode.barcode,
            onTap: () => _setMode(ScanMode.barcode),
          ),
          _buildModeButton(
            context,
            'Label',
            Icons.text_fields,
            ScanMode.label,
            scanMode == ScanMode.label,
            onTap: () => _setMode(ScanMode.label),
          ),
        ],
      ),
    );
  }
  
  /// Set scan mode with error handling
  void _setMode(ScanMode mode) {
    try {
      final provider = Provider.of<CameraProvider>(context, listen: false);
      provider.setScanMode(mode);
    } catch (e, stackTrace) {
      getIt<ErrorHandler>().handleError(
        'Failed to change scan mode: $e',
        stackTrace,
        context: context,
      );
    }
  }
  
  /// Builds a mode selection button
  Widget _buildModeButton(
    BuildContext context,
    String label,
    IconData icon,
    ScanMode mode,
    bool isSelected, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}