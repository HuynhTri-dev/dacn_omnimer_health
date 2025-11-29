import 'package:equatable/equatable.dart';

abstract class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChangePasswordInitial extends ChangePasswordState {}

/// Loading state while changing password
class ChangePasswordLoading extends ChangePasswordState {}

/// Success state when password changed successfully
class ChangePasswordSuccess extends ChangePasswordState {
  final String message;

  const ChangePasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error state when password change failed
class ChangePasswordError extends ChangePasswordState {
  final String message;

  const ChangePasswordError({required this.message});

  @override
  List<Object?> get props => [message];
}

