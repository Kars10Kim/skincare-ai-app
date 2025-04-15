/// Verification status for scientific references
enum VerificationStatus {
  /// Reference is verified
  verified,
  
  /// Reference verification is pending
  pending,
  
  /// Reference verification failed
  failed,
}

/// Scientific reference
class ScientificReference {
  /// Digital Object Identifier
  final String? doi;
  
  /// PubMed ID
  final String? pubMedId;
  
  /// Article title
  final String title;
  
  /// Article authors
  final List<String>? authors;
  
  /// Journal name
  final String? journal;
  
  /// Publication year
  final int? year;
  
  /// Article summary
  final String? summary;
  
  /// Reference URL
  final String? url;
  
  /// Article keywords
  final List<String>? keywords;
  
  /// Verification status
  final VerificationStatus verificationStatus;
  
  /// Create scientific reference
  ScientificReference({
    this.doi,
    this.pubMedId,
    required this.title,
    this.authors,
    this.journal,
    this.year,
    this.summary,
    this.url,
    this.keywords,
    this.verificationStatus = VerificationStatus.pending,
  });
  
  /// Get citation text
  String getCitation() {
    final authorText = authors != null && authors!.isNotEmpty
        ? authors!.join(', ')
        : 'Unknown Authors';
    
    final yearText = year != null ? year.toString() : 'n.d.';
    
    final journalText = journal ?? 'Unknown Journal';
    
    return '$authorText ($yearText). $title. $journalText.';
  }
  
  /// Check if reference is valid
  bool get isValid => verificationStatus == VerificationStatus.verified;
}