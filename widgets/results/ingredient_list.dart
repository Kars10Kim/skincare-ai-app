import 'package:flutter/material.dart';
import '../../models/ingredient_model.dart';

/// A widget that displays a list of ingredients with expandable sections
class IngredientListWidget extends StatefulWidget {
  /// List of ingredients to display
  final List<Ingredient> ingredients;
  
  /// Callback when an ingredient is tapped
  final Function(Ingredient)? onIngredientTap;
  
  /// Whether to group ingredients by category
  final bool groupByCategory;
  
  /// Whether to show the category distribution chart
  final bool showDistributionChart;
  
  const IngredientListWidget({
    Key? key,
    required this.ingredients,
    this.onIngredientTap,
    this.groupByCategory = true,
    this.showDistributionChart = true,
  }) : super(key: key);

  @override
  State<IngredientListWidget> createState() => _IngredientListWidgetState();
}

class _IngredientListWidgetState extends State<IngredientListWidget> {
  // Track expanded categories
  final Set<String> _expandedCategories = {};
  
  @override
  void initState() {
    super.initState();
    // Expand all categories initially
    if (widget.groupByCategory) {
      _expandedCategories.addAll(_getCategoriesFromIngredients());
    }
  }
  
  Set<String> _getCategoriesFromIngredients() {
    return widget.ingredients.map((i) => i.category).toSet();
  }
  
  Map<String, List<Ingredient>> _groupIngredientsByCategory() {
    final Map<String, List<Ingredient>> groupedIngredients = {};
    
    for (final ingredient in widget.ingredients) {
      if (!groupedIngredients.containsKey(ingredient.category)) {
        groupedIngredients[ingredient.category] = [];
      }
      groupedIngredients[ingredient.category]!.add(ingredient);
    }
    
    return groupedIngredients;
  }
  
  Map<String, int> _getCategoryDistribution() {
    final Map<String, int> distribution = {};
    
    for (final ingredient in widget.ingredients) {
      if (!distribution.containsKey(ingredient.category)) {
        distribution[ingredient.category] = 0;
      }
      distribution[ingredient.category] = distribution[ingredient.category]! + 1;
    }
    
    return distribution;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ingredients.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No ingredients found'),
        ),
      );
    }
    
    if (widget.groupByCategory) {
      final groupedIngredients = _groupIngredientsByCategory();
      
      return Column(
        children: [
          // Category distribution chart
          if (widget.showDistributionChart) 
            _buildCategoryDistributionChart(),
            
          // Grouped ingredients
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: groupedIngredients.length,
            itemBuilder: (context, index) {
              final category = groupedIngredients.keys.elementAt(index);
              final categoryIngredients = groupedIngredients[category]!;
              
              return _buildCategoryExpansionTile(category, categoryIngredients);
            },
          ),
        ],
      );
    } else {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.ingredients.length,
        itemBuilder: (context, index) {
          return _buildIngredientTile(widget.ingredients[index]);
        },
      );
    }
  }
  
  Widget _buildCategoryDistributionChart() {
    final distribution = _getCategoryDistribution();
    final totalIngredients = widget.ingredients.length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              'Ingredient Distribution',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.grey.shade200,
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: distribution.entries.map((entry) {
                final percentage = entry.value / totalIngredients;
                return Expanded(
                  flex: (percentage * 100).round(),
                  child: Container(
                    color: _getCategoryColor(entry.key),
                    height: double.infinity,
                    child: percentage > 0.1 ? Center(
                      child: Text(
                        '${(percentage * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ) : const SizedBox(),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Legend
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: distribution.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.key} (${entry.value})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryExpansionTile(String category, List<Ingredient> ingredients) {
    final isExpanded = _expandedCategories.contains(category);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 1,
      child: ExpansionTile(
        title: Text(
          '$category (${ingredients.length})',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(category),
          child: Text(
            ingredients.length.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              _expandedCategories.add(category);
            } else {
              _expandedCategories.remove(category);
            }
          });
        },
        children: ingredients.map(_buildIngredientTile).toList(),
      ),
    );
  }
  
  Widget _buildIngredientTile(Ingredient ingredient) {
    return ListTile(
      title: Text(
        ingredient.name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(ingredient.category),
      leading: CircleAvatar(
        backgroundColor: _getCategoryColor(ingredient.category).withOpacity(0.2),
        child: Text(
          ingredient.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: _getCategoryColor(ingredient.category),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      trailing: const Icon(Icons.info_outline, color: Colors.grey, size: 20),
      onTap: widget.onIngredientTap != null 
          ? () => widget.onIngredientTap!(ingredient)
          : null,
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'acid':
        return Colors.orange;
      case 'vitamin':
        return Colors.green;
      case 'oil':
        return Colors.amber;
      case 'plant extract':
        return Colors.teal;
      case 'alcohol':
        return Colors.red;
      case 'preservative':
        return Colors.purple;
      case 'antioxidant':
        return Colors.blue;
      case 'fragrance':
        return Colors.pink;
      case 'colorant':
        return Colors.indigo;
      case 'surfactant':
        return Colors.brown;
      case 'emollient':
        return Colors.cyan;
      case 'humectant':
        return Colors.lightGreen;
      default:
        return Colors.blueGrey;
    }
  }
}