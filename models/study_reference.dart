/// Represents a scientific study reference with academic citation information
class StudyReference {
  /// Unique identifier (DOI or PubMed ID)
  final String id;
  
  /// Study title
  final String title;
  
  /// Journal name
  final String? journal;
  
  /// Publication year
  final int? year;
  
  /// Primary author
  final String? author;
  
  /// Full citation text
  final String citation;
  
  /// Validation status
  final bool isValidated;
  
  const StudyReference({
    required this.id,
    required this.title,
    this.journal,
    this.year,
    this.author,
    required this.citation,
    this.isValidated = false,
  });
  
  /// Create a StudyReference from JSON data
  factory StudyReference.fromJson(Map<String, dynamic> json) {
    return StudyReference(
      id: json['id'] as String,
      title: json['title'] as String,
      journal: json['journal'] as String?,
      year: json['year'] as int?,
      author: json['author'] as String?,
      citation: json['citation'] as String,
      isValidated: json['isValidated'] as bool? ?? false,
    );
  }
  
  /// Convert this reference to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'journal': journal,
      'year': year,
      'author': author,
      'citation': citation,
      'isValidated': isValidated,
    };
  }
  
  /// Get a formatted URL for DOI references
  Uri get doiUrl => Uri.parse('https://doi.org/$id');
  
  /// Get a formatted URL for PubMed references
  Uri get pubmedUrl => Uri.parse('https://pubmed.ncbi.nlm.nih.gov/$id/');
  
  /// Create a copy of this reference with updated fields
  StudyReference copyWith({
    String? id,
    String? title,
    String? journal,
    int? year,
    String? author,
    String? citation,
    bool? isValidated,
  }) {
    return StudyReference(
      id: id ?? this.id,
      title: title ?? this.title,
      journal: journal ?? this.journal,
      year: year ?? this.year,
      author: author ?? this.author,
      citation: citation ?? this.citation,
      isValidated: isValidated ?? this.isValidated,
    );
  }
  
  /// Format the reference as APA style citation
  String get apaStyle {
    final authorText = author ?? 'et al.';
    final yearText = year != null ? '($year)' : '';
    final journalText = journal != null ? 'In $journal' : '';
    
    return '$authorText $yearText. $title. $journalText. doi:$id';
  }
  
  /// Format the reference as Vancouver style citation
  String get vancouverStyle {
    final authorText = author ?? 'et al.';
    final yearText = year != null ? '$year;' : '';
    final journalText = journal != null ? '$journal.' : '';
    
    return '$authorText. $title. $journalText $yearText doi:$id';
  }
}