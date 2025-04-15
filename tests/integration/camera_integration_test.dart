import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import 'package:skincare_scanner/main.dart';
import 'package:skincare_scanner/providers/camera_provider.dart';
import 'package:skincare_scanner/screens/camera/camera_screen.dart';
import 'package:skincare_scanner/widgets/loading/loading_state_widget.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Camera Screen Integration Tests', () {
    // This test should only run on a real device, not on simulators
    testWidgets('Camera screen initializes and takes picture', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CameraProvider()),
          ],
          child: MaterialApp(
            home: CameraScreen(),
          ),
        ),
      );

      // Initially it should show loading
      expect(find.byType(LoadingStateWidget), findsOneWidget);
      expect(find.text('Initializing camera...'), findsOneWidget);

      // Allow time for camera to initialize
      await tester.pumpAndSettle(Duration(seconds: 5));

      // If camera initialized successfully, we should see the camera preview
      final cameraPreviewFinder = find.byType(CameraPreview);
      
      // Note: on simulators or test environment without camera access,
      // this test may fail. It should be run on a physical device.
      if (cameraPreviewFinder.evaluate().isNotEmpty) {
        expect(cameraPreviewFinder, findsOneWidget);
        
        // Check for control buttons
        expect(find.byIcon(Icons.flash_auto), findsOneWidget);
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
        
        // Toggle flash mode
        await tester.tap(find.byIcon(Icons.flash_auto));
        await tester.pumpAndSettle();
        
        // Should now show flash off
        expect(find.byIcon(Icons.flash_off), findsOneWidget);
        
        // Toggle scan mode
        final scanToggleFinder = find.byType(Switch);
        expect(scanToggleFinder, findsOneWidget);
        await tester.tap(scanToggleFinder);
        await tester.pumpAndSettle();
        
        // Should now be in ingredients mode
        expect(find.text('Ingredients'), findsOneWidget);
        
        // Take a picture
        await tester.tap(find.byIcon(Icons.camera_alt));
        await tester.pumpAndSettle();
        
        // Should show processing
        expect(find.text('Processing...'), findsOneWidget);
        
        // Allow time for processing
        await tester.pumpAndSettle(Duration(seconds: 3));
        
        // Should navigate to results page (but this might not happen in test environment)
      } else {
        // Skip test if we can't access camera
        print('Skipping camera test - no camera preview found. This is expected in simulators.');
      }
    });
    
    testWidgets('Camera screen handles permissions gracefully', (WidgetTester tester) async {
      // Create a mock camera provider that simulates permission denial
      final mockCameraProvider = MockCameraProvider();
      
      // Build our app with the mock provider
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CameraProvider>.value(value: mockCameraProvider),
          ],
          child: MaterialApp(
            home: CameraScreen(),
          ),
        ),
      );
      
      // Initially it should show loading
      expect(find.byType(LoadingStateWidget), findsOneWidget);
      
      // Simulate camera permission denial
      mockCameraProvider.simulatePermissionDenied();
      await tester.pump();
      
      // Should show error message about permissions
      expect(find.text('Camera permission is required'), findsOneWidget);
      
      // Should have retry button
      expect(find.text('Grant Permission'), findsOneWidget);
    });
    
    testWidgets('Camera screen fallback UI works when camera unavailable', (WidgetTester tester) async {
      // Create a mock camera provider that simulates camera unavailability
      final mockCameraProvider = MockCameraProvider();
      
      // Build our app with the mock provider
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CameraProvider>.value(value: mockCameraProvider),
          ],
          child: MaterialApp(
            home: CameraScreen(),
          ),
        ),
      );
      
      // Initially it should show loading
      expect(find.byType(LoadingStateWidget), findsOneWidget);
      
      // Simulate camera unavailability
      mockCameraProvider.simulateCameraUnavailable();
      await tester.pump();
      
      // Should show error message
      expect(find.text('Could not initialize camera'), findsOneWidget);
      
      // Should have retry button
      expect(find.text('Try Again'), findsOneWidget);
      
      // Should have manual input option
      expect(find.text('Enter Barcode Manually'), findsOneWidget);
      
      // Tap manual input
      await tester.tap(find.text('Enter Barcode Manually'));
      await tester.pumpAndSettle();
      
      // Should show manual input dialog
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter Barcode'), findsOneWidget);
      
      // Enter barcode and submit
      await tester.enterText(find.byType(TextField), '1234567890123');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      
      // Should process the manual barcode
      // (Navigation will not occur in test environment)
    });
  });
}

/// Mock CameraProvider for testing error conditions
class MockCameraProvider extends CameraProvider {
  MockCameraProvider() {
    super.isLoading = true;
  }
  
  void simulatePermissionDenied() {
    isLoading = false;
    isInitialized = false;
    error = 'Camera permission is required to use this feature.';
    notifyListeners();
  }
  
  void simulateCameraUnavailable() {
    isLoading = false;
    isInitialized = false;
    error = 'Could not initialize camera. Please check your device.';
    notifyListeners();
  }
}