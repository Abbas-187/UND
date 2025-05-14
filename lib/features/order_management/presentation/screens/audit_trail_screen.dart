import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/order_audit_trail_provider.dart';

class AuditTrailScreen extends ConsumerStatefulWidget {
  const AuditTrailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  ConsumerState<AuditTrailScreen> createState() => _AuditTrailScreenState();
}

class _AuditTrailScreenState extends ConsumerState<AuditTrailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderId = widget.orderId;
      ref.read(orderAuditTrailProvider.notifier).fetch(orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final trailsAsync = ref.watch(orderAuditTrailProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Trail')),
      body: trailsAsync.when(
        data: (trails) {
          if (trails.isEmpty) {
            return const Center(child: Text('No audit entries found'));
          }
          return ListView.separated(
            separatorBuilder: (_, __) => const Divider(),
            itemCount: trails.length,
            itemBuilder: (context, index) {
              final entry = trails[index];
              return ListTile(
                title: Text(entry.action),
                subtitle:
                    Text('By ${entry.userId} at ${entry.timestamp.toLocal()}'),
                trailing: entry.justification != null
                    ? const Icon(Icons.comment)
                    : null,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading audit trail: $e')),
      ),
    );
  }
}
