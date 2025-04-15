import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// Dialog for requesting API keys from the user
class ApiKeyDialog extends StatefulWidget {
  final String apiName;
  final String description;
  final String? initialValue;
  final Function(String) onSubmit;
  
  const ApiKeyDialog({
    Key? key,
    required this.apiName,
    required this.description,
    this.initialValue,
    required this.onSubmit,
  }) : super(key: key);
  
  /// Show the API key dialog
  static Future<String?> show({
    required BuildContext context,
    required String apiName,
    required String description,
    String? initialValue,
    required Function(String) onSubmit,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ApiKeyDialog(
          apiName: apiName,
          description: description,
          initialValue: initialValue,
          onSubmit: onSubmit,
        );
      },
    );
  }
  
  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  late TextEditingController _controller;
  bool _isValid = false;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _validateInput(widget.initialValue ?? '');
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _validateInput(String value) {
    setState(() {
      _isValid = value.trim().isNotEmpty;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.apiName} API Key'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '${widget.apiName} API Key',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              obscureText: true,
              onChanged: _validateInput,
            ),
            const SizedBox(height: 8),
            const Text(
              'This key will be stored locally and used only for API requests.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
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
          onPressed: _isValid
              ? () {
                  widget.onSubmit(_controller.text.trim());
                  Navigator.of(context).pop(_controller.text.trim());
                }
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}