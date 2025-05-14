// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CrmReport _$CrmReportFromJson(Map<String, dynamic> json) => _CrmReport(
      totalCustomers: (json['total_customers'] as num).toInt(),
      totalInteractions: (json['total_interactions'] as num).toInt(),
      totalOrders: (json['total_orders'] as num).toInt(),
    );

Map<String, dynamic> _$CrmReportToJson(_CrmReport instance) =>
    <String, dynamic>{
      'total_customers': instance.totalCustomers,
      'total_interactions': instance.totalInteractions,
      'total_orders': instance.totalOrders,
    };
