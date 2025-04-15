/// Model class representing an authenticated user
class User {
  /// User ID
  final int id;
  
  /// Username
  final String username;
  
  /// Email address
  final String email;
  
  /// Date when user was created
  final DateTime createdAt;
  
  /// Last login date
  final DateTime? lastLogin;
  
  /// User roles (optional)
  final List<String>? roles;
  
  /// Constructor
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    this.lastLogin,
    this.roles,
  });
  
  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin']) 
          : null,
      roles: json['roles'] != null 
          ? List<String>.from(json['roles']) 
          : null,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      if (lastLogin != null) 'lastLogin': lastLogin!.toIso8601String(),
      if (roles != null) 'roles': roles,
    };
  }
  
  /// Check if user has specific role
  bool hasRole(String role) {
    return roles?.contains(role) ?? false;
  }
  
  /// Creates a copy with modified fields
  User copyWith({
    int? id,
    String? username,
    String? email,
    DateTime? createdAt,
    DateTime? lastLogin,
    List<String>? roles,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      roles: roles ?? this.roles,
    );
  }
}