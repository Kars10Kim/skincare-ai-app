import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/conflict/conflict_model.dart';
import '../../widgets/conflict/conflict_severity_widget.dart';
import '../../utils/auto_dispose_mixin.dart';
import '../../utils/accessibility.dart';

/// Screen showing detailed information about an ingredient conflict
class ConflictDetailScreen extends StatefulWidget {
  /// The conflict to display
  final Conflict conflict;
  
  /// Creates a conflict detail screen
  const ConflictDetailScreen({
    Key? key, 
    required this.conflict,
  }) : super(key: key);

  @override
  State<ConflictDetailScreen> createState() => _ConflictDetailScreenState();
}

class _ConflictDetailScreenState extends State<ConflictDetailScreen>
    with AutoDisposeMixin, AccessibilitySupport {
  
  /// Handle tap on DOI link
  Future<void> _handleDoiTap(String? doi) async {
    if (doi == null) return;
    
    final url = Uri.parse('https://doi.org/$doi');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Show error snackbar if URL can't be launched
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open citation link'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conflict Details'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Conflict name and type
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.conflict.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.conflict.type.displayName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Severity widget (expanded detailed view)
              ConflictSeverityWidget(
                conflict: widget.conflict,
                showDetails: true,
                showCitation: true,
                onCitationTap: _handleDoiTap,
              ),
              const SizedBox(height: 24),
              
              // Affected ingredients
              _buildSection(
                context,
                title: 'Affected Ingredients',
                icon: Icons.science,
                child: Column(
                  children: [
                    for (final ingredient in widget.conflict.ingredients)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const CircleAvatar(
                          backgroundColor: Colors.amber,
                          child: Icon(Icons.warning, color: Colors.white, size: 16),
                        ),
                        title: Text(
                          _capitalizeFirstLetter(ingredient),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          // Navigate to ingredient details in the future
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Description
              _buildSection(
                context,
                title: 'What This Means',
                icon: Icons.info_outline,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    widget.conflict.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Recommendation
              if (widget.conflict.recommendation != null) ...[
                _buildSection(
                  context,
                  title: 'Recommendations',
                  icon: Icons.lightbulb_outline,
                  backgroundColor: Colors.green.shade50,
                  iconColor: Colors.green,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      widget.conflict.recommendation!,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Additional resources
              _buildSection(
                context,
                title: 'Additional Resources',
                icon: Icons.link,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.conflict.url != null)
                      _buildResourceLink(
                        context, 
                        'Learn more', 
                        widget.conflict.url!,
                      ),
                    if (widget.conflict.doi != null)
                      _buildResourceLink(
                        context, 
                        'View research paper', 
                        'https://doi.org/${widget.conflict.doi!}',
                      ),
                    const SizedBox(height: 12),
                    const Text(
                      'Note: This information is provided for educational purposes only and is not meant to replace professional medical advice.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build a section with a title and icon
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: backgroundColor != null 
              ? backgroundColor.withOpacity(0.5) 
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
  
  /// Build a clickable resource link
  Widget _buildResourceLink(BuildContext context, String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () async {
          try {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          } catch (e) {
            debugPrint('Could not launch URL: $e');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.open_in_new,
                size: 16,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Capitalize the first letter of a string
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}