class CustomerBranch {

  CustomerBranch({required this.id, required this.name, required this.address});

  factory CustomerBranch.fromJson(Map<String, dynamic> json) => CustomerBranch(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
      );
  final String id;
  final String name;
  final String address;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
      };

  CustomerBranch copyWith({String? id, String? name, String? address}) {
    return CustomerBranch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }
}

class CustomerModel {

  CustomerModel(
      {this.id,
      required this.name,
      this.customerType,
      this.branches = const []});

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] as String?,
        name: json['name'] as String,
        customerType: json['customerType'] as String?,
        branches: (json['branches'] as List<dynamic>?)
                ?.map((e) => CustomerBranch.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
  final String? id;
  final String name;
  final String? customerType;
  final List<CustomerBranch> branches;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        if (customerType != null) 'customerType': customerType,
        if (branches.isNotEmpty)
          'branches': branches.map((b) => b.toJson()).toList(),
      };

  CustomerModel copyWith({
    String? id,
    String? name,
    String? customerType,
    List<CustomerBranch>? branches,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      customerType: customerType ?? this.customerType,
      branches: branches ?? this.branches,
    );
  }
}
