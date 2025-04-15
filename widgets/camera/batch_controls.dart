import 'package:flutter/material.dart';

class BatchControls extends StatelessWidget {
  final bool isBatchMode;
  final int batchCount;
  final VoidCallback onToggleBatchMode;
  final VoidCallback onClearBatch;
  final VoidCallback onCompleteBatch;

  const BatchControls({
    Key? key,
    required this.isBatchMode,
    required this.batchCount,
    required this.onToggleBatchMode,
    required this.onClearBatch,
    required this.onCompleteBatch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Batch mode toggle button
                ElevatedButton.icon(
                  onPressed: onToggleBatchMode,
                  icon: Icon(isBatchMode ? Icons.close : Icons.add_shopping_cart),
                  label: Text(isBatchMode ? 'Exit Batch' : 'Batch Mode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBatchMode ? Colors.red : Colors.teal,
                  ),
                ),
                
                // Batch count indicator
                if (isBatchMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '$batchCount items',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Complete batch button (only if items are in batch)
                if (isBatchMode && batchCount > 0)
                  ElevatedButton.icon(
                    onPressed: onCompleteBatch,
                    icon: const Icon(Icons.check),
                    label: const Text('Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  
                // Clear batch button (only if items are in batch)
                if (isBatchMode && batchCount > 0)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: onClearBatch,
                    tooltip: 'Clear batch',
                  ),
              ],
            ),
            
            // Instructions
            if (isBatchMode)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Scan multiple products. Tap Complete when finished.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}