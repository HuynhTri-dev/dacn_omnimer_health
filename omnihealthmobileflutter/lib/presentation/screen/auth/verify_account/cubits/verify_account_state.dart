import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/verification_status_entity.dart';

/// States for VerifyAccountCubit
abstract class VerifyAccountState extends Equatable {
  const VerifyAccountState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class VerifyAccountInitial extends VerifyAccountState {
  const VerifyAccountInitial();
}

/// Loading state
class VerifyAccountLoading extends VerifyAccountState {
  final String? loadingMessage;

  const VerifyAccountLoading({this.loadingMessage});

  @override
  List<Object?> get props => [loadingMessage];
}

/// Loaded state with verification status
class VerifyAccountLoaded extends VerifyAccountState {
  final VerificationStatusEntity status;

  const VerifyAccountLoaded({required this.status});

  @override
  List<Object?> get props => [status];
}

/// Email sending state
class VerifyAccountEmailSending extends VerifyAccountState {
  const VerifyAccountEmailSending();
}

/// Email sent successfully
class VerifyAccountEmailSent extends VerifyAccountState {
  final String message;
  final VerificationStatusEntity? status;

  const VerifyAccountEmailSent({
    required this.message,
    this.status,
  });

  @override
  List<Object?> get props => [message, status];
}

/// Change email request sending
class VerifyAccountChangeEmailSending extends VerifyAccountState {
  const VerifyAccountChangeEmailSending();
}

/// Change email request sent successfully
class VerifyAccountChangeEmailSent extends VerifyAccountState {
  final String message;

  const VerifyAccountChangeEmailSent({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error state
class VerifyAccountError extends VerifyAccountState {
  final String message;
  final VerificationStatusEntity? previousStatus;

  const VerifyAccountError({
    required this.message,
    this.previousStatus,
  });

  @override
  List<Object?> get props => [message, previousStatus];
}

