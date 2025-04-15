
import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ConflictHeatmap extends StatelessWidget {
  final List<Map<String, dynamic>> conflicts;

  const ConflictHeatmap({
    Key? key,
    required this.conflicts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingredient Conflict Heatmap',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1,
              ),
              itemCount: conflicts.length,
              itemBuilder: (context, index) {
                final conflict = conflicts[index];
                return Tooltip(
                  message: conflict['description'] as String,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(conflict['severity'] as int),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 3:
        return Colors.red.shade300;
      case 2:
        return Colors.orange.shade300;
      case 1:
        return Colors.yellow.shade300;
      default:
        return Colors.green.shade300;
    }
  }
}
