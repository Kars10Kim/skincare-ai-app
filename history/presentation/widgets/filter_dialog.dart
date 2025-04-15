import 'package:flutter/material.dart';

import '../../../recognition/domain/entities/ingredient_conflict.dart';
import '../../domain/entities/scan_history_item.dart';

/// History filter dialog
class HistoryFilterDialog extends StatefulWidget {
  /// Apply filters callback
  final void Function(Map<String, dynamic>) onApplyFilters;
  
  /// Create history filter dialog
  const HistoryFilterDialog({
    Key? key,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<HistoryFilterDialog> createState() => _HistoryFilterDialogState();
}

class _HistoryFilterDialogState extends State<HistoryFilterDialog> {
  ScanHistoryItemType? _selectedScanType;
  DateTime? _startDate;
  DateTime? _endDate;
  ConflictSeverity? _minSeverity;
  RangeValues _safetyScoreRange = const RangeValues(0, 100);
  final List<String> _selectedTags = [];
  
  final Map<String, bool> _availableTags = {
    'summer': false,
    'winter': false,
    'sensitive': false,
    'daily': false,
    'travel': false,
  };
  
  String? _sortBy = 'date';
  String _sortDirection = 'desc';
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter History'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScanTypeFilter(),
            const Divider(),
            _buildDateRangeFilter(),
            const Divider(),
            _buildSeverityFilter(),
            const Divider(),
            _buildSafetyScoreFilter(),
            const Divider(),
            _buildTagsFilter(),
            const Divider(),
            _buildSortingOptions(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _resetFilters,
          child: const Text('RESET'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _applyFilters,
          child: const Text('APPLY'),
        ),
      ],
    );
  }
  
  Widget _buildScanTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scan Type',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: _selectedScanType == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedScanType = null;
                  });
                }
              },
            ),
            ChoiceChip(
              label: const Text('Barcode'),
              selected: _selectedScanType == ScanHistoryItemType.barcode,
              onSelected: (selected) {
                setState(() {
                  _selectedScanType = selected ? ScanHistoryItemType.barcode : null;
                });
              },
            ),
            ChoiceChip(
              label: const Text('Camera'),
              selected: _selectedScanType == ScanHistoryItemType.camera,
              onSelected: (selected) {
                setState(() {
                  _selectedScanType = selected ? ScanHistoryItemType.camera : null;
                });
              },
            ),
            ChoiceChip(
              label: const Text('Manual'),
              selected: _selectedScanType == ScanHistoryItemType.manual,
              onSelected: (selected) {
                setState(() {
                  _selectedScanType = selected ? ScanHistoryItemType.manual : null;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('From'),
                subtitle: Text(
                  _startDate != null
                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                      : 'Any date',
                ),
                onTap: () => _selectDate(true),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('To'),
                subtitle: Text(
                  _endDate != null
                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                      : 'Any date',
                ),
                onTap: () => _selectDate(false),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSeverityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conflict Severity',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Any'),
              selected: _minSeverity == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _minSeverity = null;
                  });
                }
              },
            ),
            ChoiceChip(
              label: const Text('Low or higher'),
              selected: _minSeverity == ConflictSeverity.low,
              onSelected: (selected) {
                setState(() {
                  _minSeverity = selected ? ConflictSeverity.low : null;
                });
              },
            ),
            ChoiceChip(
              label: const Text('Medium or higher'),
              selected: _minSeverity == ConflictSeverity.medium,
              onSelected: (selected) {
                setState(() {
                  _minSeverity = selected ? ConflictSeverity.medium : null;
                });
              },
            ),
            ChoiceChip(
              label: const Text('High only'),
              selected: _minSeverity == ConflictSeverity.high,
              onSelected: (selected) {
                setState(() {
                  _minSeverity = selected ? ConflictSeverity.high : null;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSafetyScoreFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Safety Score',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '${_safetyScoreRange.start.round()} - ${_safetyScoreRange.end.round()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        RangeSlider(
          values: _safetyScoreRange,
          min: 0,
          max: 100,
          divisions: 10,
          labels: RangeLabels(
            _safetyScoreRange.start.round().toString(),
            _safetyScoreRange.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _safetyScoreRange = values;
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildTagsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Wrap(
          spacing: 8,
          children: _availableTags.entries.map((entry) {
            return FilterChip(
              label: Text(entry.key),
              selected: entry.value,
              onSelected: (selected) {
                setState(() {
                  _availableTags[entry.key] = selected;
                  if (selected) {
                    _selectedTags.add(entry.key);
                  } else {
                    _selectedTags.remove(entry.key);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildSortingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: const InputDecoration(
                  labelText: 'Field',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'date',
                    child: Text('Date'),
                  ),
                  DropdownMenuItem(
                    value: 'safetyScore',
                    child: Text('Safety Score'),
                  ),
                  DropdownMenuItem(
                    value: 'conflictSeverity',
                    child: Text('Conflict Severity'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortBy = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _sortDirection,
                decoration: const InputDecoration(
                  labelText: 'Direction',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'desc',
                    child: Text('Descending'),
                  ),
                  DropdownMenuItem(
                    value: 'asc',
                    child: Text('Ascending'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortDirection = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Future<void> _selectDate(bool isStartDate) async {
    final initialDate = isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // If end date is before start date, adjust it
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = pickedDate;
          // If start date is after end date, adjust it
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }
  
  void _resetFilters() {
    setState(() {
      _selectedScanType = null;
      _startDate = null;
      _endDate = null;
      _minSeverity = null;
      _safetyScoreRange = const RangeValues(0, 100);
      _selectedTags.clear();
      _availableTags.forEach((key, value) {
        _availableTags[key] = false;
      });
      _sortBy = 'date';
      _sortDirection = 'desc';
    });
  }
  
  void _applyFilters() {
    final filters = <String, dynamic>{};
    
    if (_selectedScanType != null) {
      filters['scanType'] = _selectedScanType;
    }
    
    if (_startDate != null && _endDate != null) {
      filters['startDate'] = _startDate;
      filters['endDate'] = _endDate;
    }
    
    if (_minSeverity != null) {
      filters['minSeverity'] = _minSeverity;
    }
    
    if (_safetyScoreRange.start > 0 || _safetyScoreRange.end < 100) {
      filters['minSafetyScore'] = _safetyScoreRange.start.round();
      filters['maxSafetyScore'] = _safetyScoreRange.end.round();
    }
    
    if (_selectedTags.isNotEmpty) {
      filters['tags'] = _selectedTags;
    }
    
    if (_sortBy != null) {
      filters['sortBy'] = _sortBy;
      filters['sortDirection'] = _sortDirection;
    }
    
    widget.onApplyFilters(filters);
    Navigator.of(context).pop();
  }
}