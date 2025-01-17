import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/features/auth/domain/entities/app_user.dart';
import 'package:huddle/features/auth/domain/repos/auth_repo.dart';
import 'package:huddle/features/settings/presentation/cubit/profile_cubit.dart';

part 'auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  final ProfileCubit profileCubit;
  AppUser? _currentUser;

  AuthCubit(this.profileCubit, {required this.authRepo}) : super(AuthInitial());

  // Check if user is authenticated or not
  void checkAuth() async {
    if (_currentUser != null) {
      emit(Authenticated(_currentUser!));
    } else {
      final AppUser? user = await authRepo.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    }
  }

  // Get current user
  AppUser? get currentUser => _currentUser;

  // Login with email and password
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await authRepo.loginWithEmailAndPassword(email, password);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
        profileCubit.fetchUserProfile(user.uid); //Fetch new user's profile
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(UnAuthenticated()); // Ensure transition out of loading state
    }
  }

  // Sign up with email and password
  Future<void> signupWithEmailAndPassword(
      String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final user =
          await authRepo.signupWithEmailAndPassword(name, email, password);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(UnAuthenticated()); // Ensure transition out of loading state
    }
  }

  //Sing in with google.
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await authRepo.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(UnAuthenticated()); // Ensure transition out of loading state
    }
  }

  // Logout
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await authRepo.logout();
      _currentUser = null; // Clear cached user
      emit(UnAuthenticated());
      profileCubit.clearUserProfile(); // reset the profile in profile cubit
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(UnAuthenticated()); // Ensure transition out of loading state
    }
  }

  Future<void> sendForgotPasswordLink(String email) async {
    try {
      await authRepo.sendPasswordResetLink(email);
    } catch (e) {
      emit(AuthError('An unexpected error occurred: $e'));
    } finally {
      emit(UnAuthenticated());
    }
  }
}
