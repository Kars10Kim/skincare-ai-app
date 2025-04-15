import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../utils/memory_management.dart';
import '../../utils/ui_performance.dart';

/// A highly optimized ListView that minimizes rebuilds and memory usage
class OptimizedListView<T> extends StatefulWidget {
  /// List of items to display
  final List<T> items;
  
  /// Builder function for items
  final Widget Function(BuildContext, T, int) itemBuilder;
  
  /// Builder for placeholders when items are not yet visible
  final Widget Function(BuildContext, int)? placeholderBuilder;
  
  /// Item height (fixed for better performance)
  final double? itemHeight;
  
  /// Padding around the list
  final EdgeInsetsGeometry? padding;
  
  /// Spacing between items
  final double itemSpacing;
  
  /// Whether items can be selected
  final bool selectable;
  
  /// Currently selected index
  final int? selectedIndex;
  
  /// Callback when an item is tapped
  final Function(int)? onTap;
  
  /// Whether to separate items with dividers
  final bool showDividers;
  
  /// Custom divider widget
  final Widget? divider;
  
  /// Scroll controller
  final ScrollController? controller;
  
  /// Scroll physics
  final ScrollPhysics? physics;
  
  /// Whether to shrinkwrap the list
  final bool shrinkWrap;
  
  /// Whether to display items in reverse order
  final bool reverse;
  
  /// Primary scroll view
  final bool? primary;
  
  /// How many items to render ahead of viewport
  final int preloadItemCount;
  
  /// Create an optimized list view
  const OptimizedListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.placeholderBuilder,
    this.itemHeight,
    this.padding,
    this.itemSpacing = 0.0,
    this.selectable = false,
    this.selectedIndex,
    this.onTap,
    this.showDividers = false,
    this.divider,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.reverse = false,
    this.primary,
    this.preloadItemCount = 5,
  }) : super(key: key);

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>>
    with AutoDisposeMixin {
  final Set<int> _visibleIndices = {};
  late ScrollController _scrollController;
  bool _isScrolling = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    
    if (widget.controller == null) {
      // Only manage our own controller
      addDisposable(_scrollController);
    }
    
    // Listen to scroll events to optimize rendering
    _scrollController.addListener(_updateVisibility);
  }
  
  @override
  void didUpdateWidget(OptimizedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update controller if it changed
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        // We created the old controller, so dispose it
        _scrollController.dispose();
      }
      
      _scrollController = widget.controller ?? ScrollController();
      
      if (widget.controller == null) {
        // Only manage our own controller
        addDisposable(_scrollController);
      }
      
      _scrollController.addListener(_updateVisibility);
    }
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      // Only dispose if we created the controller
      _scrollController.removeListener(_updateVisibility);
    }
    super.dispose();
  }
  
  /// Update the list of visible item indices based on scroll position
  void _updateVisibility() {
    if (!mounted) return;
    
    // Detect if scrolling
    final isScrolling = _scrollController.position.isScrollingNotifier.value;
    if (_isScrolling != isScrolling) {
      _isScrolling = isScrolling;
    }
    
    if (widget.itemHeight == null) {
      // Skip visibility optimization if we don't know item heights
      return;
    }
    
    // Calculate visible range
    final viewportHeight = _scrollController.position.viewportDimension;
    final scrollOffset = _scrollController.offset;
    
    final itemHeightWithSpacing = widget.itemHeight! + widget.itemSpacing;
    
    // Calculate which items are visible
    final startIndex = (scrollOffset / itemHeightWithSpacing).floor();
    final endIndex = ((scrollOffset + viewportHeight) / itemHeightWithSpacing).ceil();
    
    // Add preload buffer
    final preloadStart = (startIndex - widget.preloadItemCount).clamp(0, widget.items.length - 1);
    final preloadEnd = (endIndex + widget.preloadItemCount).clamp(0, widget.items.length - 1);
    
    // Update visible indices
    final newVisibleIndices = Set<int>.from(
      List.generate(preloadEnd - preloadStart + 1, (i) => preloadStart + i),
    );
    
    if (!setEquals(_visibleIndices, newVisibleIndices)) {
      setState(() {
        _visibleIndices.clear();
        _visibleIndices.addAll(newVisibleIndices);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      reverse: widget.reverse,
      primary: widget.primary,
      itemCount: widget.items.length,
      separatorBuilder: (context, index) {
        if (widget.showDividers) {
          return widget.divider ?? const Divider(height: 1);
        }
        if (widget.itemSpacing > 0) {
          return SizedBox(height: widget.itemSpacing);
        }
        return const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        final isVisible = widget.itemHeight == null || _visibleIndices.contains(index);
        final isSelected = widget.selectable && widget.selectedIndex == index;
        
        // If not visible and we have a placeholder, render placeholder
        if (!isVisible && widget.placeholderBuilder != null) {
          return widget.placeholderBuilder!(context, index);
        }
        
        // Build item with tap handling and selection if needed
        final item = widget.items[index];
        Widget itemWidget = widget.itemBuilder(context, item, index);
        
        // Add tap handling and selection styling if needed
        if (widget.selectable || widget.onTap != null) {
          itemWidget = InkWell(
            onTap: widget.onTap != null ? () => widget.onTap!(index) : null,
            child: Container(
              color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null,
              height: widget.itemHeight,
              child: itemWidget,
            ),
          );
        } else if (widget.itemHeight != null) {
          // Apply fixed height if specified
          itemWidget = SizedBox(
            height: widget.itemHeight,
            child: itemWidget,
          );
        }
        
        // Optimize rendering based on visibility
        return OptimizedRenderingBox(
          forceHighQuality: isVisible,
          complexityScore: isVisible ? 5.0 : 2.0, // Higher score for visible items
          child: itemWidget,
        );
      },
    );
  }
}

/// A list view that renders items on demand to improve performance
class LazyLoadListView<T> extends StatefulWidget {
  /// List of items to display
  final List<T> items;
  
  /// Builder function for items
  final Widget Function(BuildContext, T, int) itemBuilder;
  
  /// Number of initial items to render
  final int initialItemCount;
  
  /// How many items to load at once
  final int loadBatchSize;
  
  /// Builder for the load more button
  final Widget Function(BuildContext, VoidCallback)? loadMoreBuilder;
  
  /// Whether to show a load more button at the end
  final bool showLoadMore;
  
  /// Padding around the list
  final EdgeInsetsGeometry? padding;
  
  /// Spacing between items
  final double itemSpacing;
  
  /// Whether to show dividers between items
  final bool showDividers;
  
  /// Custom divider widget
  final Widget? divider;
  
  /// Callback when an item is tapped
  final Function(int)? onTap;
  
  /// Create a lazy load list view
  const LazyLoadListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.initialItemCount = 10,
    this.loadBatchSize = 10,
    this.loadMoreBuilder,
    this.showLoadMore = true,
    this.padding,
    this.itemSpacing = 0.0,
    this.showDividers = false,
    this.divider,
    this.onTap,
  }) : super(key: key);

  @override
  State<LazyLoadListView<T>> createState() => _LazyLoadListViewState<T>();
}

