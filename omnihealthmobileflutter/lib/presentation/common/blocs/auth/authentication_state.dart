import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

// ĐÃ SỬA: State này chỉ nhận UserAuth
class AuthenticationAuthenticated extends AuthenticationState {
  final UserAuth user;

  const AuthenticationAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthenticationUnauthenticated extends AuthenticationState {}

class AuthenticationError extends AuthenticationState {
  final String message;

  const AuthenticationError(this.message);

  @override
  List<Object?> get props => [message];
}
