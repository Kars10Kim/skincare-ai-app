import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// UI performance tracking
class UIPerformance {
  /// Timestamp map for measuring durations
  static final Map<String, DateTime> _timestamps = {};
  
  /// Start measuring a section of code
  static void startMeasure(String name) {
    if (kReleaseMode) return;
    
    _timestamps[name] = DateTime.now();
    
    developer.Timeline.startSync(name);
  }
  
  /// End measuring a section of code
  static void endMeasure(String name) {
    if (kReleaseMode) return;
    
    final startTime = _timestamps[name];
    if (startTime == null) {
      debugPrint('UIPerformance: No start time for $name');
      return;
    }
    
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    
    debugPrint('UIPerformance: $name took ${duration.inMilliseconds}ms');
    
    developer.Timeline.finishSync();
  }
  
  /// Measure the duration of a function
  static Future<T> measure<T>(
    String name,
    Future<T> Function() callback,
  ) async {
    if (kReleaseMode) return callback();
    
    startMeasure(name);
    final result = await callback();
    endMeasure(name);
    
    return result;
  }
  
  /// Measure the duration of a synchronous function
  static T measureSync<T>(String name, T Function() callback) {
    if (kReleaseMode) return callback();
    
    startMeasure(name);
    final result = callback();
    endMeasure(name);
    
    return result;
  }
  
  /// Track a frame
  static void trackFrame(String name) {
    if (kReleaseMode) return;
    
    developer.Timeline.instantSync(
      'Frame: $name',
      arguments: <String, dynamic>{
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  /// Check if a widget is being rebuilt too frequently
  static void checkRebuild(String widgetName) {
    if (kReleaseMode) return;
    
    final now = DateTime.now();
    final lastRebuild = _timestamps['rebuild_$widgetName'];
    
    if (lastRebuild != null) {
      final duration = now.difference(lastRebuild);
      
      if (duration.inMilliseconds < 16) {
        debugPrint(
          'UIPerformance: $widgetName rebuilt too quickly '
          '(${duration.inMilliseconds}ms)',
        );
      }
    }
    
    _timestamps['rebuild_$widgetName'] = now;
  }
}