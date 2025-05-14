import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/procurement_routes.dart';

class TestNavigationScreen extends StatelessWidget {
  const TestNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procurement Navigation Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Test Procurement Navigation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.goNamed(
                  ProcurementRoutes.poApproval,
                  pathParameters: {'poId': 'po-123'},
                );
              },
              child: const Text('Go to PO Approval Screen'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.go('/procurement/dashboard');
              },
              child: const Text('Go to Procurement Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
