import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skincare_scanner/providers/user_provider.dart';
import 'package:skincare_scanner/utils/analytics_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _skinType = 'normal';
  List<String> _skinConcerns = [];
  List<String> _allergies = [];
  List<String> _avoidIngredients = [];
  List<String> _preferredBrands = [];
  bool _isLoading = false;
  
  // Lists for selection options
  final List<String> _skinTypes = ['normal', 'dry', 'oily', 'combination', 'sensitive'];
  final List<String> _skinConcernOptions = [
    'acne', 'redness', 'dryness', 'aging', 'hyperpigmentation', 
    'uneven tone', 'large pores', 'sun damage', 'dullness'
  ];
  final List<String> _commonAllergies = [
    'fragrance', 'alcohol', 'sulfates', 'parabens', 'essential oils',
    'lanolin', 'formaldehyde', 'propylene glycol', 'nickel'
  ];
  
  final TextEditingController _avoidIngredientsController = TextEditingController();
  final TextEditingController _preferredBrandsController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    
    // Log screen view
    AnalyticsService.logScreenView('SettingsScreen', 'SettingsScreen');
  }
  
  @override
  void dispose() {
    _avoidIngredientsController.dispose();
    _preferredBrandsController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserPreferences() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final preferences = userProvider.preferences;
      
      if (preferences != null) {
        setState(() {
          _skinType = preferences.skinType;
          _skinConcerns = List<String>.from(preferences.skinConcerns);
          _allergies = List<String>.from(preferences.allergies);
          _avoidIngredients = preferences.avoidIngredients != null ? List<String>.from(preferences.avoidIngredients!) : [];
          _preferredBrands = preferences.preferredBrands != null ? List<String>.from(preferences.preferredBrands!) : [];
          
          _avoidIngredientsController.text = _avoidIngredients.join(', ');
          _preferredBrandsController.text = _preferredBrands.join(', ');
        });
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveUserPreferences() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final preferences = UserPreferences(
        skinType: _skinType,
        skinConcerns: _skinConcerns,
        allergies: _allergies,
        avoidIngredients: _avoidIngredients,
        preferredBrands: _preferredBrands,
      );
      
      await userProvider.setPreferences(preferences);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved')),
        );
      }
    } catch (e) {
      debugPrint('Error saving preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skin Profile section
                  const Text(
                    'Skin Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Skin type
                  const Text(
                    'Skin Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSkinTypeDropdown(),
                  const SizedBox(height: 16),
                  
                  // Skin concerns
                  const Text(
                    'Skin Concerns',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSkinConcernsChips(),
                  const SizedBox(height: 16),
                  
                  // Allergies
                  const Text(
                    'Allergies',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildAllergiesChips(),
                  const SizedBox(height: 16),
                  
                  // Avoid ingredients
                  const Text(
                    'Ingredients to Avoid',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _avoidIngredientsController,
                    decoration: const InputDecoration(
                      hintText: 'Enter ingredients, separated by commas',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _avoidIngredients = value.split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Preferred brands
                  const Text(
                    'Preferred Brands',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _preferredBrandsController,
                    decoration: const InputDecoration(
                      hintText: 'Enter brands, separated by commas',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _preferredBrands = value.split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // App Settings section
                  const Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Notification settings
                  ListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Manage notification preferences'),
                    leading: const Icon(Icons.notifications),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to notification settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification settings would be implemented here')),
                      );
                    },
                  ),
                  
                  // Data & privacy
                  ListTile(
                    title: const Text('Data & Privacy'),
                    subtitle: const Text('Manage your data and privacy settings'),
                    leading: const Icon(Icons.privacy_tip),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to data & privacy settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data & privacy settings would be implemented here')),
                      );
                    },
                  ),
                  
                  // Account settings
                  ListTile(
                    title: const Text('Account Settings'),
                    subtitle: const Text('Manage your account'),
                    leading: const Icon(Icons.account_circle),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to account settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account settings would be implemented here')),
                      );
                    },
                  ),
                  
                  // About
                  ListTile(
                    title: const Text('About'),
                    subtitle: const Text('App information and version'),
                    leading: const Icon(Icons.info),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Show about dialog
                      showAboutDialog(
                        context: context,
                        applicationName: 'Skincare Scanner',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2023 Skincare Scanner App',
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveUserPreferences,
                      child: const Text('Save Changes'),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Reset button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _loadUserPreferences,
                      child: const Text('Reset Changes'),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
  
  // Build skin type dropdown
  Widget _buildSkinTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _skinType,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: _skinTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(_capitalizeFirstLetter(type)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _skinType = value;
          });
        }
      },
    );
  }
  
  // Build skin concerns chips
  Widget _buildSkinConcernsChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _skinConcernOptions.map((concern) {
        final isSelected = _skinConcerns.contains(concern);
        
        return FilterChip(
          label: Text(_capitalizeFirstLetter(concern)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _skinConcerns.add(concern);
              } else {
                _skinConcerns.remove(concern);
              }
            });
          },
        );
      }).toList(),
    );
  }
  
  // Build allergies chips
  Widget _buildAllergiesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _commonAllergies.map((allergy) {
        final isSelected = _allergies.contains(allergy);
        
        return FilterChip(
          label: Text(_capitalizeFirstLetter(allergy)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _allergies.add(allergy);
              } else {
                _allergies.remove(allergy);
              }
            });
          },
        );
      }).toList(),
    );
  }
  
  // Helper method to capitalize first letter
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}