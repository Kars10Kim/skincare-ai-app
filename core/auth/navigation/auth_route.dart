import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

/// A widget that protects routes and redirects to authentication if needed.
///
/// Any widget wrapped with AuthRoute will only be accessible if the user
/// is authenticated. Otherwise, they will be redirected to the auth screen.
class AuthRoute extends StatelessWidget {
  /// The widget to render if authenticated
  final Widget child;
  
  /// Route to redirect to if not authenticated (defaults to '/auth')
  final String authRoute;
  
  /// Optional loading widget to show while authentication state is being determined
  final Widget? loadingWidget;
  
  /// Creates an auth-protected route.
  ///
  /// The [child] parameter is required and contains the widget to render if authenticated.
  /// The [authRoute] defaults to '/auth' and is the route to redirect to if not authenticated.
  /// The [loadingWidget] is optional and will be shown while authentication state is being checked.
  const AuthRoute({
    Key? key,
    required this.child,
    this.authRoute = '/auth',
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // If still initializing, show loading indicator
        if (!authProvider.initialized) {
          return loadingWidget ?? const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        // If not authenticated, redirect to auth route
        if (!authProvider.isAuthenticated) {
          // Use a post-frame callback to avoid build-time navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(authRoute);
          });
          
          // Return an empty container while redirecting
          return Container();
        }
        
        // If authenticated, show the child widget
        return child;
      },
    );
  }
}

/// A builder function for creating auth-protected routes
typedef AuthRouteBuilder = Widget Function(BuildContext context);

/// A convenience extension for NavigatorState to simplify auth-protected navigation
extension AuthNavigator on NavigatorState {
  /// Navigate to a route that requires authentication
  ///
  /// If the user is not authenticated, they will be redirected to the auth screen.
  /// Returns true if navigation was successful, false if redirected to auth.
  Future<bool> pushProtectedNamed(String routeName, {Object? arguments}) async {
    final context = overlay!.context; // Get current context from overlay
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (await authProvider.checkAuthenticated()) {
      pushNamed(routeName, arguments: arguments);
      return true;
    } else {
      pushReplacementNamed('/auth');
      return false;
    }
  }
}