import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/ingredient_model.dart';
import '../../models/study_reference.dart';
import '../../services/conflict_validator.dart';

/// A card widget that displays an ingredient conflict with expandable details
class ConflictCard extends StatefulWidget {
  /// The conflict to display
  final IngredientConflict conflict;
  
  /// Optional conflict validator for reference validation
  final ConflictValidator? validator;
  
  /// Callback when the user taps on an ingredient
  final Function(String)? onIngredientTap;
  
  const ConflictCard({
    Key? key,
    required this.conflict,
    this.validator,
    this.onIngredientTap,
  }) : super(key: key);

  @override
  State<ConflictCard> createState() => _ConflictCardState();
}

class _ConflictCardState extends State<ConflictCard> {
  late IngredientConflict _conflict;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _conflict = widget.conflict;
    
    // Validate studies if validator is provided and studies exist
    if (widget.validator != null && 
        widget.conflict.studies != null && 
        widget.conflict.studies!.isNotEmpty) {
      _validateStudies();
    }
  }
  
  Future<void> _validateStudies() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final validatedConflict = await widget.validator!.validateConflict(widget.conflict);
      setState(() {
        _conflict = validatedConflict;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error validating studies: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getSeverityColor(_conflict.severity).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getSeverityColor(_conflict.severity).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(_conflict.severity),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _conflict.severity.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Conflict Detected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _getSeverityColor(_conflict.severity),
                    ),
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          
          // Ingredients
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildIngredientTag(_conflict.ingredientA),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.warning, color: Colors.amber),
                ),
                Expanded(
                  child: _buildIngredientTag(_conflict.ingredientB),
                ),
              ],
            ),
          ),
          
          // Reason
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _conflict.reason,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          
          // Recommendation
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _conflict.recommendation,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // References
          if (_conflict.hasScientificBacking)
            _StudiesExpansion(_conflict.studies!),
        ],
      ),
    );
  }
  
  Widget _buildIngredientTag(String ingredient) {
    return InkWell(
      onTap: widget.onIngredientTap != null 
          ? () => widget.onIngredientTap!(ingredient)
          : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          ingredient,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    );
  }
  
  Color _getSeverityColor(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.mild:
        return Colors.orange.shade300;
      case ConflictSeverity.moderate:
        return Colors.orange;
      case ConflictSeverity.severe:
        return Colors.deepOrange;
      case ConflictSeverity.critical:
        return Colors.red;
    }
  }
}

/// Widget for displaying study references in an expansion tile
class _StudiesExpansion extends StatelessWidget {
  final List<StudyReference> studies;

  const _StudiesExpansion(this.studies);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Scientific References'),
      children: studies.map((study) => ListTile(
        leading: study.id.startsWith('10.') 
          ? const Icon(Icons.article, color: Colors.indigo) 
          : const Icon(Icons.medical_services, color: Colors.teal),
        title: Text(study.journal ?? 'Unverified Journal'),
        subtitle: Text(study.citation),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new, size: 20),
          onPressed: () => _launchStudyUrl(context, study),
        ),
      )).toList(),
    );
  }

  Future<void> _launchStudyUrl(BuildContext context, StudyReference study) async {
    try {
      final url = study.id.startsWith('10.') ? study.doiUrl : study.pubmedUrl;
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open reference')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}