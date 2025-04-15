import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/route_guard.dart';
import '../../widgets/card_container.dart';

/// Profile screen showing user information and settings
class ProfileScreen extends StatefulWidget {
  /// Creates a profile screen
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State variables for skin preferences
  String _selectedSkinType = 'Normal';
  final List<String> _selectedSkinConcerns = [];
  final List<String> _selectedIngredientAllergies = [];

  // Available options
  final List<String> _skinTypes = [
    'Normal',
    'Dry',
    'Oily',
    'Combination',
    'Sensitive',
  ];

  final List<String> _skinConcerns = [
    'Acne',
    'Aging',
    'Dullness',
    'Hyperpigmentation',
    'Redness',
    'Uneven Texture',
  ];

  final List<String> _commonAllergens = [
    'Alcohol',
    'Fragrance',
    'Formaldehyde',
    'Parabens',
    'Sulfates',
    'Essential Oils',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  /// Load user preferences from server or local storage
  Future<void> _loadUserPreferences() async {
    // Here you would load user preferences from the server
    // For now we'll just use some defaults
    setState(() {
      _selectedSkinType = 'Combination';
      _selectedSkinConcerns = ['Acne', 'Hyperpigmentation'];
      _selectedIngredientAllergies = ['Fragrance'];
    });
  }

  /// Save user preferences
  Future<void> _saveUserPreferences() async {
    // Here you would save the preferences to the server
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Redirect to auth screen if not authenticated
    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please sign in to view your profile',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await RouteGuard.navigateTo(context, '/auth');
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('SIGN OUT'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) {
                await authProvider.signOut(
                  onSignOut: () {
                    RouteGuard.navigateToReplacement(context, '/auth');
                  },
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info card
          CardContainer(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryLightColor,
                    child: Text(
                      authProvider.currentUser!.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Username
                  Text(
                    authProvider.currentUser!.username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    authProvider.currentUser!.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Member since
                  Text(
                    'Member since: ${_formatDate(authProvider.currentUser!.createdAt)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Skin profile section
          const Text(
            'Skin Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Skin type
          CardContainer(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Skin Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: _skinTypes.map((type) =>
                      ChoiceChip(
                        label: Text(type),
                        selected: _selectedSkinType == type,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedSkinType = type;
                            });
                          }
                        },
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Skin concerns
          CardContainer(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Skin Concerns',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select all that apply',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: _skinConcerns.map((concern) =>
                      FilterChip(
                        label: Text(concern),
                        selected: _selectedSkinConcerns.contains(concern),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSkinConcerns.add(concern);
                            } else {
                              _selectedSkinConcerns.remove(concern);
                            }
                          });
                        },
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Ingredient allergies/sensitivities
          CardContainer(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingredient Allergies/Sensitivities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select all that apply',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: _commonAllergens.map((allergen) =>
                      FilterChip(
                        label: Text(allergen),
                        selected: _selectedIngredientAllergies.contains(allergen),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedIngredientAllergies.add(allergen);
                            } else {
                              _selectedIngredientAllergies.remove(allergen);
                            }
                          });
                        },
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Save button
          ElevatedButton(
            onPressed: _saveUserPreferences,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('SAVE PREFERENCES'),
          ),

          const SizedBox(height: 24),

          // App settings section
          const Text(
            'App Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Settings options
          CardContainer(
            child: Column(
              children: [
                _buildSettingsItem(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () {
                    // Open language settings
                  },
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'On',
                  onTap: () {
                    // Open notification settings
                  },
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.delete_outline,
                  title: 'Clear Scan History',
                  subtitle: 'Delete all scan records',
                  onTap: () {
                    // Show confirmation dialog for clearing history
                  },
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'FAQs, contact us',
                  onTap: () {
                    // Open help and support
                  },
                ),
                _buildDivider(),
                _buildSettingsItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'Version ${AppConstants.appVersion}',
                  onTap: () {
                    // Open about screen
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Build a divider line
  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  /// Build a settings item with icon, title, and subtitle
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  /// Format a date for display
  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}