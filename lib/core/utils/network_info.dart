import 'package:connectivity_plus/connectivity_plus.dart';

/// Utility class to check network connectivity
class NetworkInfo {

  NetworkInfo([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();
  final Connectivity _connectivity;

  /// Checks if the device is connected to the internet
  Future<bool> get isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Stream of connectivity changes
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged
          .map((List<ConnectivityResult> results) {
        // Return the first result or NONE if the list is empty
        return results.isNotEmpty ? results.first : ConnectivityResult.none;
      });
}
