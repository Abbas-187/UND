import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Constants for SharedPreferences keys
const String _inventorySettingsKey = 'inventory_settings';

// A provider for inventory settings that persists between app launches
final inventorySettingsProvider =
    StateNotifierProvider<InventorySettingsNotifier, InventorySettings>((ref) {
  return InventorySettingsNotifier();
});

// Notifier to handle inventory settings state and persistence
class InventorySettingsNotifier extends StateNotifier<InventorySettings> {
  InventorySettingsNotifier()
      : super(const InventorySettings(
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
        )) {
    // Load saved settings when notifier is created
    _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSettings = prefs.getString(_inventorySettingsKey);

      if (savedSettings != null) {
        final Map<String, dynamic> settingsMap = jsonDecode(savedSettings);
        state = InventorySettings.fromJson(settingsMap);
      }
    } catch (e) {
      // If loading fails, the default settings in super() will be used
      debugPrint('Error loading inventory settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_inventorySettingsKey, jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('Error saving inventory settings: $e');
    }
  }

  // Update settings with new values
  void updateSettings(InventorySettings newSettings) {
    state = newSettings;
    saveSettings();
  }

  // Update specific setting fields
  void updateDefaultUnit(String defaultUnit) {
    state = state.copyWith(defaultUnit: defaultUnit);
    saveSettings();
  }

  void updateDefaultLocation(String defaultLocation) {
    state = state.copyWith(defaultLocation: defaultLocation);
    saveSettings();
  }

  void updateLowStockThreshold(int threshold) {
    state = state.copyWith(lowStockThreshold: threshold);
    saveSettings();
  }

  void updateAutomaticReorder(bool enabled) {
    state = state.copyWith(automaticReorder: enabled);
    saveSettings();
  }

  void updateReorderMethod(ReorderMethod method) {
    state = state.copyWith(reorderMethod: method);
    saveSettings();
  }

  void updateLowStockNotifications(bool enabled) {
    state = state.copyWith(lowStockNotifications: enabled);
    saveSettings();
  }

  void updateExpiryNotifications(bool enabled) {
    state = state.copyWith(expiryNotifications: enabled);
    saveSettings();
  }

  void updateExpiryNotificationDays(int days) {
    state = state.copyWith(expiryNotificationDays: days);
    saveSettings();
  }

  void updateDefaultScanType(ScanType type) {
    state = state.copyWith(defaultScanType: type);
    saveSettings();
  }

  void updateAutoGenerateBarcodes(bool enabled) {
    state = state.copyWith(autoGenerateBarcodes: enabled);
    saveSettings();
  }
}

enum ReorderMethod { fixed, dynamic }

enum ScanType { barcode, qrCode, both }

