import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

/// Set this to true to bypass authentication checks (for development/testing only)
const bool bypassAuthChecks = false;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.redirectTo});
  final String? redirectTo;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // Bypass login screen during testing
    if (bypassAuthChecks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );

      // Navigation will be handled by the auth state listener
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState == AuthState.loading;

    // Listen for authentication state changes
    ref.listen(authProvider, (previous, next) {
      if (next == AuthState.authenticated) {
        // Navigate after successful authentication
        if (widget.redirectTo != null) {
          context.go(widget.redirectTo!);
        } else {
          context.go('/');
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Icon(
                  Icons.inventory,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'UND Warehouse Management',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),

                Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 32),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[800]),
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 16),

                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Forgot password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.go('/forgot-password');
                          },
                          child: Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign in button
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleSignIn,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Sign In',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
