import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:und_app/l10n/app_localizations.dart';
import '../../../../features/inventory/data/repositories/dairy_inventory_repository.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isResettingInventory = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(l10n.language),
          _buildLanguageSelector(settings.language),
          const Divider(),
          _buildSectionHeader(l10n.notifications),
          _buildNotificationSettings(settings),
          const Divider(),
          _buildSectionHeader(l10n.appearance),
          _buildAppearanceSettings(settings),
          const Divider(),
          _buildSectionHeader('Data Management'),
          _buildDataManagementSettings(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildLanguageSelector(String currentLanguage) {
    return ListTile(
      title: Text(AppLocalizations.of(context).language),
      trailing: DropdownButton<String>(
        value: currentLanguage,
        items: [
          DropdownMenuItem(
            value: 'en',
            child: Text('English'),
          ),
          DropdownMenuItem(
            value: 'ar',
            child: Text('العربية'),
          ),
          DropdownMenuItem(
            value: 'ur',
            child: Text('اردو'),
          ),
          DropdownMenuItem(
            value: 'hi',
            child: Text('हिंदी'),
          ),
        ],
        onChanged: (String? newValue) {
          if (newValue != null) {
            ref.read(settingsProvider.notifier).setLanguage(newValue);
          }
        },
      ),
    );
  }

  Widget _buildNotificationSettings(SettingsState settings) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(AppLocalizations.of(context).pushNotifications),
          subtitle: Text(AppLocalizations.of(context).receivePushNotifications),
          value: settings.pushNotificationsEnabled,
          onChanged: (bool value) {
            ref.read(settingsProvider.notifier).togglePushNotifications();
          },
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context).emailNotifications),
          subtitle:
              Text(AppLocalizations.of(context).receiveEmailNotifications),
          value: settings.emailNotificationsEnabled,
          onChanged: (bool value) {
            ref.read(settingsProvider.notifier).toggleEmailNotifications();
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSettings(SettingsState settings) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(AppLocalizations.of(context).darkMode),
          subtitle: Text(AppLocalizations.of(context).enableDarkMode),
          value: settings.darkModeEnabled,
          onChanged: (bool value) {
            ref.read(settingsProvider.notifier).toggleDarkMode();
          },
        ),
      ],
    );
  }

  Widget _buildDataManagementSettings() {
    return Column(
      children: [
        ListTile(
          title: const Text('Reset Dairy Inventory Data'),
          subtitle:
              const Text('Restore all dairy inventory data to default state'),
          trailing: _isResettingInventory
              ? const SizedBox(
                  width: 24, height: 24, child: CircularProgressIndicator())
              : const Icon(Icons.restart_alt),
          onTap: () => _showResetConfirmationDialog(),
        ),
      ],
    );
  }

  Future<void> _showResetConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Inventory Data'),
        content: const Text(
            'Are you sure you want to reset all dairy inventory data to default values? '
            'This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('RESET'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _resetInventoryData();
    }
  }

  Future<void> _resetInventoryData() async {
    try {
      setState(() {
        _isResettingInventory = true;
      });

      // Get the repository and reset the inventory
      final dairyRepo = ref.read(dairyInventoryRepositoryProvider);
      await dairyRepo.resetInventory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dairy inventory data has been reset successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResettingInventory = false;
        });
      }
    }
  }
}
