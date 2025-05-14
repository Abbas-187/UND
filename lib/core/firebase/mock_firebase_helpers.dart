import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// A MockMessaging implementation for testing without Firebase
class MockMessaging {
  // Simulate requesting permission
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) async {
    return MockNotificationSettings();
  }

  // Simulate setting foreground notification options
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async {
    debugPrint('Mock: Setting foreground notification options');
    return;
  }
}

/// Mock notification settings
class MockNotificationSettings implements NotificationSettings {
  @override
  AuthorizationStatus get authorizationStatus => AuthorizationStatus.authorized;

  @override
  AppleNotificationSetting get lockScreen => AppleNotificationSetting.enabled;

  @override
  AppleNotificationSetting get notificationCenter =>
      AppleNotificationSetting.enabled;

  @override
  AppleNotificationSetting get providesAppNotificationSettings =>
      AppleNotificationSetting.disabled;

  NotificationSettings copyWith({
    AuthorizationStatus? authorizationStatus,
    AppleNotificationSetting? alert,
    bool? announcement,
    AppleNotificationSetting? badge,
    AppleNotificationSetting? carPlay,
    AppleNotificationSetting? criticalAlert,
    AppleNotificationSetting? lockScreen,
    AppleNotificationSetting? notificationCenter,
    AppleShowPreviewSetting? showPreviews,
    AppleNotificationSetting? sound,
    AppleNotificationSetting? timeSensitive,
  }) {
    return this;
  }

  @override
  AppleNotificationSetting get alert => AppleNotificationSetting.enabled;

  @override
  AppleNotificationSetting get announcement =>
      AppleNotificationSetting.disabled;

  @override
  AppleNotificationSetting get badge => AppleNotificationSetting.enabled;

  @override
  AppleNotificationSetting get carPlay => AppleNotificationSetting.disabled;

  @override
  AppleNotificationSetting get criticalAlert =>
      AppleNotificationSetting.disabled;

  @override
  AppleShowPreviewSetting get showPreviews => AppleShowPreviewSetting.always;

  @override
  AppleNotificationSetting get sound => AppleNotificationSetting.enabled;

  @override
  AppleNotificationSetting get timeSensitive =>
      AppleNotificationSetting.disabled;
}

/// Provides Firebase implementation
class FirebaseImplementationProvider {
  /// Get a Firebase-like instance
  static dynamic getFirestoreInstance() {
    return null; // Will be handled by real Firebase
  }

  /// Get a messaging instance
  static dynamic getMessagingInstance() {
    return null; // Will be handled by real Firebase
  }

  /// Initialize app
  static Future<void> initializeApp(WidgetRef ref) async {
    // Use the real Firebase implementation
    debugPrint('Initializing app with real Firebase implementation');
  }

  /// Helper for safely handling required Firebase dependency in repositories
  static T safelyWrapRepository<T>(
      T Function(dynamic) repositoryCreator, dynamic mockInstance) {
    return repositoryCreator(mockInstance);
  }
}
