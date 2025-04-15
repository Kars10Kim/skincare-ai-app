import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../providers/camera_provider.dart';
import '../../services/encryption_service.dart';
import '../../utils/accessibility.dart';
import '../../utils/animations.dart';
import '../../utils/memory_management.dart';
import '../../utils/secure_storage.dart';
import '../../utils/ui_performance.dart';
import '../../widgets/animated_components.dart';
import '../../widgets/loading/loading_state_widget.dart';
import '../../widgets/skincare_icons.dart';

/// Onboarding skin type options
enum SkinType {
  /// Normal skin
  normal,
  
  /// Oily skin
  oily,
  
  /// Dry skin
  dry,
  
  /// Combination skin
  combination,
  
  /// Sensitive skin
  sensitive,
}

/// Onboarding skin concerns
enum SkinConcern {
  /// Acne skin concern
  acne,
  
  /// Wrinkles skin concern
  wrinkles,
  
  /// Dark spots skin concern
  darkSpots,
  
  /// Dryness skin concern
  dryness,
  
  /// Redness skin concern
  redness,
  
  /// Sensitivity skin concern
  sensitivity,
}

/// Onboarding screen shown to new users
class OnboardingScreen extends StatefulWidget {
  /// Create onboarding screen
  const OnboardingScreen({Key? key}) : super(key: key);
  
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin, AutoDisposeMixin, AccessibilitySupport {
  /// Current page index
  int _currentPage = 0;
  
  /// Page controller
  late final PageController _pageController;
  
  /// Animation controller for transitions
  late final AnimationController _animationController;
  
  /// Selected skin type
  SkinType? _selectedSkinType;
  
  /// Selected skin concerns
  final Set<SkinConcern> _selectedConcerns = {};
  
  /// Sensitive ingredients
  final List<String> _sensitiveIngredients = [];
  
  /// New ingredient text controller
  final TextEditingController _ingredientController = TextEditingController();
  
  /// Whether user data is being saved
  bool _isSaving = false;
  
  /// Secure preferences
  late final SecurePreferences _securePreferences;
  
  /// Encryption service
  late final EncryptionService _encryptionService;
  
  @override
  void initState() {
    super.initState();
    
    // Track performance
    UIPerformance.startMeasure('OnboardingScreen');
    
    // Initialize controllers
    _pageController = PageController();
    addDisposable(_pageController);
    
    _animationController = AnimationController(
      vsync: this,
      duration: AnimationDurations.medium,
    );
    addDisposable(_animationController);
    
    addDisposable(_ingredientController);
    
    // Initialize services
    _initServices();
  }
  
  /// Initialize services
  Future<void> _initServices() async {
    try {
      _encryptionService = EncryptionService();
      await _encryptionService.initialize();
      
      _securePreferences = SecurePreferences(
        encryptionService: _encryptionService,
      );
      
      // Check if user has completed onboarding before
      final hasCompletedOnboarding = await _securePreferences.getBool('onboarding_completed');
      
      if (hasCompletedOnboarding) {
        // Load user preferences
        await _loadUserPreferences();
        
        // If onboarding was completed, skip to camera screen
        if (mounted) {
          _navigateToCamera();
        }
      }
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }
  
  /// Load user preferences
  Future<void> _loadUserPreferences() async {
    try {
      // Get skin type
      final skinTypeStr = await _securePreferences.getString('skin_type');
      if (skinTypeStr != null) {
        _selectedSkinType = SkinType.values.firstWhere(
          (type) => type.toString() == skinTypeStr,
          orElse: () => SkinType.normal,
        );
      }
      
      // Get skin concerns
      final concernsObj = await _securePreferences.getObject('skin_concerns');
      if (concernsObj != null) {
        final concerns = List<String>.from(concernsObj['concerns'] ?? []);
        _selectedConcerns.clear();
        for (final concern in concerns) {
          final skinConcern = SkinConcern.values.firstWhere(
            (c) => c.toString() == concern,
            orElse: () => SkinConcern.acne,
          );
          _selectedConcerns.add(skinConcern);
        }
      }
      
      // Get sensitive ingredients
      final ingredientsObj = await _securePreferences.getObject('sensitive_ingredients');
      if (ingredientsObj != null) {
        _sensitiveIngredients.clear();
        _sensitiveIngredients.addAll(
          List<String>.from(ingredientsObj['ingredients'] ?? []),
        );
      }
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
    }
  }
  
  /// Navigate to home screen
  void _navigateToCamera() {
    Navigator.of(context).pushReplacementNamed('/home');
  }
  
  /// Go to next page
  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: AnimationDurations.medium,
        curve: AnimationCurves.standard,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  /// Go to previous page
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AnimationDurations.medium,
        curve: AnimationCurves.standard,
      );
    }
  }
  
  /// Complete onboarding
  Future<void> _completeOnboarding() async {
    setState(() {
      _isSaving = true;
    });
    
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        // Check connectivity
        final connectivityService = ConnectivityService();
        final isConnected = await connectivityService.checkConnectivity();
        
        // Save skin type
        if (_selectedSkinType != null) {
          await _securePreferences.setString(
            'skin_type',
            _selectedSkinType.toString(),
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('Saving preferences timed out'),
          );
        }
      
      // Save skin concerns
      final concerns = _selectedConcerns.map((c) => c.toString()).toList();
      await _securePreferences.setObject(
        'skin_concerns',
        {'concerns': concerns},
      );
      
      // Save sensitive ingredients
      await _securePreferences.setObject(
        'sensitive_ingredients',
        {'ingredients': _sensitiveIngredients},
      );
      
      // Mark onboarding as completed
      await _securePreferences.setBool('onboarding_completed', true);
      
      // Navigate to camera screen
      if (mounted) {
        _navigateToCamera();
      }
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
      retryCount++;
      
      if (mounted) {
        if (retryCount < maxRetries) {
          // Show retry dialog
          final shouldRetry = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context).errorSavingPreferences),
              content: Text('${AppLocalizations.of(context).errorRetryMessage} ($retryCount/$maxRetries)'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppLocalizations.of(context).buttonCancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(AppLocalizations.of(context).buttonRetry),
                ),
              ],
            ),
          ) ?? false;
          
          if (shouldRetry) {
            continue;
          }
        }
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorSavingPreferences),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: AppLocalizations.of(context).buttonTryAgain,
              onPressed: _completeOnboarding,
            ),
          ),
        );
      }
      break;
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  
  /// Add sensitive ingredient
  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty && !_sensitiveIngredients.contains(ingredient)) {
      setState(() {
        _sensitiveIngredients.add(ingredient);
        _ingredientController.clear();
      });
    }
  }
  
  /// Remove sensitive ingredient
  void _removeIngredient(String ingredient) {
    setState(() {
      _sensitiveIngredients.remove(ingredient);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return WillPopScope(
      onWillPop: () async {
        if (_currentPage > 0) {
          _previousPage();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: LoadingStateWidget(
        isLoading: _isSaving,
        message: localizations.loading,
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) / 4,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              
              // Pages
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0 && _currentPage > 0) {
                      _previousPage();
                    } else if (details.primaryVelocity! < 0 && _currentPage < 3) {
                      _nextPage();
                    }
                  },
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    
                    _animationController.forward(from: 0);
                  },
                  children: [
                    _buildWelcomePage(context, localizations, theme),
                    _buildSkinTypePage(context, localizations, theme),
                    _buildSkinConcernsPage(context, localizations, theme),
                    _buildSensitiveIngredientsPage(context, localizations, theme),
                  ],
                ),
              ),
              
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: _isSaving ? null : _previousPage,
                        child: Text(localizations.buttonBack),
                      )
                    else
                      const SizedBox.shrink(),
                    
                    // Next button
                    ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : _canProceed()
                              ? _nextPage
                              : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage < 3
                            ? localizations.buttonNext
                            : localizations.buttonDone,
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
  
  /// Build welcome page
  Widget _buildWelcomePage(
    BuildContext context,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return AccessibleFadeTransition(
      opacity: _animationController.drive(
        Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: AnimationCurves.standard),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated welcome illustration
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: SkincareIcons.buildWelcomeAnimation(
                    context,
                    theme.colorScheme.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            
            // Title with glass effect
            GlassmorphicCard(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
              borderColor: theme.colorScheme.primary.withOpacity(0.1),
              blur: 0,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Text(
                localizations.onboardingWelcome,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            
            // Animated description text appearance
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  localizations.onboardingDescription,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            // Visual feature highlights
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFeatureItem(
                  context, 
                  Icons.camera_alt, 
                  localizations.scan, 
                  theme.colorScheme.primary
                ),
                _buildFeatureItem(
                  context, 
                  Icons.science, 
                  localizations.analyze, 
                  theme.colorScheme.secondary
                ),
                _buildFeatureItem(
                  context, 
                  Icons.shield, 
                  localizations.protect, 
                  theme.colorScheme.tertiary
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build feature item with animation
  Widget _buildFeatureItem(
    BuildContext context, 
    IconData icon, 
    String label, 
    Color color
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build skin type page
  Widget _buildSkinTypePage(
    BuildContext context,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return AccessibleFadeTransition(
      opacity: _animationController.drive(
        Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: AnimationCurves.standard),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              localizations.onboardingSkinType,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Skin type options
            _buildSkinTypeOption(
              context,
              localizations.onboardingSkinTypeNormal,
              SkinType.normal,
              theme,
            ),
            _buildSkinTypeOption(
              context,
              localizations.onboardingSkinTypeOily,
              SkinType.oily,
              theme,
            ),
            _buildSkinTypeOption(
              context,
              localizations.onboardingSkinTypeDry,
              SkinType.dry,
              theme,
            ),
            _buildSkinTypeOption(
              context,
              localizations.onboardingSkinTypeCombination,
              SkinType.combination,
              theme,
            ),
            _buildSkinTypeOption(
              context,
              localizations.onboardingSkinTypeSensitive,
              SkinType.sensitive,
              theme,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build skin type option
  Widget _buildSkinTypeOption(
    BuildContext context,
    String title,
    SkinType type,
    ThemeData theme,
  ) {
    final isSelected = _selectedSkinType == type;
    final primaryColor = theme.colorScheme.primary;
    final typeString = type.toString().split('.').last;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedSelectionCard(
        isSelected: isSelected,
        selectedColor: primaryColor,
        unselectedColor: Colors.grey.shade300,
        onTap: () {
          setState(() {
            _selectedSkinType = type;
          });
          // Add haptic feedback
          HapticFeedback.selectionClick();
        },
        child: Row(
          children: [
            // Skin type icon
            SkincareIcons.buildSkinTypeIcon(
              typeString,
              isSelected ? primaryColor : Colors.grey.shade500,
              48,
            ),
            const SizedBox(width: 16),
            
            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? primaryColor : theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSkinTypeDescription(type, localizations),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Animated selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Get skin type description
  String _getSkinTypeDescription(SkinType type, AppLocalizations localizations) {
    switch (type) {
      case SkinType.normal:
        return localizations.skinTypeNormalDescription ?? 'Balanced, not too oily or dry';
      case SkinType.oily:
        return localizations.skinTypeOilyDescription ?? 'Excess oil, especially in T-zone';
      case SkinType.dry:
        return localizations.skinTypeDryDescription ?? 'Feels tight, can be flaky';
      case SkinType.combination:
        return localizations.skinTypeCombinationDescription ?? 'Oily T-zone, dry cheeks';
      case SkinType.sensitive:
        return localizations.skinTypeSensitiveDescription ?? 'Reacts easily to products';
    }
  }
  
  /// Build skin concerns page
  Widget _buildSkinConcernsPage(
    BuildContext context,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return AccessibleFadeTransition(
      opacity: _animationController.drive(
        Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: AnimationCurves.standard),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              localizations.onboardingSkinConcerns,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              'Select all that apply',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Skin concerns grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildSkinConcernOption(
                  context,
                  localizations.onboardingSkinConcernAcne,
                  SkinConcern.acne,
                  theme,
                ),
                _buildSkinConcernOption(
                  context,
                  localizations.onboardingSkinConcernWrinkles,
                  SkinConcern.wrinkles,
                  theme,
                ),
                _buildSkinConcernOption(
                  context,
                  localizations.onboardingSkinConcernDarkSpots,
                  SkinConcern.darkSpots,
                  theme,
                ),
                _buildSkinConcernOption(
                  context,
                  localizations.onboardingSkinConcernDryness,
                  SkinConcern.dryness,
                  theme,
                ),
                _buildSkinConcernOption(
                  context,
                  localizations.onboardingSkinConcernRedness,
                  SkinConcern.redness,
                  theme,
                ),
                _buildSkinConcernOption(
                  context,
                  localizations.onboardingSkinConcernSensitivity,
                  SkinConcern.sensitivity,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build skin concern option
  Widget _buildSkinConcernOption(
    BuildContext context,
    String title,
    SkinConcern concern,
    ThemeData theme,
  ) {
    final isSelected = _selectedConcerns.contains(concern);
    final primaryColor = theme.colorScheme.primary;
    final concernString = concern.toString().split('.').last;
    
    return AnimatedScale(
      scale: isSelected ? 1.03 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedConcerns.remove(concern);
                } else {
                  _selectedConcerns.add(concern);
                }
              });
              // Add haptic feedback
              HapticFeedback.selectionClick();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Row(
                children: [
                  // Concern icon
                  SkincareIcons.buildSkinConcernIcon(
                    concernString,
                    primaryColor,
                    36,
                    isSelected,
                  ),
                  const SizedBox(width: 8),
                  
                  // Title
                  Flexible(
                    child: Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? primaryColor : theme.textTheme.bodyMedium?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Animated checkbox
                  const SizedBox(width: 4),
                  AnimatedCheckbox(
                    isChecked: isSelected,
                    activeColor: primaryColor,
                    inactiveColor: Colors.grey.shade400,
                    size: 20,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedConcerns.remove(concern);
                        } else {
                          _selectedConcerns.add(concern);
                        }
                      });
                      // Add haptic feedback
                      HapticFeedback.selectionClick();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build sensitive ingredients page
  Widget _buildSensitiveIngredientsPage(
    BuildContext context,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    final primaryColor = theme.colorScheme.primary;
    
    return AccessibleFadeTransition(
      opacity: _animationController.drive(
        Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: AnimationCurves.standard),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and illustration
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.onboardingIngredientsSensitive,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Description
                      Text(
                        'Add ingredients that cause skin reactions',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Ingredient icon
                SkincareIcons.buildIngredientIcon(primaryColor, 64),
              ],
            ),
            const SizedBox(height: 24),
            
            // Visual instruction
            GlassmorphicCard(
              backgroundColor: Colors.white.withOpacity(0.7),
              borderColor: primaryColor.withOpacity(0.2),
              blur: 0,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'These ingredients will be flagged when found in scanned products',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Add ingredient field with animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _ingredientController,
                        decoration: InputDecoration(
                          hintText: 'Enter ingredient name',
                          prefixIcon: Icon(Icons.science_outlined, color: primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addIngredient(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(56, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Sensitive ingredients list
            if (_sensitiveIngredients.isEmpty)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.science_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No ingredients added yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sensitiveIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = _sensitiveIngredients[index];
                      
                      // Staggered animation
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final delay = index * 0.2;
                          final slideAnimation = Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                delay.clamp(0.0, 0.8),
                                (delay + 0.2).clamp(0.0, 1.0),
                                curve: Curves.easeOut,
                              ),
                            ),
                          );
                          
                          return SlideTransition(
                            position: slideAnimation,
                            child: child,
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            bottom: index < _sensitiveIngredients.length - 1 ? 1 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? primaryColor.withOpacity(0.05)
                                : Colors.white,
                          ),
                          child: ListTile(
                            leading: SkincareIcons.buildIngredientIcon(
                              primaryColor,
                              36,
                            ),
                            title: Text(
                              ingredient,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removeIngredient(ingredient),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red.shade700,
                                shape: const CircleBorder(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// Check if user can proceed to next page
  bool _canProceed() {
    if (_currentPage == 1 && _selectedSkinType == null) {
      return false;
    }
    
    return true;
  }
  
  @override
  void dispose() {
    UIPerformance.endMeasure('OnboardingScreen');
    super.dispose();
  }
}