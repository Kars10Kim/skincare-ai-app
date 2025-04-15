import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/route_guard.dart';
import '../camera/camera_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';

/// The main home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  /// Creates a home screen
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // List of screens to display based on bottom navigation selection
  late final List<Widget> _screens = [
    const CameraScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0), // Add padding to avoid overlap with bottom nav bar
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/recognition');
          },
          icon: const Icon(Icons.document_scanner),
          label: const Text('Recognize'),
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          elevation: 4.0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) async {
              // If profile tab selected and user is not authenticated, 
              // show auth screen instead
              if (index == 2 && !authProvider.isAuthenticated) {
                await RouteGuard.navigateTo(context, '/auth');
                return;
              }
              
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Theme.of(context).cardColor,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_outlined),
                activeIcon: Icon(Icons.camera_alt),
                label: 'Scan',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                activeIcon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: authProvider.isAuthenticated
                    ? const Icon(Icons.person_outline)
                    : const Icon(Icons.login_outlined),
                activeIcon: authProvider.isAuthenticated
                    ? const Icon(Icons.person)
                    : const Icon(Icons.login),
                label: authProvider.isAuthenticated ? 'Profile' : 'Sign In',
              ),
            ],
          ),
        ),
      ),
    );
  }
}