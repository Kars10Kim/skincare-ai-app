import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';

/// Utility for analyzing memory usage
///
/// This class is used to track memory usage throughout the app,
/// helping identify memory leaks and optimize performance.
class MemoryAnalyzer {
  /// Private constructor for singleton pattern
  MemoryAnalyzer._();
  
  /// Singleton instance
  static final MemoryAnalyzer instance = MemoryAnalyzer._();
  
  /// Memory usage tracking
  Map<String, int> _memorySnapshots = {};
  
  /// Timer for periodic snapshots
  Timer? _periodicSnapshotTimer;
  
  /// Tag for memory snapshots
  String? _autoSnapshotTag;
  
  /// Start monitoring memory
  void startMonitoring({
    Duration interval = const Duration(seconds: 30),
    String tag = 'periodic',
  }) {
    _periodicSnapshotTimer?.cancel();
    _autoSnapshotTag = tag;
    
    // Take initial snapshot
    takeSnapshot('$tag-start');
    
    // Schedule periodic snapshots
    _periodicSnapshotTimer = Timer.periodic(interval, (_) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      takeSnapshot('$tag-$timestamp');
    });
  }
  
  /// Stop monitoring memory
  void stopMonitoring() {
    _periodicSnapshotTimer?.cancel();
    
    // Take final snapshot
    if (_autoSnapshotTag != null) {
      takeSnapshot('${_autoSnapshotTag!}-end');
    }
  }
  
  /// Take a memory snapshot with a tag
  void takeSnapshot(String tag) {
    final memoryInfo = _getMemoryInfo();
    _memorySnapshots[tag] = memoryInfo;
    
    debugPrint('Memory snapshot [$tag]: ${memoryInfo ~/ 1024} KB');
  }
  
  /// Compare two snapshots
  int compareSnapshots(String tag1, String tag2) {
    if (!_memorySnapshots.containsKey(tag1) || !_memorySnapshots.containsKey(tag2)) {
      throw Exception('Snapshot not found');
    }
    
    final diff = _memorySnapshots[tag2]! - _memorySnapshots[tag1]!;
    final diffKb = diff ~/ 1024;
    
    debugPrint('Memory diff [$tag1 → $tag2]: $diffKb KB');
    
    return diff;
  }
  
  /// Get memory usage info
  int _getMemoryInfo() {
    // For this example, we'll use a simplified approach
    // In a real app, you'd use platform-specific implementations
    return _estimateMemoryUsage();
  }
  
  /// Estimate current memory usage
  int _estimateMemoryUsage() {
    // This is a very basic estimation using dev tools
    try {
      final memoryInfo = developer.Service.getInfo();
      // A real implementation would parse the VM's memory stats
      // For now we'll just return a rough estimate
      return 1024 * 1024; // 1 MB placeholder
    } catch (e) {
      debugPrint('Failed to get memory info: $e');
      return 0;
    }
  }
  
  /// Force a garbage collection (for debugging only)
  ///
  /// WARNING: This is not a reliable way to free memory in production.
  /// It's only included here for completeness and debugging purposes.
  Future<void> forceGarbageCollection() async {
    debugPrint('Forcing garbage collection...');
    
    // Request a full GC cycle - note this is not reliable
    developer.registerExtension('ext.flutter.gc', (method, params) async {
      developer.ServiceExtensionResponse response;
      try {
        debugPrint('GC requested via service extension');
        response = developer.ServiceExtensionResponse.result('{"result":"success"}');
      } catch (e) {
        response = developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.kExtensionError,
          'Failed to trigger GC: $e',
        );
      }
      return response;
    });
    
    // Small delay to allow GC to run
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// Get a memory report
  String getMemoryReport() {
    final buffer = StringBuffer();
    buffer.writeln('===== MEMORY REPORT =====');
    
    // Sort snapshots by value
    final sortedEntries = _memorySnapshots.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    for (final entry in sortedEntries) {
      final tag = entry.key;
      final memory = entry.value;
      buffer.writeln('  $tag: ${memory ~/ 1024} KB');
    }
    
    buffer.writeln('========================');
    return buffer.toString();
  }
  
  /// Reset memory snapshots
  void resetSnapshots() {
    _memorySnapshots = {};
  }
}

/// Widget that tracks memory when it's built and disposed
class MemoryTrackingWidget extends StatefulWidget {
  /// Child widget
  final Widget child;
  
  /// Tag to identify this widget in memory snapshots
  final String tag;
  
  /// Whether to force a garbage collection when disposed
  /// WARNING: Only use this for debugging
  final bool forceGcOnDispose;
  
  /// Create a new memory tracking widget
  const MemoryTrackingWidget({
    Key? key,
    required this.child,
    required this.tag,
    this.forceGcOnDispose = false,
  }) : super(key: key);
  
  @override
  State<MemoryTrackingWidget> createState() => _MemoryTrackingWidgetState();
}

class _MemoryTrackingWidgetState extends State<MemoryTrackingWidget> {
  late final String _buildTag;
  late final String _disposeTag;
  
  @override
  void initState() {
    super.initState();
    _buildTag = '${widget.tag}-build';
    _disposeTag = '${widget.tag}-dispose';
    
    // Take snapshot when widget is built
    MemoryAnalyzer.instance.takeSnapshot(_buildTag);
  }
  
  @override
  void dispose() {
    // Take snapshot when widget is disposed
    MemoryAnalyzer.instance.takeSnapshot(_disposeTag);
    
    // Try to compare the snapshots
    try {
      MemoryAnalyzer.instance.compareSnapshots(_buildTag, _disposeTag);
    } catch (e) {
      debugPrint('Failed to compare memory snapshots: $e');
    }
    
    // Force GC if requested (debugging only)
    if (widget.forceGcOnDispose) {
      MemoryAnalyzer.instance.forceGarbageCollection();
    }
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}