/// Represents an authenticated user
class User {
  final int id;
  final String username;
  final String email;
  final DateTime createdAt;
  final Map<String, dynamic>? preferences;
  
  /// Create a new User object
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    this.preferences,
  });
  
  /// Create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      preferences: json['preferences'],
    );
  }
  
  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'preferences': preferences,
    };
  }
  
  /// Create a copy of this User with modified fields
  User copyWith({
    int? id,
    String? username,
    String? email,
    DateTime? createdAt,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
    );
  }
  
  @override
  String toString() => 'User(id: $id, username: $username, email: $email)';
}