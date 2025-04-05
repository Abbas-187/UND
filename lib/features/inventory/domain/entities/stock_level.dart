class StockLevel {
  final String materialId;
  final String materialName;
  final double currentLevel;
  final double minLevel;
  final double maxLevel;
  final double criticalLevel;
  final int leadTimeDays;
  final String unit;

  StockLevel({
    required this.materialId,
    required this.materialName,
    required this.currentLevel,
    required this.minLevel,
    required this.maxLevel,
    required this.criticalLevel,
    required this.leadTimeDays,
    required this.unit,
  });

  factory StockLevel.fromJson(Map<String, dynamic> json) {
    return StockLevel(
      materialId: json['materialId'] as String,
      materialName: json['materialName'] as String,
      currentLevel: json['currentLevel'] as double,
      minLevel: json['minLevel'] as double,
      maxLevel: json['maxLevel'] as double,
      criticalLevel: json['criticalLevel'] as double,
      leadTimeDays: json['leadTimeDays'] as int,
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'currentLevel': currentLevel,
      'minLevel': minLevel,
      'maxLevel': maxLevel,
      'criticalLevel': criticalLevel,
      'leadTimeDays': leadTimeDays,
      'unit': unit,
    };
  }
}
