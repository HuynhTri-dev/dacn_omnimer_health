import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';

class UserEntity extends Equatable {
  final String? uid;
  final String? email;
  final String? fullname;
  final String? birthday;
  final GenderEnum? gender;
  final List<String>? roleIds;
  final String? imageUrl;

  const UserEntity({
    this.uid,
    this.email,
    this.fullname,
    this.birthday,
    this.gender,
    this.roleIds,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [uid, email, fullname, birthday, gender, roleIds];
}
