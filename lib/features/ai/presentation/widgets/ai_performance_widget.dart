import 'package:flutter/material.dart';

class AIPerformanceWidget extends StatelessWidget {
  final String title;
  final Map<String, dynamic>
      metrics; // e.g., {'Response Time': '1.2s', 'Accuracy': '89%'}
  final IconData icon;

  const AIPerformanceWidget({
    super.key,
    required this.title,
    required this.metrics,
    this.icon = Icons.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(icon,
                  size: 40, color: Theme.of(context).colorScheme.tertiary),
              title: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 10),
            ...metrics.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(entry.value.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
