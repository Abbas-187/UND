import 'permission.dart';
import 'user_role.dart';

/// Represents a user in the application
class AppUser {

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.emailVerified = false,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.customClaims,
  });

  /// Creates a user from Firebase auth and Firestore data
  factory AppUser.fromFirebase({
    required Map<String, dynamic> authData,
    required Map<String, dynamic>? firestoreData,
  }) {
    final String id = authData['uid'] as String;
    final String email = authData['email'] as String;
    final bool emailVerified = authData['emailVerified'] as bool? ?? false;
    final String? photoUrl = authData['photoURL'] as String?;

    // Get custom claims if available
    final Map<String, dynamic>? claims =
        authData['claims'] as Map<String, dynamic>?;

    // Get role from claims or Firestore, default to viewer if not found
    UserRole role = UserRole.viewer;
    if (claims != null && claims['role'] != null) {
      role = _parseRole(claims['role'] as String?);
    } else if (firestoreData != null && firestoreData['role'] != null) {
      role = _parseRole(firestoreData['role'] as String?);
    }

    // Parse dates
    final DateTime createdAt =
        firestoreData != null && firestoreData['createdAt'] != null
            ? DateTime.parse(firestoreData['createdAt'] as String)
            : DateTime.now();

    final DateTime? lastLoginAt =
        firestoreData != null && firestoreData['lastLoginAt'] != null
            ? DateTime.parse(firestoreData['lastLoginAt'] as String)
            : null;

    return AppUser(
      id: id,
      email: email,
      displayName:
          firestoreData?['displayName'] as String? ?? email.split('@').first,
      role: role,
      emailVerified: emailVerified,
      photoUrl: photoUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      customClaims: claims,
    );
  }

  /// Create an AppUser from a JSON object (for local storage)
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: _parseRole(json['role'] as String?),
      emailVerified: json['emailVerified'] as bool? ?? false,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      customClaims: json['customClaims'] as Map<String, dynamic>?,
    );
  }
  /// The unique identifier for the user
  final String id;

  /// The user's email address, used for login
  final String email;

  /// The user's full name
  final String displayName;

  /// The user's role in the system
  final UserRole role;

  /// Whether the user's email has been verified
  final bool emailVerified;

  /// Optional photo URL
  final String? photoUrl;

  /// When the user was created
  final DateTime createdAt;

  /// When the user last logged in
  final DateTime? lastLoginAt;

  /// Additional custom claims for the user
  final Map<String, dynamic>? customClaims;

  /// Creates a copy of this user with the specified fields replaced
  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    bool? emailVerified,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? customClaims,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      customClaims: customClaims ?? this.customClaims,
    );
  }

  /// Checks if the user has the specified permission
  bool hasPermission(Permission permission) {
    return PermissionManager.hasPermission(role, permission);
  }

  /// Gets all permissions for this user
  Set<Permission> get permissions {
    return PermissionManager.getPermissionsForRole(role);
  }

  /// Converts the user to a map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'emailVerified': emailVerified,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Parse role from string
  static UserRole _parseRole(String? roleStr) {
    if (roleStr == null) return UserRole.viewer;

    try {
      return UserRole.values.firstWhere(
        (r) => r.name.toLowerCase() == roleStr.toLowerCase(),
        orElse: () => UserRole.viewer,
      );
    } catch (_) {
      return UserRole.viewer;
    }
  }

  /// Convert this AppUser to a JSON object (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'emailVerified': emailVerified,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'customClaims': customClaims,
    };
  }

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, displayName: $displayName, role: ${role.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUser &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.role == role &&
        other.emailVerified == emailVerified &&
        other.photoUrl == photoUrl &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        role.hashCode ^
        emailVerified.hashCode ^
        photoUrl.hashCode ^
        createdAt.hashCode ^
        lastLoginAt.hashCode;
  }
}
