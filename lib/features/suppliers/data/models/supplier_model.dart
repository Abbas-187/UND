import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/supplier.dart';

class SupplierModel {
  final String id;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final Map<String, String> address;
  final List<String> productCategories;
  final Map<String, dynamic>? additionalAttributes;
  final DateTime lastOrderDate;
  final bool isActive;
  final double rating;
  final String notes;
  final String taxId;
  final String paymentTerms;
  final String website;
  final DateTime lastUpdated;
  final List<String> searchTerms;

  SupplierModel({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    required this.productCategories,
    this.additionalAttributes,
    required this.lastOrderDate,
    required this.isActive,
    required this.rating,
    required this.notes,
    required this.taxId,
    required this.paymentTerms,
    required this.website,
    required this.lastUpdated,
    required this.searchTerms,
  });

  // Convert Firestore document to SupplierModel
  factory SupplierModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupplierModel(
      id: doc.id,
      name: data['name'] ?? '',
      contactPerson: data['contactPerson'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: Map<String, String>.from(data['address'] ?? {}),
      productCategories: List<String>.from(data['productCategories'] ?? []),
      additionalAttributes: data['additionalAttributes'],
      lastOrderDate:
          (data['lastOrderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      rating: (data['rating'] ?? 3.0).toDouble(),
      notes: data['notes'] ?? '',
      taxId: data['taxId'] ?? '',
      paymentTerms: data['paymentTerms'] ?? '',
      website: data['website'] ?? '',
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      searchTerms: List<String>.from(data['searchTerms'] ?? []),
    );
  }

  // Convert domain entity to data model
  factory SupplierModel.fromDomain(Supplier supplier) {
    return SupplierModel(
      id: supplier.id,
      name: supplier.name,
      contactPerson: supplier.contactPerson,
      email: supplier.email,
      phone: supplier.phone,
      address: {
        'street': supplier.address.street,
        'city': supplier.address.city,
        'state': supplier.address.state,
        'zipCode': supplier.address.zipCode,
        'country': supplier.address.country,
      },
      productCategories: supplier.productCategories,
      additionalAttributes: supplier.additionalAttributes,
      lastOrderDate: supplier.lastOrderDate,
      isActive: supplier.isActive,
      rating: supplier.rating,
      notes: supplier.notes,
      taxId: supplier.taxId,
      paymentTerms: supplier.paymentTerms,
      website: supplier.website,
      lastUpdated: supplier.lastUpdated,
      searchTerms: _generateSearchTerms(
          supplier.name, supplier.contactPerson, supplier.productCategories),
    );
  }

  // Convert data model to domain entity
  Supplier toDomain() {
    return Supplier(
      id: id,
      name: name,
      contactPerson: contactPerson,
      email: email,
      phone: phone,
      address: SupplierAddress(
        street: address['street'] ?? '',
        city: address['city'] ?? '',
        state: address['state'] ?? '',
        zipCode: address['zipCode'] ?? '',
        country: address['country'] ?? '',
      ),
      productCategories: productCategories,
      additionalAttributes: additionalAttributes,
      lastOrderDate: lastOrderDate,
      isActive: isActive,
      rating: rating,
      notes: notes,
      taxId: taxId,
      paymentTerms: paymentTerms,
      website: website,
      lastUpdated: lastUpdated,
    );
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'productCategories': productCategories,
      'additionalAttributes': additionalAttributes,
      'lastOrderDate': Timestamp.fromDate(lastOrderDate),
      'isActive': isActive,
      'rating': rating,
      'notes': notes,
      'taxId': taxId,
      'paymentTerms': paymentTerms,
      'website': website,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'searchTerms': searchTerms,
    };
  }

  SupplierModel copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? email,
    String? phone,
    Map<String, String>? address,
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
    List<String>? searchTerms,
  }) {
    return SupplierModel(
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
      searchTerms: searchTerms ?? this.searchTerms,
    );
  }

  // Generate search terms for better searchability
  static List<String> _generateSearchTerms(
      String name, String contactPerson, List<String> categories) {
    final searchTerms = <String>[];

    // Add full name
    searchTerms.add(name.toLowerCase());

    // Add contact person
    searchTerms.add(contactPerson.toLowerCase());

    // Add name parts
    final nameParts = name.toLowerCase().split(' ');
    searchTerms.addAll(nameParts);

    // Add categories
    for (final category in categories) {
      searchTerms.add(category.toLowerCase());
    }

    // Add partial matches for name (for typeahead search)
    for (final part in nameParts) {
      for (int i = 1; i < part.length; i++) {
        searchTerms.add(part.substring(0, i));
      }
    }

    // Remove duplicates
    return searchTerms.toSet().toList();
  }
}
