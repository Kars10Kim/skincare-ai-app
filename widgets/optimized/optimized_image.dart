import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../utils/memory_management.dart';
import '../../utils/ui_performance.dart';

/// A widget that displays an optimized image with memory management
class OptimizedImage extends StatefulWidget {
  /// Image from network URL
  final String? url;
  
  /// Image from asset
  final String? asset;
  
  /// Image from file
  final File? file;
  
  /// Image from memory
  final Uint8List? bytes;
  
  /// Width constraint
  final double? width;
  
  /// Height constraint
  final double? height;
  
  /// Image fit
  final BoxFit fit;
  
  /// Border radius
  final BorderRadius? borderRadius;
  
  /// Loading placeholder widget
  final Widget? placeholder;
  
  /// Error placeholder widget
  final Widget? errorWidget;
  
  /// Whether to apply blur effect on low-end devices
  final bool enableBlurOnLowEnd;
  
  /// Whether to use low quality when scrolling
  final bool enableLowQualityOnScroll;
  
  /// Whether to cache the image
  final bool cache;
  
  /// Sigma for blur effect (if applied)
  final double blurSigma;
  
  /// Create an optimized image
  const OptimizedImage({
    Key? key,
    this.url,
    this.asset,
    this.file,
    this.bytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.enableBlurOnLowEnd = true,
    this.enableLowQualityOnScroll = true,
    this.cache = true,
    this.blurSigma = 2.0,
  })  : assert(url != null || asset != null || file != null || bytes != null,
            'At least one image source must be provided'),
        super(key: key);

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage>
    with SingleTickerProviderStateMixin, AutoDisposeMixin {
  ImageProvider? _imageProvider;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isScrolling = false;
  Size? _originalSize;
  ImageInfo? _imageInfo;
  late AnimationController _qualityController;
  
  bool get _shouldApplyBlur => widget.enableBlurOnLowEnd && 
      UIPerformance.performanceMode == PerformanceMode.battery;
  
  double get _blurSigma => _shouldApplyBlur ? widget.blurSigma : 0.0;

  @override
  void initState() {
    super.initState();
    _loadImage();
    
    _qualityController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 300),
      value: 1.0, // start with high quality
    );
    
    addDisposable(_qualityController);
  }

  @override
  void didUpdateWidget(OptimizedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if image source changed
    if (widget.url != oldWidget.url ||
        widget.asset != oldWidget.asset ||
        widget.file != oldWidget.file ||
        widget.bytes != oldWidget.bytes) {
      _loadImage();
    }
  }
  
  void _loadImage() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _imageProvider = null;
    });
    
    try {
      ImageProvider? provider;
      
      if (widget.url != null) {
        provider = NetworkImage(widget.url!);
      } else if (widget.asset != null) {
        provider = AssetImage(widget.asset!);
      } else if (widget.file != null) {
        provider = FileImage(widget.file!);
      } else if (widget.bytes != null) {
        provider = MemoryImage(widget.bytes!);
      }
      
      if (provider == null) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }
      
      final imageStream = provider.resolve(const ImageConfiguration());
      final listener = ImageStreamListener(
        (info, _) {
          _imageInfo = info;
          _originalSize = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
          
          setState(() {
            _imageProvider = provider;
            _isLoading = false;
          });
        },
        onError: (exception, stackTrace) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        },
      );
      
      imageStream.addListener(listener);
      
      // Cleanup on dispose
      addDisposable(() {
        imageStream.removeListener(listener);
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }
  
  void _setScrolling(bool isScrolling) {
    if (_isScrolling != isScrolling) {
      _isScrolling = isScrolling;
      
      if (widget.enableLowQualityOnScroll) {
        if (isScrolling) {
          _qualityController.animateTo(0.0); // low quality
        } else {
          _qualityController.animateTo(1.0); // high quality
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.placeholder ?? 
            const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_hasError || _imageProvider == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.errorWidget ?? 
            const Center(child: Icon(Icons.error_outline)),
      );
    }
    
    // Build optimized image
    Widget image = NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          _setScrolling(true);
        } else if (notification is ScrollEndNotification) {
          _setScrolling(false);
        }
        return false;
      },
      child: AnimatedBuilder(
        animation: _qualityController,
        builder: (context, child) {
          // Determine if we should show high quality
          final highQuality = _qualityController.value > 0.5;
          
          // Create image with or without blur
          return _buildImageWithBlur(highQuality);
        },
      ),
    );
    
    // Apply border radius if specified
    if (widget.borderRadius != null) {
      image = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: image,
      );
    }
    
    return image;
  }
  
  Widget _buildImageWithBlur(bool highQuality) {
    Widget imageWidget = Image(
      image: _imageProvider!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      filterQuality: highQuality 
          ? FilterQuality.high 
          : FilterQuality.low,
      isAntiAlias: highQuality,
      frameBuilder: widget.cache 
          ? (_, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                return child;
              }
              return AnimatedOpacity(
                opacity: 0.0,
                duration: const Duration(milliseconds: 300),
                child: child,
              );
            }
          : null,
    );
    
    // Apply blur effect for low-end devices if enabled
    if (_blurSigma > 0) {
      return Stack(
        children: [
          // Sharp image
          imageWidget,
          
          // Apply blur based on performance mode
          if (_shouldApplyBlur)
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: _blurSigma, 
                  sigmaY: _blurSigma,
                ),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
        ],
      );
    }
    
    return imageWidget;
  }
}

