import 'package:equatable/equatable.dart';

/// Type of answer for a survey question
enum AnswerType {
  /// Single choice from a list of options
  singleChoice,
  
  /// Multiple choices from a list of options
  multipleChoice,
  
  /// Text input
  text,
  
  /// Numeric input
  numeric,
  
  /// Date input
  date,
  
  /// Boolean (yes/no) input
  boolean,
}

/// Option for a survey question
class SurveyOption extends Equatable {
  /// Option ID
  final String id;
  
  /// Option label to display
  final String label;
  
  /// Option value
  final dynamic value;
  
  /// Optional image asset path
  final String? imagePath;
  
  /// Create a survey option
  const SurveyOption({
    required this.id,
    required this.label,
    this.value,
    this.imagePath,
  });
  
  /// Create a copy with new values
  SurveyOption copyWith({
    String? id,
    String? label,
    dynamic value,
    String? imagePath,
  }) {
    return SurveyOption(
      id: id ?? this.id,
      label: label ?? this.label,
      value: value ?? this.value,
      imagePath: imagePath ?? this.imagePath,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'value': value,
      'imagePath': imagePath,
    };
  }
  
  /// Create from JSON
  factory SurveyOption.fromJson(Map<String, dynamic> json) {
    return SurveyOption(
      id: json['id'],
      label: json['label'],
      value: json['value'],
      imagePath: json['imagePath'],
    );
  }
  
  @override
  List<Object?> get props => [id, label, value, imagePath];
}

/// A step in a survey
class SurveyStep extends Equatable {
  /// Step ID
  final String id;
  
  /// Title of the step
  final String title;
  
  /// Description or question text
  final String description;
  
  /// Type of answer for this step
  final AnswerType answerType;
  
  /// Available options for selection
  final List<SurveyOption> options;
  
  /// Whether this step is required
  final bool isRequired;
  
  /// Whether this step has been answered
  final bool isAnswered;
  
  /// The user's answer(s)
  final dynamic answer;
  
  /// Create a survey step
  const SurveyStep({
    required this.id,
    required this.title,
    required this.description,
    required this.answerType,
    this.options = const [],
    this.isRequired = true,
    this.isAnswered = false,
    this.answer,
  });
  
  /// Create a copy with new values
  SurveyStep copyWith({
    String? id,
    String? title,
    String? description,
    AnswerType? answerType,
    List<SurveyOption>? options,
    bool? isRequired,
    bool? isAnswered,
    dynamic answer,
  }) {
    return SurveyStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      answerType: answerType ?? this.answerType,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      isAnswered: isAnswered ?? this.isAnswered,
      answer: answer ?? this.answer,
    );
  }
  
  /// Create a copy with an answer
  SurveyStep withAnswer(dynamic value) {
    return copyWith(
      answer: value,
      isAnswered: value != null,
    );
  }
  
  /// Check if this step is valid
  bool get isValid {
    if (!isRequired) return true;
    if (!isAnswered) return false;
    
    switch (answerType) {
      case AnswerType.singleChoice:
        return answer != null;
      case AnswerType.multipleChoice:
        return answer is List && answer.isNotEmpty;
      case AnswerType.text:
        return answer is String && answer.isNotEmpty;
      case AnswerType.numeric:
        return answer is num;
      case AnswerType.date:
        return answer is DateTime;
      case AnswerType.boolean:
        return answer is bool;
    }
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'answerType': answerType.toString().split('.').last,
      'options': options.map((option) => option.toJson()).toList(),
      'isRequired': isRequired,
      'isAnswered': isAnswered,
      'answer': _serializeAnswer(),
    };
  }
  
  /// Create from JSON
  factory SurveyStep.fromJson(Map<String, dynamic> json) {
    final step = SurveyStep(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      answerType: _parseAnswerType(json['answerType']),
      options: (json['options'] as List<dynamic>?)
          ?.map((option) => SurveyOption.fromJson(Map<String, dynamic>.from(option)))
          .toList() ?? [],
      isRequired: json['isRequired'] ?? true,
      isAnswered: json['isAnswered'] ?? false,
    );
    
    // Parse answer based on answer type
    if (json['answer'] != null) {
      switch (step.answerType) {
        case AnswerType.singleChoice:
          return step.copyWith(answer: json['answer']);
        case AnswerType.multipleChoice:
          return step.copyWith(answer: List<String>.from(json['answer']));
        case AnswerType.text:
          return step.copyWith(answer: json['answer']);
        case AnswerType.numeric:
          return step.copyWith(answer: num.tryParse(json['answer'].toString()));
        case AnswerType.date:
          return step.copyWith(
            answer: json['answer'] != null 
              ? DateTime.parse(json['answer']) 
              : null,
          );
        case AnswerType.boolean:
          return step.copyWith(answer: json['answer'] as bool);
      }
    }
    
    return step;
  }
  
  /// Serialize the answer based on its type
  dynamic _serializeAnswer() {
    if (answer == null) return null;
    
    switch (answerType) {
      case AnswerType.date:
        return answer is DateTime ? (answer as DateTime).toIso8601String() : null;
      default:
        return answer;
    }
  }
  
  /// Parse answer type from string
  static AnswerType _parseAnswerType(String? value) {
    switch (value) {
      case 'singleChoice':
        return AnswerType.singleChoice;
      case 'multipleChoice':
        return AnswerType.multipleChoice;
      case 'text':
        return AnswerType.text;
      case 'numeric':
        return AnswerType.numeric;
      case 'date':
        return AnswerType.date;
      case 'boolean':
        return AnswerType.boolean;
      default:
        return AnswerType.text;
    }
  }
  
  @override
  List<Object?> get props => [
    id, 
    title, 
    description, 
    answerType, 
    options,
    isRequired,
    isAnswered,
    answer,
  ];
}