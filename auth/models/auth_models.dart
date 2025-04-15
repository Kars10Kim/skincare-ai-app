/// User model
class User {
  /// User ID
  final int id;
  
  /// Username
  final String username;
  
  /// Email
  final String? email;
  
  /// Create a new user
  const User({
    required this.id,
    required this.username,
    this.email,
  });
  
  /// Create a user from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }
  
  /// Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      if (email != null) 'email': email,
    };
  }
}

/// Login result
class LoginResult {
  /// Whether login was successful
  final bool success;
  
  /// User data (if successful)
  final User? user;
  
  /// Error message (if failed)
  final String? errorMessage;
  
  /// Create a new login result
  const LoginResult({
    required this.success,
    this.user,
    this.errorMessage,
  });
}

/// Register request
class RegisterRequest {
  /// Username
  final String username;
  
  /// Password
  final String password;
  
  /// Email
  final String? email;
  
  /// Create a new register request
  const RegisterRequest({
    required this.username,
    required this.password,
    this.email,
  });
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      if (email != null) 'email': email,
    };
  }
}

/// Register result
class RegisterResult {
  /// Whether registration was successful
  final bool success;
  
  /// User data (if successful)
  final User? user;
  
  /// Error message (if failed)
  final String? errorMessage;
  
  /// Create a new register result
  const RegisterResult({
    required this.success,
    this.user,
    this.errorMessage,
  });
}