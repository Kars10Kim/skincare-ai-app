import 'package:equatable/equatable.dart';

import '../../domain/entities/scan_history_item.dart';

/// History filter options
enum HistoryFilter {
  /// All scans
  all,
  
  /// Only safe products
  safe,
  
  /// Products with any conflicts
  conflicts,
  
  /// Products with high severity conflicts
  highSeverity,
}

/// History state
abstract class HistoryState extends Equatable {
  /// Create history state
  const HistoryState();
  
  @override
  List<Object> get props => [];
}

/// Initial history state
class HistoryInitial extends HistoryState {}

/// History loading state
class HistoryLoading extends HistoryState {}

/// History loaded state
class HistoryLoaded extends HistoryState {
  /// List of history items
  final List<ScanHistoryItem> items;
  
  /// Original unfiltered items
  final List<ScanHistoryItem> allItems;
  
  /// Current filter
  final HistoryFilter filter;
  
  /// Show only favorites
  final bool favoritesOnly;
  
  /// Current search query
  final String? searchQuery;
  
  /// Create history loaded state
  const HistoryLoaded({
    required this.items,
    required this.allItems,
    this.filter = HistoryFilter.all,
    this.favoritesOnly = false,
    this.searchQuery,
  });
  
  /// Create a copy with new values
  HistoryLoaded copyWith({
    List<ScanHistoryItem>? items,
    List<ScanHistoryItem>? allItems,
    HistoryFilter? filter,
    bool? favoritesOnly,
    String? searchQuery,
  }) {
    return HistoryLoaded(
      items: items ?? this.items,
      allItems: allItems ?? this.allItems,
      filter: filter ?? this.filter,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
  
  @override
  List<Object?> get props => [items, allItems, filter, favoritesOnly, searchQuery];
}

/// History error state
class HistoryError extends HistoryState {
  /// Error message
  final String message;
  
  /// Create history error state
  const HistoryError({required this.message});
  
  @override
  List<Object> get props => [message];
}