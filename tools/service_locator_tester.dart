import 'package:flutter/foundation.dart';
import '../core/services/service_locator.dart';
import '../core/services/lifecycle/lazy_service.dart';

import '../core/services/individual_services/connectivity_service.dart';
import '../core/services/individual_services/analytics_service.dart';
import '../core/services/individual_services/camera_service.dart';
import '../core/services/individual_services/sync_service.dart';
import '../core/services/individual_services/ingredient_analyzer_service.dart';
import '../features/auth/service/auth_service.dart';

/// Utility for testing the service locator
///
/// This class provides methods to test the service locator
/// and verify that services are being instantiated correctly.
class ServiceLocatorTester {
  /// Test all services in the service locator
  static Future<void> testAllServices() async {
    debugPrint('=========== TESTING SERVICE LOCATOR ===========');
    
    // Test connectivity service
    debugPrint('Testing ConnectivityService...');
    await _testService<ConnectivityService>();
    
    // Test analytics service
    debugPrint('Testing AnalyticsService...');
    await _testService<AnalyticsService>();
    
    // Test camera service
    debugPrint('Testing CameraService...');
    await _testService<CameraService>();
    
    // Test sync service
    debugPrint('Testing SyncService...');
    await _testService<SyncService>();
    
    // Test ingredient analyzer service
    debugPrint('Testing IngredientAnalyzerService...');
    await _testService<IngredientAnalyzerService>();
    
    // Test auth service
    debugPrint('Testing AuthService...');
    await _testService<AuthService>();
    
    debugPrint('=========== SERVICE LOCATOR TESTS COMPLETED ===========');
  }
  
  /// Test a single service
  static Future<void> _testService<T extends LazyService>() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    
    try {
      final service = await ServiceLocator.instance.get<T>();
      final className = service.runtimeType.toString();
      
      debugPrint('✓ Successfully created $className in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      debugPrint('✗ Failed to create ${T.toString()}: $e');
    } finally {
      stopwatch.stop();
    }
  }
  
  /// Test memory management
  static Future<void> testMemoryManagement() async {
    debugPrint('=========== TESTING MEMORY MANAGEMENT ===========');
    
    // Get multiple services
    debugPrint('Initializing services...');
    final connectivityService = await ServiceLocator.instance.get<ConnectivityService>();
    final analyticsService = await ServiceLocator.instance.get<AnalyticsService>();
    final syncService = await ServiceLocator.instance.get<SyncService>();
    
    // Verify they're initialized
    debugPrint('Services initialized: ${[
      connectivityService.isInitialized,
      analyticsService.isInitialized,
      syncService.isInitialized,
    ]}');
    
    // Simulate memory pressure
    debugPrint('Simulating memory pressure...');
    await ServiceLocator.instance.handleMemoryPressure();
    
    // Get services again and check initialization
    debugPrint('Getting services again...');
    final connectivityService2 = await ServiceLocator.instance.get<ConnectivityService>();
    final analyticsService2 = await ServiceLocator.instance.get<AnalyticsService>();
    final syncService2 = await ServiceLocator.instance.get<SyncService>();
    
    // Verify they're still the same instances (singletons)
    debugPrint('Services are same instances: ${[
      identical(connectivityService, connectivityService2),
      identical(analyticsService, analyticsService2),
      identical(syncService, syncService2),
    ]}');
    
    debugPrint('=========== MEMORY MANAGEMENT TESTS COMPLETED ===========');
  }
  
  /// Test service recreation after reset
  static Future<void> testServiceReset() async {
    debugPrint('=========== TESTING SERVICE RESET ===========');
    
    // Get a service
    debugPrint('Getting a service...');
    final service1 = await ServiceLocator.instance.get<ConnectivityService>();
    
    // Reset all services
    debugPrint('Resetting all services...');
    await ServiceLocator.instance.reset();
    
    // Get the service again
    debugPrint('Getting service again...');
    final service2 = await ServiceLocator.instance.get<ConnectivityService>();
    
    // Verify it's a different instance
    final areSame = identical(service1, service2);
    debugPrint('Services are same instance: $areSame (should be false)');
    
    debugPrint('=========== SERVICE RESET TESTS COMPLETED ===========');
  }
  
  /// Run all tests
  static Future<void> runAllTests() async {
    await testAllServices();
    await testMemoryManagement();
    await testServiceReset();
  }
}