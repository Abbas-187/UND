import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  // Track logout operations for analytics or debugging
  static int _logoutCount = 0;
  static DateTime? _lastLogoutTime;

  LogoutUseCase(this.repository);

  Future<void> execute() async {
    try {
      // Pre-logout operations
      await _performPreLogoutCleanup();

      // Perform the actual logout
      await repository.logout();

      // Post-logout tracking
      _logoutCount++;
      _lastLogoutTime = DateTime.now();

      // Post-logout cleanup
      await _performPostLogoutCleanup();
    } catch (e) {
      // Log the error but don't expose internal details
      print('Logout failed: $e'); // In production, use proper logging
      rethrow;
    }
  }

  Future<void> _performPreLogoutCleanup() async {
    // Add pre-logout cleanup operations here
    // For example:
    // - Save any unsaved data
    // - Clear sensitive data from memory
    // - Cancel ongoing operations
    // - Disconnect from real-time services
  }

  Future<void> _performPostLogoutCleanup() async {
    // Add post-logout cleanup operations here
    // For example:
    // - Clear local storage
    // - Reset app state
    // - Clear caches
    // - Reset navigation stack
  }

  // Analytics methods (could be moved to a separate analytics service)
  static int getLogoutCount() => _logoutCount;
  static DateTime? getLastLogoutTime() => _lastLogoutTime;
  static void resetAnalytics() {
    _logoutCount = 0;
    _lastLogoutTime = null;
  }
}
