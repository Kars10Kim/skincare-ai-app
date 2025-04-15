import '../../domain/entities/survey_step.dart';

/// Default survey configuration
class DefaultSurveyConfig {
  /// Get default survey steps
  static List<SurveyStep> getSteps() {
    return [
      // Welcome step
      const SurveyStep(
        id: 'welcome',
        title: 'Welcome to Skincare Scanner',
        description: 'Let\'s create your personalized skin profile to help you make better skincare choices.',
        answerType: AnswerType.text,
        isRequired: false,
      ),
      
      // Skin type step
      SurveyStep(
        id: 'skin_type',
        title: 'What\'s your skin type?',
        description: 'Choose the option that best describes your skin most of the time.',
        answerType: AnswerType.singleChoice,
        options: [
          const SurveyOption(
            id: 'normal',
            label: 'Normal',
            value: 'normal',
            imagePath: 'assets/images/skin_type_normal.png',
          ),
          const SurveyOption(
            id: 'dry',
            label: 'Dry',
            value: 'dry',
            imagePath: 'assets/images/skin_type_dry.png',
          ),
          const SurveyOption(
            id: 'oily',
            label: 'Oily',
            value: 'oily',
            imagePath: 'assets/images/skin_type_oily.png',
          ),
          const SurveyOption(
            id: 'combination',
            label: 'Combination',
            value: 'combination',
            imagePath: 'assets/images/skin_type_combination.png',
          ),
        ],
      ),
      
      // Sensitivity step
      SurveyStep(
        id: 'sensitivity',
        title: 'How sensitive is your skin?',
        description: 'Does your skin react easily to new products or environmental factors?',
        answerType: AnswerType.singleChoice,
        options: [
          const SurveyOption(
            id: 'none',
            label: 'Not sensitive',
            value: 'none',
          ),
          const SurveyOption(
            id: 'mild',
            label: 'Slightly sensitive',
            value: 'mild',
          ),
          const SurveyOption(
            id: 'moderate',
            label: 'Moderately sensitive',
            value: 'moderate',
          ),
          const SurveyOption(
            id: 'high',
            label: 'Very sensitive',
            value: 'high',
          ),
        ],
      ),
      
      // Climate step
      SurveyStep(
        id: 'climate',
        title: 'What climate do you live in?',
        description: 'Your environment affects your skin\'s needs.',
        answerType: AnswerType.singleChoice,
        options: [
          const SurveyOption(
            id: 'dry',
            label: 'Dry',
            value: 'dry',
          ),
          const SurveyOption(
            id: 'humid',
            label: 'Humid',
            value: 'humid',
          ),
          const SurveyOption(
            id: 'temperate',
            label: 'Temperate',
            value: 'temperate',
          ),
          const SurveyOption(
            id: 'cold',
            label: 'Cold',
            value: 'cold',
          ),
          const SurveyOption(
            id: 'hot',
            label: 'Hot',
            value: 'hot',
          ),
        ],
      ),
      
      // Skin concerns step
      SurveyStep(
        id: 'concerns',
        title: 'What are your main skin concerns?',
        description: 'Select all that apply to you.',
        answerType: AnswerType.multipleChoice,
        options: [
          const SurveyOption(
            id: 'acne',
            label: 'Acne',
            value: 'acne',
          ),
          const SurveyOption(
            id: 'aging',
            label: 'Aging',
            value: 'aging',
          ),
          const SurveyOption(
            id: 'dryness',
            label: 'Dryness',
            value: 'dryness',
          ),
          const SurveyOption(
            id: 'hyperpigmentation',
            label: 'Hyperpigmentation',
            value: 'hyperpigmentation',
          ),
          const SurveyOption(
            id: 'redness',
            label: 'Redness',
            value: 'redness',
          ),
          const SurveyOption(
            id: 'texture',
            label: 'Texture',
            value: 'texture',
          ),
          const SurveyOption(
            id: 'oilControl',
            label: 'Oil Control',
            value: 'oilControl',
          ),
          const SurveyOption(
            id: 'pores',
            label: 'Pores',
            value: 'pores',
          ),
          const SurveyOption(
            id: 'dullness',
            label: 'Dullness',
            value: 'dullness',
          ),
        ],
      ),
      
      // Allergies step
      SurveyStep(
        id: 'allergies',
        title: 'Any known allergies or sensitivities?',
        description: 'Select all ingredients that your skin reacts negatively to.',
        answerType: AnswerType.multipleChoice,
        isRequired: false,
        options: [
          const SurveyOption(
            id: 'fragrance',
            label: 'Fragrance',
            value: 'fragrance',
          ),
          const SurveyOption(
            id: 'essentialOils',
            label: 'Essential Oils',
            value: 'essentialOils',
          ),
          const SurveyOption(
            id: 'alcohol',
            label: 'Alcohol',
            value: 'alcohol',
          ),
          const SurveyOption(
            id: 'sulfates',
            label: 'Sulfates',
            value: 'sulfates',
          ),
          const SurveyOption(
            id: 'parabens',
            label: 'Parabens',
            value: 'parabens',
          ),
          const SurveyOption(
            id: 'retinoids',
            label: 'Retinoids',
            value: 'retinoids',
          ),
          const SurveyOption(
            id: 'lanolin',
            label: 'Lanolin',
            value: 'lanolin',
          ),
          const SurveyOption(
            id: 'formaldehyde',
            label: 'Formaldehyde',
            value: 'formaldehyde',
          ),
          const SurveyOption(
            id: 'salicylicAcid',
            label: 'Salicylic Acid',
            value: 'salicylicAcid',
          ),
        ],
      ),
      
      // Notes step
      const SurveyStep(
        id: 'notes',
        title: 'Additional Notes',
        description: 'Is there anything else we should know about your skin?',
        answerType: AnswerType.text,
        isRequired: false,
      ),
      
      // Completion step
      const SurveyStep(
        id: 'completion',
        title: 'Profile Complete!',
        description: 'Thanks for providing your information. We\'ll use this to personalize your skincare recommendations.',
        answerType: AnswerType.text,
        isRequired: false,
      ),
    ];
  }
}