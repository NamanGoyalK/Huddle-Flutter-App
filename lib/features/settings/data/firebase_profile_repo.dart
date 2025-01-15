import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:huddle/features/settings/domain/entities/user_profile.dart';
import 'package:huddle/features/settings/domain/repos/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<UserProfile?> fetchUserProfile(String uid) async {
    try {
      // Get user doc from the firestore
      final userDoc =
          await firebaseFirestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;

        return UserProfile(
          uid: uid,
          email: userData['email'],
          name: userData['name'],
          address: userData['address'] ?? '',
          bio: userData['bio'] ?? '',
          gender: userData['gender'] ?? '',
          roomNo: userData['roomNo'] ?? 0,
          lastEditTime: userData['lastEditTime'] != null
              ? DateTime.parse(userData['lastEditTime'])
              : DateTime(1970, 1, 1),
        );
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
    return null;
  }

  @override
  Future<void> updateProfile(UserProfile updatedProfile) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(updatedProfile.uid)
          .update({
        'address': updatedProfile.address,
        'bio': updatedProfile.bio,
        'gender': updatedProfile.gender,
        'roomNo': updatedProfile.roomNo,
        'lastEditTime': updatedProfile.lastEditTime.toIso8601String(),
      });
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Error updating profile');
    }
  }
}
