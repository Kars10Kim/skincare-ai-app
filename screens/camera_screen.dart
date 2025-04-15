
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:skincare_scanner/utils/analytics_service.dart';
import 'package:skincare_scanner/widgets/barcode_scanner.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  // Camera control states
  double _startDragY = 0;
  double _zoomLevel = 1.0;
  double _brightness = 0.5;
  bool _isStabilized = false;
  bool _isAutoFocus = true;
  bool _isMultiScanMode = false;
  List<String> _scannedBarcodes = [];
  
  // UI control states
  bool _showTips = true;
  bool _showControls = true;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AnalyticsService.logScreenView('CameraScreen', 'CameraScreen');
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  void _handleZoomUpdate(double value) {
    setState(() {
      _zoomLevel = value;
    });
  }

  void _handleBrightnessUpdate(double value) {
    setState(() {
      _brightness = value;
    });
  }

  void _toggleFocusMode() {
    setState(() {
      _isAutoFocus = !_isAutoFocus;
    });
  }

  void _toggleMultiScanMode() {
    setState(() {
      _isMultiScanMode = !_isMultiScanMode;
      if (!_isMultiScanMode) {
        _scannedBarcodes.clear();
      }
    });
  }

  void _onBarcodeDetected(String barcode) {
    if (_isMultiScanMode) {
      if (!_scannedBarcodes.contains(barcode)) {
        setState(() {
          _scannedBarcodes.add(barcode);
        });
      }
    } else {
      // Handle single scan mode
      Navigator.of(context).pushNamed('/product_details', arguments: barcode);
    }
  }

  Widget _buildZoomControl() {
    return Positioned(
      right: 16,
      top: 100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              '${_zoomLevel.toStringAsFixed(1)}x',
              style: const TextStyle(color: Colors.white),
            ),
            RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: _zoomLevel,
                  min: 1.0,
                  max: 5.0,
                  onChanged: _handleZoomUpdate,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrightnessControl() {
    return Positioned(
      left: 16,
      top: 100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            const Icon(Icons.brightness_6, color: Colors.white, size: 20),
            RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: _brightness,
                  onChanged: _handleBrightnessUpdate,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isAutoFocus ? Icons.center_focus_strong : Icons.center_focus_weak,
            label: _isAutoFocus ? 'Auto Focus' : 'Manual Focus',
            onPressed: _toggleFocusMode,
          ),
          _buildControlButton(
            icon: _isMultiScanMode ? Icons.filter_none : Icons.filter_1,
            label: _isMultiScanMode ? 'Multi Scan' : 'Single Scan',
            onPressed: _toggleMultiScanMode,
          ),
          if (_showTips)
            _buildControlButton(
              icon: Icons.help_outline,
              label: 'Hide Tips',
              onPressed: () => setState(() => _showTips = false),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        tooltip: label,
      ),
    );
  }

  Widget _buildStabilizationIndicator() {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isStabilized ? Colors.green.withOpacity(0.7) : Colors.orange.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _isStabilized ? 'Stable' : 'Stabilizing...',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildScanningTips() {
    if (!_showTips) return const SizedBox.shrink();
    
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.15,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Scanning Tips:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Hold the device steady\n'
              '• Ensure good lighting\n'
              '• Center the barcode in frame\n'
              '• Keep 6-12 inches distance',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiScanIndicator() {
    if (!_isMultiScanMode || _scannedBarcodes.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              '${_scannedBarcodes.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          SizedBox.expand(
            child: BarcodeScannerWidget(
              onBarcodeDetected: _onBarcodeDetected,
              zoomLevel: _zoomLevel,
              brightness: _brightness,
              isAutoFocus: _isAutoFocus,
              isMultiScanMode: _isMultiScanMode,
              onStabilizationChanged: (isStable) {
                setState(() => _isStabilized = isStable);
              },
            ),
          ),
          
          // UI Controls and Indicators
          _buildZoomControl(),
          _buildBrightnessControl(),
          _buildStabilizationIndicator(),
          _buildControls(),
          _buildScanningTips(),
          _buildMultiScanIndicator(),

          // Standard app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () => Navigator.of(context).pushNamed('/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isMultiScanMode ? FloatingActionButton.extended(
        onPressed: () {
          if (_scannedBarcodes.isNotEmpty) {
            Navigator.of(context).pushNamed(
              '/product_details',
              arguments: _scannedBarcodes,
            );
          }
        },
        label: const Text('View All'),
        icon: const Icon(Icons.check),
      ) : null,
    );
  }
}
