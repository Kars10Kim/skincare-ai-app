import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../recognition/domain/entities/scan_error.dart';
import '../../../recognition/domain/entities/scan_history_item.dart';
import '../../../recognition/domain/repositories/scan_repository.dart';
import 'home_state.dart';

/// Cubit for managing home screen state
class HomeCubit extends Cubit<HomeState> {
  /// Repository for scan data
  final ScanRepository repository;
  
  /// Create a home cubit
  HomeCubit({
    required this.repository,
  }) : super(HomeState.initial());
  
  /// Load scan history
  Future<void> loadScanHistory() async {
    emit(state.copyWith(isLoading: true));
    
    try {
      final history = await repository.getScanHistory();
      emit(HomeState.loaded(history));
    } catch (e) {
      emit(HomeState.error(
        ScanError.unknown('Failed to load scan history: $e'),
      ));
    }
  }
  
  /// Clear scan history
  Future<void> clearScanHistory() async {
    emit(state.copyWith(isLoading: true));
    
    try {
      await repository.clearScanHistory();
      emit(HomeState.loaded([]));
    } catch (e) {
      emit(HomeState.error(
        ScanError.unknown('Failed to clear scan history: $e'),
      ));
    }
  }
  
  /// Delete a scan from history
  Future<void> deleteScan(String barcode) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      await repository.deleteScan(barcode);
      
      // Remove from local state
      final updatedHistory = state.scanHistory
          .where((scan) => scan.barcode != barcode)
          .toList();
          
      emit(HomeState.loaded(updatedHistory));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: ScanError.unknown('Failed to delete scan: $e'),
      ));
    }
  }
  
  /// Add a scan to history
  Future<void> addScanToHistory(ScanHistoryItem scan) async {
    try {
      await repository.addScanToHistory(scan);
      
      // Update local state
      final updatedHistory = [
        scan,
        ...state.scanHistory
            .where((item) => item.barcode != scan.barcode),
      ];
      
      emit(HomeState.loaded(updatedHistory));
    } catch (e) {
      emit(state.copyWith(
        error: ScanError.unknown('Failed to add scan to history: $e'),
      ));
    }
  }
  
  /// Toggle favorite status of a scan
  Future<void> toggleFavorite(String barcode) async {
    try {
      // Find the scan in history
      final scanIndex = state.scanHistory
          .indexWhere((scan) => scan.barcode == barcode);
          
      if (scanIndex == -1) return;
      
      final scan = state.scanHistory[scanIndex];
      final updatedScan = scan.copyWith(isFavorite: !scan.isFavorite);
      
      // Update in repository
      await repository.updateScan(updatedScan);
      
      // Update local state
      final updatedHistory = List<ScanHistoryItem>.from(state.scanHistory);
      updatedHistory[scanIndex] = updatedScan;
      
      emit(HomeState.loaded(updatedHistory));
    } catch (e) {
      emit(state.copyWith(
        error: ScanError.unknown('Failed to update favorite status: $e'),
      ));
    }
  }
  
  /// Expand bottom sheet
  void expandBottomSheet() {
    emit(state.copyWith(isBottomSheetExpanded: true));
  }
  
  /// Collapse bottom sheet
  void collapseBottomSheet() {
    emit(state.copyWith(isBottomSheetExpanded: false));
  }
}