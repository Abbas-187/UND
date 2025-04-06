class TimeSeriesPoint {

  TimeSeriesPoint({
    required this.date,
    required this.value,
  });

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    return TimeSeriesPoint(
      date: DateTime.parse(json['date']),
      value: json['value'].toDouble(),
    );
  }
  final DateTime date;
  final double value;

  @override
  String toString() => 'TimeSeriesPoint(date: $date, value: $value)';

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'value': value,
      };
}
