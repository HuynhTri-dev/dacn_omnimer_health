// ==================== EVENTS ====================
import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

class AuthenticationStarted extends AuthenticationEvent {}

class AuthenticationLoggedIn extends AuthenticationEvent {
  final AuthEntity authEntity;

  const AuthenticationLoggedIn(this.authEntity);

  @override
  List<Object?> get props => [authEntity];
}

class AuthenticationLoggedOut extends AuthenticationEvent {}
