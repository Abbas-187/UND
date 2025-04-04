enum SupplierType {
  manufacturer,
  distributor,
  retailer,
  serviceProvider,
  contractor
}

enum SupplierStatus { active, inactive, pending, blacklisted, onHold }

class Supplier {
  final String id;
  final String name;
  final String code;
  final SupplierType type;
  final SupplierStatus status;
  final String? address;
  final String? contactPerson;
  final String? contactEmail;
  final String? contactPhone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Supplier({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.status,
    this.address,
    this.contactPerson,
    this.contactEmail,
    this.contactPhone,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Supplier && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
