import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Guard for protecting routes that require authentication
class RouteGuard {
  /// Check if a route can be accessed based on authentication state
  static Future<bool> canActivate(BuildContext context, String routeName) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Routes that require authentication
    const protectedRoutes = [
      '/profile',
    ];
    
    // If the route requires authentication and user is not authenticated,
    // redirect to auth screen
    if (protectedRoutes.contains(routeName) && !authProvider.isAuthenticated) {
      await Navigator.of(context).pushNamed('/auth');
      return false;
    }
    
    // Routes that should not be accessible when authenticated
    const publicOnlyRoutes = [
      '/auth',
    ];
    
    // If the route should not be accessible when authenticated
    if (publicOnlyRoutes.contains(routeName) && authProvider.isAuthenticated) {
      await Navigator.of(context).pushReplacementNamed('/home');
      return false;
    }
    
    return true;
  }
  
  /// Navigate to a route with protection
  static Future<void> navigateTo(
    BuildContext context, 
    String routeName, {
    Object? arguments,
  }) async {
    final canActivate = await RouteGuard.canActivate(context, routeName);
    
    if (canActivate && context.mounted) {
      await Navigator.of(context).pushNamed(routeName, arguments: arguments);
    }
  }
  
  /// Navigate to a route with protection and replace current route
  static Future<void> navigateToReplacement(
    BuildContext context, 
    String routeName, {
    Object? arguments,
  }) async {
    final canActivate = await RouteGuard.canActivate(context, routeName);
    
    if (canActivate && context.mounted) {
      await Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
    }
  }
}