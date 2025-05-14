/// Represents a reminder for follow-up with a customer
class CrmReminder {

  const CrmReminder({
    required this.id,
    required this.customerId,
    required this.message,
    required this.remindAt,
    this.isCompleted = false,
  });

  /// Creates a CrmReminder from JSON map
  factory CrmReminder.fromJson(Map<String, dynamic> json) {
    return CrmReminder(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      message: json['message'] as String,
      remindAt: DateTime.parse(json['remindAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
  final String id;
  final String customerId;
  final String message;
  final DateTime remindAt;
  final bool isCompleted;

  /// Converts this CrmReminder to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'message': message,
      'remindAt': remindAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  /// Creates a copy of this CrmReminder with modified properties
  CrmReminder copyWith({
    String? id,
    String? customerId,
    String? message,
    DateTime? remindAt,
    bool? isCompleted,
  }) {
    return CrmReminder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      message: message ?? this.message,
      remindAt: remindAt ?? this.remindAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CrmReminder &&
        other.id == id &&
        other.customerId == customerId &&
        other.message == message &&
        other.remindAt == remindAt &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      customerId,
      message,
      remindAt,
      isCompleted,
    );
  }

  @override
  String toString() {
    return 'CrmReminder(id: $id, customerId: $customerId, message: $message, remindAt: $remindAt, isCompleted: $isCompleted)';
  }
}
