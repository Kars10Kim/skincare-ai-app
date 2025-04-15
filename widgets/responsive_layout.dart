import 'package:flutter/material.dart';

/// A widget that adapts to different screen sizes
class ResponsiveLayout extends StatelessWidget {
  /// Widget to display on mobile devices (narrow screens)
  final Widget mobileBody;
  
  /// Widget to display on tablet devices (wider screens)
  final Widget tabletBody;
  
  /// Width threshold for tablet layout
  final double tabletBreakpoint;
  
  /// Creates a responsive layout that adapts to screen size
  const ResponsiveLayout({
    Key? key,
    required this.mobileBody,
    required this.tabletBody,
    this.tabletBreakpoint = 600,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletBreakpoint) {
          return mobileBody;
        }
        return tabletBody;
      },
    );
  }
}