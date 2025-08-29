class UserModel {
  final String fullName;
  final String email;
  final String usrename;
  final String phoneNumber;
  final DateTime lastSeen;
  final DateTime createdAt;
  final String id;
  final String fcmToken;
  final List<String> blockUsers;
  final bool isonline;

  UserModel({
    this.blockUsers = const [],
    this.isonline = false,
    required this.fullName,
    required this.email,
    required this.usrename,
    required this.phoneNumber,
    DateTime? lastSeen,
    DateTime? createdAt,
    required this.id,
    required this.fcmToken,
  }) : lastSeen = lastSeen ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now();

  // copyWith
  UserModel copyWith({
    String? fullName,
    String? email,
    String? usrename,
    String? phoneNumber,
    DateTime? lastSeen,
    DateTime? createdAt,
    String? id,
    String? fcmToken,
    List<String>? blockUsers,
    bool? isonline,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      usrename: usrename ?? this.usrename,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      fcmToken: fcmToken ?? this.fcmToken,
      blockUsers: blockUsers ?? this.blockUsers,
      isonline: isonline ?? this.isonline,
    );
  }

  // fromSupabase
  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel(
      fullName: data['full_name'] ?? '',
      email: data['email'] ?? '',
      usrename: data['username'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      lastSeen: data['last_seen'] != null
          ? DateTime.parse(data['last_seen'])
          : DateTime.now(),
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      id: data['id'] ?? '',
      fcmToken: data['fcm_token'] ?? '',
      blockUsers: data['block_users'] != null
          ? List<String>.from(data['block_users'])
          : [],
      isonline: data['is_online'] ?? false,
    );
  }

  // toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'username': usrename,
      'phone_number': phoneNumber,
      'fcm_token': fcmToken,
      'block_users': blockUsers,
      'is_online': isonline,
      // last_seen و created_at يضافوا تلقائي من الـ DB
    };
  }
}
