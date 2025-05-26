import 'package:flutter/material.dart';

class AIRecommendationWidget extends StatelessWidget {
  final String title;
  final List<String> recommendations;
  final IconData icon;
  final Function(String recommendation)? onRecommendationTapped;

  const AIRecommendationWidget({
    super.key,
    required this.title,
    required this.recommendations,
    this.icon = Icons.assistant_photo,
    this.onRecommendationTapped,
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
                  size: 40, color: Theme.of(context).colorScheme.secondary),
              title: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 10),
            ...recommendations.map((rec) => ListTile(
                  leading: const Icon(Icons.arrow_forward_ios, size: 14),
                  title:
                      Text(rec, style: Theme.of(context).textTheme.bodyMedium),
                  onTap: onRecommendationTapped != null
                      ? () => onRecommendationTapped!(rec)
                      : null,
                )),
          ],
        ),
      ),
    );
  }
}
