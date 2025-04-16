import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final String language;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool darkModeEnabled;

  const SettingsState({
    this.language = 'en',
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.darkModeEnabled = false,
  });

  SettingsState copyWith({
    String? language,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? darkModeEnabled,
  }) {
    return SettingsState(
      language: language ?? this.language,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs)
      : super(SettingsState(
          language: _prefs.getString('language') ?? 'en',
          pushNotificationsEnabled:
              _prefs.getBool('pushNotificationsEnabled') ?? true,
          emailNotificationsEnabled:
              _prefs.getBool('emailNotificationsEnabled') ?? true,
          darkModeEnabled: _prefs.getBool('darkModeEnabled') ?? false,
        ));

  void setLanguage(String language) async {
    await _prefs.setString('language', language);
    state = state.copyWith(language: language);
  }

  void togglePushNotifications() async {
    final newValue = !state.pushNotificationsEnabled;
    await _prefs.setBool('pushNotificationsEnabled', newValue);
    state = state.copyWith(pushNotificationsEnabled: newValue);
  }

  void toggleEmailNotifications() async {
    final newValue = !state.emailNotificationsEnabled;
    await _prefs.setBool('emailNotificationsEnabled', newValue);
    state = state.copyWith(emailNotificationsEnabled: newValue);
  }

  void toggleDarkMode() async {
    final newValue = !state.darkModeEnabled;
    await _prefs.setBool('darkModeEnabled', newValue);
    state = state.copyWith(darkModeEnabled: newValue);
  }
}

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main.dart');
});

// Provider for settings
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
