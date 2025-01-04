class Post {
  final String id;
  final String userId;
  final String userName;
  final String address;
  final int roomNo;
  final String status;
  final DateTime timestamp;
  final String description;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.address,
    required this.roomNo,
    required this.status,
    required this.timestamp,
    required this.description,
  });

  Post copyWith(String? status, String? description) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      address: address,
      roomNo: roomNo,
      status: status ?? this.status,
      timestamp: timestamp,
      description: description ?? this.description,
    );
  }

  //convert post to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'address': address,
      'roomNo': roomNo,
      'status': status,
      'timestamp': timestamp,
      'description': description
    };
  }

  //convert jason to post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        userId: json['userId'],
        userName: json['userName'],
        address: json['address'],
        roomNo: json['roomNo'],
        status: json['status'],
        timestamp: json['timestamp'],
        description: json['description']);
  }
}
