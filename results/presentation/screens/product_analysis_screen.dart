import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/product_analysis_cubit.dart';
import '../cubit/recommendation_cubit.dart';
import '../widgets/safety_score_card.dart';
import '../widgets/ingredient_conflict_card.dart';
import '../widgets/analyzed_ingredient_item.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/scientific_reference_card.dart';
import '../../domain/entities/ingredient_conflict.dart';
import '../../domain/entities/product_analysis.dart';
import '../../domain/entities/scientific_reference.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../recognition/domain/entities/scan_history_item.dart';

/// Screen to display product analysis
class ProductAnalysisScreen extends StatefulWidget {
  /// Scan data
  final ScanHistoryItem scanData;
  
  /// User profile
  final UserProfile userProfile;
  
  /// Create product analysis screen
  const ProductAnalysisScreen({
    super.key,
    required this.scanData,
    required this.userProfile,
  });
  
  @override
  State<ProductAnalysisScreen> createState() => _ProductAnalysisScreenState();
}

class _ProductAnalysisScreenState extends State<ProductAnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedIngredient;
  List<ScientificReference>? _selectedIngredientReferences;
  bool _showConfirmationDialog = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Analyze the product
    context.read<ProductAnalysisCubit>().analyzeProduct(widget.scanData);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Analysis'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Ingredients'),
            Tab(text: 'Recommendations'),
          ],
        ),
        actions: [
          BlocBuilder<ProductAnalysisCubit, ProductAnalysisState>(
            builder: (context, state) {
              if (state is ProductAnalysisLoaded) {
                return IconButton(
                  icon: Icon(
                    state.analysis.isFavorite
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                  onPressed: () {
                    context.read<ProductAnalysisCubit>().toggleFavorite(state.analysis.id);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ProductAnalysisCubit, ProductAnalysisState>(
        listener: (context, state) {
          if (state is ProductAnalysisLoaded) {
            // Generate recommendations
            context.read<RecommendationCubit>().generateRecommendations(
              userProfile: widget.userProfile,
              currentProduct: state.analysis,
            );
          } else if (state is ProductAnalysisIngredientValidated) {
            setState(() {
              _selectedIngredient = state.ingredient;
              _selectedIngredientReferences = state.references;
              _showConfirmationDialog = true;
            });
          }
        },
        builder: (context, state) {
          if (state is ProductAnalysisLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ProductAnalysisError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48.0,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Error analyzing product',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductAnalysisCubit>().analyzeProduct(widget.scanData);
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (state is ProductAnalysisLoaded || 
                     state is ProductAnalysisValidatingIngredient ||
                     state is ProductAnalysisIngredientValidated) {
            ProductAnalysis analysis;
            
            if (state is ProductAnalysisLoaded) {
              analysis = state.analysis;
            } else if (state is ProductAnalysisValidatingIngredient) {
              analysis = state.analysis;
            } else if (state is ProductAnalysisIngredientValidated) {
              analysis = state.analysis;
            } else {
              return const Center(
                child: Text('Unknown state'),
              );
            }
            
            return Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    // Overview tab
                    _buildOverviewTab(analysis),
                    
                    // Ingredients tab
                    _buildIngredientsTab(analysis),
                    
                    // Recommendations tab
                    _buildRecommendationsTab(),
                  ],
                ),
                
                // Overlay for ingredient validation
                if (state is ProductAnalysisValidatingIngredient)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Card(
                        margin: const EdgeInsets.all(32.0),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 24.0),
                              Text(
                                'Validating ingredient: ${state.ingredient}',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8.0),
                              const Text(
                                'Checking scientific databases and references...',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Dialog for ingredient validation results
                if (_showConfirmationDialog && 
                    _selectedIngredient != null && 
                    _selectedIngredientReferences != null)
                  _buildIngredientValidationDialog(),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
  
  /// Build overview tab
  Widget _buildOverviewTab(ProductAnalysis analysis) {
    final theme = Theme.of(context).textTheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product info
          Text(
            analysis.scanData.brand ?? 'Unknown Brand',
            style: theme.titleMedium,
          ),
          Text(
            analysis.scanData.displayName,
            style: theme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8.0),
          
          // Product image if available
          if (analysis.scanData.hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.file(
                File(analysis.scanData.imagePath!),
                height: 200.0,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200.0,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 48.0,
                      ),
                    ),
                  );
                },
              ),
            ),
          
          const SizedBox(height: 16.0),
          
          // Safety score
          SafetyScoreCard(score: analysis.safetyScore),
          
          const SizedBox(height: 16.0),
          
          // Conflict overview
          if (analysis.hasConflicts) ...[
            Text(
              'Potential Issues',
              style: theme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8.0),
            
            Text(
              'We found ${analysis.totalConflicts} potential conflicts in this product:',
              style: theme.bodyMedium,
            ),
            
            const SizedBox(height: 8.0),
            
            // High severity conflicts
            if (analysis.highSeverityConflicts.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    width: 16.0,
                    height: 16.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    '${analysis.highSeverityConflicts.length} High Severity Conflict${analysis.highSeverityConflicts.length == 1 ? '' : 's'}',
                    style: theme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            
            // Medium severity conflicts
            if (analysis.mediumSeverityConflicts.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Container(
                    width: 16.0,
                    height: 16.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    '${analysis.mediumSeverityConflicts.length} Medium Severity Conflict${analysis.mediumSeverityConflicts.length == 1 ? '' : 's'}',
                    style: theme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            
            // Low severity conflicts
            if (analysis.lowSeverityConflicts.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Container(
                    width: 16.0,
                    height: 16.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    '${analysis.lowSeverityConflicts.length} Low Severity Conflict${analysis.lowSeverityConflicts.length == 1 ? '' : 's'}',
                    style: theme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16.0),
            
            // Display high severity conflicts
            if (analysis.highSeverityConflicts.isNotEmpty) ...[
              Text(
                'High Severity Conflicts',
                style: theme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8.0),
              
              ...analysis.highSeverityConflicts.map((conflict) => 
                IngredientConflictCard(
                  conflict: conflict,
                  onTap: () {
                    context.read<ProductAnalysisCubit>().validateIngredient(
                      conflict.primaryIngredient,
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16.0),
            ],
            
            // View all conflicts button
            Center(
              child: OutlinedButton(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                child: const Text('View All Conflicts'),
              ),
            ),
          ] else ...[
            // No conflicts found
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48.0,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'No Conflicts Found',
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'We did not find any potential conflicts between the ingredients in this product.',
                    style: theme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24.0),
          
          // Recommendations preview
          Text(
            'Personalized Recommendations',
            style: theme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4.0),
          
          Text(
            'Based on your profile and this product',
            style: theme.bodyMedium,
          ),
          
          const SizedBox(height: 8.0),
          
          // Recommendations
          BlocBuilder<RecommendationCubit, RecommendationState>(
            builder: (context, state) {
              if (state is RecommendationLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is RecommendationLoaded && state.recommendations.isNotEmpty) {
                return Column(
                  children: [
                    RecommendationCard(
                      recommendation: state.recommendations.first,
                      onTap: () {
                        _tabController.animateTo(2);
                      },
                      onSave: () {
                        context.read<RecommendationCubit>().saveRecommendation(
                          state.recommendations.first,
                        );
                      },
                    ),
                    
                    const SizedBox(height: 8.0),
                    
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          _tabController.animateTo(2);
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('View All Recommendations'),
                      ),
                    ),
                  ],
                );
              } else if (state is RecommendationLoaded) {
                return Center(
                  child: Text(
                    'No recommendations available',
                    style: theme.bodyMedium,
                  ),
                );
              } else if (state is RecommendationError) {
                return Center(
                  child: Text(
                    'Error loading recommendations: ${state.message}',
                    style: theme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                );
              }
              
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }
  
  /// Build ingredients tab
  Widget _buildIngredientsTab(ProductAnalysis analysis) {
    final theme = Theme.of(context).textTheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ingredients count
          Text(
            '${analysis.ingredients.length} Ingredients',
            style: theme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16.0),
          
          // Conflict summary
          if (analysis.hasConflicts) ...[
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        color: Colors.amber,
                        size: 24.0,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Potential Conflicts Found',
                          style: theme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'We found ${analysis.totalConflicts} potential conflicts in this product. Tap on an ingredient to learn more.',
                    style: theme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16.0),
          ],
          
          // Conflict sections
          if (analysis.hasConflicts) ...[
            // High severity conflicts
            if (analysis.highSeverityConflicts.isNotEmpty) ...[
              _buildConflictSection(
                'High Severity Conflicts',
                analysis.highSeverityConflicts,
                Colors.red.shade100,
                Colors.red,
              ),
              
              const SizedBox(height: 16.0),
            ],
            
            // Medium severity conflicts
            if (analysis.mediumSeverityConflicts.isNotEmpty) ...[
              _buildConflictSection(
                'Medium Severity Conflicts',
                analysis.mediumSeverityConflicts,
                Colors.orange.shade100,
                Colors.orange,
              ),
              
              const SizedBox(height: 16.0),
            ],
            
            // Low severity conflicts
            if (analysis.lowSeverityConflicts.isNotEmpty) ...[
              _buildConflictSection(
                'Low Severity Conflicts',
                analysis.lowSeverityConflicts,
                Colors.green.shade100,
                Colors.green,
              ),
              
              const SizedBox(height: 16.0),
            ],
          ],
          
          // All ingredients
          Text(
            'All Ingredients',
            style: theme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8.0),
          
          ...analysis.ingredients.map((ingredient) => 
            AnalyzedIngredientItem(
              ingredient: ingredient,
              onTap: () {
                context.read<ProductAnalysisCubit>().validateIngredient(
                  ingredient.name,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build recommendations tab
  Widget _buildRecommendationsTab() {
    final theme = Theme.of(context).textTheme;
    
    return BlocBuilder<RecommendationCubit, RecommendationState>(
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
                      Icons.search_off,
                      size: 64.0,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'No Recommendations Available',
                      style: theme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'We could not find any suitable recommendations for this product based on your profile.',
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
                  if (recommendation.isSaved) {
                    context.read<RecommendationCubit>().deleteRecommendation(
                      recommendation.id,
                    );
                  } else {
                    context.read<RecommendationCubit>().saveRecommendation(
                      recommendation,
                    );
                  }
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
                      final analysisState = context.read<ProductAnalysisCubit>().state;
                      
                      if (analysisState is ProductAnalysisLoaded) {
                        context.read<RecommendationCubit>().generateRecommendations(
                          userProfile: widget.userProfile,
                          currentProduct: analysisState.analysis,
                        );
                      }
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
    );
  }
  
  /// Build conflict section
  Widget _buildConflictSection(
    String title,
    List<IngredientConflict> conflicts,
    Color backgroundColor,
    Color borderColor,
  ) {
    final theme = Theme.of(context).textTheme;
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: theme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: borderColor,
              ),
            ),
          ),
          
          const Divider(height: 1.0),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: conflicts.map((conflict) => 
                IngredientConflictCard(
                  conflict: conflict,
                  onTap: () {
                    context.read<ProductAnalysisCubit>().validateIngredient(
                      conflict.primaryIngredient,
                    );
                  },
                ),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build ingredient validation dialog
  Widget _buildIngredientValidationDialog() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showConfirmationDialog = false;
          _selectedIngredient = null;
          _selectedIngredientReferences = null;
        });
      },
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent taps from propagating
            child: Card(
              margin: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scientific Validation',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showConfirmationDialog = false;
                              _selectedIngredient = null;
                              _selectedIngredientReferences = null;
                            });
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16.0),
                    
                    Text(
                      'Ingredient: $_selectedIngredient',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16.0),
                    
                    if (_selectedIngredientReferences != null && 
                        _selectedIngredientReferences!.isNotEmpty) ...[
                      Text(
                        'Scientific References',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      
                      const SizedBox(height: 8.0),
                      
                      ...(_selectedIngredientReferences ?? []).map((reference) => 
                        ScientificReferenceCard(reference: reference),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.search_off,
                              color: Colors.grey,
                              size: 48.0,
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              'No Scientific References Found',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'We could not find any scientific references for this ingredient in our database.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16.0),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showConfirmationDialog = false;
                            _selectedIngredient = null;
                            _selectedIngredientReferences = null;
                          });
                        },
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Import dart:io to use File class
import 'dart:io';