import 'package:huddle/features/auth/domain/entities/app_user.dart';

class UserProfile extends AppUser {
  final String address;
  final int roomNo;
  final String bio;
  final String gender;

  UserProfile({
    required super.uid,
    required super.email,
    required super.name,
    required this.address,
    required this.bio,
    required this.gender,
    required this.roomNo,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? newAddress,
    String? newBio,
    String? newGender,
    int? newRoomNo,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      address: newAddress ?? address,
      bio: newBio ?? bio,
      gender: newGender ?? gender,
      roomNo: newRoomNo ?? roomNo,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'address': address,
      'bio': bio,
      'gender': gender,
      'roomNo': roomNo,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      address: json['address'] ?? '',
      bio: json['bio'] ?? '',
      gender: json['gender'] ?? '',
      roomNo: json['roomNo'] ?? 0,
    );
  }
}
