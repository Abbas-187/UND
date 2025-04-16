import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';

// A provider for inventory settings
final inventorySettingsProvider = StateProvider<InventorySettings>((ref) {
  return const InventorySettings(
    defaultUnit: 'kg',
    defaultLocation: 'Main Warehouse',
    lowStockThreshold: 5,
    automaticReorder: false,
    reorderMethod: ReorderMethod.fixed,
    lowStockNotifications: true,
    expiryNotifications: true,
    expiryNotificationDays: 30,
    defaultScanType: ScanType.barcode,
    autoGenerateBarcodes: true,
  );
});

enum ReorderMethod { fixed, dynamic }

enum ScanType { barcode, qrCode, both }

// Model for inventory settings - immutable class
class InventorySettings {
  const InventorySettings({
    required this.defaultUnit,
    required this.defaultLocation,
    required this.lowStockThreshold,
    required this.automaticReorder,
    required this.reorderMethod,
    required this.lowStockNotifications,
    required this.expiryNotifications,
    required this.expiryNotificationDays,
    required this.defaultScanType,
    required this.autoGenerateBarcodes,
  });

  final String defaultUnit;
  final String defaultLocation;
  final int lowStockThreshold;
  final bool automaticReorder;
  final ReorderMethod reorderMethod;
  final bool lowStockNotifications;
  final bool expiryNotifications;
  final int expiryNotificationDays;
  final ScanType defaultScanType;
  final bool autoGenerateBarcodes;

  InventorySettings copyWith({
    String? defaultUnit,
    String? defaultLocation,
    int? lowStockThreshold,
    bool? automaticReorder,
    ReorderMethod? reorderMethod,
    bool? lowStockNotifications,
    bool? expiryNotifications,
    int? expiryNotificationDays,
    ScanType? defaultScanType,
    bool? autoGenerateBarcodes,
  }) {
    return InventorySettings(
      defaultUnit: defaultUnit ?? this.defaultUnit,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      automaticReorder: automaticReorder ?? this.automaticReorder,
      reorderMethod: reorderMethod ?? this.reorderMethod,
      lowStockNotifications:
          lowStockNotifications ?? this.lowStockNotifications,
      expiryNotifications: expiryNotifications ?? this.expiryNotifications,
      expiryNotificationDays:
          expiryNotificationDays ?? this.expiryNotificationDays,
      defaultScanType: defaultScanType ?? this.defaultScanType,
      autoGenerateBarcodes: autoGenerateBarcodes ?? this.autoGenerateBarcodes,
    );
  }
}

class InventorySettingsScreen extends ConsumerStatefulWidget {
  const InventorySettingsScreen({super.key});

  @override
  ConsumerState<InventorySettingsScreen> createState() =>
      _InventorySettingsScreenState();
}

