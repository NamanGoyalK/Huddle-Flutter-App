import 'package:huddle/features/settings/domain/entities/user_profile.dart';

abstract class ProfileRepo {
  Future<UserProfile?> fetchUserProfile(String uid);
  Future<void> updateProfile(UserProfile updatedProfile);
}
