/// Contains utility functions for route protection

/// Utility class for route protection
class RouteProtection {
  /// List of routes that require authentication
  static const List<String> _protectedRoutes = [
    '/home',
    '/profile',
    '/camera',
    '/recognition',
    '/results',
    '/history',
    '/favorites',
    '/settings',
  ];
  
  /// List of routes that are accessible without authentication
  static const List<String> _publicRoutes = [
    '/',
    '/auth',
    '/onboarding',
    '/about',
    '/privacy',
    '/terms',
  ];
  
  /// Check if a route requires authentication
  ///
  /// Returns true if the route requires authentication, false otherwise
  static bool requiresAuth(String routeName) {
    // If it's in protected routes, it requires auth
    if (_protectedRoutes.contains(routeName)) {
      return true;
    }
    
    // If it's in public routes, it doesn't require auth
    if (_publicRoutes.contains(routeName)) {
      return false;
    }
    
    // For any other route, check if it has a protected route prefix
    return _protectedRoutes.any((route) => 
      routeName.startsWith(route) && routeName != route);
  }
  
  /// Get the authentication redirect route for a given route
  ///
  /// Returns the route to redirect to if authentication is required
  static String getAuthRedirectRoute(String attemptedRoute) {
    // Store the attempted route in a query parameter
    return '/auth?redirect=$attemptedRoute';
  }
  
  /// Extract the redirect route from an authentication redirect
  ///
  /// Returns the route to redirect to after authentication, or null if there is no redirect
  static String? extractRedirectRoute(String authRoute) {
    // Check if there is a redirect parameter
    if (authRoute.contains('?redirect=')) {
      // Extract the redirect parameter
      return authRoute.split('?redirect=').last;
    }
    
    return null;
  }
}