class _LazyLoadListViewState<T> extends State<LazyLoadListView<T>> {
  late int _visibleItemCount;
  
  @override
  void initState() {
    super.initState();
    _visibleItemCount = widget.initialItemCount.clamp(0, widget.items.length);
  }
  
  @override
  void didUpdateWidget(LazyLoadListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update visible count if the items length changed
    if (widget.items.length != oldWidget.items.length) {
      _visibleItemCount = _visibleItemCount.clamp(0, widget.items.length);
    }
  }
  
  /// Load more items
  void _loadMore() {
    setState(() {
      _visibleItemCount = (_visibleItemCount + widget.loadBatchSize)
          .clamp(0, widget.items.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we need to show the load more button
    final showLoadMore = widget.showLoadMore && _visibleItemCount < widget.items.length;
    
    return ListView.separated(
      padding: widget.padding,
      itemCount: _visibleItemCount + (showLoadMore ? 1 : 0),
      separatorBuilder: (context, index) {
        if (widget.showDividers) {
          return widget.divider ?? const Divider(height: 1);
        }
        if (widget.itemSpacing > 0) {
          return SizedBox(height: widget.itemSpacing);
        }
        return const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        if (index == _visibleItemCount && showLoadMore) {
          // Build load more item
          if (widget.loadMoreBuilder != null) {
            return widget.loadMoreBuilder!(context, _loadMore);
          }
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: _loadMore,
                child: const Text('Load More'),
              ),
            ),
          );
        }
        
        // Build regular item
        final item = widget.items[index];
        Widget itemWidget = widget.itemBuilder(context, item, index);
        
        // Add tap handling if needed
        if (widget.onTap != null) {
          itemWidget = InkWell(
            onTap: () => widget.onTap!(index),
            child: itemWidget,
          );
        }
        
        // Use optimized rendering for better performance
        return OptimizedRenderingBox(
          complexityScore: 5.0,
          child: itemWidget,
        );
      },
    );
  }
}

/// A grid with optimized rendering for performance
class OptimizedGridView<T> extends StatefulWidget {
  /// List of items to display
  final List<T> items;
  
  /// Builder function for items
  final Widget Function(BuildContext, T, int) itemBuilder;
  
  /// Builder for placeholders when items are not yet visible
  final Widget Function(BuildContext, int)? placeholderBuilder;
  
