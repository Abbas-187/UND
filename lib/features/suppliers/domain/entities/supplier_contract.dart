class SupplierContract {

  const SupplierContract({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.contractNumber,
    required this.contractType,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.value,
    required this.currency,
    required this.isActive,
    required this.autoRenew,
    required this.renewalNoticeDays,
    this.terms,
    required this.attachments,
    required this.pricingSchedule,
    required this.tags,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String supplierId;
  final String supplierName;
  final String contractNumber;
  final String contractType;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double value;
  final String currency;
  final bool isActive;
  final bool autoRenew;
  final int renewalNoticeDays;
  final Map<String, dynamic>? terms;
  final List<Map<String, dynamic>> attachments;
  final List<Map<String, dynamic>> pricingSchedule;
  final List<String> tags;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Calculate if the contract is expiring soon
  bool isExpiringSoon(int daysThreshold) {
    final daysRemaining = endDate.difference(DateTime.now()).inDays;
    return daysRemaining <= daysThreshold && daysRemaining >= 0;
  }

  // Calculate if the contract needs renewal notice
  bool needsRenewalNotice() {
    if (!autoRenew) return false;

    final daysUntilRenewalNotice = endDate
        .subtract(Duration(days: renewalNoticeDays))
        .difference(DateTime.now())
        .inDays;

    return daysUntilRenewalNotice <= 0 &&
        daysUntilRenewalNotice >= -renewalNoticeDays;
  }

  // Calculate contract status
  String get status {
    if (!isActive) return 'Inactive';

    final now = DateTime.now();
    if (now.isBefore(startDate)) return 'Pending';
    if (now.isAfter(endDate)) return 'Expired';
    if (isExpiringSoon(30)) return 'Expiring Soon';
    return 'Active';
  }

  // Calculate contract duration in months
  int get durationInMonths {
    return ((endDate.year - startDate.year) * 12) +
        (endDate.month - startDate.month);
  }

  SupplierContract copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    String? contractNumber,
    String? contractType,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? value,
    String? currency,
    bool? isActive,
    bool? autoRenew,
    int? renewalNoticeDays,
    Map<String, dynamic>? terms,
    List<Map<String, dynamic>>? attachments,
    List<Map<String, dynamic>>? pricingSchedule,
    List<String>? tags,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierContract(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      contractNumber: contractNumber ?? this.contractNumber,
      contractType: contractType ?? this.contractType,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      value: value ?? this.value,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      autoRenew: autoRenew ?? this.autoRenew,
      renewalNoticeDays: renewalNoticeDays ?? this.renewalNoticeDays,
      terms: terms ?? this.terms,
      attachments: attachments ?? this.attachments,
      pricingSchedule: pricingSchedule ?? this.pricingSchedule,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
