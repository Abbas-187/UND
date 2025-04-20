import 'package:meta/meta.dart';

/// Represents a supplier.
@immutable
class Supplier {
  final String id;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String address;
  final List<String> itemCategories;
  final String? taxId;
  final String? notes;

  const Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    required this.itemCategories,
    this.taxId,
    this.notes,
  });

  Supplier copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? email,
    String? phone,
    String? address,
    List<String>? itemCategories,
    String? taxId,
    String? notes,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      itemCategories: itemCategories ?? this.itemCategories,
      taxId: taxId ?? this.taxId,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Supplier &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          contactPerson == other.contactPerson &&
          email == other.email &&
          phone == other.phone &&
          address == other.address;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      contactPerson.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      address.hashCode;
}
