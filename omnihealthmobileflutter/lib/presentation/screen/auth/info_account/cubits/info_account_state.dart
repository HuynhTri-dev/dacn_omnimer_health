import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/user_entity.dart';

abstract class InfoAccountState extends Equatable {
  const InfoAccountState();

  @override
  List<Object?> get props => [];
}

class InfoAccountInitial extends InfoAccountState {}

class InfoAccountLoading extends InfoAccountState {}

class InfoAccountLoaded extends InfoAccountState {
  final UserEntity user;

  const InfoAccountLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class InfoAccountUpdating extends InfoAccountState {}

class InfoAccountSuccess extends InfoAccountState {
  final UserEntity user;
  final String message;

  const InfoAccountSuccess(
    this.user, {
    this.message = "Update information successfully",
  });

  @override
  List<Object?> get props => [user, message];
}

class InfoAccountError extends InfoAccountState {
  final String message;

  const InfoAccountError(this.message);

  @override
  List<Object?> get props => [message];
}
