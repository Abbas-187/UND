import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/auth/services/auth_service.dart';
import '../../../../core/routes/app_go_router.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final remembered = prefs.getBool('remember_me') ?? false;
    if (remembered) {
      final email = prefs.getString('saved_email') ?? '';
      _emailController.text = email;
    }
    setState(() {
      _rememberMe = remembered;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    print('Login button pressed');
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print(
          'Attempting to sign in with email: ${_emailController.text.trim()}');
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('Login successful');
      if (!mounted) return;

      // Navigate to home screen on successful login using GoRouter
      print('Navigating to home screen');
      // Persist remember me preference
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_email', _emailController.text.trim());
      } else {
        await prefs.remove('remember_me');
        await prefs.remove('saved_email');
      }
      GoRouter.of(context).go(AppRoutes.home);
    } catch (e) {
      print('Login error: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and app name
                    const Icon(
                      Icons.inventory_2_rounded,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'UND Inventory',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Email field
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Add forgot password functionality
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Remember Me checkbox
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Remember Me'),
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Login button
                    PrimaryButton(
                      text: 'Login',
                      onPressed: _isLoading ? null : _login,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 24),

                    // Sign up option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            // Navigate to sign up screen
                          },
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
