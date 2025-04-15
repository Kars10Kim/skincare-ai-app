import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/favorite_product.dart';
import '../../domain/entities/scan_history_item.dart';
import '../../domain/usecases/add_favorite_usecase.dart';
import '../../domain/usecases/add_scan_history_usecase.dart';
import '../../domain/usecases/clear_history_usecase.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/remove_favorite_usecase.dart';
import '../../domain/usecases/update_scan_note_usecase.dart';
import 'history_state.dart';

/// History cubit
class HistoryCubit extends Cubit<HistoryState> {
  /// Get history use case
  final GetHistoryUseCase getHistoryUseCase;
  
  /// Add scan history use case
  final AddScanHistoryUseCase addScanHistoryUseCase;
  
  /// Clear history use case
  final ClearHistoryUseCase clearHistoryUseCase;
  
  /// Update scan note use case
  final UpdateScanNoteUseCase updateScanNoteUseCase;
  
  /// Add favorite use case
  final AddFavoriteUseCase addFavoriteUseCase;
  
  /// Remove favorite use case
  final RemoveFavoriteUseCase removeFavoriteUseCase;
  
  /// UUID generator
  final _uuid = const Uuid();
  
  /// Create history cubit
  HistoryCubit({
    required this.getHistoryUseCase,
    required this.addScanHistoryUseCase,
    required this.clearHistoryUseCase,
    required this.updateScanNoteUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
  }) : super(HistoryInitial());
  
  /// Load history
  Future<void> loadHistory() async {
    emit(HistoryLoading());
    
    try {
      final items = await getHistoryUseCase();
      emit(HistoryLoaded(items: items, allItems: items));
    } catch (e) {
      emit(HistoryError(message: e.toString()));
    }
  }
  
  /// Add scan to history
  Future<void> addScanToHistory(ScanHistoryItem item) async {
    try {
      final newItem = await addScanHistoryUseCase(item);
      
      final currentState = state;
      if (currentState is HistoryLoaded) {
        final updatedAllItems = [newItem, ...currentState.allItems];
        final filteredItems = _applyFilters(
          updatedAllItems,
          currentState.filter,
          currentState.favoritesOnly,
          currentState.searchQuery,
        );
        
        emit(currentState.copyWith(
          items: filteredItems,
          allItems: updatedAllItems,
        ));
      } else {
        await loadHistory();
      }
    } catch (e) {
      emit(HistoryError(message: e.toString()));
    }
  }
  
  /// Clear history
  Future<void> clearHistory() async {
    try {
      await clearHistoryUseCase();
      emit(const HistoryLoaded(items: [], allItems: []));
    } catch (e) {
      emit(HistoryError(message: e.toString()));
    }
  }
  
  /// Update scan note
  Future<void> updateScanNote(String scanId, String? note) async {
    try {
      final updatedItem = await updateScanNoteUseCase(scanId, note);
      
      final currentState = state;
      if (currentState is HistoryLoaded) {
        final updatedAllItems = currentState.allItems.map((item) {
          return item.id == scanId ? updatedItem : item;
        }).toList();
        
        final filteredItems = _applyFilters(
          updatedAllItems,
          currentState.filter,
          currentState.favoritesOnly,
          currentState.searchQuery,
        );
        
        emit(currentState.copyWith(
          items: filteredItems,
          allItems: updatedAllItems,
        ));
      }
    } catch (e) {
      emit(HistoryError(message: e.toString()));
    }
  }
  
  /// Toggle favorite status
  Future<void> toggleFavorite(String scanId, bool isFavorite) async {
    try {
      final currentState = state;
      if (currentState is HistoryLoaded) {
        // Find the item
        final itemIndex = currentState.allItems.indexWhere((i) => i.id == scanId);
        if (itemIndex < 0) {
          return;
        }
        
        final item = currentState.allItems[itemIndex];
        
        // Update the item
        final updatedItem = item.copyWith(isFavorite: isFavorite);
        
        // Save to history
        await addScanHistoryUseCase(updatedItem);
        
        // Also add/remove from favorites
        if (isFavorite) {
          final favorite = FavoriteProduct(
            id: _uuid.v4(),
            product: item.product,
            addedDate: DateTime.now(),
          );
          await addFavoriteUseCase(favorite);
        } else {
          // Note: This is simplified and would need to find the
          // corresponding favorite ID in a real implementation
          // Here we assume we need a way to find the favorite by product ID
          // This would typically require a query to the favorites repository
        }
        
        // Update state
        final updatedAllItems = List<ScanHistoryItem>.from(currentState.allItems);
        updatedAllItems[itemIndex] = updatedItem;
        
        final filteredItems = _applyFilters(
          updatedAllItems,
          currentState.filter,
          currentState.favoritesOnly,
          currentState.searchQuery,
        );
        
        emit(currentState.copyWith(
          items: filteredItems,
          allItems: updatedAllItems,
        ));
      }
    } catch (e) {
      emit(HistoryError(message: e.toString()));
    }
  }
  
