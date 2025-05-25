import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_go_router.dart';
import '../../../../features/shared/models/user_role.dart';
import '../../../../features/shared/providers/user_role_provider.dart';
import '../../../shared/presentation/screens/app_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentRole = ref.watch(userRoleProvider);
    // Watch persisted app settings
    final appSettings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settings ?? 'Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Role selection section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Role Settings (Testing)',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Current role indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select a role to test different UI layouts and permissions:',
              style: theme.textTheme.bodyMedium,
            ),
          ),

          const SizedBox(height: 16),

          // Role selection cards
          ...UserRoles.allRoles.map((role) => _buildRoleCard(
                context: context,
                role: role,
                isSelected: role.id == currentRole.id,
                onSelected: () => _changeRole(ref, role),
              )),

          const SizedBox(height: 32),

          // Permissions explanation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: theme.colorScheme.primaryContainer
                  .withValues(alpha: 0.5 * 255),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Role Permissions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPermissionItem(
                      context: context,
                      label: 'Allowed Modules',
                      value: currentRole.allowedModules.join(', '),
                      icon: Icons.dashboard,
                    ),
                    _buildPermissionItem(
                      context: context,
                      label: 'Access Settings',
                      value: currentRole.canAccessSettings ? 'Yes' : 'No',
                      icon: Icons.settings,
                    ),
                    _buildPermissionItem(
                      context: context,
                      label: 'Access Notifications',
                      value: currentRole.canAccessNotifications ? 'Yes' : 'No',
                      icon: Icons.notifications,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Language Settings
          _buildSectionHeader(
              context, l10n?.languageSettings ?? 'Language Settings'),
          Card(
            child: ListTile(
              title: Text(l10n?.language ?? 'English'),
              trailing: DropdownButton<String>(
                value: appSettings.language,
                onChanged: (value) => value != null
                    ? settingsNotifier.updateLanguage(value)
                    : null,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  DropdownMenuItem(value: 'ur', child: Text('اردو')),
                  DropdownMenuItem(value: 'hi', child: Text('हिंदी')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Theme Settings
          _buildSectionHeader(context, l10n?.themeSettings ?? 'Theme Settings'),
          Card(
            child: Column(
              children: ThemeMode.values.map((mode) {
                final label = mode == ThemeMode.light
                    ? l10n?.lightTheme
                    : mode == ThemeMode.dark
                        ? l10n?.darkTheme
                        : l10n?.systemTheme;
                return RadioListTile<ThemeMode>(
                  title: Text(label ?? 'System Theme'),
                  value: mode,
                  groupValue: appSettings.themeMode,
                  onChanged: (value) => value != null
                      ? settingsNotifier.updateThemeMode(value)
                      : null,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Notification Settings
          _buildSectionHeader(
              context, l10n?.notificationSettings ?? 'Notification Settings'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title:
                      Text(l10n?.enableNotifications ?? 'Enable Notifications'),
                  value: appSettings.notificationsEnabled,
                  onChanged: settingsNotifier.updateNotificationsEnabled,
                ),
                if (appSettings.notificationsEnabled) ...[
                  SwitchListTile(
                    title: Text(l10n?.enableSounds ?? 'Enable Sounds'),
                    value: appSettings.soundEnabled,
                    onChanged: settingsNotifier.updateSoundEnabled,
                  ),
                  SwitchListTile(
                    title: Text(l10n?.enableVibration ?? 'Enable Vibration'),
                    value: appSettings.vibrationEnabled,
                    onChanged: settingsNotifier.updateVibrationEnabled,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Module-specific Settings
          _buildSectionHeader(
              context, l10n?.moduleSettings ?? 'Module Settings'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2),
              title: Text(l10n?.inventorySettings ?? 'Inventory Settings'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => context.go(AppRoutes.inventorySettings),
            ),
          ),
          const SizedBox(height: 32),

          // Save preferences explicitly if needed
          ElevatedButton(
            onPressed: () async {
              await settingsNotifier.saveSettings();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(l10n?.settingsSaved ?? 'Settings saved'),
                      backgroundColor: Colors.green),
                );
              }
            },
            child: Text(l10n?.saveSettings ?? 'Save Settings'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _changeRole(WidgetRef ref, UserRole role) {
    ref.read(userRoleProvider.notifier).setRole(role);
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required UserRole role,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 2 : 1,
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2 * 255)),
      ),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.2 * 255)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface
                            .withValues(alpha: 0.2 * 255),
                    width: 1,
                  ),
                ),
                child: Icon(
                  role.icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface
                          .withValues(alpha: 0.7 * 255),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.8 * 255)
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.6 * 255),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer
                .withValues(alpha: 0.7 * 255),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
