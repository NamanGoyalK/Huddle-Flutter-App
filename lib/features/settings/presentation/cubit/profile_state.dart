part of 'profile_cubit.dart';

@immutable
abstract class ProfileState {}

//Initial state
final class ProfileInitial extends ProfileState {}

//Loading state
final class ProfileLoading extends ProfileState {}

//Loaded state
final class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;
  ProfileLoaded(this.userProfile);
}

//Error state
final class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
