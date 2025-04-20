class PriceListModel {
  PriceListModel({
    this.id,
    required this.name,
    required this.description,
    required this.effectiveFrom,
    this.effectiveTo,
    this.status = 'active',
    required this.prices,
    this.customerCategory,
    this.applicableCustomerIds,
    this.createdBy,
    this.createdDate,
    this.approvedBy,
    this.approvalDate,
  });

  factory PriceListModel.fromJson(Map<String, dynamic> json) {
    return PriceListModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      effectiveFrom: DateTime.parse(json['effectiveFrom'] as String),
      effectiveTo: json['effectiveTo'] != null
          ? DateTime.parse(json['effectiveTo'] as String)
          : null,
      status: json['status'] as String? ?? 'active',
      prices: _parsePrices(json['prices'] as Map<String, dynamic>),
      customerCategory: json['customerCategory'] as String?,
      applicableCustomerIds: json['applicableCustomerIds'] != null
          ? List<String>.from(json['applicableCustomerIds'] as List)
          : null,
      createdBy: json['createdBy'] as String?,
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'] as String)
          : null,
      approvedBy: json['approvedBy'] as String?,
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'] as String)
          : null,
    );
  }
  final String? id;
  final String name;
  final String description;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final String status;
  final Map<String, Map<String, double>> prices;
  final String? customerCategory;
  final List<String>? applicableCustomerIds;
  final String? createdBy;
  final DateTime? createdDate;
  final String? approvedBy;
  final DateTime? approvalDate;

  static Map<String, Map<String, double>> _parsePrices(
      Map<String, dynamic> json) {
    final result = <String, Map<String, double>>{};
    json.forEach((productId, priceData) {
      final priceMap = <String, double>{};
      (priceData as Map<String, dynamic>).forEach((key, value) {
        priceMap[key] = (value as num).toDouble();
      });
      result[productId] = priceMap;
    });
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'effectiveFrom': effectiveFrom.toIso8601String(),
      if (effectiveTo != null) 'effectiveTo': effectiveTo!.toIso8601String(),
      'status': status,
      'prices': prices,
      if (customerCategory != null) 'customerCategory': customerCategory,
      if (applicableCustomerIds != null)
        'applicableCustomerIds': applicableCustomerIds,
      if (createdBy != null) 'createdBy': createdBy,
      if (createdDate != null) 'createdDate': createdDate!.toIso8601String(),
      if (approvedBy != null) 'approvedBy': approvedBy,
      if (approvalDate != null) 'approvalDate': approvalDate!.toIso8601String(),
    };
  }

  PriceListModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    String? status,
    Map<String, Map<String, double>>? prices,
    String? customerCategory,
    List<String>? applicableCustomerIds,
    String? createdBy,
    DateTime? createdDate,
    String? approvedBy,
    DateTime? approvalDate,
  }) {
    return PriceListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      status: status ?? this.status,
      prices: prices ?? this.prices,
      customerCategory: customerCategory ?? this.customerCategory,
      applicableCustomerIds:
          applicableCustomerIds ?? this.applicableCustomerIds,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      approvedBy: approvedBy ?? this.approvedBy,
      approvalDate: approvalDate ?? this.approvalDate,
    );
  }
}

// Remove legacy freezed comment
