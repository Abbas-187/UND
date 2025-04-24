import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/utils/network_info.dart';

/// Provider for the HTTP client
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

/// Provider for the DefaultCacheManager
final cacheManagerProvider = Provider<DefaultCacheManager>((ref) {
  return DefaultCacheManager();
});

/// Provider for NetworkInfo
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo();
});
