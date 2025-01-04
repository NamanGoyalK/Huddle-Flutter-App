part of 'logout_cubit.dart';

abstract class LogoutState extends Equatable {
  const LogoutState();

  @override
  List<Object> get props => [];
}

class LogoutInitial extends LogoutState {}

class LogoutInProgress extends LogoutState {
  final int tapCount;

  const LogoutInProgress(this.tapCount);

  @override
  List<Object> get props => [tapCount];
}

class LogoutComplete extends LogoutState {}

class LogoutError extends LogoutState {
  final String message;

  const LogoutError(this.message);

  @override
  List<Object> get props => [message];
}
