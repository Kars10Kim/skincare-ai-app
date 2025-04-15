# Service Optimization Framework Migration Guide

This document provides a guide for migrating existing services to the optimized service framework. This framework is designed to improve performance, optimize memory usage, and better manage the lifecycle of services in the Skincare Scanner application.

## Key Benefits

- **Memory Optimization**: Services are lazily loaded only when needed and can be unloaded when not in use
- **Lifecycle Management**: Consistent lifecycle hooks for initialization and cleanup
- **Thread Safety**: Mutex locks prevent race conditions during concurrent initialization
- **Background Optimization**: Services automatically respond to app background state to free resources
- **Simplified Dependencies**: Clear dependency resolution through ServiceLocator

## Step 1: Convert Your Service Class

To migrate an existing service, follow these steps:

1. Extend `LazyService` instead of just using a plain class
2. Implement the singleton pattern with private constructor
3. Override the `init()` and `dispose()` methods
4. Use lazy initialization for expensive dependencies

### Before:

```dart
class MyService {
  final dependency = ExpensiveDependency();
  
  void doSomething() {
    // Your code here
  }
  
  void dispose() {
    // Cleanup
  }
}
```

### After:

```dart
class MyService extends LazyService {
  // Singleton pattern
  factory MyService() => _instance;
  
  MyService._internal() {
    assert(!_isInstantiated, 'Use ServiceLocator.get<MyService>() instead');
    _isInstantiated = true;
  }
  
  static final MyService _instance = MyService._internal();
  static bool _isInstantiated = false;
  
  // Lazy initialization for expensive resources
  late final ExpensiveDependency _dependency;
  
  @override
  Future<void> init() async {
    if (isInitialized) return;
    
    await super.init();
    
    // Initialize dependencies here
    _dependency = ExpensiveDependency();
    
    debugPrint('MyService initialized');
  }
  
  Future<void> doSomething() async {
    // Make sure service is initialized
    if (!isInitialized) {
      await init();
    }
    
    // Your code here using _dependency
  }
  
  @override
  Future<void> dispose() async {
    if (!isInitialized) return;
    
    // Clean up resources
    
    await super.dispose();
  }
}
```

## Step 2: Register in Service Locator

Add your service to the ServiceLocator's `_createInstance` method:

```dart
T _createInstance() {
  switch (T) {
    case MyService:
      return MyService._internal() as T;
    // Other services...
    default:
      throw ServiceNotFoundException('Service $T not found in ServiceLocator');
  }
}
```

## Step 3: Update Import Path

Update the import in the service locator:

```dart
import 'individual_services/my_service.dart';
```

## Step 4: Update Service Usage

Update how the service is used throughout the app:

### Before:

```dart
final myService = MyService();
myService.doSomething();
```

### After:

```dart
final myService = await ServiceLocator.instance.get<MyService>();
await myService.doSomething();
```

## Service Lifecycle Phases

1. **Creation** - Service instance created via `_createInstance`
2. **Initialization** - `init()` called to set up resources
3. **Active use** - Service methods used throughout the app
4. **Memory pressure** - `handleMemoryPressure()` may release non-critical services
5. **Disposal** - `dispose()` called to clean up resources

## Best Practices

1. **Check Initialization** - Always check `isInitialized` and call `init()` if needed
2. **Lazy Load Dependencies** - Use `late final` for expensive resources
3. **Clean Disposal** - Release all resources in `dispose()`
4. **Memory Pressure Handling** - Implement `handleMemoryPressure()` for non-critical services
5. **Error Handling** - Use proper error handling in async methods

## Background Optimization

Services implementing `handleMemoryPressure()` will automatically respond when the app goes to the background:

```dart
@override
Future<void> handleMemoryPressure() async {
  // Release non-critical resources here
  _largeCache.clear();
}
```

## Real-World Example: Camera Service

```dart
class CameraService extends LazyService {
  factory CameraService() => _instance;
  
  CameraService._internal() {
    assert(!_isInstantiated, 'Use ServiceLocator.get<CameraService>() instead');
    _isInstantiated = true;
  }
  
  static final CameraService _instance = CameraService._internal();
  static bool _isInstantiated = false;
  
  late final CameraController _controller;
  
  @override
  Future<void> init() async {
    if (isInitialized) return;
    
    await super.init();
    
    // Don't initialize camera controller yet - we'll do it on demand
    debugPrint('CameraService initialized');
  }
  
  Future<void> setupCamera() async {
    // Make sure service is initialized
    if (!isInitialized) {
      await init();
    }
    
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }
    
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    
    await _controller.initialize();
  }
  
  @override
  Future<void> dispose() async {
    if (!isInitialized) return;
    
    await _controller.dispose();
    
    await super.dispose();
  }
}
```