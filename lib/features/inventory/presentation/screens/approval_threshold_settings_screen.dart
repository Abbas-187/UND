import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inventory_settings_repository_provider.dart';

class ApprovalThresholdSettingsScreen extends ConsumerStatefulWidget {
  const ApprovalThresholdSettingsScreen({super.key});
  @override
  ConsumerState<ApprovalThresholdSettingsScreen> createState() =>
      _ApprovalThresholdSettingsScreenState();
}

class _ApprovalThresholdSettingsScreenState
    extends ConsumerState<ApprovalThresholdSettingsScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  double? _currentThreshold;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(inventorySettingsRepositoryProvider);
    final threshold = await repo.getApprovalThreshold();
    setState(() {
      _currentThreshold = threshold;
      _controller.text = threshold?.toString() ?? '';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(inventorySettingsRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Approval Threshold Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cycle Count Approval Threshold',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Text('Current Threshold: ${_currentThreshold ?? 'Not Set'}'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Set New Threshold (value)'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            final value = double.tryParse(_controller.text);
                            if (value == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Enter a valid number')));
                              return;
                            }
                            setState(() => _loading = true);
                            await repo.setApprovalThreshold(value);
                            await _load();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Threshold updated')));
                          },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }
}
