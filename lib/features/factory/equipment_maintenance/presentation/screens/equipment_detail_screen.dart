import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../common/widgets/detail_appbar.dart';

class EquipmentDetailScreen extends ConsumerWidget {
  const EquipmentDetailScreen({
    super.key,
    required this.equipmentId,
  });

  final String equipmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: DetailAppBar(
        title: 'Equipment Details',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Equipment ID: $equipmentId'),
            const SizedBox(height: 20),
            const Text('Equipment details will be displayed here.'),
          ],
        ),
      ),
    );
  }
}
