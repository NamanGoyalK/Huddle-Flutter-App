import 'package:cloud_firestore/cloud_firestore.dart';

class Favour {
  final String id;
  final String userId;
  final String userName;
  final String address;
  final int roomNo;
  final bool isComplete;
  final DateTime timestamp;
  final String description;

  Favour({
    required this.id,
    required this.userId,
    required this.userName,
    required this.address,
    required this.roomNo,
    required this.isComplete,
    required this.timestamp,
    required this.description,
  });

  Favour copyWith({bool? isComplete, String? description}) {
    return Favour(
      id: id,
      userId: userId,
      userName: userName,
      address: address,
      roomNo: roomNo,
      isComplete: isComplete ?? this.isComplete,
      timestamp: timestamp,
      description: description ?? this.description,
    );
  }

  // Convert Favour to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'address': address,
      'roomNo': roomNo,
      'isComplete': isComplete,
      'timestamp': timestamp,
      'description': description,
    };
  }

  // Convert JSON to Favour
  factory Favour.fromJson(Map<String, dynamic> json) {
    return Favour(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      address: json['address'],
      roomNo: json['roomNo'],
      isComplete: json['isComplete'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      description: json['description'],
    );
  }
}
