/// Utility class for validating auth-related input fields
class AuthValidator {
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final _passwordMinLength = 8;
  static final _usernameMinLength = 3;
  static final _usernameMaxLength = 30;
  
  /// Validate an email address
  /// 
  /// Returns null if the email is valid, otherwise returns an error message
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    
    if (!_emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validate a password
  /// 
  /// Returns null if the password is valid, otherwise returns an error message
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < _passwordMinLength) {
      return 'Password must be at least $_passwordMinLength characters long';
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  /// Validate a username
  /// 
  /// Returns null if the username is valid, otherwise returns an error message
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }
    
    if (username.length < _usernameMinLength) {
      return 'Username must be at least $_usernameMinLength characters long';
    }
    
    if (username.length > _usernameMaxLength) {
      return 'Username must be at most $_usernameMaxLength characters long';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, dots, and underscores';
    }
    
    return null;
  }
  
  /// Validate password confirmation
  /// 
  /// Returns null if the passwords match, otherwise returns an error message
  static String? validatePasswordConfirmation(String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (password != confirmation) {
      return 'Passwords do not match';
    }
    
    return null;
  }
}