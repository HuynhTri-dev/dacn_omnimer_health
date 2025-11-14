import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';

class UserAuth extends Equatable {
  final String fullname;
  final String? email;
  final String? imageUrl;
  final GenderEnum? gender;
  final DateTime? birthday;
  final List<String> roleName;

  const UserAuth({
    required this.fullname,
    this.email,
    this.imageUrl,
    this.gender,
    this.birthday,
    required this.roleName,
  });

  @override
  List<Object?> get props => [
    fullname,
    email,
    imageUrl,
    gender,
    birthday,
    roleName,
  ];
}

class AuthEntity extends Equatable {
  final UserAuth user;
  final String accessToken;
  final String refreshToken;

  const AuthEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}

class LoginEntity extends Equatable {
  final String email;
  final String password;

  const LoginEntity({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEntity extends Equatable {
  final String? email;
  final String? password;
  final String? fullname;
  final String? birthday;
  final GenderEnum? gender;
  final List<String>? roleIds;
  final File? image;

  const RegisterEntity({
    this.email,
    this.password,
    this.fullname,
    this.birthday,
    this.gender,
    this.roleIds,
    this.image,
  });

  @override
  List<Object?> get props => [
    password,
    email,
    fullname,
    birthday,
    gender,
    roleIds,
    image,
  ];
}
