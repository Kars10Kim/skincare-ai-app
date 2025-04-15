import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/onboarding_model.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/onboarding/onboarding_card.dart';
import '../../../widgets/onboarding/onboarding_step_widget.dart';

/// Skin concerns selection step in the onboarding process
class ConcernsStep extends OnboardingStepWidget {
  /// Creates a skin concerns selection step
  const ConcernsStep({Key? key}) : super(key: key);

  @override
  OnboardingStep get step => OnboardingStep.concerns;

  @override
  String getTitle(BuildContext context) => 'What are your skin concerns?';

  @override
  String getSubtitle(BuildContext context) => 'Select all that apply';

  @override
  bool canProceed(OnboardingProvider provider) {
    // Can proceed even without concerns, but they're recommended
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
                AppColors.secondaryColor.withOpacity(0.1),
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

              // Concerns grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 3 : 2,
                    childAspectRatio: isTablet ? 1.5 : 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: SkinConcern.values.length,
                  itemBuilder: (context, index) {
                    final concern = SkinConcern.values[index];
                    final isSelected = provider.isConcernSelected(concern);

                    return AnimatedOnboardingCard(
                      onTap: () => provider.toggleConcern(concern),
                      backgroundColor: isSelected
                          ? AppColors.secondaryColor.withOpacity(0.1)
                          : Colors.white,
                      borderColor: isSelected
                          ? AppColors.secondaryColor
                          : Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.secondaryColor.withOpacity(0.15)
                                      : AppColors.secondaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.secondaryColor
                                        : AppColors.secondaryColor.withOpacity(0.2),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/icons/concern_${concern.name.toLowerCase()}.png',
                                      width: 30,
                                      height: 30,
                                      color: AppColors.secondaryColor,
                                    ),
                                    if (isSelected)
                                      TweenAnimationBuilder<double>(
                                        duration: const Duration(milliseconds: 300),
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        builder: (context, value, child) {
                                          return Transform.scale(
                                            scale: value,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.secondaryColor.withOpacity(0.8),
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(2),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      concern.displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      concern.description,
                                      style: TextStyle(
                                        color: AppColors.textSecondaryColor,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Tip
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Tip: Selecting your concerns helps us identify ingredients to avoid',
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

  /// Get an icon for each skin concern
  IconData _getConcernIcon(SkinConcern concern) {
    switch (concern) {
      case SkinConcern.acne:
        return Icons.face_retouching_natural;
      case SkinConcern.aging:
        return Icons.watch_later_outlined;
      case SkinConcern.hyperpigmentation:
        return Icons.contrast;
      case SkinConcern.redness:
        return Icons.local_fire_department_outlined;
      case SkinConcern.dryness:
        return Icons.water_drop_outlined;
      case SkinConcern.unevenTexture:
        return Icons.grid_3x3;
    }
  }
}