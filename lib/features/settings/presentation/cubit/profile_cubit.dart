import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:huddle/features/settings/domain/entities/user_profile.dart';
import 'package:huddle/features/settings/domain/repos/profile_repo.dart';
import 'package:meta/meta.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(ProfileInitial());

  ProfileState? fromJson(Map<String, dynamic> json) {
    try {
      final userProfile = UserProfile.fromJson(json['profile']);

      return ProfileLoaded(userProfile);
    } catch (e) {
      return ProfileInitial();
    }
  }

  Map<String, dynamic>? toJson(ProfileState state) {
    if (state is ProfileLoaded) {
      return {'profile': state.userProfile.toJson()};
    }
    return null;
  }

  // Fetch user profile
  Future<void> fetchUserProfile(String uid) async {
    emit(ProfileLoading()); // Always show loading before fetching new data
    try {
      final profile = await profileRepo.fetchUserProfile(uid);
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(ProfileError('Error fetching user profile'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    int? newRoomNo,
    String? newAddress,
    String? newGender,
  }) async {
    emit(ProfileLoading()); // Trigger loading state

    try {
      // Fetch current user first
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError('Failed to fetch current user'));
        return;
      }

      // Update user profile
      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newRoomNo: newRoomNo ?? currentUser.roomNo,
        newAddress: newAddress ?? currentUser.address,
        newGender: newGender ?? currentUser.gender,
      );

      // Update in repository
      await profileRepo.updateProfile(updatedProfile);

      // Refetch updated user profile and emit ProfileLoaded
      final refetchedProfile = await profileRepo.fetchUserProfile(uid);
      if (refetchedProfile != null) {
        emit(ProfileLoaded(refetchedProfile)); // Emit new loaded state
      } else {
        emit(ProfileError('Failed to fetch updated profile'));
      }
    } catch (e) {
      emit(ProfileError('Error updating profile: ${e.toString()}'));
    }
  }

  Future<void> clearUserProfile() async {
    emit(ProfileInitial()); // Reset to initial state
    return Future.value(); // Explicitly return a Future
  }
}
