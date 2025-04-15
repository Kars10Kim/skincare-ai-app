import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/onboarding_model.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/onboarding/onboarding_card.dart';
import '../../../widgets/onboarding/onboarding_step_widget.dart';

/// Skin type selection step in the onboarding process
class SkinTypeStep extends OnboardingStepWidget {
  /// Creates a skin type selection step
  const SkinTypeStep({Key? key}) : super(key: key);

  @override
  OnboardingStep get step => OnboardingStep.skinType;

  @override
  String getTitle(BuildContext context) => 'What\'s your skin type?';

  @override
  String getSubtitle(BuildContext context) => 'This helps us recommend the right products for you';

  @override
  bool canProceed(OnboardingProvider provider) {
    return provider.data.skinType != null;
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
        final selectedSkinType = provider.data.skinType;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                AppColors.primaryColor.withOpacity(0.1),
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

              // Skin type grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 3 : 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: SkinType.values.length,
                  itemBuilder: (context, index) {
                    final skinType = SkinType.values[index];
                    final isSelected = selectedSkinType == skinType;

                    return AnimatedOnboardingCard(
                      onTap: () => provider.setSkinType(skinType),
                      backgroundColor: isSelected
                          ? AppColors.primaryColor.withOpacity(0.1)
                          : Colors.white,
                      borderColor: isSelected
                          ? AppColors.primaryColor
                          : Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Illustrated skin type icon
                          Hero(
                            tag: 'skin_type_${skinType.name}',
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor.withOpacity(0.15)
                                    : AppColors.primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : AppColors.primaryColor.withOpacity(0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryColor.withOpacity(0.2),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Custom illustrated icon
                                  Image.asset(
                                    'assets/icons/skin_type_${skinType.name.toLowerCase()}.png',
                                    width: 60,
                                    height: 60,
                                    color: AppColors.primaryColor,
                                  ),
                                  // Selection indicator
                                  if (isSelected)
                                    Positioned(
                                      right: 5,
                                      top: 5,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Type name and description
                          Text(
                            skinType.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            skinType.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),

                          // Selection indicator - Removed as it's now in the icon
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get an icon for each skin type -  This function is no longer needed.
}