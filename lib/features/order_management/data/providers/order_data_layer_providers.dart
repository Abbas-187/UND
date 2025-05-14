import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../shared/constants/api_endpoints.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local/order_local_datasource.dart';
import '../datasources/remote/order_remote_datasource.dart';
import '../repositories/order_repository_impl.dart';

/// Provides remote datasource for orders
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  final baseUrl = ApiEndpoints.orders;
  return OrderRemoteDataSourceImpl(client: client, baseUrl: baseUrl);
});

/// Provides local datasource for orders
final orderLocalDataSourceProvider = Provider<OrderLocalDataSource>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return OrderLocalDataSourceImpl(sharedPreferences: sharedPrefs);
});

/// Provides repository implementation combining remote and local datasources
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remote = ref.watch(orderRemoteDataSourceProvider);
  final local = ref.watch(orderLocalDataSourceProvider);
  return OrderRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: local,
  );
});
