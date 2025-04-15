import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences_model.dart';
import '../../providers/database_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/onboarding/survey_option_card.dart';

/// Screen for the onboarding skin type and concerns survey
class SkinSurveyScreen extends StatefulWidget {
  const SkinSurveyScreen({Key? key}) : super(key: key);

  @override
  State<SkinSurveyScreen> createState() => _SkinSurveyScreenState();
}

class _SkinSurveyScreenState extends State<SkinSurveyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  
  // Survey answers
  String? _selectedSkinType;
  final List<String> _selectedConcerns = [];
  String? _selectedGoal;
  
  // Page titles and subtitles
  final List<Map<String, String>> _pageData = [
    {
      'title': 'What\'s your skin type?',
      'subtitle': 'This helps us understand your skin\'s natural balance.',
    },
    {
      'title': 'What skin concerns do you have?',
      'subtitle': 'Select all that apply to you.',
    },
    {
      'title': 'What\'s your main skincare goal?',
      'subtitle': 'This helps us prioritize recommendations for you.',
    },
  ];
  
  // Skincare goals
  final List<Map<String, dynamic>> _goals = [
    {
      'name': 'Anti-Aging',
      'icon': Icons.timelapse,
      'description': 'Reduce fine lines and improve firmness',
    },
    {
      'name': 'Brightening',
      'icon': Icons.wb_sunny,
      'description': 'Even skin tone and reduce dark spots',
    },
    {
      'name': 'Acne Control',
      'icon': Icons.healing,
      'description': 'Clear breakouts and prevent new ones',
    },
    {
      'name': 'Hydration',
      'icon': Icons.water_drop,
      'description': 'Boost moisture levels and prevent dryness',
    },
    {
      'name': 'Oil Control',
      'icon': Icons.opacity,
      'description': 'Reduce excess oil and shine',
    },
    {
      'name': 'Soothing',
      'icon': Icons.spa,
      'description': 'Calm irritation and reduce redness',
    },
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // Navigate to the next page
  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishSurvey();
    }
  }
  
  // Navigate to the previous page
  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
  
  // Check if the current page has valid input
  bool _isCurrentPageValid() {
    switch (_currentPage) {
      case 0:
        return _selectedSkinType != null;
      case 1:
        return _selectedConcerns.isNotEmpty;
      case 2:
        return _selectedGoal != null;
      default:
        return false;
    }
  }
  
  // Save user preferences and finish the survey
  Future<void> _finishSurvey() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create user preferences object
      final userPreferences = UserPreferences(
        skinType: _selectedSkinType!,
        concerns: _selectedConcerns,
        primaryGoal: _selectedGoal!,
        onboardingCompleted: true,
      );
      
      // Save to storage
      final repository = Provider.of<DatabaseProvider>(context, listen: false).scanRepository;
      await repository.saveUserPreferences(userPreferences);
      
      setState(() {
        _isLoading = false;
      });
      
      // Navigate back to previous screen or main app
      Navigator.of(context).pop(userPreferences);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save preferences: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Saving your preferences...'),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress indicator
                    LinearProgressIndicator(
                      value: (_currentPage + 1) / 3,
                      backgroundColor: Colors.grey[200],
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 24),
                    
                    // Page content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          // Page 1: Skin Type
                          _buildSkinTypePage(),
                          
                          // Page 2: Skin Concerns
                          _buildSkinConcernsPage(),
                          
                          // Page 3: Skincare Goals
                          _buildSkincareGoalsPage(),
                        ],
                      ),
                    ),
                    
                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _currentPage > 0
                            ? TextButton.icon(
                                onPressed: _previousPage,
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Back'),
                              )
                            : const SizedBox(width: 100),
                        ElevatedButton(
                          onPressed: _isCurrentPageValid() ? _nextPage : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: Text(_currentPage < 2 ? 'Next' : 'Finish'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
  
  Widget _buildSkinTypePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _pageData[0]['title']!,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _pageData[0]['subtitle']!,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: AppConstants.skinTypes.length,
            itemBuilder: (context, index) {
              final skinType = AppConstants.skinTypes[index];
              return SurveyOptionCard(
                title: skinType,
                description: _getSkinTypeDescription(skinType),
                isSelected: _selectedSkinType == skinType,
                onTap: () {
                  setState(() {
                    _selectedSkinType = skinType;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildSkinConcernsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _pageData[1]['title']!,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _pageData[1]['subtitle']!,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: AppConstants.skinConcerns.length,
            itemBuilder: (context, index) {
              final concern = AppConstants.skinConcerns[index];
              return SurveyOptionCard(
                title: concern,
                description: '',
                isSelected: _selectedConcerns.contains(concern),
                isMultiSelect: true,
                onTap: () {
                  setState(() {
                    if (_selectedConcerns.contains(concern)) {
                      _selectedConcerns.remove(concern);
                    } else {
                      _selectedConcerns.add(concern);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildSkincareGoalsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _pageData[2]['title']!,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _pageData[2]['subtitle']!,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _goals.length,
            itemBuilder: (context, index) {
              final goal = _goals[index];
              return Card(
                elevation: _selectedGoal == goal['name'] ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _selectedGoal == goal['name']
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedGoal = goal['name'];
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          goal['icon'],
                          size: 40,
                          color: _selectedGoal == goal['name']
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          goal['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedGoal == goal['name']
                                ? Theme.of(context).primaryColor
                                : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          goal['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  String _getSkinTypeDescription(String skinType) {
    switch (skinType) {
      case 'Normal':
        return 'Not too oily or dry, few imperfections';
      case 'Dry':
        return 'Tight, flaky, or rough texture';
      case 'Oily':
        return 'Shiny appearance, enlarged pores';
      case 'Combination':
        return 'Oily T-zone, dry cheeks';
      case 'Sensitive':
        return 'Easily irritated, prone to redness';
      default:
        return '';
    }
  }
}