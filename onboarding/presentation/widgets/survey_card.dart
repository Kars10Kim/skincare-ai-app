import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../domain/entities/survey_step.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

/// Card for displaying a survey question
class SurveyCard extends StatelessWidget {
  /// Create a survey card
  const SurveyCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final step = state.currentStep;
        
        if (step == null) {
          return const Center(
            child: Text('No survey step available'),
          );
        }
        
        return _buildCard(context, step);
      },
    );
  }
  
  /// Build the card for a step
  Widget _buildCard(BuildContext context, SurveyStep step) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: _buildGlassmorphicCard(
        context,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                step.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              
              // Different inputs based on answer type
              _buildInputForStep(context, step),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build a glassmorphic card
  Widget _buildGlassmorphicCard(BuildContext context, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
  
  /// Build the input widget for a step
  Widget _buildInputForStep(BuildContext context, SurveyStep step) {
    final cubit = context.read<OnboardingCubit>();
    
    switch (step.answerType) {
      case AnswerType.singleChoice:
        return _buildSingleChoiceInput(context, step, cubit);
      case AnswerType.multipleChoice:
        return _buildMultipleChoiceInput(context, step, cubit);
      case AnswerType.text:
        return _buildTextInput(context, step, cubit);
      case AnswerType.numeric:
        return _buildNumericInput(context, step, cubit);
      case AnswerType.date:
        return _buildDateInput(context, step, cubit);
      case AnswerType.boolean:
        return _buildBooleanInput(context, step, cubit);
    }
  }
  
  /// Build a single choice input
  Widget _buildSingleChoiceInput(
    BuildContext context, 
    SurveyStep step, 
    OnboardingCubit cubit,
  ) {
    return Column(
      children: step.options.map((option) {
        final isSelected = step.answer == option.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOptionCard(
            context,
            option: option,
            isSelected: isSelected,
            onTap: () => cubit.updateAnswer(option.value),
          ),
        );
      }).toList(),
    );
  }
  
  /// Build a multiple choice input
  Widget _buildMultipleChoiceInput(
    BuildContext context, 
    SurveyStep step, 
    OnboardingCubit cubit,
  ) {
    final selectedValues = (step.answer as List?) ?? [];
    
    return Column(
      children: step.options.map((option) {
        final isSelected = selectedValues.contains(option.value);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOptionCard(
            context,
            option: option,
            isSelected: isSelected,
            onTap: () {
              final newValues = List<dynamic>.from(selectedValues);
              if (isSelected) {
                newValues.remove(option.value);
              } else {
                newValues.add(option.value);
              }
              cubit.updateAnswer(newValues);
            },
          ),
        );
      }).toList(),
    );
  }
  
  /// Build a text input
  Widget _buildTextInput(
    BuildContext context, 
    SurveyStep step, 
    OnboardingCubit cubit,
  ) {
    // Special case for welcome and completion steps
    if (step.id == 'welcome') {
      return _buildWelcomeContent(context);
    } else if (step.id == 'completion') {
      return _buildCompletionContent(context);
    }
    
    final controller = TextEditingController(text: step.answer ?? '');
    
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your answer',
            filled: true,
            fillColor: Colors.white.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 4,
          onChanged: (value) => cubit.updateAnswer(value),
        ),
      ],
    );
  }
  
  /// Build a numeric input
  Widget _buildNumericInput(
    BuildContext context, 
    SurveyStep step, 
    OnboardingCubit cubit,
  ) {
    final controller = TextEditingController(
      text: step.answer?.toString() ?? '',
    );
    
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter a number',
            filled: true,
            fillColor: Colors.white.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final numValue = num.tryParse(value);
            if (numValue != null) {
              cubit.updateAnswer(numValue);
            }
          },
        ),
      ],
    );
  }
  
  /// Build a date input
  Widget _buildDateInput(
    BuildContext context, 
    SurveyStep step, 
    OnboardingCubit cubit,
  ) {
    final selectedDate = step.answer as DateTime? ?? DateTime.now();
    
    return Column(
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: Text(
            selectedDate.toString().split(' ')[0],
            style: const TextStyle(fontSize: 16),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            
            if (date != null) {
              cubit.updateAnswer(date);
            }
          },
        ),
      ],
    );
  }
  
  /// Build a boolean input
  Widget _buildBooleanInput(
    BuildContext context, 
    SurveyStep step, 
    OnboardingCubit cubit,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                context,
                option: const SurveyOption(
                  id: 'yes',
                  label: 'Yes',
                  value: true,
                ),
                isSelected: step.answer == true,
                onTap: () => cubit.updateAnswer(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                context,
                option: const SurveyOption(
                  id: 'no',
                  label: 'No',
                  value: false,
                ),
                isSelected: step.answer == false,
                onTap: () => cubit.updateAnswer(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// Build an option card
  Widget _buildOptionCard(
    BuildContext context, {
    required SurveyOption option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.3),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (option.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  option.imagePath!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
  
  /// Build welcome content
  Widget _buildWelcomeContent(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Lottie.asset(
            'assets/animations/welcome.json',
            width: 200,
            height: 200,
            repeat: true,
            frameRate: FrameRate.max,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'We\'ll ask you a few questions to understand your skin better. '
          'This helps us provide personalized recommendations and identify '
          'potential ingredient conflicts.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  /// Build completion content
  Widget _buildCompletionContent(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Lottie.asset(
            'assets/animations/complete.json',
            width: 200,
            height: 200,
            repeat: true,
            frameRate: FrameRate.max,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Your profile is now set up! You can always update it later from '
          'your profile settings.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}