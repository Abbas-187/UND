import 'package:freezed_annotation/freezed_annotation.dart';

part 'crm_report.freezed.dart';
part 'crm_report.g.dart';

/// Represents a report of CRM metrics
@freezed
abstract class CrmReport with _$CrmReport {
  const factory CrmReport({
    @JsonKey(name: 'total_customers') required int totalCustomers,
    @JsonKey(name: 'total_interactions') required int totalInteractions,
    @JsonKey(name: 'total_orders') required int totalOrders,
  }) = _CrmReport;

  /// Creates a CrmReport from JSON map
  factory CrmReport.fromJson(Map<String, dynamic> json) =>
      _$CrmReportFromJson(json);
}

/// Extension to provide dummy data for CrmReport
extension CrmReportDummy on CrmReport {
  static CrmReport dummy() {
    return CrmReport(
      totalCustomers: 0,
      totalInteractions: 0,
      totalOrders: 0,
    );
  }
}
