import 'package:freezed_annotation/freezed_annotation.dart';

part 'reason_code.freezed.dart';
part 'reason_code.g.dart';

@freezed
abstract class ReasonCode with _$ReasonCode {
  const factory ReasonCode({
    required String reasonCodeId,
    required String reasonCode,
    String? description,
    required String appliesTo, // e.g., 'CycleCount', 'ManualAdjustment'
  }) = _ReasonCode;

  factory ReasonCode.fromJson(Map<String, dynamic> json) =>
      _$ReasonCodeFromJson(json);
}
