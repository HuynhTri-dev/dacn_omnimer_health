import 'package:equatable/equatable.dart';

/// Enum for forgot password steps
enum ForgotPasswordStep {
  enterEmail,
  enterCode,
  enterNewPassword,
  success,
}

/// Base state for forgot password
abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

/// Loading state
class ForgotPasswordLoading extends ForgotPasswordState {
  final ForgotPasswordStep step;

  const ForgotPasswordLoading({required this.step});

  @override
  List<Object?> get props => [step];
}

/// Email submitted successfully - code sent
class ForgotPasswordCodeSent extends ForgotPasswordState {
  final String email;
  final String message;

  const ForgotPasswordCodeSent({
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [email, message];
}

/// Code verified successfully - got reset token
class ForgotPasswordCodeVerified extends ForgotPasswordState {
  final String email;
  final String resetToken;

  const ForgotPasswordCodeVerified({
    required this.email,
    required this.resetToken,
  });

  @override
  List<Object?> get props => [email, resetToken];
}

/// Password reset successfully
class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;

  const ForgotPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error state
class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  final ForgotPasswordStep step;
  final bool requireEmailVerification;

  const ForgotPasswordError({
    required this.message,
    required this.step,
    this.requireEmailVerification = false,
  });

  @override
  List<Object?> get props => [message, step, requireEmailVerification];
}

/// Code resent successfully
class ForgotPasswordCodeResent extends ForgotPasswordState {
  final String email;
  final String message;

  const ForgotPasswordCodeResent({
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [email, message];
}

