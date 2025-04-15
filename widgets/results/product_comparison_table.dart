
import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductComparisonTable extends StatelessWidget {
  final List<Product> products;
  final List<Map<String, dynamic>> conflicts;
  final Function(int, bool)? onSort;

  const ProductComparisonTable({
    Key? key,
    required this.products,
    required this.conflicts,
    this.onSort,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(
            label: const Text('Product'),
            onSort: (columnIndex, ascending) => onSort?.call(columnIndex, ascending),
          ),
          DataColumn(
            label: const Text('Ingredients'),
            onSort: (columnIndex, ascending) => onSort?.call(columnIndex, ascending),
          ),
          DataColumn(
            label: const Text('Conflicts'),
            onSort: (columnIndex, ascending) => onSort?.call(columnIndex, ascending),
          ),
        ],
        rows: products.map((product) {
          final productConflicts = conflicts.where(
            (c) => c['products'].contains(product.barcode)
          ).toList();
          
          return DataRow(
            cells: [
              DataCell(Text(product.name)),
              DataCell(Text('${product.ingredients.length} ingredients')),
              DataCell(Text('${productConflicts.length} conflicts')),
            ],
          );
        }).toList(),
      ),
    );
  }
}