  /// Number of columns in the grid
  final int crossAxisCount;
  
  /// Spacing between items horizontally
  final double crossAxisSpacing;
  
  /// Spacing between items vertically
  final double mainAxisSpacing;
  
  /// Aspect ratio of each item
  final double childAspectRatio;
  
  /// Padding around the grid
  final EdgeInsetsGeometry? padding;
  
  /// Callback when an item is tapped
  final Function(int)? onTap;
  
  /// Scroll controller
  final ScrollController? controller;
  
  /// Scroll physics
  final ScrollPhysics? physics;
  
  /// Whether to shrinkwrap the grid
  final bool shrinkWrap;
  
  /// How many items to render ahead of viewport
  final int preloadItemCount;
  
  /// Create an optimized grid view
  const OptimizedGridView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.placeholderBuilder,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.padding,
    this.onTap,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.preloadItemCount = 10,
  }) : super(key: key);

  @override
  State<OptimizedGridView<T>> createState() => _OptimizedGridViewState<T>();
}

class _OptimizedGridViewState<T> extends State<OptimizedGridView<T>>
    with AutoDisposeMixin {
  final Set<int> _visibleIndices = {};
  late ScrollController _scrollController;
  bool _isScrolling = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    
    if (widget.controller == null) {
      // Only manage our own controller
      addDisposable(_scrollController);
    }
    
    // Listen to scroll events to optimize rendering
    _scrollController.addListener(_updateVisibility);
  }
  
  @override
  void didUpdateWidget(OptimizedGridView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update controller if it changed
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        // We created the old controller, so dispose it
        _scrollController.dispose();
      }
      
      _scrollController = widget.controller ?? ScrollController();
      
      if (widget.controller == null) {
        // Only manage our own controller
        addDisposable(_scrollController);
      }
      
      _scrollController.addListener(_updateVisibility);
    }
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      // Only dispose if we created the controller
      _scrollController.removeListener(_updateVisibility);
    }
    super.dispose();
  }
  
  /// Update the list of visible item indices based on scroll position
  void _updateVisibility() {
    if (!mounted) return;
    
    // Detect if scrolling
    final isScrolling = _scrollController.position.isScrollingNotifier.value;
    if (_isScrolling != isScrolling) {
      _isScrolling = isScrolling;
    }
    
    // Calculate visible range
    final viewportHeight = _scrollController.position.viewportDimension;
    final scrollOffset = _scrollController.offset;
    
    // Estimate item height based on aspect ratio
    final columnWidth = MediaQuery.of(context).size.width / widget.crossAxisCount;
    final estimatedItemHeight = columnWidth / widget.childAspectRatio;
    
    // Calculate row height
    final rowHeight = estimatedItemHeight + widget.mainAxisSpacing;
    
    // Calculate which rows are visible
    final startRow = (scrollOffset / rowHeight).floor();
    final endRow = ((scrollOffset + viewportHeight) / rowHeight).ceil();
    
    // Add preload buffer
    final preloadStartRow = (startRow - (widget.preloadItemCount / widget.crossAxisCount).ceil())
        .clamp(0, (widget.items.length / widget.crossAxisCount).ceil() - 1);
    final preloadEndRow = (endRow + (widget.preloadItemCount / widget.crossAxisCount).ceil())
        .clamp(0, (widget.items.length / widget.crossAxisCount).ceil() - 1);
    
    // Calculate visible indices
    final newVisibleIndices = <int>{};
    for (int row = preloadStartRow; row <= preloadEndRow; row++) {
      for (int col = 0; col < widget.crossAxisCount; col++) {
        final index = row * widget.crossAxisCount + col;
        if (index < widget.items.length) {
          newVisibleIndices.add(index);
        }
      }
    }
    
    if (!setEquals(_visibleIndices, newVisibleIndices)) {
      setState(() {
        _visibleIndices.clear();
        _visibleIndices.addAll(newVisibleIndices);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final isVisible = _visibleIndices.contains(index) || _visibleIndices.isEmpty;
        
        // If not visible and we have a placeholder, render placeholder
        if (!isVisible && widget.placeholderBuilder != null) {
          return widget.placeholderBuilder!(context, index);
        }
        
        // Build item
        final item = widget.items[index];
        Widget itemWidget = widget.itemBuilder(context, item, index);
        
        // Add tap handling if needed
        if (widget.onTap != null) {
          itemWidget = GestureDetector(
            onTap: () => widget.onTap!(index),
            child: itemWidget,
          );
        }
        
        // Optimize rendering based on visibility
        return OptimizedRenderingBox(
          forceHighQuality: isVisible,
          complexityScore: 5.0,
          child: itemWidget,
        );
      },
    );
  }
}