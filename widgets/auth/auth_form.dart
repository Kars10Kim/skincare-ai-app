import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

enum AuthFormType { login, register, passwordReset }

class AuthForm extends StatefulWidget {
  final AuthFormType formType;
  final Function? onSuccess;
  final Function? onToggleForm;

  const AuthForm({
    Key? key,
    required this.formType,
    this.onSuccess,
    this.onToggleForm,
  }) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Get form title based on form type
  String get _formTitle {
    switch (widget.formType) {
      case AuthFormType.login:
        return 'Log In';
      case AuthFormType.register:
        return 'Create Account';
      case AuthFormType.passwordReset:
        return 'Reset Password';
    }
  }

  // Get submit button text based on form type
  String get _submitButtonText {
    switch (widget.formType) {
      case AuthFormType.login:
        return 'Log In';
      case AuthFormType.register:
        return 'Create Account';
      case AuthFormType.passwordReset:
        return 'Send Reset Link';
    }
  }

  // Get secondary action text based on form type
  String get _secondaryActionText {
    switch (widget.formType) {
      case AuthFormType.login:
        return 'Don\'t have an account? Sign up';
      case AuthFormType.register:
        return 'Already have an account? Log in';
      case AuthFormType.passwordReset:
        return 'Remember your password? Log in';
    }
  }

  // Submit form
  Future<void> _submitForm() async {
    if (_isSubmitting) return;

    // Validate form
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSubmitting = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    try {
      switch (widget.formType) {
        case AuthFormType.login:
          success = await authProvider.login(
            _emailController.text.trim(),
            _passwordController.text,
          );
          break;
        case AuthFormType.register:
          success = await authProvider.register(
            _usernameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
          break;
        case AuthFormType.passwordReset:
          success = await authProvider.requestPasswordReset(
            _emailController.text.trim(),
          );
          break;
      }

      if (success && widget.onSuccess != null) {
        widget.onSuccess!();
      }
    } catch (e) {
      // Error already handled in auth provider
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final errorMessage = authProvider.errorMessage;

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _formTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),

              // Display error message if any
              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    errorMessage.replaceAll('Exception: ', ''),
                    style: TextStyle(color: Colors.red[800]),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16.0),
              ],

              // Username field (only for registration)
              if (widget.formType == AuthFormType.register) ...[
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a username';
                    }
                    if (value.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
              ],

              // Email field (for all forms)
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: widget.formType == AuthFormType.passwordReset
                    ? TextInputAction.done
                    : TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Password field (for login and register)
              if (widget.formType != AuthFormType.passwordReset) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  textInputAction: widget.formType == AuthFormType.register
                      ? TextInputAction.next
                      : TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (widget.formType == AuthFormType.register) {
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'Password must contain at least one uppercase letter';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'Password must contain at least one number';
                      }
                      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                        return 'Password must contain at least one special character';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
              ],

              // Confirm password field (only for registration)
              if (widget.formType == AuthFormType.register) ...[
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
              ],

              // Forgot password link (only for login)
              if (widget.formType == AuthFormType.login) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      authProvider.clearError();
                      if (widget.onToggleForm != null) {
                        widget.onToggleForm!(AuthFormType.passwordReset);
                      }
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 8.0),
              ],

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(_submitButtonText),
              ),
              const SizedBox(height: 16.0),

              // Toggle between login and register
              TextButton(
                onPressed: () {
                  authProvider.clearError();
                  if (widget.onToggleForm != null) {
                    if (widget.formType == AuthFormType.login) {
                      widget.onToggleForm!(AuthFormType.register);
                    } else {
                      widget.onToggleForm!(AuthFormType.login);
                    }
                  }
                },
                child: Text(_secondaryActionText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}