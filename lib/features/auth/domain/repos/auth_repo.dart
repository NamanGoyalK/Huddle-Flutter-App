// The AuthRepo outlines the possible auth operations that can be done for this application.

import 'package:huddle/features/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailAndPassword(
    String email,
    String password,
  );
  Future<AppUser?> signupWithEmailAndPassword(
    String name,
    String email,
    String password,
  );
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}
