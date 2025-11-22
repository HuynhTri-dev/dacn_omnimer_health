// ==================== STATES ====================
import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/role_entity.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final AuthEntity authEntity;

  const RegisterSuccess(this.authEntity);

  @override
  List<Object?> get props => [authEntity];
}

class RegisterFailure extends RegisterState {
  final String message;

  const RegisterFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class RolesLoading extends RegisterState {}

class RolesLoaded extends RegisterState {
  final List<RoleSelectBoxEntity> roles;

  const RolesLoaded(this.roles);

  @override
  List<Object?> get props => [roles];
}

class RolesLoadFailure extends RegisterState {
  final String message;

  const RolesLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
