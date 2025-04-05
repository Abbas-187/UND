/// on generated files.
class DairyQualityParametersModel {
  const DairyQualityParametersModel({
    required this.id,
    required this.parameterName,
    required this.value,
    this.status,
    this.testDate,
    this.fatContent,
    this.proteinContent,
  });

  factory DairyQualityParametersModel.fromJson(Map<String, dynamic> json) {
    return DairyQualityParametersModel(
      id: json['id'] as String,
      parameterName: json['parameterName'] as String,
      value: (json['value'] as num).toDouble(),
      status: json['status'] as String?,
      testDate: json['testDate'] != null
          ? DateTime.parse(json['testDate'] as String)
          : null,
      fatContent: json['fatContent'] != null
          ? (json['fatContent'] as num).toDouble()
          : null,
      proteinContent: json['proteinContent'] != null
          ? (json['proteinContent'] as num).toDouble()
          : null,
    );
  }
  final String id;
  final String parameterName;
  final double value;
  final String? status;
  final DateTime? testDate;
  final double? fatContent;
  final double? proteinContent;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parameterName': parameterName,
      'value': value,
      'status': status,
      'testDate': testDate?.toIso8601String(),
      'fatContent': fatContent,
      'proteinContent': proteinContent,
    };
  }
}
