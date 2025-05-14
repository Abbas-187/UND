import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../shared/constants/api_endpoints.dart';
import '../../domain/repositories/order_discussion_repository.dart';
import '../datasources/local/order_discussion_local_datasource.dart';
import '../datasources/remote/order_discussion_remote_datasource.dart';
import '../repositories/order_discussion_repository_impl.dart';

/// Provides remote datasource for order discussions
final orderDiscussionRemoteDataSourceProvider =
    Provider<OrderDiscussionRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  final baseUrl = ApiEndpoints.orderDiscussions;
  return OrderDiscussionRemoteDataSourceImpl(client: client, baseUrl: baseUrl);
});

/// Provides local datasource for order discussions
final orderDiscussionLocalDataSourceProvider =
    Provider<OrderDiscussionLocalDataSource>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return OrderDiscussionLocalDataSourceImpl(sharedPreferences: sharedPrefs);
});

/// Provides repository implementation for order discussions
final orderDiscussionRepositoryProvider =
    Provider<OrderDiscussionRepository>((ref) {
  final remote = ref.watch(orderDiscussionRemoteDataSourceProvider);
  final local = ref.watch(orderDiscussionLocalDataSourceProvider);
  return OrderDiscussionRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: local,
  );
});
