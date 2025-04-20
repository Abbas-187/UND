enum Environment { dev, test, prod }

class AppConfig {
  // Singleton pattern
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() {
    return _instance;
  }

  // Private properties
  Environment _environment;
  String _apiBaseUrl;
  bool _enableLogging;
  bool _useMockData;

  AppConfig._internal()
      : _environment = Environment.dev,
        _apiBaseUrl = 'https://api.und-dairy.com',
        _enableLogging = true,
        _useMockData = true;

  // Factory method to initialize with specific environment
  static void initialize({
    required Environment environment,
    required String apiBaseUrl,
    required bool enableLogging,
    required bool useMockData,
  }) {
    _instance._environment = environment;
    _instance._apiBaseUrl = apiBaseUrl;
    _instance._enableLogging = enableLogging;
    _instance._useMockData = useMockData;
  }

  // Getters
  Environment get environment => _environment;
  String get apiBaseUrl => _apiBaseUrl;
  bool get enableLogging => _enableLogging;
  bool get useMockData => _useMockData;
}
