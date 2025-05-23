import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String address;
  final int roomNo;
  final String status;
  final DateTime timestamp;
  final String description;
  final DateTime scheduledTime;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.address,
    required this.roomNo,
    required this.status,
    required this.timestamp,
    required this.description,
    required this.scheduledTime,
  });

  Post copyWith({String? status, String? description}) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      address: address,
      roomNo: roomNo,
      status: status ?? this.status,
      timestamp: timestamp,
      description: description ?? this.description,
      scheduledTime: scheduledTime,
    );
  }

  // Convert Post to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'address': address,
      'roomNo': roomNo,
      'status': status,
      'timestamp': timestamp,
      'description': description,
      'scheduledTime': scheduledTime,
    };
  }

  // Convert JSON to Post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      address: json['address'],
      roomNo: json['roomNo'],
      status: json['status'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      description: json['description'],
      scheduledTime: (json['scheduledTime'] as Timestamp).toDate(),
    );
  }
}
