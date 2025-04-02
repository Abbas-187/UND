class SupplierAddress {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  const SupplierAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

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

  factory SupplierAddress.fromJson(Map<String, dynamic> json) {
    return SupplierAddress(
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
    );
  }
}

class Supplier {
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
  })  : lastOrderDate = lastOrderDate ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

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
    };
  }

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
    );
  }
}
