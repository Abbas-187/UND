class SupplierAddress {
  const SupplierAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  factory SupplierAddress.fromJson(Map<String, dynamic> json) {
    return SupplierAddress(
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
    );
  }
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  SupplierAddress copyWith({
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
  }) {
    return SupplierAddress(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }
}

class SupplierMetrics {
  const SupplierMetrics({
    required this.onTimeDeliveryRate,
    required this.qualityScore,
    required this.responseTime,
  });
  final double onTimeDeliveryRate;
  final int qualityScore;
  final int responseTime;

  factory SupplierMetrics.fromJson(Map<String, dynamic> json) {
    return SupplierMetrics(
      onTimeDeliveryRate: (json['onTimeDeliveryRate'] as num).toDouble(),
      qualityScore: json['qualityScore'] as int,
      responseTime: json['responseTime'] as int,
    );
  }
  Map<String, dynamic> toJson() => {
        'onTimeDeliveryRate': onTimeDeliveryRate,
        'qualityScore': qualityScore,
        'responseTime': responseTime,
      };
  SupplierMetrics copyWith({
    double? onTimeDeliveryRate,
    int? qualityScore,
    int? responseTime,
  }) =>
      SupplierMetrics(
        onTimeDeliveryRate: onTimeDeliveryRate ?? this.onTimeDeliveryRate,
        qualityScore: qualityScore ?? this.qualityScore,
        responseTime: responseTime ?? this.responseTime,
      );
}

class QualityLog {
  const QualityLog({
    required this.date,
    required this.score,
    required this.notes,
  });
  final DateTime date;
  final double score;
  final String notes;

  factory QualityLog.fromJson(Map<String, dynamic> json) {
    return QualityLog(
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toDouble(),
      notes: json['notes'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'score': score,
        'notes': notes,
      };
  QualityLog copyWith({
    DateTime? date,
    double? score,
    String? notes,
  }) =>
      QualityLog(
        date: date ?? this.date,
        score: score ?? this.score,
        notes: notes ?? this.notes,
      );
}

class SupplierPerformanceMetrics {
  /// Creates a new immutable [SupplierPerformanceMetrics] instance
  const SupplierPerformanceMetrics({
    required this.qualityScore,
    required this.deliveryScore,
    required this.priceScore,
    required this.overallScore,
  });

  /// Quality score of the supplier (0-5 scale)
  final double qualityScore;

  /// Delivery reliability score of the supplier (0-5 scale)
  final double deliveryScore;

  /// Price/value score of the supplier (0-5 scale)
  final double priceScore;

  /// Overall performance score of the supplier (0-5 scale)
  final double overallScore;

  /// Creates a [SupplierPerformanceMetrics] instance from a JSON map
  factory SupplierPerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return SupplierPerformanceMetrics(
      qualityScore: (json['quality_score'] ?? 0.0).toDouble(),
      deliveryScore: (json['delivery_score'] ?? 0.0).toDouble(),
      priceScore: (json['price_score'] ?? 0.0).toDouble(),
      overallScore: (json['overall_score'] ?? 0.0).toDouble(),
    );
  }

  /// Creates a copy of this [SupplierPerformanceMetrics] instance with the given fields replaced
  SupplierPerformanceMetrics copyWith({
    double? qualityScore,
    double? deliveryScore,
    double? priceScore,
    double? overallScore,
  }) {
    return SupplierPerformanceMetrics(
      qualityScore: qualityScore ?? this.qualityScore,
      deliveryScore: deliveryScore ?? this.deliveryScore,
      priceScore: priceScore ?? this.priceScore,
      overallScore: overallScore ?? this.overallScore,
    );
  }

  /// Converts this [SupplierPerformanceMetrics] instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'quality_score': qualityScore,
      'delivery_score': deliveryScore,
      'price_score': priceScore,
      'overall_score': overallScore,
    };
  }

  @override
  String toString() {
    return 'SupplierPerformanceMetrics(qualityScore: $qualityScore, deliveryScore: $deliveryScore, priceScore: $priceScore, overallScore: $overallScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SupplierPerformanceMetrics &&
        other.qualityScore == qualityScore &&
        other.deliveryScore == deliveryScore &&
        other.priceScore == priceScore &&
        other.overallScore == overallScore;
  }

  @override
  int get hashCode {
    return Object.hash(
      qualityScore,
      deliveryScore,
      priceScore,
      overallScore,
    );
  }
}

class Supplier {
  Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    required this.productCategories,
    this.additionalAttributes,
    DateTime? lastOrderDate,
    required this.isActive,
    required this.rating,
    this.notes = '',
    this.taxId = '',
    this.paymentTerms = '',
    this.website = '',
    DateTime? lastUpdated,
    required this.metrics,
    this.certifications = const [],
    this.qualityLogs = const [],
  })  : lastOrderDate = lastOrderDate ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      contactPerson: json['contactPerson'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address:
          SupplierAddress.fromJson(json['address'] as Map<String, dynamic>),
      productCategories: List<String>.from(json['productCategories'] as List),
      additionalAttributes:
          json['additionalAttributes'] as Map<String, dynamic>?,
      lastOrderDate: DateTime.parse(json['lastOrderDate'] as String),
      isActive: json['isActive'] as bool,
      rating: (json['rating'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
      taxId: json['taxId'] as String? ?? '',
      paymentTerms: json['paymentTerms'] as String? ?? '',
      website: json['website'] as String? ?? '',
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      metrics:
          SupplierMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      qualityLogs: (json['qualityLogs'] as List<dynamic>?)
              ?.map((e) => QualityLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
  final String id;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final SupplierAddress address;
  final List<String> productCategories;
  final Map<String, dynamic>? additionalAttributes;
  final DateTime lastOrderDate;
  final bool isActive;
  final double rating; // 1-5 scale
  final String notes;
  final String taxId;
  final String paymentTerms;
  final String website;
  final DateTime lastUpdated;
  final SupplierMetrics metrics;
  final List<String> certifications;
  final List<QualityLog> qualityLogs;

  Supplier copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? email,
    String? phone,
    SupplierAddress? address,
    List<String>? productCategories,
    Map<String, dynamic>? additionalAttributes,
    DateTime? lastOrderDate,
    bool? isActive,
    double? rating,
    String? notes,
    String? taxId,
    String? paymentTerms,
    String? website,
    DateTime? lastUpdated,
    SupplierMetrics? metrics,
    List<String>? certifications,
    List<QualityLog>? qualityLogs,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      productCategories: productCategories ?? this.productCategories,
      additionalAttributes: additionalAttributes ?? this.additionalAttributes,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      taxId: taxId ?? this.taxId,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      website: website ?? this.website,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metrics: metrics ?? this.metrics,
      certifications: certifications ?? this.certifications,
      qualityLogs: qualityLogs ?? this.qualityLogs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'address': address.toJson(),
      'productCategories': productCategories,
      'additionalAttributes': additionalAttributes,
      'lastOrderDate': lastOrderDate.toIso8601String(),
      'isActive': isActive,
      'rating': rating,
      'notes': notes,
      'taxId': taxId,
      'paymentTerms': paymentTerms,
      'website': website,
      'lastUpdated': lastUpdated.toIso8601String(),
      'metrics': metrics.toJson(),
      'certifications': certifications,
      'qualityLogs': qualityLogs.map((e) => e.toJson()).toList(),
    };
  }
}
