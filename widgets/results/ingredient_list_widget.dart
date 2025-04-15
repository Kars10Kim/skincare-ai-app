import 'package:flutter/material.dart';
import '../../models/product/product_model.dart';
import '../../utils/constants.dart';

/// Widget to display product ingredients
class IngredientListWidget extends StatelessWidget {
  /// List of ingredients
  final List<String> ingredients;
  
  /// Detailed ingredient information (if available)
  final List<Ingredient> ingredientDetails;
  
  /// Ingredients that match user's allergens
  final List<String> allergenMatches;

  /// Creates an ingredient list widget
  const IngredientListWidget({
    Key? key,
    required this.ingredients,
    required this.ingredientDetails,
    required this.allergenMatches,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ingredients.isEmpty
        ? _buildEmptyState()
        : _buildIngredientList(context);
  }
  
  /// Builds an empty state when no ingredients are available
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science_outlined,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Ingredients Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This product does not have any ingredients listed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Builds the ingredient list
  Widget _buildIngredientList(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Ingredients (${ingredients.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap on an ingredient to learn more about its function and properties.',
            style: TextStyle(
              color: AppColors.textSecondaryColor,
              fontSize: 14,
            ),
          ),
          
          // Filter options
          _buildFilterOptions(),
          
          // Ingredients list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              final isAllergen = allergenMatches.contains(ingredient);
              final ingredientDetail = _findIngredientDetails(ingredient);
              
              return _buildIngredientItem(
                context,
                ingredient,
                isAllergen,
                ingredientDetail,
                index,
              );
            },
          ),
        ],
      ),
    );
  }
  
  /// Builds filter options for the ingredient list
  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildFilterChip('All (${ingredients.length})', true),
          if (allergenMatches.isNotEmpty)
            _buildFilterChip('Allergens (${allergenMatches.length})', false),
          _buildFilterChip('Antioxidants', false),
          _buildFilterChip('Humectants', false),
          _buildFilterChip('Preservatives', false),
          _buildFilterChip('Fragrances', false),
        ],
      ),
    );
  }
  
  /// Builds a filter chip
  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // Would filter the list in a real implementation
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.primaryColor,
    );
  }
  
  /// Builds an ingredient item
  Widget _buildIngredientItem(
    BuildContext context,
    String ingredient,
    bool isAllergen,
    Ingredient? ingredientDetail,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isAllergen
              ? AppColors.warningColor
              : Colors.transparent,
          width: isAllergen ? 1 : 0,
        ),
      ),
      child: InkWell(
        onTap: () => _showIngredientDetails(context, ingredient, ingredientDetail),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredient number
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Ingredient name and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ingredient,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isAllergen)
                              Tooltip(
                                message: 'Matches your allergen preferences',
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.warningColor,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                        
                        if (ingredientDetail != null && ingredientDetail.function != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            ingredientDetail.function!,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        
                        if (ingredientDetail != null && ingredientDetail.ewgScore != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'EWG Score: ',
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              _buildEwgBadge(ingredientDetail.ewgScore!),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              // Show expandable section if it's an allergen
              if (isAllergen) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warningColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This ingredient matches your allergens. It may cause sensitivity or irritation.',
                        style: TextStyle(
                          color: AppColors.warningColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// Builds an EWG score badge
  Widget _buildEwgBadge(int score) {
    final color = _getEwgScoreColor(score);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        score.toString(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  /// Get the EWG score color based on score
  Color _getEwgScoreColor(int score) {
    if (score <= 2) return Colors.green;
    if (score <= 6) return Colors.orange;
    return Colors.red;
  }
  
  /// Show ingredient details dialog
  void _showIngredientDetails(
    BuildContext context,
    String ingredient,
    Ingredient? ingredientDetail,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => _IngredientDetailsSheet(
        ingredient: ingredient,
        ingredientDetail: ingredientDetail,
      ),
    );
  }
  
  /// Find detailed information for an ingredient
  Ingredient? _findIngredientDetails(String ingredientName) {
    try {
      return ingredientDetails.firstWhere(
        (detail) => detail.name.toLowerCase() == ingredientName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

/// Ingredient details bottom sheet
class _IngredientDetailsSheet extends StatelessWidget {
  /// Ingredient name
  final String ingredient;
  
  /// Ingredient details
  final Ingredient? ingredientDetail;
  
  /// Creates an ingredient details sheet
  const _IngredientDetailsSheet({
    Key? key,
    required this.ingredient,
    this.ingredientDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Ingredient name
              Text(
                ingredient,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              if (ingredientDetail != null) ...[
                // INCI name
                if (ingredientDetail!.inciName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'INCI: ${ingredientDetail!.inciName}',
                    style: TextStyle(
                      color: AppColors.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                
                // CAS number
                if (ingredientDetail!.casNumber != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'CAS: ${ingredientDetail!.casNumber}',
                    style: TextStyle(
                      color: AppColors.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
                
                // EWG score
                if (ingredientDetail!.ewgScore != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'EWG Safety Score:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildEwgScoreIndicator(ingredientDetail!.ewgScore!),
                    ],
                  ),
                ],
                
                // Description
                if (ingredientDetail!.description != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(ingredientDetail!.description!),
                ],
                
                // Function
                if (ingredientDetail!.function != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Function',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(ingredientDetail!.function!),
                ],
                
                // Categories
                if (ingredientDetail!.categories.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ingredientDetail!.categories.map(
                      (category) => Chip(
                        label: Text(category),
                        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ).toList(),
                  ),
                ],
                
                // Potential issues
                if (ingredientDetail!.potentialIssues.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Potential Issues',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...ingredientDetail!.potentialIssues.map(
                    (issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            color: AppColors.warningColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(issue)),
                        ],
                      ),
                    ),
                  ),
                ],
                
                // Scientific references
                if (ingredientDetail!.scientificReferences.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Scientific References',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...ingredientDetail!.scientificReferences.map(
                    (ref) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            color: AppColors.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(ref)),
                        ],
                      ),
                    ),
                  ),
                ],
              ] else ...[
                // No detailed information available
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.science_outlined,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No detailed information available for this ingredient.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  
  /// Build EWG score indicator
  Widget _buildEwgScoreIndicator(int score) {
    final color = _getEwgScoreColor(score);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _getEwgScoreText(score),
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Get the EWG score color based on score
  Color _getEwgScoreColor(int score) {
    if (score <= 2) return Colors.green;
    if (score <= 6) return Colors.orange;
    return Colors.red;
  }
  
  /// Get the EWG score text based on score
  String _getEwgScoreText(int score) {
    if (score <= 2) return 'Low Hazard';
    if (score <= 6) return 'Moderate Hazard';
    return 'High Hazard';
  }
}