  /// Apply filter
  void applyFilter(HistoryFilter filter) {
    final currentState = state;
    if (currentState is HistoryLoaded) {
      final filteredItems = _applyFilters(
        currentState.allItems,
        filter,
        currentState.favoritesOnly,
        currentState.searchQuery,
      );
      
      emit(currentState.copyWith(
        items: filteredItems,
        filter: filter,
      ));
    }
  }
  
  /// Toggle favorites only
  void toggleFavoritesOnly(bool favoritesOnly) {
    final currentState = state;
    if (currentState is HistoryLoaded) {
      final filteredItems = _applyFilters(
        currentState.allItems,
        currentState.filter,
        favoritesOnly,
        currentState.searchQuery,
      );
      
      emit(currentState.copyWith(
        items: filteredItems,
        favoritesOnly: favoritesOnly,
      ));
    }
  }
  
  /// Search history
  void searchHistory(String query) {
    final currentState = state;
    if (currentState is HistoryLoaded) {
      final filteredItems = _applyFilters(
        currentState.allItems,
        currentState.filter,
        currentState.favoritesOnly,
        query,
      );
      
      emit(currentState.copyWith(
        items: filteredItems,
        searchQuery: query,
      ));
    }
  }
  
  /// Reset search
  void resetSearch() {
    final currentState = state;
    if (currentState is HistoryLoaded) {
      final filteredItems = _applyFilters(
        currentState.allItems,
        currentState.filter,
        currentState.favoritesOnly,
        null,
      );
      
      emit(currentState.copyWith(
        items: filteredItems,
        searchQuery: null,
      ));
    }
  }
  
  /// Apply filters to items
  List<ScanHistoryItem> _applyFilters(
    List<ScanHistoryItem> items,
    HistoryFilter filter,
    bool favoritesOnly,
    String? searchQuery,
  ) {
    var filteredItems = List<ScanHistoryItem>.from(items);
    
    // Apply favorites filter
    if (favoritesOnly) {
      filteredItems = filteredItems.where((item) => item.isFavorite).toList();
    }
    
    // Apply main filter
    switch (filter) {
      case HistoryFilter.all:
        // No filtering needed
        break;
      case HistoryFilter.safe:
        filteredItems = filteredItems.where((item) => item.conflicts.isEmpty).toList();
        break;
      case HistoryFilter.conflicts:
        filteredItems = filteredItems.where((item) => item.conflicts.isNotEmpty).toList();
        break;
      case HistoryFilter.highSeverity:
        filteredItems = filteredItems.where((item) {
          final highestSeverity = item.highestConflictSeverity;
          return highestSeverity >= 4; // High severity threshold
        }).toList();
        break;
    }
    
    // Apply search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredItems = filteredItems.where((item) {
        // Search in product name
        if (item.product.name.toLowerCase().contains(query)) {
          return true;
        }
        
        // Search in brand
        if (item.product.brand != null &&
            item.product.brand!.toLowerCase().contains(query)) {
          return true;
        }
        
        // Search in category
        if (item.product.category != null &&
            item.product.category!.toLowerCase().contains(query)) {
          return true;
        }
        
        // Search in ingredients
        if (item.product.ingredients.any((i) => i.toLowerCase().contains(query))) {
          return true;
        }
        
        // Search in notes
        if (item.notes != null && item.notes!.toLowerCase().contains(query)) {
          return true;
        }
        
        // Search in tags
        if (item.tags.any((t) => t.toLowerCase().contains(query))) {
          return true;
        }
        
        return false;
      }).toList();
    }
    
    return filteredItems;
  }
}