import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/milk_reception_model.dart';
import '../../domain/providers/milk_reception_provider.dart';
import '../widgets/milk_reception_form.dart';
import 'milk_reception_details_screen.dart';

class MilkReceptionScreen extends ConsumerWidget {
  const MilkReceptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayReceptionsAsync = ref.watch(todayMilkReceptionsProvider);
    final awaitingTestingAsync = ref.watch(receptionsAwaitingTestingProvider);

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
            todayReceptionsAsync.when(
              data: (receptions) => _buildReceptionsList(
                context,
                receptions,
                'No milk receptions today',
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading receptions: $error'),
              ),
            ),

            // Awaiting Testing Tab
            awaitingTestingAsync.when(
              data: (receptions) => _buildReceptionsList(
                context,
                receptions,
                'No receptions awaiting testing',
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading receptions: $error'),
              ),
            ),

            // New Reception Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: MilkReceptionForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceptionsList(
    BuildContext context,
    List<MilkReceptionModel> receptions,
    String emptyMessage,
  ) {
    if (receptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: receptions.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final reception = receptions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(
                '${reception.supplierName} - ${reception.quantityLiters}L'),
            subtitle: Text(
              'Received: ${_formatDateTime(reception.receptionDate)}\n'
              'Status: ${_getStatusText(reception.status)}',
            ),
            trailing: _buildStatusIcon(reception.status),
            isThreeLine: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MilkReceptionDetailsScreen(
                    receptionId: reception.id,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText(ReceptionStatus status) {
    switch (status) {
      case ReceptionStatus.received:
        return 'Received';
      case ReceptionStatus.testing:
        return 'Testing in Progress';
      case ReceptionStatus.accepted:
        return 'Accepted';
      case ReceptionStatus.rejected:
        return 'Rejected';
    }
  }

  Widget _buildStatusIcon(ReceptionStatus status) {
    IconData iconData;
    Color color;

    switch (status) {
      case ReceptionStatus.received:
        iconData = Icons.inventory;
        color = Colors.blue;
        break;
      case ReceptionStatus.testing:
        iconData = Icons.science;
        color = Colors.orange;
        break;
      case ReceptionStatus.accepted:
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case ReceptionStatus.rejected:
        iconData = Icons.cancel;
        color = Colors.red;
        break;
    }

    return Icon(iconData, color: color);
  }
}
