import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_go_router.dart';
import '../../../../core/widgets/primary_button.dart';

/// Screen shown when a user attempts to access a page they don't have permission for
class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 100,
                color: Colors.amber,
              ),
              const SizedBox(height: 24),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'You do not have permission to access this page. Please contact your administrator if you believe you should have access.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Go Back',
                onPressed: () {
                  context.go(AppRoutes.home);
                },
                icon: Icons.home,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
