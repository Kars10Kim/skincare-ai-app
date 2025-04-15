import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:camera/camera.dart';

import 'package:skincare_scanner/providers/camera_provider.dart';

// Generate mocks
@GenerateMocks([CameraController, CameraDescription])
import 'camera_provider_test.mocks.dart';

void main() {
  group('CameraProvider Tests', () {
    late CameraProvider cameraProvider;
    late MockCameraController mockCameraController;
    
    setUp(() {
      // Create mock camera description
      final mockCamera = MockCameraDescription();
      when(mockCamera.name).thenReturn('mock_camera');
      when(mockCamera.lensDirection).thenReturn(CameraLensDirection.back);
      
      // Create mock camera controller
      mockCameraController = MockCameraController();
      when(mockCameraController.initialize()).thenAnswer((_) async {});
      when(mockCameraController.dispose()).thenAnswer((_) async {});
      when(mockCameraController.startImageStream(any)).thenAnswer((_) async {});
      when(mockCameraController.stopImageStream()).thenAnswer((_) async {});
      when(mockCameraController.value).thenReturn(CameraValue(
        isInitialized: true,
        previewSize: Size(1920, 1080),
        isRecordingVideo: false,
        isTakingPicture: false,
        isStreamingImages: false,
        flashMode: FlashMode.off,
        exposureMode: ExposureMode.auto,
        focusMode: FocusMode.auto,
        deviceOrientation: DeviceOrientation.portraitUp,
      ));
      
      // Initialize the CameraProvider with mock controller
      cameraProvider = CameraProvider();
      cameraProvider.mockCameraControllerForTesting = mockCameraController;
    });
    
    test('Initial state is correct', () {
      expect(cameraProvider.isInitialized, false);
      expect(cameraProvider.isLoading, false);
      expect(cameraProvider.error, isNull);
      expect(cameraProvider.flashMode, FlashMode.auto);
      expect(cameraProvider.scanMode, ScanMode.barcode);
    });
    
    test('Initialize camera successfully', () async {
      // Arrange: Setup mock response for available cameras
      CameraProvider.availableCamerasForTesting = [MockCameraDescription()];
      
      // Act: Initialize camera
      await cameraProvider.initializeCamera();
      
      // Assert: Check that camera is initialized
      expect(cameraProvider.isInitialized, true);
      expect(cameraProvider.isLoading, false);
      expect(cameraProvider.error, isNull);
      verify(mockCameraController.initialize()).called(1);
    });
    
    test('Initialize camera fails without cameras', () async {
      // Arrange: Setup empty list of available cameras
      CameraProvider.availableCamerasForTesting = [];
      
      // Act: Initialize camera
      await cameraProvider.initializeCamera();
      
      // Assert: Check that camera initialization failed
      expect(cameraProvider.isInitialized, false);
      expect(cameraProvider.isLoading, false);
      expect(cameraProvider.error, isNotNull);
      expect(cameraProvider.error, contains('No cameras available on this device'));
      
      // Verify controller was properly disposed
      verify(mockCameraController.dispose()).called(1);
    });
    
    test('Camera availability check works', () async {
      final cameraService = CameraService();
      
      // Test with available cameras
      CameraProvider.availableCamerasForTesting = [MockCameraDescription()];
      expect(await cameraService.checkCameraAvailability(), true);
      
      // Test without cameras
      CameraProvider.availableCamerasForTesting = [];
      expect(await cameraService.checkCameraAvailability(), false);
    });
    
    test('Toggle flash mode works correctly', () {
      // Act: Toggle flash mode
      cameraProvider.toggleFlashMode();
      
      // Assert: Check that flash mode changed
      expect(cameraProvider.flashMode, FlashMode.off);
      
      // Act: Toggle again
      cameraProvider.toggleFlashMode();
      
      // Assert: Check that flash mode changed to torch
      expect(cameraProvider.flashMode, FlashMode.torch);
      
      // Act: Toggle again
      cameraProvider.toggleFlashMode();
      
      // Assert: Check that flash mode changed to auto
      expect(cameraProvider.flashMode, FlashMode.auto);
    });
    
    test('Toggle scan mode works correctly', () {
      // Act: Toggle scan mode
      cameraProvider.toggleScanMode();
      
      // Assert: Check that scan mode changed
      expect(cameraProvider.scanMode, ScanMode.ingredients);
      
      // Act: Toggle again
      cameraProvider.toggleScanMode();
      
      // Assert: Check that scan mode changed back to barcode
      expect(cameraProvider.scanMode, ScanMode.barcode);
    });

    test('Take picture works correctly', () async {
      // Arrange: Mock a successful picture capture
      final mockXFile = MockXFile();
      when(mockCameraController.takePicture()).thenAnswer((_) async => mockXFile);
      when(mockXFile.path).thenReturn('/mock/path/image.jpg');
      
      // Act: Initialize camera and take picture
      CameraProvider.availableCamerasForTesting = [MockCameraDescription()];
      await cameraProvider.initializeCamera();
      final result = await cameraProvider.takePicture();
      
      // Assert: Check that picture was taken
      expect(result, isNotNull);
      expect(result?.path, '/mock/path/image.jpg');
      verify(mockCameraController.takePicture()).called(1);
    });
    
    test('Take picture returns null when controller not initialized', () async {
      // Arrange: Ensure controller is not initialized
      cameraProvider = CameraProvider();
      
      // Act: Take picture
      final result = await cameraProvider.takePicture();
      
      // Assert: Check that result is null
      expect(result, isNull);
    });
    
    test('Dispose releases resources correctly', () async {
      // Arrange: Initialize camera
      CameraProvider.availableCamerasForTesting = [MockCameraDescription()];
      await cameraProvider.initializeCamera();
      
      // Act: Dispose
      await cameraProvider.dispose();
      
      // Assert: Check that controller is disposed
      expect(cameraProvider.isInitialized, false);
      verify(mockCameraController.dispose()).called(1);
    });
  });
}

// Mock XFile for testing
class MockXFile extends Mock implements XFile {
  @override
  String get path => '/mock/path/image.jpg';
}