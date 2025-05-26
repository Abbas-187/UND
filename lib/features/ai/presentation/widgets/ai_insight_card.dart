import 'package:flutter/material.dart';

class AIInsightCard extends StatelessWidget {
  final String title;
  final List<String> insights;
  final IconData icon;
  final Color? backgroundColor;

  const AIInsightCard({
    super.key,
    required this.title,
    required this.insights,
    this.icon = Icons.lightbulb_outline,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? Theme.of(context).cardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading:
                  Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              title: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 10),
            ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text('• $insight',
                      style: Theme.of(context).textTheme.bodyMedium),
                )),
          ],
        ),
      ),
    );
  }
}
