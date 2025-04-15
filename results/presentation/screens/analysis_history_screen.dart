import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubit/product_analysis_cubit.dart';
import '../../domain/entities/product_analysis.dart';
import '../../domain/entities/ingredient_conflict.dart';
import 'product_analysis_screen.dart';
import '../../../profile/domain/entities/user_profile.dart';

/// Screen to display analysis history
class AnalysisHistoryScreen extends StatefulWidget {
  /// User profile
  final UserProfile userProfile;
  
  /// Create analysis history screen
  const AnalysisHistoryScreen({
    super.key,
    required this.userProfile,
  });
  
  @override
  State<AnalysisHistoryScreen> createState() => _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState extends State<AnalysisHistoryScreen> {
  @override
  void initState() {
    super.initState();
    
    // Load recent analyses
    context.read<ProductAnalysisCubit>().getRecentAnalyses();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
        actions: [
          // Toggle between recent and favorites
          BlocBuilder<ProductAnalysisCubit, ProductAnalysisState>(
            builder: (context, state) {
              if (state is ProductAnalysisListLoaded) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'recent') {
                      context.read<ProductAnalysisCubit>().getRecentAnalyses();
                    } else if (value == 'favorites') {
                      context.read<ProductAnalysisCubit>().getFavoriteAnalyses();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'recent',
                      child: Text('Recent Analyses'),
                    ),
                    const PopupMenuItem(
                      value: 'favorites',
                      child: Text('Favorites'),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: const [
                        Text('Filter'),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                );
              }
              
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductAnalysisCubit, ProductAnalysisState>(
        builder: (context, state) {
          if (state is ProductAnalysisListLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ProductAnalysisListLoaded) {
            if (state.analyses.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 64.0,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'No Analysis History',
                        style: theme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'You have not analyzed any products yet. Scan a product to get started.',
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
              itemCount: state.analyses.length,
              itemBuilder: (context, index) {
                final analysis = state.analyses[index];
                
                return _buildAnalysisCard(analysis, dateFormat);
              },
            );
          } else if (state is ProductAnalysisError) {
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
                      'Error Loading Analysis History',
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
                        context.read<ProductAnalysisCubit>().getRecentAnalyses();
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
  
  /// Build analysis card
  Widget _buildAnalysisCard(ProductAnalysis analysis, DateFormat dateFormat) {
    final theme = Theme.of(context).textTheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductAnalysisScreen(
                scanData: analysis.scanData,
                userProfile: widget.userProfile,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and favorite button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(analysis.timestamp),
                    style: theme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      analysis.isFavorite
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: analysis.isFavorite
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () {
                      context.read<ProductAnalysisCubit>().toggleFavorite(analysis.id);
                    },
                  ),
                ],
              ),
              
              // Product info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image if available
                  if (analysis.scanData.hasImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(analysis.scanData.imagePath!),
                        width: 80.0,
                        height: 80.0,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80.0,
                            height: 80.0,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                  ],
                  
                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (analysis.scanData.brand != null) ...[
                          Text(
                            analysis.scanData.brand!,
                            style: theme.bodyMedium,
                          ),
                        ],
                        
                        Text(
                          analysis.scanData.displayName,
                          style: theme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 4.0),
                        
                        Text(
                          '${analysis.scanData.ingredientCount} Ingredients',
                          style: theme.bodySmall,
                        ),
                        
                        const SizedBox(height: 4.0),
                        
                        // Source badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            analysis.scanData.getSourceText(),
                            style: theme.bodySmall?.copyWith(
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16.0),
              
              // Safety score and conflicts
              Row(
                children: [
                  // Safety score
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Safety Score',
                          style: theme.bodySmall,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 24.0,
                              height: 24.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getSafetyColor(analysis.safetyScore.overall),
                              ),
                              child: Center(
                                child: Text(
                                  '${analysis.safetyScore.overall}',
                                  style: theme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              analysis.safetyScore.safetyRating,
                              style: theme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Conflicts count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conflicts',
                          style: theme.bodySmall,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 24.0,
                              height: 24.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: analysis.hasConflicts
                                    ? (analysis.hasHighSeverityConflicts 
                                        ? Colors.red 
                                        : Colors.orange)
                                    : Colors.green,
                              ),
                              child: Center(
                                child: Text(
                                  '${analysis.totalConflicts}',
                                  style: theme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              analysis.hasConflicts
                                  ? (analysis.hasHighSeverityConflicts 
                                      ? 'Issues Found' 
                                      : 'Minor Issues')
                                  : 'No Issues',
                              style: theme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Get color for safety score
  Color _getSafetyColor(int score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 60) {
      return Colors.greenAccent.shade700;
    } else if (score >= 40) {
      return Colors.orange;
    } else if (score >= 20) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }
}

/// Import dart:io to use File class
import 'dart:io';