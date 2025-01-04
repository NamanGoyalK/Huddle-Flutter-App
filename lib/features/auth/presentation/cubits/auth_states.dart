//Auth states
part of 'auth_cubit.dart';

abstract class AuthState {}

//initial state
class AuthInitial extends AuthState {}

//loading state
class AuthLoading extends AuthState {}

//error state
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

//authenticated state
class Authenticated extends AuthState {
  final AppUser user;
  Authenticated(this.user);
}

//unauthenticated state
class UnAuthenticated extends AuthState {}
