import 'package:flutter/material.dart';
import '../../models/product_model.dart';

/// Widget for displaying ingredient conflict severity triage
/// with scientific reference validation
class ConflictSeverityTriageWidget extends StatelessWidget {
  final List<IngredientConflict> conflicts;
  final bool showReferences;
  final Function(IngredientConflict)? onConflictTap;
  
  const ConflictSeverityTriageWidget({
    Key? key,
    required this.conflicts,
    this.showReferences = true,
    this.onConflictTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Group conflicts by severity level
    final Map<String, List<IngredientConflict>> groupedConflicts = {
      'High': [],
      'Medium': [],
      'Low': [],
    };
    
    for (final conflict in conflicts) {
      final severity = conflict.severityLevel;
      if (groupedConflicts.containsKey(severity)) {
        groupedConflicts[severity]!.add(conflict);
      } else {
        // Default to low severity if unknown
        groupedConflicts['Low']!.add(conflict);
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and overview
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Conflict Severity Triage (${conflicts.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // High severity conflicts
        if (groupedConflicts['High']!.isNotEmpty)
          _buildSeveritySection(
            context: context,
            title: 'High Severity',
            conflicts: groupedConflicts['High']!,
            color: Colors.red.shade700,
            backgroundColor: Colors.red.shade50,
          ),
        
        // Medium severity conflicts
        if (groupedConflicts['Medium']!.isNotEmpty)
          _buildSeveritySection(
            context: context,
            title: 'Medium Severity',
            conflicts: groupedConflicts['Medium']!,
            color: Colors.orange.shade700,
            backgroundColor: Colors.orange.shade50,
          ),
        
        // Low severity conflicts
        if (groupedConflicts['Low']!.isNotEmpty)
          _buildSeveritySection(
            context: context,
            title: 'Low Severity',
            conflicts: groupedConflicts['Low']!,
            color: Colors.blue.shade700,
            backgroundColor: Colors.blue.shade50,
          ),
        
        // No conflicts message
        if (conflicts.isEmpty)
          _buildNoConflictsMessage(context),
      ],
    );
  }
  
  /// Build a section displaying conflicts of a specific severity
  Widget _buildSeveritySection({
    required BuildContext context,
    required String title,
    required List<IngredientConflict> conflicts,
    required Color color,
    required Color backgroundColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              '$title (${conflicts.length})',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border.all(
                color: color.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: conflicts.map((conflict) => _buildConflictItem(
                context: context,
                conflict: conflict,
                color: color,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a widget displaying a single conflict
  Widget _buildConflictItem({
    required BuildContext context,
    required IngredientConflict conflict,
    required Color color,
  }) {
    return InkWell(
      onTap: onConflictTap != null ? () => onConflictTap!(conflict) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ingredients
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: conflict.ingredientA,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' + '),
                  TextSpan(
                    text: conflict.ingredientB,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            
            // Description
            Text(
              conflict.description,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
            
            // References
            if (showReferences && conflict.scientificReferences.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 4),
              Text(
                'Scientific References (${conflict.scientificReferences.length}):',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              ...conflict.scientificReferences.map((ref) => _buildReference(
                context: context,
                reference: ref,
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Build a widget displaying a scientific reference
  Widget _buildReference({
    required BuildContext context,
    required AcademicReference reference,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.article_outlined,
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              reference.getFormattedCitation(),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a message when there are no conflicts
  Widget _buildNoConflictsMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Conflicts Found',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'These ingredients appear to work well together based on our current data.',
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}