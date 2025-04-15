import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth.dart';
import '../../utils/constants.dart';
import '../../widgets/card_container.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/loading/loading_state_widget.dart';

/// Authentication screen with login and register functionality
class AuthScreen extends StatefulWidget {
  /// Creates an authentication screen
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  
  // Login form controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  
  // Register form controllers
  final TextEditingController _registerUsernameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _registerConfirmPasswordController = TextEditingController();
  
  // Form visibility toggles
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }
  
  /// Handle login submission
  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.login(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
      );
      
      if (authProvider.isAuthenticated && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }
  
  /// Handle register submission
  Future<void> _handleRegister() async {
    if (_registerFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.register(
        _registerEmailController.text.trim(),
        _registerUsernameController.text.trim(),
        _registerPasswordController.text,
      );
      
      if (authProvider.isAuthenticated && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Redirect to home if already authenticated
    if (authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ResponsiveLayout(
              mobileBody: _buildMobileLayout(),
              tabletBody: _buildTabletLayout(),
            ),
            // Error message
            if (authProvider.state.error != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          authProvider.state.error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: Colors.red.shade700,
                        onPressed: () {
                          setState(() {
                            // Since we can't clear the error directly, we'll
                            // just update the UI until the next auth action
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            // Loading overlay
            if (authProvider.state.isLoading)
              const Positioned.fill(
                child: LoadingStateWidget.message(
                  message: 'Authenticating...',
                  backgroundColor: Colors.black45,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// Builds mobile layout
  Widget _buildMobileLayout() {
    return Column(
      children: [
        AppBar(
          title: const Text('Sign In'),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'LOGIN'),
              Tab(text: 'REGISTER'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildLoginForm(),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildRegisterForm(),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Builds tablet layout
  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Left panel with hero image and app info
        Expanded(
          flex: 5,
          child: Container(
            color: AppColors.primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skincare Scanner',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your personal skincare assistant that analyzes ingredients, identifies conflicts, and recommends products for your unique skin profile.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 32),
                // App features
                _buildFeatureItem(
                  icon: Icons.check_circle_outline,
                  text: 'Scan product barcodes instantly',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: Icons.check_circle_outline,
                  text: 'Analyze ingredient conflicts',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: Icons.check_circle_outline,
                  text: 'Get personalized recommendations',
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: Icons.check_circle_outline,
                  text: 'Access your history across devices',
                ),
              ],
            ),
          ),
        ),
        // Right panel with auth forms
        Expanded(
          flex: 7,
          child: Column(
            children: [
              AppBar(
                title: const Text('Create Account or Sign In'),
                centerTitle: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'LOGIN'),
                    Tab(text: 'REGISTER'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: _buildLoginForm(),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: _buildRegisterForm(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Builds feature item with icon and text
  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  
  /// Builds login form
  Widget _buildLoginForm() {
    return CardContainer(
      useGlassmorphism: true,
      backgroundColor: Colors.white.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome Back!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Email field
              TextFormField(
                controller: _loginEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) => AuthValidator.validateEmail(value),
              ),
              const SizedBox(height: 16),
              // Password field
              TextFormField(
                controller: _loginPasswordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureLoginPassword = !_obscureLoginPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureLoginPassword,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 24),
              // Login button
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('SIGN IN'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Handle forgot password
                },
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Builds register form
  Widget _buildRegisterForm() {
    return CardContainer(
      useGlassmorphism: true,
      backgroundColor: Colors.white.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _registerFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Username field
              TextFormField(
                controller: _registerUsernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => AuthValidator.validateUsername(value),
              ),
              const SizedBox(height: 16),
              // Email field
              TextFormField(
                controller: _registerEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) => AuthValidator.validateEmail(value),
              ),
              const SizedBox(height: 16),
              // Password field
              TextFormField(
                controller: _registerPasswordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureRegisterPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureRegisterPassword = !_obscureRegisterPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureRegisterPassword,
                textInputAction: TextInputAction.next,
                validator: (value) => AuthValidator.validatePassword(value),
              ),
              const SizedBox(height: 16),
              // Confirm password field
              TextFormField(
                controller: _registerConfirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureRegisterConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureRegisterConfirmPassword = !_obscureRegisterConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureRegisterConfirmPassword,
                textInputAction: TextInputAction.done,
                validator: (value) => AuthValidator.validatePasswordConfirmation(
                  _registerPasswordController.text,
                  value,
                ),
                onFieldSubmitted: (_) => _handleRegister(),
              ),
              const SizedBox(height: 24),
              // Register button
              ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('CREATE ACCOUNT'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      _tabController.animateTo(0); // Switch to login tab
                    },
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}