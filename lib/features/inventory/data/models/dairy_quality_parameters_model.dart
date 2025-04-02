/// on generated files.
class DairyQualityParametersModel {
  const DairyQualityParametersModel({
    required this.id,
    required this.parameterName,
    required this.value,
  });

  factory DairyQualityParametersModel.fromJson(Map<String, dynamic> json) {
    return DairyQualityParametersModel(
      id: json['id'] as String,
      parameterName: json['parameterName'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }
  final String id;
  final String parameterName;
  final double value;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parameterName': parameterName,
      'value': value,
    };
  }
}
