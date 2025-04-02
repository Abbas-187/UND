// Non-freezed model implementation to avoid generation issues

class CustomerModel {
  final String? id;
  final String name;
  final String code;
  final String customerType;
  final String status;
  final String email;
  final String phoneNumber;
  final AddressModel billingAddress;
  final AddressModel shippingAddress;
  final String? contactPerson;
  final String? taxId;
  final String? paymentTerms;
  final double? creditLimit;
  final double? currentBalance;
  final DateTime? lastOrderDate;
  final DateTime? createdDate;
  final DateTime? lastUpdatedDate;
  final List<String> searchTerms;

  CustomerModel({
    this.id,
    required this.name,
    required this.code,
    required this.customerType,
    required this.status,
    required this.email,
    required this.phoneNumber,
    required this.billingAddress,
    required this.shippingAddress,
    this.contactPerson,
    this.taxId,
    this.paymentTerms,
    this.creditLimit,
    this.currentBalance,
    this.lastOrderDate,
    this.createdDate,
    this.lastUpdatedDate,
    this.searchTerms = const [],
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      code: json['code'] as String,
      customerType: json['customerType'] as String,
      status: json['status'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      billingAddress:
          AddressModel.fromJson(json['billingAddress'] as Map<String, dynamic>),
      shippingAddress: AddressModel.fromJson(
          json['shippingAddress'] as Map<String, dynamic>),
      contactPerson: json['contactPerson'] as String?,
      taxId: json['taxId'] as String?,
      paymentTerms: json['paymentTerms'] as String?,
      creditLimit: json['creditLimit'] != null
          ? (json['creditLimit'] as num).toDouble()
          : null,
      currentBalance: json['currentBalance'] != null
          ? (json['currentBalance'] as num).toDouble()
          : null,
      lastOrderDate: json['lastOrderDate'] != null
          ? DateTime.parse(json['lastOrderDate'] as String)
          : null,
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'] as String)
          : null,
      lastUpdatedDate: json['lastUpdatedDate'] != null
          ? DateTime.parse(json['lastUpdatedDate'] as String)
          : null,
      searchTerms: (json['searchTerms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      'customerType': customerType,
      'status': status,
      'email': email,
      'phoneNumber': phoneNumber,
      'billingAddress': billingAddress.toJson(),
      'shippingAddress': shippingAddress.toJson(),
      if (contactPerson != null) 'contactPerson': contactPerson,
      if (taxId != null) 'taxId': taxId,
      if (paymentTerms != null) 'paymentTerms': paymentTerms,
      if (creditLimit != null) 'creditLimit': creditLimit,
      if (currentBalance != null) 'currentBalance': currentBalance,
      if (lastOrderDate != null)
        'lastOrderDate': lastOrderDate!.toIso8601String(),
      if (createdDate != null) 'createdDate': createdDate!.toIso8601String(),
      if (lastUpdatedDate != null)
        'lastUpdatedDate': lastUpdatedDate!.toIso8601String(),
      'searchTerms': searchTerms,
    };
  }

  /// Checks if this customer has available credit
  bool hasAvailableCredit(double orderAmount) {
    if (creditLimit == null) return true; // No credit limit defined
    if (currentBalance == null) return true; // No current balance tracked

    final availableCredit = creditLimit! - currentBalance!;
    return availableCredit >= orderAmount;
  }

  /// Returns whether this is a new customer (no orders in last 60 days)
  bool isNewCustomer() {
    if (lastOrderDate == null) return true;

    final daysSinceLastOrder = DateTime.now().difference(lastOrderDate!).inDays;
    return daysSinceLastOrder > 60;
  }

  /// Gets a properly formatted address
  String getFormattedAddress(bool isShipping) {
    final address = isShipping ? shippingAddress : billingAddress;
    return address.toString();
  }

  /// Creates a copy of this CustomerModel but with the given field values replaced
  CustomerModel copyWith({
    String? id,
    String? name,
    String? code,
    String? customerType,
    String? status,
    String? email,
    String? phoneNumber,
    AddressModel? billingAddress,
    AddressModel? shippingAddress,
    String? contactPerson,
    String? taxId,
    String? paymentTerms,
    double? creditLimit,
    double? currentBalance,
    DateTime? lastOrderDate,
    DateTime? createdDate,
    DateTime? lastUpdatedDate,
    List<String>? searchTerms,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      customerType: customerType ?? this.customerType,
      status: status ?? this.status,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      contactPerson: contactPerson ?? this.contactPerson,
      taxId: taxId ?? this.taxId,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      createdDate: createdDate ?? this.createdDate,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
      searchTerms: searchTerms ?? this.searchTerms,
    );
  }
}

class AddressModel {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  AddressModel({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }

  @override
  String toString() {
    return '$street, $city, $state $postalCode, $country';
  }
}
