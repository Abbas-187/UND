// Model representing a demand signal from CRM for forecasting
class DemandSignalModel {
  // Opportunity/campaign/segment/lead id

  DemandSignalModel({
    required this.productId,
    required this.signalDate,
    required this.signalQuantity,
    required this.signalType,
    required this.confidenceScore,
    this.sourceId,
  });

  factory DemandSignalModel.fromJson(Map<String, dynamic> json) =>
      DemandSignalModel(
        productId: json['productId'] as String,
        signalDate: DateTime.parse(json['signalDate'] as String),
        signalQuantity: (json['signalQuantity'] as num).toDouble(),
        signalType: json['signalType'] as String,
        confidenceScore: (json['confidenceScore'] as num).toDouble(),
        sourceId: json['sourceId'] as String?,
      );
  final String productId;
  final DateTime signalDate;
  final double signalQuantity;
  final String
      signalType; // e.g., 'PROMOTION', 'OPPORTUNITY', 'SEGMENT_TREND', 'NEW_CUSTOMER'
  final double confidenceScore;
  final String? sourceId;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'signalDate': signalDate.toIso8601String(),
        'signalQuantity': signalQuantity,
        'signalType': signalType,
        'confidenceScore': confidenceScore,
        'sourceId': sourceId,
      };
}
