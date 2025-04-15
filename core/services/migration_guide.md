# Service Locator Migration Guide

This guide provides instructions for migrating from direct service instantiation to using the optimized service locator.

## Overview

The new service locator pattern provides several benefits:

- **Lazy Loading**: Services are only initialized when they're first used
- **Memory Optimization**: Services can be cleaned up when not in use to reduce memory footprint
- **Singleton Management**: Ensures only one instance of each service exists in the app
- **Thread Safety**: Prevents race conditions when services are initialized
- **Lifecycle Awareness**: Services are properly disposed when the app is backgrounded or memory pressure occurs

## Migration Steps

### 1. Update Imports

Replace imports of individual service files with the service locator:

```dart
// Old imports
import 'package:app/services/connectivity_service.dart';
import 'package:app/services/analytics_service.dart';

// New import
import 'package:app/core/services/service_locator.dart';
```

### 2. Update Service Instantiation

Replace direct service instantiation with service locator usage:

```dart
// Old (eager loading, creates new instance)
final connectivityService = ConnectivityService();
await connectivityService.initialize();

// New (lazy loading, reuses singleton)
final connectivityService = await ServiceLocator.instance.get<ConnectivityService>();
// No need to call initialize, it's done automatically
```

### 3. Update Widget Usage

Update widgets that use services:

```dart
// Old
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _analyticsService = AnalyticsService();
  
  @override
  void initState() {
    super.initState();
    _analyticsService.initialize();
  }
  
  // Widget implementation...
}

// New
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late AnalyticsService _analyticsService;
  
  @override
  void initState() {
    super.initState();
    _initServices();
  }
  
  Future<void> _initServices() async {
    _analyticsService = await ServiceLocator.instance.get<AnalyticsService>();
  }
  
  // Widget implementation...
}
```

### 4. Update BLoC/Cubit Classes

Update BLoC or Cubit classes that depend on services:

```dart
// Old
class MyCubit extends Cubit<MyState> {
  final ConnectivityService _connectivityService = ConnectivityService();
  
  MyCubit() : super(MyInitialState()) {
    _connectivityService.initialize();
  }
  
  // Cubit implementation...
}

// New
class MyCubit extends Cubit<MyState> {
  late ConnectivityService _connectivityService;
  
  MyCubit() : super(MyInitialState()) {
    _initServices();
  }
  
  Future<void> _initServices() async {
    _connectivityService = await ServiceLocator.instance.get<ConnectivityService>();
  }
  
  // Cubit implementation...
}
```

## Service Lifecycle

The optimized services follow a defined lifecycle:

1. **Creation**: Service instance is created when first requested
2. **Initialization**: Service is initialized automatically on first access
3. **Active Use**: Service is used by the application
4. **Memory Pressure**: If memory becomes constrained, non-critical services are disposed
5. **Reinitialization**: If a disposed service is needed again, it will be reinitialized

## Testing with Service Locator

When writing tests, you can replace services with mocks:

```dart
// In your test setup
void setUp() {
  // Reset service locator to clear any registered services
  await ServiceLocator.instance.reset();
  
  // Register mock services
  when(() => mockConnectivityService.checkConnectivity())
      .thenAnswer((_) async => true);
  
  // Register the mock in the service locator
  ServiceLocator.instance.registerMockForTesting<ConnectivityService>(
    mockConnectivityService,
  );
}
```

## Performance Monitoring

You can monitor service performance in development:

```dart
// Get service initialization statistics
final stats = await ServiceLocator.instance.getPerformanceStats();
debugPrint('Services stats: $stats');
```

## Important Notes

1. Services should no longer be directly instantiated with `Service()` constructor
2. Always use `await ServiceLocator.instance.get<Service>()` to get a service
3. Services are automatically initialized, so don't call `initialize()` manually
4. The app lifecycle observer will automatically manage service disposal when the app is backgrounded
5. Service locator provides better dependency management and testing capabilities

## Example Migration

### Before

```dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _connectivityService = ConnectivityService();
  final _analyticsService = AnalyticsService();
  
  @override
  void initState() {
    super.initState();
    _connectivityService.initialize();
    _analyticsService.initialize();
    _analyticsService.logScreenView(screenName: 'Home');
  }
  
  @override
  Widget build(BuildContext context) {
    // Widget implementation...
  }
}
```

### After

```dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConnectivityService _connectivityService;
  late AnalyticsService _analyticsService;
  bool _servicesInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initServices();
  }
  
  Future<void> _initServices() async {
    _connectivityService = await ServiceLocator.instance.get<ConnectivityService>();
    _analyticsService = await ServiceLocator.instance.get<AnalyticsService>();
    
    if (mounted) {
      await _analyticsService.logScreenView(screenName: 'Home');
      setState(() {
        _servicesInitialized = true;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_servicesInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Widget implementation...
  }
}
```