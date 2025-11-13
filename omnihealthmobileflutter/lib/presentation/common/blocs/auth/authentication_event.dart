// ==================== STATES ====================
import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final AuthEntity authEntity;

  const AuthenticationAuthenticated(this.authEntity);

  @override
  List<Object?> get props => [authEntity];
}

class AuthenticationUnauthenticated extends AuthenticationState {}

class AuthenticationError extends AuthenticationState {
  final String message;

  const AuthenticationError(this.message);

  @override
  List<Object?> get props => [message];
}
