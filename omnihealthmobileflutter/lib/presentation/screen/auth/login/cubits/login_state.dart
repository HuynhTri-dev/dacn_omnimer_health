// ==================== STATES ====================
import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final AuthEntity authEntity;

  const LoginSuccess(this.authEntity);

  @override
  List<Object?> get props => [authEntity];
}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}
