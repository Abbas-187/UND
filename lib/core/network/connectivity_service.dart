import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum representing the different connectivity states
enum ConnectivityStatus {
  /// Device is connected to the internet
  connected,

  /// Device is not connected to the internet
  disconnected
}

/// Provider for the connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Stream provider for the current connectivity status
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.statusStream;
});

/// Service to monitor network connectivity
class ConnectivityService {
  /// Stream controller for connectivity status
  final _controller = StreamController<ConnectivityStatus>.broadcast();

  /// The Connectivity instance
  final Connectivity _connectivity = Connectivity();

  /// Stream subscription for connectivity changes
  StreamSubscription? _subscription;

  /// Constructor
  ConnectivityService() {
    // Subscribe to connectivity changes
    _initConnectivity();
  }

  /// Initialize connectivity monitoring
  Future<void> _initConnectivity() async {
    // Set up the subscription to connectivity changes
    _subscription =
        _connectivity.onConnectivityChanged.listen(_processConnectivityResult);

    // Check initial connectivity
    await _checkConnectivity();
  }

  /// Stream of connectivity status updates
  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _processConnectivityResult(result);
    } catch (e) {
      // Default to disconnected if there's an error
      _controller.add(ConnectivityStatus.disconnected);
    }
  }

  /// Process connectivity result and determine if connected
  void _processConnectivityResult(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _controller.add(ConnectivityStatus.disconnected);
      return;
    }

    // If any of these connection types is available, consider as connected
    final hasConnection = results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);

    if (hasConnection) {
      _controller.add(ConnectivityStatus.connected);
    } else {
      _controller.add(ConnectivityStatus.disconnected);
    }
  }
}
