/// Configuration for the application
class AppConfig {

  /// Create a new AppConfig instance
  AppConfig({
    this.enableLogging = true,
    this.isProduction = false,
    this.appName = 'UND Dairy Management',
    this.apiBaseUrl = 'https://api.unddairy.com/v1',
  });
  /// Whether to enable logging
  final bool enableLogging;

  /// Whether the app is in production mode
  final bool isProduction;

  /// The application name
  final String appName;

  /// The base URL for API requests
  final String apiBaseUrl;
}
