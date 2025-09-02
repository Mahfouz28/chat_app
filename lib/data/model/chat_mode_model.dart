class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, DateTime> lastRead;
  final Map<String, String> participantsName;
  final bool isTyping;
  final String? isTypingUId;
  final bool isCallActive;

  ChatRoomModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    Map<String, DateTime>? lastRead,
    Map<String, String>? participantsName,
    this.isTyping = false,
    this.isTypingUId,
    this.isCallActive = false,
  }) : lastRead = lastRead ?? {},
       participantsName = participantsName ?? {};

  /// fromSupabase
  factory ChatRoomModel.fromSupabase(Map<String, dynamic> data) {
    return ChatRoomModel(
      id: data['id'] ?? '',
      participants: data['participants'] != null
          ? List<String>.from(data['participants'])
          : [],
      lastMessage: data['last_message'],
      lastMessageTime: data['last_message_time'] != null
          ? DateTime.tryParse(data['last_message_time'].toString())
          : null,
      lastRead: data['last_read'] != null
          ? (data['last_read'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, DateTime.parse(v.toString())),
            )
          : {},
      participantsName: data['participants_name'] != null
          ? Map<String, String>.from(data['participants_name'])
          : {},
      isTyping: data['is_typing'] ?? false,
      isTypingUId: data['is_typing_uid'],
      isCallActive: data['is_call_active'] ?? false,
    );
  }

  /// toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'last_read': lastRead.map((k, v) => MapEntry(k, v.toIso8601String())),
      'participants_name': participantsName,
      'is_typing': isTyping,
      'is_typing_uid': isTypingUId,
      'is_call_active': isCallActive,
    };
  }
}
