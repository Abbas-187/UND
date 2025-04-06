class User {

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }
  final String id;
  final String email;
  final String name;
  final String role;
  final DateTime? lastLogin;

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}
