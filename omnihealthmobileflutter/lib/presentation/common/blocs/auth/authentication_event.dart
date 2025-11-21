import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/auth_entity.dart'; // Để import UserAuth

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

class AuthenticationStarted extends AuthenticationEvent {}

// ĐÃ SỬA: Event này chỉ truyền vào UserAuth
class AuthenticationLoggedIn extends AuthenticationEvent {
  final UserAuth user;

  const AuthenticationLoggedIn(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthenticationLoggedOut extends AuthenticationEvent {}
