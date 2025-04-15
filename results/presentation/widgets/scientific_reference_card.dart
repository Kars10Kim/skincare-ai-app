import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/scientific_reference.dart';

/// Widget to display scientific reference
class ScientificReferenceCard extends StatelessWidget {
  /// Scientific reference
  final ScientificReference reference;
  
  /// Card elevation
  final double elevation;
  
  /// Create scientific reference card
  const ScientificReferenceCard({
    super.key,
    required this.reference,
    this.elevation = 1.0,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Card(
      elevation: elevation,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with verification status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    reference.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                _buildVerificationBadge(context),
              ],
            ),
            
            const SizedBox(height: 8.0),
            
            // Journal and year
            if (reference.journal != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.book,
                    size: 14.0,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      reference.year != null 
                          ? '${reference.journal} (${reference.year})' 
                          : reference.journal!,
                      style: textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4.0),
            ],
            
            // Authors
            if (reference.authors != null && reference.authors!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.person,
                    size: 14.0,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      reference.authors!.join(', '),
                      style: textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8.0),
            ],
            
            // Summary
            if (reference.summary != null) ...[
              Text(
                reference.summary!,
                style: textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 12.0),
            ],
            
            // DOI and PubMed ID
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                if (reference.doi != null)
                  _buildReferenceChip(
                    context,
                    'DOI: ${reference.doi}',
                    Icons.link,
                    onTap: () => _launchUrl('https://doi.org/${reference.doi}'),
                  ),
                
                if (reference.pubMedId != null)
                  _buildReferenceChip(
                    context,
                    'PubMed: ${reference.pubMedId}',
                    Icons.medical_information,
                    onTap: () => _launchUrl(
                      'https://pubmed.ncbi.nlm.nih.gov/${reference.pubMedId}/',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build verification badge
  Widget _buildVerificationBadge(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;
    
    switch (reference.verificationStatus) {
      case VerificationStatus.verified:
        badgeColor = Colors.green;
        badgeText = 'Verified';
        badgeIcon = Icons.check_circle;
        break;
      case VerificationStatus.pending:
        badgeColor = Colors.amber;
        badgeText = 'Pending';
        badgeIcon = Icons.access_time;
        break;
      case VerificationStatus.failed:
        badgeColor = Colors.red;
        badgeText = 'Failed';
        badgeIcon = Icons.cancel;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 12.0,
            color: badgeColor,
          ),
          const SizedBox(width: 4.0),
          Text(
            badgeText,
            style: textTheme.bodySmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build reference chip
  Widget _buildReferenceChip(
    BuildContext context,
    String text,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.0,
              color: primary,
            ),
            const SizedBox(width: 4.0),
            Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Launch URL
  Future<void> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}