class _InventorySettingsScreenState
    extends ConsumerState<InventorySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _defaultUnitController;
  late TextEditingController _defaultLocationController;
  late TextEditingController _lowStockThresholdController;
  late TextEditingController _expiryDaysController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(inventorySettingsProvider);
    _defaultUnitController = TextEditingController(text: settings.defaultUnit);
    _defaultLocationController =
        TextEditingController(text: settings.defaultLocation);
    _lowStockThresholdController =
        TextEditingController(text: settings.lowStockThreshold.toString());
    _expiryDaysController =
        TextEditingController(text: settings.expiryNotificationDays.toString());
  }

  @override
  void dispose() {
    _defaultUnitController.dispose();
    _defaultLocationController.dispose();
    _lowStockThresholdController.dispose();
    _expiryDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(inventorySettingsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventorySettings),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: l10n.saveSettings,
                  onPressed: _saveSettings,
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // General Settings
            _buildSectionHeader(l10n.generalSettings),
            const SizedBox(height: 16),

            // Default Unit
            TextFormField(
              controller: _defaultUnitController,
              decoration: InputDecoration(
                labelText: l10n.defaultUnit,
                border: const OutlineInputBorder(),
                helperText: 'kg, l, pc, etc.',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a default unit';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Default Location
            TextFormField(
              controller: _defaultLocationController,
              decoration: InputDecoration(
                labelText: l10n.defaultLocation,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a default location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Low Stock Threshold
            TextFormField(
              controller: _lowStockThresholdController,
              decoration: InputDecoration(
                labelText: l10n.lowStockThreshold,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a threshold value';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Reorder Settings
            _buildSectionHeader(l10n.reorderSettings),
            const SizedBox(height: 16),

            // Automatic Reorder
            SwitchListTile(
              title: Text(l10n.automaticReorder),
              value: settings.automaticReorder,
              onChanged: (value) {
                ref.read(inventorySettingsProvider.notifier).state =
                    settings.copyWith(automaticReorder: value);
              },
            ),

            // Reorder Method
            ListTile(
              title: Text(l10n.reorderMethod),
              subtitle: Column(
                children: [
                  RadioListTile<ReorderMethod>(
                    title: Text(l10n.fixedReorderPoint),
                    value: ReorderMethod.fixed,
                    groupValue: settings.reorderMethod,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(inventorySettingsProvider.notifier).state =
                            settings.copyWith(reorderMethod: value);
                      }
                    },
                  ),
                  RadioListTile<ReorderMethod>(
                    title: Text(l10n.dynamicReorderPoint),
                    value: ReorderMethod.dynamic,
                    groupValue: settings.reorderMethod,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(inventorySettingsProvider.notifier).state =
                            settings.copyWith(reorderMethod: value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notification Settings
            _buildSectionHeader(l10n.notificationSettings),
            const SizedBox(height: 16),

            // Low Stock Notifications
            SwitchListTile(
              title: Text(l10n.lowStockNotifications),
              value: settings.lowStockNotifications,
              onChanged: (value) {
                ref.read(inventorySettingsProvider.notifier).state =
                    settings.copyWith(lowStockNotifications: value);
              },
            ),

            // Expiry Notifications
            SwitchListTile(
              title: Text(l10n.expiryNotifications),
              value: settings.expiryNotifications,
              onChanged: (value) {
                ref.read(inventorySettingsProvider.notifier).state =
                    settings.copyWith(expiryNotifications: value);
              },
            ),

            // Expiry Notification Days
            if (settings.expiryNotifications)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextFormField(
                  controller: _expiryDaysController,
                  decoration: InputDecoration(
                    labelText: l10n.expiryNotificationDays,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter days';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            const SizedBox(height: 24),

            // Scanning Settings
            _buildSectionHeader(l10n.scanningSettings),
            const SizedBox(height: 16),

            // Default Scan Type
            ListTile(
              title: Text(l10n.defaultScanType),
              subtitle: Column(
                children: [
                  RadioListTile<ScanType>(
                    title: Text(l10n.barcode),
                    value: ScanType.barcode,
                    groupValue: settings.defaultScanType,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(inventorySettingsProvider.notifier).state =
                            settings.copyWith(defaultScanType: value);
                      }
                    },
                  ),
                  RadioListTile<ScanType>(
                    title: Text(l10n.qrCode),
                    value: ScanType.qrCode,
                    groupValue: settings.defaultScanType,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(inventorySettingsProvider.notifier).state =
                            settings.copyWith(defaultScanType: value);
                      }
                    },
                  ),
                  RadioListTile<ScanType>(
                    title: const Text('Both'),
                    value: ScanType.both,
                    groupValue: settings.defaultScanType,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(inventorySettingsProvider.notifier).state =
                            settings.copyWith(defaultScanType: value);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Auto-generate Barcodes
            SwitchListTile(
              title: Text(l10n.autoGenerateBarcodes),
              value: settings.autoGenerateBarcodes,
              onChanged: (value) {
                ref.read(inventorySettingsProvider.notifier).state =
                    settings.copyWith(autoGenerateBarcodes: value);
              },
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(l10n.saveSettings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });

      try {
        // Save settings to provider
        final settings = ref.read(inventorySettingsProvider);
        ref.read(inventorySettingsProvider.notifier).state = settings.copyWith(
          defaultUnit: _defaultUnitController.text,
          defaultLocation: _defaultLocationController.text,
          lowStockThreshold: int.parse(_lowStockThresholdController.text),
          expiryNotificationDays: int.parse(_expiryDaysController.text),
        );

        // Simulate network delay
        await Future.delayed(const Duration(seconds: 1));

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).settingsSaved),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }
}
