import 'package:flutter/material.dart';

class MilkReceptionDetailsScreen extends StatelessWidget {
  const MilkReceptionDetailsScreen({super.key, required this.receptionId});
  final String receptionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Reception Details'),
      ),
      body: Center(
        child: Text('Details for Reception ID: $receptionId'),
      ),
    );
  }
}
