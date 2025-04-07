import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/milk_reception_model.dart';
import '../../domain/providers/milk_reception_provider.dart';
import '../widgets/milk_reception_form.dart';
import 'milk_reception_details_screen.dart';
import '../../../../theme/app_theme_extensions.dart';

class MilkReceptionScreen extends ConsumerWidget {
  const MilkReceptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Milk Reception'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Today's Receptions"),
              Tab(text: 'Awaiting Testing'),
              Tab(text: 'New Reception'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Today's Receptions Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.water_drop,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Today\'s Milk Receptions',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text('No milk receptions today'),
                ],
              ),
            ),

            // Awaiting Testing Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.science,
                    size: 80,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Awaiting Testing',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text('No milk receptions awaiting testing'),
                ],
              ),
            ),

            // New Reception Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle,
                    size: 80,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'New Milk Reception',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                      'Form to create a new milk reception will appear here'),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // Show a snackbar since this is a placeholder
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'This functionality will be implemented soon'),
                        ),
                      );
                    },
                    child: const Text('Create New Reception'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
