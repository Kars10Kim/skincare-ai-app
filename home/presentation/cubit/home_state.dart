import 'package:equatable/equatable.dart';

import '../../../recognition/domain/entities/scan_error.dart';
import '../../../recognition/domain/entities/scan_history_item.dart';

/// State for the home screen
class HomeState extends Equatable {
  /// Is data loading
  final bool isLoading;
  
  /// Scan history items
  final List<ScanHistoryItem> scanHistory;
  
  /// Error that occurred
  final ScanError? error;
  
  /// Is bottom sheet expanded
  final bool isBottomSheetExpanded;
  
  /// Create a home state
  const HomeState({
    this.isLoading = false,
    this.scanHistory = const [],
    this.error,
    this.isBottomSheetExpanded = false,
  });
  
  /// Create an initial state
  factory HomeState.initial() {
    return const HomeState();
  }
  
  /// Create a loading state
  factory HomeState.loading() {
    return const HomeState(isLoading: true);
  }
  
  /// Create a loaded state
  factory HomeState.loaded(List<ScanHistoryItem> scanHistory) {
    return HomeState(scanHistory: scanHistory);
  }
  
  /// Create an error state
  factory HomeState.error(ScanError error) {
    return HomeState(error: error);
  }
  
  /// Create a copy with new values
  HomeState copyWith({
    bool? isLoading,
    List<ScanHistoryItem>? scanHistory,
    ScanError? error,
    bool? isBottomSheetExpanded,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      scanHistory: scanHistory ?? this.scanHistory,
      error: error,
      isBottomSheetExpanded: isBottomSheetExpanded ?? this.isBottomSheetExpanded,
    );
  }
  
  /// Clear the error
  HomeState clearError() {
    return copyWith(error: null);
  }
  
  @override
  List<Object?> get props => [
    isLoading,
    scanHistory,
    error,
    isBottomSheetExpanded,
  ];
}