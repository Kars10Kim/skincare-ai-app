import 'package:flutter/material.dart';
import '../utils/api_key_manager.dart';
import '../utils/constants.dart';

/// Dialog for setting up API keys
class ApiKeyDialog extends StatefulWidget {
  /// Whether to show the dialog when opened
  final bool showOnOpen;
  
  /// Creates an API key dialog
  const ApiKeyDialog({
    Key? key,
    this.showOnOpen = false,
  }) : super(key: key);
  
  /// Shows the API key dialog
  static Future<bool> show(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ApiKeyDialog(showOnOpen: true),
    ) ?? false;
  }

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final TextEditingController _visionApiController = TextEditingController();
  bool _isVisionApiKeyValid = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.showOnOpen) {
      _checkExistingKeys();
    }
  }
  
  Future<void> _checkExistingKeys() async {
    setState(() {
      _isLoading = true;
    });
    
    final hasVisionKey = await ApiKeyManager.hasGoogleVisionApiKey();
    
    setState(() {
      _isVisionApiKeyValid = hasVisionKey;
      _isLoading = false;
    });
  }
  
  Future<void> _saveGoogleVisionApiKey() async {
    final apiKey = _visionApiController.text.trim();
    
    if (apiKey.isEmpty) {
      _showErrorSnackBar('Please enter a valid API key');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final success = await ApiKeyManager.saveGoogleVisionApiKey(apiKey);
    
    setState(() {
      _isVisionApiKeyValid = success;
      _isLoading = false;
    });
    
    if (success) {
      _showSuccessSnackBar('Google Vision API key saved successfully');
      _visionApiController.clear();
    } else {
      _showErrorSnackBar('Failed to save Google Vision API key');
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
      ),
    );
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successColor,
      ),
    );
  }
  
  @override
  void dispose() {
    _visionApiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('API Key Setup'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To use the product recognition feature, you need to provide a Google Vision API key. '
              'This key will be stored securely on your device.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _visionApiController,
              decoration: InputDecoration(
                labelText: 'Google Vision API Key',
                hintText: 'Enter your API key here',
                prefixIcon: const Icon(Icons.vpn_key),
                suffixIcon: _isVisionApiKeyValid
                    ? const Icon(Icons.check_circle, color: AppColors.successColor)
                    : null,
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    if (widget.showOnOpen) {
                      Navigator.of(context).pop(_isVisionApiKeyValid);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveGoogleVisionApiKey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save Key'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}