import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:skincare_scanner/features/camera/presentation/widgets/camera_preview.dart';
import 'package:skincare_scanner/features/camera/utils/camera_utils.dart';
import 'package:skincare_scanner/features/recognition/presentation/screens/product_recognition_screen.dart';
import 'package:skincare_scanner/providers/user_provider.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/bottom_sheet_content.dart';
import '../widgets/scan_history_list.dart';
import '../widgets/scan_option_button.dart';

/// Home screen with camera-first approach
class HomeScreen extends StatefulWidget {
  /// Create a home screen
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late HomeCubit _cubit;
  bool _hasCamera = false;
  
  @override
  void initState() {
    super.initState();
    _checkCamera();
    WidgetsBinding.instance.addObserver(this);
    
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<HomeCubit>();
    _cubit.loadScanHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.resumed) {
      _checkCamera();
    }
  }
  
  /// Check if a camera is available
  Future<void> _checkCamera() async {
    final hasCamera = await CameraUtils.hasCamera();
    if (mounted) {
      setState(() {
        _hasCamera = hasCamera;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        // Handle state changes like errors
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!.displayMessage),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => _cubit.loadScanHistory(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: _buildBody(context, state),
          extendBodyBehindAppBar: true,
          floatingActionButton: _buildScanFAB(context),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _buildBottomAppBar(context, state),
        );
      },
    );
  }
  
  /// Build the main body of the home screen
  Widget _buildBody(BuildContext context, HomeState state) {
    return Stack(
      children: [
        // Camera preview takes the full screen
        if (_hasCamera)
          ClipRect(
            child: SizedBox.expand(
              child: CameraPreview(
                onCapture: (image) => _handleImageCapture(context, image),
                fit: BoxFit.cover,
                enablePinchZoom: true,
                showControls: false,
              ),
            ),
          )
        else
          _buildNoCameraPlaceholder(),
          
        // Content overlay 
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              // Rest of the space is available for the bottom sheet to expand into
              Expanded(child: Container()),
            ],
          ),
        ),
        
        // Bottom sheet that can be dragged up to show scan history
        _buildDraggableSheet(context, state),
      ],
    );
  }
  
  /// Build a placeholder when no camera is available
  Widget _buildNoCameraPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            Text(
              'No camera available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please enable camera permissions or use a device with a camera',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the app bar
  Widget _buildAppBar(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Skincare Scanner',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                const Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: userProvider.isAuthenticated
                ? Text(
                    userProvider.user?.displayName?.substring(0, 1).toUpperCase() ?? '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: () => Navigator.of(context).pushNamed('/auth'),
                  ),
          ),
        ],
      ),
    );
  }
  
  /// Build the draggable bottom sheet
  Widget _buildDraggableSheet(BuildContext context, HomeState state) {
    final minChildSize = MediaQuery.of(context).size.height > 700 ? 0.1 : 0.15;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: minChildSize,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: BottomSheetContent(
                  state: state,
                  scrollController: scrollController,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Recent Scans',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 80),
                sliver: ScanHistoryList(
                  scanHistory: state.scanHistory,
                  isLoading: state.isLoading,
                  onItemTap: (scan) {
                    // Navigate to detailed view
                    Navigator.of(context).pushNamed(
                      '/product',
                      arguments: scan.barcode,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Build the floating action button for scanning
  Widget _buildScanFAB(BuildContext context) {
    return FloatingActionButton.large(
      elevation: 4,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      onPressed: () => _navigateToScanner(context),
      child: const Icon(Icons.qr_code_scanner_rounded, size: 32),
    );
  }
  
  /// Build the bottom app bar
  Widget _buildBottomAppBar(BuildContext context, HomeState state) {
    return BottomAppBar(
      notchMargin: 8,
      elevation: 8,
      shape: const CircularNotch(
        notchRadius: 36,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ScanOptionButton(
              icon: Icons.image_search_outlined,
              label: 'Image',
              onPressed: () => _navigateToImageScanner(context),
            ),
            ScanOptionButton(
              icon: Icons.text_fields_outlined,
              label: 'Text',
              onPressed: () => _navigateToTextScanner(context),
            ),
            // Space for FAB
            const SizedBox(width: 64),
            ScanOptionButton(
              icon: Icons.history_outlined,
              label: 'History',
              onPressed: () {
                // Expand bottom sheet to show history
                if (state.scanHistory.isNotEmpty) {
                  _cubit.expandBottomSheet();
                }
              },
              badgeCount: state.scanHistory.length,
            ),
            ScanOptionButton(
              icon: Icons.favorite_border_outlined,
              label: 'Favorites',
              onPressed: () => Navigator.of(context).pushNamed('/favorites'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Navigate to the scanner screen
  void _navigateToScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProductRecognitionScreen(
          initialTab: ScanType.barcode,
        ),
      ),
    );
  }
  
  /// Navigate to the image scanner screen
  void _navigateToImageScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProductRecognitionScreen(
          initialTab: ScanType.image,
        ),
      ),
    );
  }
  
  /// Navigate to the text scanner screen
  void _navigateToTextScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProductRecognitionScreen(
          initialTab: ScanType.text,
        ),
      ),
    );
  }
  
  /// Handle image capture from the camera
  void _handleImageCapture(BuildContext context, dynamic image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductRecognitionScreen(
          initialTab: ScanType.image,
          initialImage: image,
        ),
      ),
    );
  }
}

/// Custom notch shape for the bottom app bar
class CircularNotch extends NotchedShape {
  /// Notch radius
  final double notchRadius;
  
  /// Create a circular notch
  const CircularNotch({
    required this.notchRadius,
  });

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    final guestCenter = guest.center;
    
    // Create a circular path around the guest (FAB)
    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..lineTo(host.left, host.top)
      ..addOval(
        Rect.fromCircle(
          center: guestCenter,
          radius: notchRadius,
        ),
      );
  }
}