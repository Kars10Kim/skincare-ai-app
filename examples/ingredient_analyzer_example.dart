import 'package:flutter/material.dart';
import '../core/services/service_locator.dart';
import '../core/services/individual_services/ingredient_analyzer_service.dart';
import '../core/models/ingredient_models.dart';
import '../widgets/service_aware_widget.dart';

/// Example screen demonstrating the IngredientAnalyzerService
/// 
/// This screen shows how to:
/// - Properly use the ingredients analyzer service
/// - Display ingredient conflicts
/// - Show safety ratings and recommendations
class IngredientAnalyzerExample extends StatefulWidget {
  const IngredientAnalyzerExample({Key? key}) : super(key: key);

  @override
  State<IngredientAnalyzerExample> createState() => _IngredientAnalyzerExampleState();
}

class _IngredientAnalyzerExampleState extends State<IngredientAnalyzerExample> {
  final TextEditingController _ingredientsController = TextEditingController();
  bool _isAnalyzing = false;
  IngredientAnalysisResult? _analysisResult;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _ingredientsController.text = 'Glycolic Acid, Retinol, Niacinamide, Hyaluronic Acid';
  }
  
  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }
  
  /// Analyze the ingredients
  Future<void> _analyzeIngredients() async {
    final ingredientsText = _ingredientsController.text.trim();
    
    if (ingredientsText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter ingredients';
      });
      return;
    }
    
    setState(() {
      _isAnalyzing = true;
      _errorMessage = '';
      _analysisResult = null;
    });
    
    try {
      // Parse the ingredients
      final ingredients = ingredientsText
          .split(',')
          .map((i) => i.trim())
          .where((i) => i.isNotEmpty)
          .toList();
      
      // Get ingredient analyzer service
      final analyzerService = await ServiceLocator.instance.get<IngredientAnalyzerService>();
      
      // Analyze the ingredients
      final result = await analyzerService.analyzeIngredients(ingredients);
      
      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error analyzing ingredients: $e';
          _isAnalyzing = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Analyzer'),
      ),
      body: ServiceAwareWidget(
        showConnectivity: true,
        trackInAnalytics: true,
        screenName: 'ingredient_analyzer_example',
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Ingredients (comma separated)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. Glycolic Acid, Retinol, Niacinamide',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeIngredients,
                child: _isAnalyzing
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Analyze Ingredients'),
              ),
              const SizedBox(height: 16),
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red.shade100,
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              if (_analysisResult != null) ...[
                _buildSafetyRating(_analysisResult!),
                const SizedBox(height: 16),
                Text(
                  'Conflicts (${_analysisResult!.conflicts.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Expanded(
                  child: _buildConflictsList(_analysisResult!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build the safety rating widget
  Widget _buildSafetyRating(IngredientAnalysisResult result) {
    Color safetyColor;
    String safetyText;
    IconData safetyIcon;
    
    if (result.offlineMode) {
      safetyColor = Colors.grey;
      safetyText = 'Offline Mode - Cannot Analyze';
      safetyIcon = Icons.signal_wifi_off;
    } else if (result.hasError) {
      safetyColor = Colors.red;
      safetyText = 'Error Analyzing Ingredients';
      safetyIcon = Icons.error_outline;
    } else if (result.safetyRating >= 90) {
      safetyColor = Colors.green;
      safetyText = 'Very Safe';
      safetyIcon = Icons.check_circle;
    } else if (result.safetyRating >= 70) {
      safetyColor = Colors.lightGreen;
      safetyText = 'Generally Safe';
      safetyIcon = Icons.check;
    } else if (result.safetyRating >= 50) {
      safetyColor = Colors.orange;
      safetyText = 'Use with Caution';
      safetyIcon = Icons.warning;
    } else {
      safetyColor = Colors.red;
      safetyText = 'Potentially Problematic';
      safetyIcon = Icons.dangerous;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: safetyColor.withOpacity(0.1),
        border: Border.all(color: safetyColor),
      ),
      child: Row(
        children: [
          Icon(
            safetyIcon,
            color: safetyColor,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  safetyText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: safetyColor,
                  ),
                ),
                if (!result.offlineMode && !result.hasError)
                  Text(
                    'Safety Rating: ${result.safetyRating}/100',
                    style: TextStyle(
                      color: safetyColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build the conflicts list
  Widget _buildConflictsList(IngredientAnalysisResult result) {
    if (result.conflicts.isEmpty) {
      return const Center(
        child: Text('No conflicts found between these ingredients'),
      );
    }
    
    return ListView.builder(
      itemCount: result.conflicts.length,
      itemBuilder: (context, index) {
        final conflict = result.conflicts[index];
        return _buildConflictItem(conflict);
      },
    );
  }
  
  /// Build a conflict item
  Widget _buildConflictItem(IngredientConflict conflict) {
    Color severityColor;
    IconData severityIcon;
    
    switch (conflict.severity) {
      case ConflictSeverity.low:
        severityColor = Colors.blue;
        severityIcon = Icons.info_outline;
        break;
      case ConflictSeverity.moderate:
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      case ConflictSeverity.high:
        severityColor = Colors.red;
        severityIcon = Icons.dangerous;
        break;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  severityIcon,
                  color: severityColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '${conflict.severity.name.toUpperCase()} SEVERITY',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: severityColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${conflict.ingredient1} + ${conflict.ingredient2}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              conflict.reason,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RECOMMENDATION',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(conflict.recommendation),
                ],
              ),
            ),
            if (conflict.citation != null) ...[
              const SizedBox(height: 8),
              Text(
                'Source: ${conflict.citation}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}