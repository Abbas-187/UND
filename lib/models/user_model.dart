import 'package:firebase_auth/firebase_auth.dart' as auth;

enum UserRole {
  admin,
  warehouseManager,
  sales,
  logistics,
  factory;

  static UserRole fromClaims(Map<String, dynamic>? claims) {
    claims ??= {};
    if (claims['admin'] == true) return UserRole.admin;
    if (claims['warehouseManager'] == true) return UserRole.warehouseManager;
    if (claims['sales'] == true) return UserRole.sales;
    if (claims['logistics'] == true) return UserRole.logistics;
    if (claims['factory'] == true) return UserRole.factory;
    return UserRole.sales; // Default role
  }

  Map<String, dynamic> toClaims() {
    return {
      'admin': this == UserRole.admin,
      'warehouseManager': this == UserRole.warehouseManager,
      'sales': this == UserRole.sales,
      'logistics': this == UserRole.logistics,
      'factory': this == UserRole.factory,
    };
  }
}

class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
    this.warehouseId,
    required this.isEmailVerified,
  });

  factory UserModel.fromFirebase(
      auth.User firebaseUser, Map<String, dynamic>? claims) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      role: UserRole.fromClaims(claims),
      warehouseId: claims?['warehouseId'],
      isEmailVerified: firebaseUser.emailVerified,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == json['role'],
        orElse: () => UserRole.sales,
      ),
      warehouseId: json['warehouseId'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool,
    );
  }
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final String? warehouseId;
  final bool isEmailVerified;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.toString(),
      'warehouseId': warehouseId,
      'isEmailVerified': isEmailVerified,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    String? warehouseId,
    bool? isEmailVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      warehouseId: warehouseId ?? this.warehouseId,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
