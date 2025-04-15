import 'package:flutter/material.dart';
import '../../models/product_model.dart';

/// Dialog for resolving data synchronization conflicts
class ConflictResolutionDialog extends StatelessWidget {
  final String barcode;
  final String title;
  final String message;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final Function(String, String) onResolve;
  
  const ConflictResolutionDialog({
    Key? key,
    required this.barcode,
    required this.title,
    required this.message,
    required this.localData,
    required this.remoteData,
    required this.onResolve,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Local Data Section
            _buildDataSection(
              context: context,
              title: 'Local Data (This Device)',
              data: localData,
              isPrimary: true,
            ),
            const SizedBox(height: 12),
            
            // Remote Data Section
            _buildDataSection(
              context: context,
              title: 'Server Data',
              data: remoteData,
              isPrimary: false,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          onPressed: () {
            onResolve(barcode, 'keep_local');
            Navigator.of(context).pop('local');
          },
          child: const Text('Keep Local'),
        ),
        ElevatedButton(
          onPressed: () {
            onResolve(barcode, 'use_remote');
            Navigator.of(context).pop('remote');
          },
          child: const Text('Use Server'),
        ),
      ],
    );
  }
  
  /// Build a section displaying data for comparison
  Widget _buildDataSection({
    required BuildContext context,
    required String title,
    required Map<String, dynamic> data,
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrimary 
            ? Colors.blue.withOpacity(0.1) 
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary ? Colors.blue.shade300 : Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.blue.shade700 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ...data.entries.map((entry) => _buildDataRow(
            context: context,
            label: entry.key,
            value: entry.value.toString(),
          )).toList(),
        ],
      ),
    );
  }
  
  /// Build a row displaying a label and value
  Widget _buildDataRow({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Show the conflict resolution dialog
  static Future<String?> show({
    required BuildContext context,
    required String barcode,
    required String title,
    required String message,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
    required Function(String, String) onResolve,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConflictResolutionDialog(
          barcode: barcode,
          title: title,
          message: message,
          localData: localData,
          remoteData: remoteData,
          onResolve: onResolve,
        );
      },
    );
  }
}