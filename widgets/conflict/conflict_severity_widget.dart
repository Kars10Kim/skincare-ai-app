import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/conflict/conflict_model.dart';
import '../../utils/accessibility.dart';
import '../../services/connectivity_service.dart';

/// Widget to display conflict severity with citations
class ConflictSeverityWidget extends StatefulWidget {
  /// The conflict to display
  final Conflict conflict;
  
  /// Whether to show details (expanded mode)
  final bool showDetails;
  
  /// Whether to show citation info
  final bool showCitation;
  
  /// Size of the severity indicator
  final double size;
  
  /// Callback when citation is tapped
  final Function(String? doi)? onCitationTap;
  
  /// Create a conflict severity widget
  const ConflictSeverityWidget({
    Key? key,
    required this.conflict,
    this.showDetails = false,
    this.showCitation = true,
    this.size = 40,
    this.onCitationTap,
  }) : super(key: key);
  
  @override
  State<ConflictSeverityWidget> createState() => _ConflictSeverityWidgetState();
}

class _ConflictSeverityWidgetState extends State<ConflictSeverityWidget> {
  bool _isVerifyingDOI = false;
  String? _citationInfo;
  bool _isCitationValid = false;
  String? _publicationDate;
  String? _journalName;
  bool _hasAttemptedVerification = false;
  
  @override
  void initState() {
    super.initState();
    
    // Only auto-verify if DOI is provided and citation should be shown
    if (widget.conflict.doi != null && widget.showCitation) {
      _verifyDOI(widget.conflict.doi!);
    }
  }
  
  @override
  void didUpdateWidget(ConflictSeverityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Re-verify if DOI has changed
    if (widget.conflict.doi != oldWidget.conflict.doi && 
        widget.conflict.doi != null && 
        widget.showCitation) {
      _verifyDOI(widget.conflict.doi!);
    }
  }
  
  /// Verify DOI reference and retrieve citation info
  Future<void> _verifyDOI(String doi) async {
    if (_isVerifyingDOI || !mounted) return;
    
    setState(() {
      _isVerifyingDOI = true;
      _hasAttemptedVerification = true;
    });
    
    try {
      // Check if we're connected first
      final connectivityService = ConnectivityService();
      if (!await connectivityService.isConnected()) {
        setState(() {
          _isVerifyingDOI = false;
          _citationInfo = 'Cannot verify citation while offline';
          _isCitationValid = false;
        });
        return;
      }
      
      // CrossRef API endpoint
      final response = await http.get(
        Uri.parse('https://api.crossref.org/works/$doi'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'];
        
        // Extract publication details
        final title = message['title']?[0] ?? 'Unknown Title';
        final authors = (message['author'] as List?)?.map((a) => 
            '${a['given'] ?? ''} ${a['family'] ?? ''}').join(', ') ?? 'Unknown Author';
        final journal = message['container-title']?[0] ?? 'Unknown Journal';
        final year = message['published']?['date-parts']?[0]?[0]?.toString() ?? 'Unknown Year';
        
        // Save journal and date info for display
        _journalName = journal;
        _publicationDate = year;
        
        // Format citation info
        _citationInfo = '$authors. "$title." $journal ($year)';
        _isCitationValid = true;
      } else {
        // Invalid or not found DOI
        _citationInfo = 'Invalid citation reference';
        _isCitationValid = false;
      }
    } catch (e) {
      // Error during verification
      _citationInfo = 'Error verifying citation';
      _isCitationValid = false;
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingDOI = false;
        });
      }
    }
  }
  
  /// Get color for severity level
  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red.shade700;
      case 'medium':
        return Colors.orange.shade700;
      case 'low':
        return Colors.yellow.shade700;
      default:
        return Colors.grey;
    }
  }
  
  /// Get text color for severity level (ensuring contrast)
  Color _getSeverityTextColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'medium':
        return Colors.white;
      case 'low':
      default:
        return Colors.black87;
    }
  }
  
  /// Get severity level text
  String _getSeverityText(String severity) {
    return severity.substring(0, 1).toUpperCase() + severity.substring(1);
  }
  
  /// Build verification status badge
  Widget _buildVerificationBadge() {
    if (!_hasAttemptedVerification) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _isCitationValid ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCitationValid ? Colors.green.shade700 : Colors.red.shade700,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isCitationValid ? Icons.verified : Icons.warning,
            size: 14,
            color: _isCitationValid ? Colors.green.shade800 : Colors.red.shade800,
          ),
          const SizedBox(width: 4),
          Text(
            _isCitationValid ? 'Verified' : 'Unverified',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _isCitationValid ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(widget.conflict.severity);
    final textColor = _getSeverityTextColor(widget.conflict.severity);
    final accessibilitySettings = context.accessibilitySettings;
    
    // Use high contrast colors if needed
    final effectiveColor = accessibilitySettings.highContrast 
        ? (widget.conflict.severity.toLowerCase() == 'high' 
            ? Colors.red.shade900 
            : widget.conflict.severity.toLowerCase() == 'medium'
                ? Colors.orange.shade900
                : Colors.yellow.shade900)
        : severityColor;
    
    // For compact mode without details
    if (!widget.showDetails) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Tooltip(
          message: 'Severity: ${_getSeverityText(widget.conflict.severity)}',
          child: Container(
            decoration: BoxDecoration(
              color: effectiveColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: effectiveColor.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.conflict.severity.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.size * 0.5,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    // Detailed card view with severity and citation info
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: effectiveColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Severity: ${_getSeverityText(widget.conflict.severity)}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.conflict.evidence != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Evidence: ${widget.conflict.evidence}',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            // Citation information
            if (widget.showCitation && widget.conflict.doi != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.source, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Academic Reference',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildVerificationBadge(),
                ],
              ),
              const SizedBox(height: 8),
              if (_isVerifyingDOI)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (_citationInfo != null)
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _citationInfo!,
                        style: TextStyle(
                          fontSize: 13,
                          color: _isCitationValid 
                              ? Colors.black87 
                              : Colors.red.shade700,
                          fontStyle: _isCitationValid 
                              ? FontStyle.normal 
                              : FontStyle.italic,
                        ),
                      ),
                      if (_isCitationValid && _journalName != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Journal: $_journalName',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            if (_publicationDate != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                'Published: $_publicationDate',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          if (widget.onCitationTap != null) {
                            widget.onCitationTap!(widget.conflict.doi);
                          }
                        },
                        child: Text(
                          'DOI: ${widget.conflict.doi}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade800,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            
            // Source information if available
            if (widget.conflict.source != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Source: ${widget.conflict.source}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            // Recommendation if available
            if (widget.conflict.recommendation != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates,
                      size: 18,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.conflict.recommendation!,
                        style: TextStyle(
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}