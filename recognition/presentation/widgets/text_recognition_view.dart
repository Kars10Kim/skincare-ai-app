import 'package:flutter/material.dart';

/// Text recognition view for manually entering ingredients
class TextRecognitionView extends StatefulWidget {
  /// Initial text
  final String? initialText;
  
  /// On text extracted callback
  final Function(String) onTextExtracted;
  
  /// On pick image callback
  final VoidCallback onPickImage;
  
  /// Create text recognition view
  const TextRecognitionView({
    Key? key,
    this.initialText,
    required this.onTextExtracted,
    required this.onPickImage,
  }) : super(key: key);

  @override
  State<TextRecognitionView> createState() => _TextRecognitionViewState();
}

class _TextRecognitionViewState extends State<TextRecognitionView> {
  /// Text controller
  late TextEditingController _textController;
  
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }
  
  @override
  void didUpdateWidget(TextRecognitionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update text controller if initial text changes
    if (widget.initialText != oldWidget.initialText && widget.initialText != null) {
      _textController.text = widget.initialText!;
    }
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
  
  /// Process text
  void _processText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    widget.onTextExtracted(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Text field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Paste or type product ingredients here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Helper text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enter ingredients separated by commas or copy directly from product label',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  // Image button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onPickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Scan Image'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.white54),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Process button
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _processText,
                      icon: const Icon(Icons.check),
                      label: const Text('Analyze'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 70), // Extra space for bottom sheet
            ],
          ),
        ),
      ),
    );
  }
}