import 'package:freezed_annotation/freezed_annotation.dart';

part 'interaction_log.freezed.dart';
part 'interaction_log.g.dart';

/// Represents an interaction with a customer in the CRM system
@freezed
abstract class InteractionLog with _$InteractionLog {
  const factory InteractionLog({
    required String id,
    required String customerId,
    required String type, // e.g., 'call', 'email', 'meeting'
    required DateTime date,
    required String notes,
  }) = _InteractionLog;

  const InteractionLog._();

  /// Creates an InteractionLog from JSON map
  factory InteractionLog.fromJson(Map<String, dynamic> json) =>
      _$InteractionLogFromJson(json);
}
