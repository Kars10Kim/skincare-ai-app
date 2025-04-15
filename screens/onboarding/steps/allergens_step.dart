import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/onboarding_model.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/onboarding/onboarding_card.dart';
import '../../../widgets/onboarding/onboarding_step_widget.dart';

/// Allergens selection step in the onboarding process
class AllergensStep extends OnboardingStepWidget {
  /// Creates an allergens selection step
  const AllergensStep({Key? key}) : super(key: key);

  @override
  OnboardingStep get step => OnboardingStep.allergens;

  @override
  String getTitle(BuildContext context) => 'Any ingredient allergies?';

  @override
  String getSubtitle(BuildContext context) => 'We\'ll help you avoid these ingredients';

  @override
  bool canProceed(OnboardingProvider provider) {
    // Allergens are optional
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return buildStepContent(
      context,
      Provider.of<OnboardingProvider>(context),
    );
  }

  @override
  Widget buildStepContent(BuildContext context, OnboardingProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppColors.warningColor.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                getTitle(context),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                getSubtitle(context),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 32),
              
              // Information card
              OnboardingCard(
                backgroundColor: AppColors.infoColor.withOpacity(0.1),
                borderColor: AppColors.infoColor.withOpacity(0.3),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.infoColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'These common ingredients can cause reactions for some people. We\'ll flag them in product scans.',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Allergens list
              Expanded(
                child: ListView.builder(
                  itemCount: commonAllergens.length,
                  itemBuilder: (context, index) {
                    final allergen = commonAllergens[index];
                    final isSelected = provider.isAllergenSelected(allergen.id);
                    
                    return AnimatedOnboardingCard(
                      onTap: () => provider.toggleAllergen(allergen.id),
                      backgroundColor: isSelected
                          ? AppColors.warningColor.withOpacity(0.1)
                          : Colors.white,
                      borderColor: isSelected
                          ? AppColors.warningColor
                          : Colors.grey[300],
                      child: Row(
                        children: [
                          Container(
                            width: isTablet ? 60 : 48,
                            height: isTablet ? 60 : 48,
                            decoration: BoxDecoration(
                              color: AppColors.warningColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.warning_amber_outlined,
                              color: AppColors.warningColor,
                              size: isTablet ? 30 : 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  allergen.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  allergen.description,
                                  style: TextStyle(
                                    color: AppColors.textSecondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => provider.toggleAllergen(allergen.id),
                            activeColor: AppColors.warningColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Skip notice
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'You can always update these preferences later in settings',
                  style: TextStyle(
                    color: AppColors.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}