/// Widget that optimizes a list of images
class OptimizedImageGrid extends StatefulWidget {
  /// List of image URLs
  final List<String> imageUrls;
  
  /// Number of columns
  final int crossAxisCount;
  
  /// Spacing between items
  final double spacing;
  
  /// Aspect ratio of each item
  final double childAspectRatio;
  
  /// Callback when an image is tapped
  final Function(int)? onTap;
  
  /// Whether to optimize rendering
  final bool optimize;
  
  /// Create an optimized image grid
  const OptimizedImageGrid({
    Key? key,
    required this.imageUrls,
    this.crossAxisCount = 2,
    this.spacing = 8.0,
    this.childAspectRatio = 1.0,
    this.onTap,
    this.optimize = true,
  }) : super(key: key);

  @override
  State<OptimizedImageGrid> createState() => _OptimizedImageGridState();
}

class _OptimizedImageGridState extends State<OptimizedImageGrid>
    with AutoDisposeMixin {
  final List<int> _visibleIndices = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Add scroll controller to disposables
    addDisposable(_scrollController);
    
    // Track scroll position for optimization
    _scrollController.addListener(_updateVisibleIndices);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_updateVisibleIndices);
    super.dispose();
  }
  
  void _updateVisibleIndices() {
    if (!widget.optimize) return;
    
    // Calculate visible range
    final viewportHeight = _scrollController.position.viewportDimension;
    final scrollOffset = _scrollController.offset;
    
    final startIndex = (scrollOffset / 100).floor().clamp(0, widget.imageUrls.length - 1);
    final endIndex = ((scrollOffset + viewportHeight) / 100).ceil().clamp(0, widget.imageUrls.length - 1);
    
    // Update visible indices
    setState(() {
      _visibleIndices.clear();
      _visibleIndices.addAll(List.generate(endIndex - startIndex + 1, (i) => startIndex + i));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.spacing,
        crossAxisSpacing: widget.spacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.imageUrls.length,
      itemBuilder: (context, index) {
        // Only render high quality for visible items
        final isVisible = !widget.optimize || _visibleIndices.contains(index);
        
        return GestureDetector(
          onTap: widget.onTap != null ? () => widget.onTap!(index) : null,
          child: OptimizedRenderingBox(
            complexityScore: 8.0, // Images are complex
            child: OptimizedImage(
              url: widget.imageUrls[index],
              borderRadius: BorderRadius.circular(8.0),
              enableLowQualityOnScroll: true,
              enableBlurOnLowEnd: !isVisible, // Blur non-visible items on low-end devices
            ),
          ),
        );
      },
    );
  }
}