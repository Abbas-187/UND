// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reason_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReasonCode _$ReasonCodeFromJson(Map<String, dynamic> json) => _ReasonCode(
      reasonCodeId: json['reason_code_id'] as String,
      reasonCode: json['reason_code'] as String,
      description: json['description'] as String?,
      appliesTo: json['applies_to'] as String,
    );

Map<String, dynamic> _$ReasonCodeToJson(_ReasonCode instance) =>
    <String, dynamic>{
      'reason_code_id': instance.reasonCodeId,
      'reason_code': instance.reasonCode,
      'description': instance.description,
      'applies_to': instance.appliesTo,
    };
