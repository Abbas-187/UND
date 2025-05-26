import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/routes/app_go_router.dart';

// Constants for SharedPreferences keys
const String _appSettingsKey = 'app_settings';

// Provider for app settings that persists between app launches
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});

// Notifier to handle app settings state and persistence
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier()
      : super(const AppSettings(
          language: 'en',
          themeMode: ThemeMode.light,
          notificationsEnabled: true,
          soundEnabled: true,
          vibrationEnabled: true,
          bypassLogin: false,
        )) {
    // Load saved settings when notifier is created
    _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSettings = prefs.getString(_appSettingsKey);

      if (savedSettings != null) {
        final Map<String, dynamic> settingsMap = jsonDecode(savedSettings);
        state = AppSettings.fromJson(settingsMap);
      }
    } catch (e) {
      // If loading fails, the default settings in super() will be used
      debugPrint('Error loading settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appSettingsKey, jsonEncode(state.toJson()));
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // Update settings with new values
  void updateSettings(AppSettings newSettings) {
    state = newSettings;
    saveSettings();
  }

  // Update specific setting fields
  void updateLanguage(String language) {
    state = state.copyWith(language: language);
    saveSettings();
  }

  void updateThemeMode(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
    saveSettings();
  }

  void updateNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    saveSettings();
  }

  void updateSoundEnabled(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
    saveSettings();
  }

  void updateVibrationEnabled(bool enabled) {
    state = state.copyWith(vibrationEnabled: enabled);
    saveSettings();
  }

  void updateBypassLogin(bool enabled) {
    state = state.copyWith(bypassLogin: enabled);
    saveSettings();
  }
}

// Model for app settings
class AppSettings {
  // Create from JSON from storage
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language'] as String? ?? 'en',
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      bypassLogin: json['bypassLogin'] as bool? ?? false,
    );
  }
  const AppSettings({
    required this.language,
    required this.themeMode,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.bypassLogin,
  });

  final String language;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool bypassLogin;

  AppSettings copyWith({
    String? language,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? bypassLogin,
  }) {
    return AppSettings(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      bypassLogin: bypassLogin ?? this.bypassLogin,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'themeMode': themeMode.index,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'bypassLogin': bypassLogin,
    };
  }
}

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settings ?? ''),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Language Settings
          _buildSectionHeader(context, l10n?.languageSettings ?? ''),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(l10n?.language ?? ''),
                    trailing: DropdownButton<String>(
                      value: settings.language,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          notifier.updateLanguage(newValue);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: const Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'ar',
                          child: const Text('العربية'),
                        ),
                        DropdownMenuItem(
                          value: 'ur',
                          child: const Text('اردو'),
                        ),
                        DropdownMenuItem(
                          value: 'hi',
                          child: const Text('हिंदी'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Theme Settings
          _buildSectionHeader(context, l10n?.themeSettings ?? ''),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text(l10n?.lightTheme ?? ''),
                    value: ThemeMode.light,
                    groupValue: settings.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        notifier.updateThemeMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n?.darkTheme ?? ''),
                    value: ThemeMode.dark,
                    groupValue: settings.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        notifier.updateThemeMode(value);
                      }
                    },
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n?.systemTheme ?? ''),
                    value: ThemeMode.system,
                    groupValue: settings.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        notifier.updateThemeMode(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notification Settings
          _buildSectionHeader(context, l10n?.notificationSettings ?? ''),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n?.enableNotifications ?? ''),
                    value: settings.notificationsEnabled,
                    onChanged: (value) {
                      notifier.updateNotificationsEnabled(value);
                    },
                  ),
                  if (settings.notificationsEnabled) ...[
                    SwitchListTile(
                      title: Text(l10n?.enableSounds ?? ''),
                      value: settings.soundEnabled,
                      onChanged: (value) {
                        notifier.updateSoundEnabled(value);
                      },
                    ),
                    SwitchListTile(
                      title: Text(l10n?.enableVibration ?? ''),
                      value: settings.vibrationEnabled,
                      onChanged: (value) {
                        notifier.updateVibrationEnabled(value);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Module-specific Settings
          _buildSectionHeader(context, l10n?.moduleSettings ?? ''),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text(l10n?.inventorySettings ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.inventorySettings);
                    },
                  ),
                  // Add more module-specific settings here as needed
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Developer Settings
          _buildSectionHeader(context, 'Developer Settings'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Bypass Login Screen'),
                    subtitle: const Text(
                        'Skip authentication for development purposes'),
                    value: settings.bypassLogin,
                    onChanged: (value) {
                      notifier.updateBypassLogin(value);
                    },
                    secondary: const Icon(Icons.security),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 32),

          // Save button
          ElevatedButton(
            onPressed: () async {
              // Explicitly save settings (though they're already saved on each change)
              await notifier.saveSettings();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n?.settingsSaved ?? ''),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(l10n?.saveSettings ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
