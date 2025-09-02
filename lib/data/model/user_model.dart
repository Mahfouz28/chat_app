class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String username;
  final String phoneNumber;
  final String fcmToken;
  final List<String> blockUsers;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.username,
    required this.phoneNumber,
    required this.fcmToken,
    this.blockUsers = const [],
    this.isOnline = false,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) : lastSeen = lastSeen ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now();

  // copyWith
  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? username,
    String? phoneNumber,
    String? fcmToken,
    List<String>? blockUsers,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      blockUsers: blockUsers ?? this.blockUsers,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // fromSupabase
  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      fullName: data['full_name'] ?? '',
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      fcmToken: data['fcm_token'] ?? '',
      blockUsers: data['block_users'] != null
          ? List<String>.from(data['block_users'])
          : [],
      isOnline: data['is_online'] ?? false,
      lastSeen: data['last_seen'] != null
          ? DateTime.parse(data['last_seen'].toString())
          : DateTime.now().toUtc(),
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'].toString())
          : DateTime.now().toUtc(),
    );
  }

  // toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'username': username,
      'phone_number': phoneNumber,
      'fcm_token': fcmToken,
      'block_users': blockUsers,
      'is_online': isOnline,
      // last_seen و created_at هي اللي بتتسجل تلقائي في DB
    };
  }
}
