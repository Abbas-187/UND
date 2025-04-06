/// A simple service locator for dependency injection
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator _instance = ServiceLocator._();

  /// Singleton instance of the service locator
  static ServiceLocator get instance => _instance;

  /// Map of registered services
  final Map<Type, dynamic> _services = {};

  /// Register a service
  void register<T>(T service) {
    _services[T] = service;
  }

  /// Get a service
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not registered');
    }
    return service as T;
  }

  /// Check if a service is registered
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Remove a service
  void unregister<T>() {
    _services.remove(T);
  }

  /// Clear all services
  void clear() {
    _services.clear();
  }
}
