import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/recommendation_cubit.dart';
import '../widgets/recommendation_card.dart';
import '../../../profile/domain/entities/user_profile.dart';

/// Screen to display saved recommendations
class RecommendationsScreen extends StatefulWidget {
  /// User profile
  final UserProfile userProfile;
  
  /// Create recommendations screen
  const RecommendationsScreen({
    super.key,
    required this.userProfile,
  });
  
  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    
    // Load saved recommendations
    context.read<RecommendationCubit>().getSavedRecommendations();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recommendations'),
      ),
      body: BlocBuilder<RecommendationCubit, RecommendationState>(
        builder: (context, state) {
          if (state is RecommendationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is RecommendationLoaded) {
            if (state.recommendations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bookmark_border,
                        size: 64.0,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'No Saved Recommendations',
                        style: theme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'You have not saved any product recommendations yet. When you find products you like, save them here for easy reference.',
                        style: theme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = state.recommendations[index];
                
                return RecommendationCard(
                  recommendation: recommendation,
                  onSave: () {
                    context.read<RecommendationCubit>().deleteRecommendation(
                      recommendation.id,
                    );
                  },
                );
              },
            );
          } else if (state is RecommendationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64.0,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Error Loading Recommendations',
                      style: theme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      state.message,
                      style: theme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        context.read<RecommendationCubit>().getSavedRecommendations();
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}