import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skincare_scanner/providers/user_provider.dart';
import 'package:skincare_scanner/utils/analytics_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class OnboardingState {
  String skinType;
  List<String> concerns;
  List<String> allergies;
  List<String> avoidIngredients;
  List<String> preferredBrands;
  bool isValid;

  OnboardingState({
    this.skinType = 'normal',
    List<String>? concerns,
    List<String>? allergies,
    List<String>? avoidIngredients,
    List<String>? preferredBrands,
    this.isValid = false,
  })  : concerns = concerns ?? [],
        allergies = allergies ?? [],
        avoidIngredients = avoidIngredients ?? [],
        preferredBrands = preferredBrands ?? [];
        
  bool validateStep(int step) {
    switch (step) {
      case 0:
        return true; // Welcome page
      case 1:
        return skinType.isNotEmpty;
      case 2:
        return true; // Concerns are optional
      case 3:
        return true; // Allergies are optional
      default:
        return false;
    }
  }
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;
  late OnboardingState _state;
  
  // Lists for selection options
  final List<String> _skinTypes = ['normal', 'dry', 'oily', 'combination', 'sensitive'];
  final List<String> _skinConcerns = [
    'acne', 'redness', 'dryness', 'aging', 'hyperpigmentation', 
    'uneven tone', 'large pores', 'sun damage', 'dullness'
  ];
  final List<String> _commonAllergies = [
    'fragrance', 'alcohol', 'sulfates', 'parabens', 'essential oils',
    'lanolin', 'formaldehyde', 'propylene glycol', 'nickel'
  ];
  
  @override
  void initState() {
    super.initState();
    _state = OnboardingState();
    AnalyticsService.logScreenView('OnboardingScreen', 'OnboardingScreen');
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Skip'),
              ),
            ),
            
            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildSkinTypePage(),
                  _buildSkinConcernsPage(),
                  _buildAllergiesPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (hidden on first page)
                  _currentPage > 0
                      ? TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Back'),
                        )
                      : const SizedBox.shrink(),
                  
                  // Next or Finish button
                  ElevatedButton(
                    onPressed: _currentPage < _totalPages - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : _completeOnboarding,
                    child: Text(_currentPage < _totalPages - 1 ? 'Next' : 'Finish'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Welcome page
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.spa,
            size: 80,
            color: Colors.teal,
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to Skincare Scanner',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Let\'s help you personalize your experience by setting up your skin profile.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            'In the next steps, we\'ll ask you about your skin type, concerns, and allergies to provide personalized recommendations.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Skin type page
  Widget _buildSkinTypePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s Your Skin Type?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select the option that best describes your skin most of the time.',
          ),
          const SizedBox(height: 24),
          
          // Skin type options
          ...List.generate(_skinTypes.length, (index) {
            final skinType = _skinTypes[index];
            final isSelected = _selectedSkinType == skinType;
            
            return _buildSelectionCard(
              title: _capitalizeFirstLetter(skinType),
              description: _getSkinTypeDescription(skinType),
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedSkinType = skinType;
                });
              },
            );
          }),
        ],
      ),
    );
  }
  
  // Skin concerns page
  Widget _buildSkinConcernsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What Are Your Skin Concerns?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select all that apply.',
          ),
          const SizedBox(height: 24),
          
          // Skin concerns options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skinConcerns.map((concern) {
              final isSelected = _selectedSkinConcerns.contains(concern);
              
              return FilterChip(
                label: Text(_capitalizeFirstLetter(concern)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSkinConcerns.add(concern);
                    } else {
                      _selectedSkinConcerns.remove(concern);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Avoid ingredients section
          Text(
            'Any Ingredients You Want to Avoid?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Enter ingredients, separated by commas',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _avoidIngredients.clear();
                if (value.isNotEmpty) {
                  _avoidIngredients.addAll(
                    value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
                  );
                }
              });
            },
          ),
          
          const SizedBox(height: 32),
          
          // Preferred brands section
          Text(
            'Any Preferred Brands?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Enter brands, separated by commas',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _preferredBrands.clear();
                if (value.isNotEmpty) {
                  _preferredBrands.addAll(
                    value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }
  
  // Allergies page
  Widget _buildAllergiesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Do You Have Any Allergies?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select all that apply.',
          ),
          const SizedBox(height: 24),
          
          // Common allergies options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonAllergies.map((allergy) {
              final isSelected = _selectedAllergies.contains(allergy);
              
              return FilterChip(
                label: Text(_capitalizeFirstLetter(allergy)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAllergies.add(allergy);
                    } else {
                      _selectedAllergies.remove(allergy);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Additional allergies section
          Text(
            'Any Other Allergies?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Enter allergies, separated by commas',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final additionalAllergies = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              
              setState(() {
                // Remove any additional allergies first (keeping the common selected ones)
                _selectedAllergies.removeWhere((allergy) => !_commonAllergies.contains(allergy));
                
                // Add the new additional allergies
                _selectedAllergies.addAll(additionalAllergies);
              });
            },
          ),
          
          const SizedBox(height: 32),
          
          // Completion information
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.teal),
                  SizedBox(height: 8),
                  Text(
                    'You can always update these preferences later in the app settings.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }
  
  // Selection card for skin type
  Widget _buildSelectionCard({
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onTap(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to capitalize first letter
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  // Helper method to get skin type description
  String _getSkinTypeDescription(String skinType) {
    switch (skinType) {
      case 'normal':
        return 'Balanced skin with no excessive oiliness or dryness';
      case 'dry':
        return 'Skin that often feels tight or rough and may be flaky';
      case 'oily':
        return 'Shiny skin with enlarged pores and prone to acne';
      case 'combination':
        return 'Oily in the T-zone (forehead, nose, chin) but dry elsewhere';
      case 'sensitive':
        return 'Easily irritated skin that may react to many products';
      default:
        return '';
    }
  }
  
  // Complete onboarding and save preferences
  Future<void> _completeOnboarding() async {
    if (!_state.validateStep(_currentPage)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Create user preferences
    final userPreferences = UserPreferences(
      skinType: _state.skinType,
      skinConcerns: _state.concerns,
      allergies: _state.allergies,
      preferredBrands: _state.preferredBrands,
      avoidIngredients: _state.avoidIngredients,
    );
    
    // Save preferences
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.setPreferences(userPreferences);
    await userProvider.setOnboardingComplete(true);
    
    // Log analytics event
    AnalyticsService.logEvent('onboarding_completed', {
      'skin_type': _selectedSkinType,
      'concerns_count': _selectedSkinConcerns.length,
      'allergies_count': _selectedAllergies.length,
    });
    
    // Navigate to home screen
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}