// chat_messege_model.dart

enum MessageType { text, audio }

enum MessageStatus { sent, delivered, read }

class ChatMessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String receiverId;
  final String content;
  final String type;
  final MessageStatus status;
  final List<String> seenBy;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.status,
    required this.seenBy,
    required this.createdAt,
  });

  // Factory constructor to create from Supabase data
  factory ChatMessageModel.fromSupabase(Map<String, dynamic> data) {
    return ChatMessageModel(
      id: data['id'] as String? ?? '',
      chatRoomId: data['chat_room_id'] as String? ?? '',
      senderId: data['sender_id'] as String? ?? '',
      receiverId: data['receiver_id'] as String? ?? '',
      content: data['content'] as String? ?? '',
      type: data['type'] as String? ?? 'text',
      status: _parseStatus(data['status'] as String? ?? 'sent'),
      seenBy:
          (data['seen_by'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.parse(
        data['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Helper to parse status string to MessageStatus enum
  static MessageStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent; // Default value
    }
  }

  // Optional: copyWith for state updates
  ChatMessageModel copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? receiverId,
    String? content,
    String? type,
    MessageStatus? status,
    List<String>? seenBy,
    DateTime? createdAt,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      seenBy: seenBy ?? this.seenBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
