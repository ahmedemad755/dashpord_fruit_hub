import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruitesdashboard/featurs/auth/domain/entites/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.email,
    // required super.password,
    required super.name,
    required super.uId,
    // required super.role,

    // required super.cardImageUrl,
  });

  factory UserModel.fromfirebaseUser(User user) {
    return UserModel(
      email: user.email ?? "",
      name: user.displayName ?? '',
      uId: user.uid,
      // role: '',

      // cardImageUrl: user.photoURL ?? '',
      // password: '',
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      uId: map['uId'] ?? '',
      // role: map['role'] ?? '',
      // cardImageUrl: map['cardImageUrl'] ?? '',
      // password: map['password'] ?? '',
    );
  }

  /// من Entity لـ Model
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uId: entity.uId,
      email: entity.email,
      name: entity.name,
      // role: entity.role,
    );
  }

  toMap() {
    return {
      'email': email,
      'name': name,
      'uId': uId,
      // 'role': role,

      // 'cardImageUrl': cardImageUrl,
    };
  }
}
