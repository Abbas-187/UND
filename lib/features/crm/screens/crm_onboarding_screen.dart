import 'package:flutter/material.dart';

class CrmOnboardingScreen extends StatelessWidget {
  const CrmOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CRM Onboarding')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome to the CRM Module!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(
                'This module helps you manage customer profiles, log interactions, view order history, and generate reports.'),
            SizedBox(height: 16),
            Text(
                'Get started by adding a new customer or viewing existing profiles.'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
