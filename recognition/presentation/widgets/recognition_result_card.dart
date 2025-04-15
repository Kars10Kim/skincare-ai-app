import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skincare_scanner/features/recognition/domain/entities/recognized_product.dart';
import 'package:skincare_scanner/localization/product_recognition_localizations.dart';

/// Card to display recognition results
class RecognitionResultCard extends StatelessWidget {
  /// The recognized product
  final RecognizedProduct? product;
  
  /// Callback when retry button is pressed
  final VoidCallback? onRetry;
  
  /// Create recognition result card
  const RecognitionResultCard({
    Key? key,
    this.product,
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    // If no product was recognized
    if (product == null) {
      return _buildErrorCard(context, theme, localizations);
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name and brand
              if (product!.name != null) ...[
                Text(
                  product!.name!,
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product!.brand != null)
                  Text(
                    product!.brand!,
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                const SizedBox(height: 8),
              ],
              
              // Match confidence
              if (product!.matchConfidence != null) ...[
                LinearProgressIndicator(
                  value: product!.matchConfidence! / 100,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Match Confidence',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${NumberFormat.percentPattern().format(product!.matchConfidence! / 100)}',
                      style: theme.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              
              // Ingredients preview
              if (product!.ingredients.isNotEmpty) ...[
                Text(
                  'Ingredients',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: product!.ingredients
                      .take(10)
                      .map((ingredient) => _buildIngredientChip(
                            context,
                            ingredient,
                          ))
                      .toList(),
                ),
                if (product!.ingredients.length > 10) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${product!.ingredients.length - 10} more',
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
              
              // Action buttons
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onRetry,
                    child: Text(localizations.tryAgain),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/results', arguments: product);
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build error card when no product was recognized
  Widget _buildErrorCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: theme.colorScheme.errorContainer.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recognition Failed',
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Unable to recognize product. Please try again with a clearer image.',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onErrorContainer,
                    ),
                    child: Text(localizations.tryAgain),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/manual-entry');
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(localizations.manualEntry),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.onErrorContainer,
                      foregroundColor: theme.colorScheme.errorContainer,
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
  
  /// Build ingredient chip
  Widget _buildIngredientChip(BuildContext context, String ingredient) {
    final theme = Theme.of(context);
    
    return Chip(
      label: Text(
        ingredient,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: theme.colorScheme.surfaceVariant,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}