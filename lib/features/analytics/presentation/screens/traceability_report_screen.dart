import 'package:flutter/material.dart';

class TraceabilityReportScreen extends StatelessWidget {
  const TraceabilityReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    // TODO: Connect to state management and usecase
    return Scaffold(
      appBar: AppBar(title: const Text('Traceability Report')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter Batch/Lot Number:'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration:
                        const InputDecoration(hintText: 'Batch/Lot Number'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Trigger report fetch
                  },
                  child: const Text('Generate'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // TODO: Display traceability report results here
            const Text('Report will appear here.'),
          ],
        ),
      ),
    );
  }
}