// Model for inventory settings - immutable class
class InventorySettings {
  // Create from JSON from storage
  factory InventorySettings.fromJson(Map<String, dynamic> json) {
    return InventorySettings(
      defaultUnit: json['defaultUnit'] as String? ?? 'kg',
      defaultLocation: json['defaultLocation'] as String? ?? 'Main Warehouse',
      lowStockThreshold: json['lowStockThreshold'] as int? ?? 5,
      automaticReorder: json['automaticReorder'] as bool? ?? false,
      reorderMethod: ReorderMethod.values[json['reorderMethod'] as int? ?? 0],
      lowStockNotifications: json['lowStockNotifications'] as bool? ?? true,
      expiryNotifications: json['expiryNotifications'] as bool? ?? true,
      expiryNotificationDays: json['expiryNotificationDays'] as int? ?? 30,
      defaultScanType: ScanType.values[json['defaultScanType'] as int? ?? 0],
      autoGenerateBarcodes: json['autoGenerateBarcodes'] as bool? ?? true,
    );
  }
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

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'defaultUnit': defaultUnit,
      'defaultLocation': defaultLocation,
      'lowStockThreshold': lowStockThreshold,
      'automaticReorder': automaticReorder,
      'reorderMethod': reorderMethod.index,
      'lowStockNotifications': lowStockNotifications,
      'expiryNotifications': expiryNotifications,
      'expiryNotificationDays': expiryNotificationDays,
      'defaultScanType': defaultScanType.index,
      'autoGenerateBarcodes': autoGenerateBarcodes,
    };
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
    final notifier = ref.read(inventorySettingsProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.inventorySettings ?? ''),
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
                  tooltip: l10n?.saveSettings ?? '',
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
            _buildSectionHeader(l10n?.generalSettings ?? ''),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _defaultUnitController,
                      decoration: InputDecoration(
                        labelText: l10n?.defaultUnit ?? '',
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
                    TextFormField(
                      controller: _defaultLocationController,
                      decoration: InputDecoration(
                        labelText: l10n?.defaultLocation ?? '',
                        helperText: 'Default location for new items',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a default location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lowStockThresholdController,
                      decoration: InputDecoration(
                        labelText: l10n?.lowStockThreshold ?? '',
                        helperText: 'Minimum quantity before alert',
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reorder Settings
            _buildSectionHeader(l10n?.reorderSettings ?? ''),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text(l10n?.automaticReorder ?? ''),
                      subtitle: const Text(
                          'Automatically create purchase orders when stock is low'),
                      value: settings.automaticReorder,
                      onChanged: (value) {
                        notifier.updateAutomaticReorder(value);
                      },
                    ),
                    if (settings.automaticReorder) ...[
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                        child: Text(
                          l10n?.reorderMethod ?? '',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      RadioListTile<ReorderMethod>(
                        title: Text(l10n?.fixedReorderPoint ?? ''),
                        subtitle:
                            const Text('Use fixed thresholds for reordering'),
                        value: ReorderMethod.fixed,
                        groupValue: settings.reorderMethod,
                        onChanged: (value) {
                          if (value != null) {
                            notifier.updateReorderMethod(value);
                          }
                        },
                      ),
                      RadioListTile<ReorderMethod>(
                        title: Text(l10n?.dynamicReorderPoint ?? ''),
                        subtitle: const Text(
                            'Calculate reorder points based on usage history'),
                        value: ReorderMethod.dynamic,
                        groupValue: settings.reorderMethod,
                        onChanged: (value) {
                          if (value != null) {
                            notifier.updateReorderMethod(value);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notification Settings
            _buildSectionHeader(l10n?.notificationSettings ?? ''),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text(l10n?.lowStockNotifications ?? ''),
                      subtitle: const Text(
                          'Get notified when items reach low stock threshold'),
                      value: settings.lowStockNotifications,
                      onChanged: (value) {
                        notifier.updateLowStockNotifications(value);
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text(l10n?.expiryNotifications ?? ''),
                      subtitle: const Text('Get notified before items expire'),
                      value: settings.expiryNotifications,
                      onChanged: (value) {
                        notifier.updateExpiryNotifications(value);
                      },
                    ),
                    if (settings.expiryNotifications) ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextFormField(
                          controller: _expiryDaysController,
                          decoration: InputDecoration(
                            labelText: l10n?.expiryNotificationDays ?? '',
                            helperText:
                                'Days before expiry to show notification',
                            suffixText: 'days',
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
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Scanning Settings
            _buildSectionHeader(l10n?.scanningSettings ?? ''),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                      child: Text(
                        l10n?.defaultScanType ?? '',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    RadioListTile<ScanType>(
                      title: const Text('Barcode'),
                      value: ScanType.barcode,
                      groupValue: settings.defaultScanType,
                      onChanged: (value) {
                        if (value != null) {
                          notifier.updateDefaultScanType(value);
                        }
                      },
                    ),
                    RadioListTile<ScanType>(
                      title: const Text('QR Code'),
                      value: ScanType.qrCode,
                      groupValue: settings.defaultScanType,
                      onChanged: (value) {
                        if (value != null) {
                          notifier.updateDefaultScanType(value);
                        }
                      },
                    ),
                    RadioListTile<ScanType>(
                      title: const Text('Both'),
                      value: ScanType.both,
                      groupValue: settings.defaultScanType,
                      onChanged: (value) {
                        if (value != null) {
                          notifier.updateDefaultScanType(value);
                        }
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text(l10n?.autoGenerateBarcodes ?? ''),
                      value: settings.autoGenerateBarcodes,
                      onChanged: (value) {
                        notifier.updateAutoGenerateBarcodes(value);
                      },
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(l10n?.saveSettings ?? ''),
                    ),
                  ],
                ),
              ),
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
        final notifier = ref.read(inventorySettingsProvider.notifier);

        // Update the settings with form values
        notifier.updateDefaultUnit(_defaultUnitController.text);
        notifier.updateDefaultLocation(_defaultLocationController.text);
        notifier.updateLowStockThreshold(
            int.parse(_lowStockThresholdController.text));
        notifier.updateExpiryNotificationDays(
            int.parse(_expiryDaysController.text));

        // Save to SharedPreferences
        await notifier.saveSettings();

        // Simulate network delay
        await Future.delayed(const Duration(seconds: 1));

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)?.settingsSaved ?? ''),
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
