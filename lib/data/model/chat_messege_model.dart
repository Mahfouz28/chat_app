enum MessageType { text, image, video, audio, file }

enum MessageStatus { sent, delivered, read }

class ChatMessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime createdAt;
  final bool isDeleted;
  final List<String> seenBy;

  ChatMessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.createdAt,
    this.isDeleted = false,
    this.seenBy = const [],
  });

  /// DB row → Dart object
  factory ChatMessageModel.fromSupabase(Map<String, dynamic> data) {
    return ChatMessageModel(
      id: data['id'] ?? '',
      chatRoomId: data['chat_room_id'] ?? '',
      senderId: data['sender_id'] ?? '',
      receiverId: data['receiver_id'] ?? '',
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (data['type'] ?? 'text').toString().toLowerCase(),
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (data['status'] ?? 'sent').toString().toLowerCase(),
        orElse: () => MessageStatus.sent,
      ),
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString()) ??
                DateTime.now().toUtc()
          : DateTime.now().toUtc(),
      isDeleted: data['is_deleted'] ?? false,
      seenBy: data['seen_by'] != null ? List<String>.from(data['seen_by']) : [],
    );
  }

  /// Dart object → DB row
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'type': type.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'is_deleted': isDeleted,
      'seen_by': seenBy,
    };
  }

  /// copyWith → create new object with updated fields
  ChatMessageModel copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? createdAt,
    bool? isDeleted,
    List<String>? seenBy,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      seenBy: seenBy ?? this.seenBy,
    );
  }
}
