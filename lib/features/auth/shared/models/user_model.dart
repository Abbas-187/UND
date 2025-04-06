import 'package:meta/meta.dart';

@immutable
class UserModel {

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
    );
  }
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoURL == photoURL;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoURL.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, photoURL: $photoURL)';
  }
}
