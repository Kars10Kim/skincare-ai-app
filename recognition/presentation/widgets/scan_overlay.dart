import 'package:flutter/material.dart';

/// Overlay for scan screen
class ScanOverlay extends StatelessWidget {
  /// Tab controller
  final TabController tabController;
  
  /// Is loading
  final bool isLoading;
  
  /// Has result
  final bool hasResult;
  
  /// On tab changed
  final Function(int) onTabChanged;
  
  /// On close
  final VoidCallback onClose;
  
  /// Create scan overlay
  const ScanOverlay({
    Key? key,
    required this.tabController,
    required this.isLoading,
    required this.hasResult,
    required this.onTabChanged,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top row with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  
                  // Loading indicator or spacer
                  if (isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Processing...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
              
              // Tab bar
              if (!hasResult) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTabButton(
                        context,
                        icon: Icons.qr_code_scanner,
                        label: 'Barcode',
                        isSelected: tabController.index == 0,
                        onTap: () => onTabChanged(0),
                      ),
                      _buildTabButton(
                        context,
                        icon: Icons.camera_alt,
                        label: 'Image',
                        isSelected: tabController.index == 1,
                        onTap: () => onTabChanged(1),
                      ),
                      _buildTabButton(
                        context,
                        icon: Icons.text_fields,
                        label: 'Text',
                        isSelected: tabController.index == 2,
                        onTap: () => onTabChanged(2),
                      ),
                    ],
                  ),
                ),
                
                // Instructions
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getInstructionText(tabController.index),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build tab button
  Widget _buildTabButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Get instruction text
  String _getInstructionText(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'Point camera at a product barcode';
      case 1:
        return 'Scan or pick an image of product ingredients';
      case 2:
        return 'Enter ingredients text manually';
      default:
        return '';
    }
  }
}