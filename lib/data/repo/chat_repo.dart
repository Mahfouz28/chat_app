import 'package:chat_app/data/model/chat_messege_model.dart';
import 'package:chat_app/data/model/chat_mode_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepo {
  final supabase = Supabase.instance.client;

  // جلب أو إنشاء غرفة
  Future<ChatRoomModel> getOrCreateRoom(
    String currentUserId,
    String otherUserId,
    Map<String, dynamic> participantsName,
  ) async {
    final userIds = [currentUserId, otherUserId]..sort();
    final roomId = userIds.join('_');

    // البحث عن الغرفة
    final existingRoom = await supabase
        .from('chat_rooms')
        .select()
        .eq('id', roomId)
        .maybeSingle();

    if (existingRoom != null) {
      return ChatRoomModel.fromSupabase(existingRoom);
    }

    // إنشاء غرفة جديدة
    final newRoom = {
      'id': roomId,
      'participants': userIds,
      'participants_name': participantsName,
      'last_read': {
        currentUserId: DateTime.now().toUtc().toIso8601String(),
        otherUserId: DateTime.now().toUtc().toIso8601String(),
      },
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    await supabase.from('chat_rooms').insert(newRoom);

    return ChatRoomModel.fromSupabase(newRoom);
  }

  // إرسال رسالة
  Future<ChatMessageModel> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final message = {
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'type': 'text',
      'status': 'sent',
      'is_deleted': false,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'seen_by': [],
    };

    await supabase.from('messages').insert(message);

    return ChatMessageModel.fromSupabase(message);
  }

  // الاستماع للرسائل RealTime
  Stream<List<ChatMessageModel>> listenMessages(String chatRoomId) {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_room_id', chatRoomId)
        .order('created_at', ascending: true)
        .map(
          (rows) =>
              rows.map((row) => ChatMessageModel.fromSupabase(row)).toList(),
        );
  }

  // جلب الرسائل القديمة
  Future<List<ChatMessageModel>> getMessages(String chatRoomId) async {
    final response = await supabase
        .from('messages')
        .select()
        .eq('chat_room_id', chatRoomId)
        .order('created_at', ascending: false);

    return response
        .map<ChatMessageModel>((m) => ChatMessageModel.fromSupabase(m))
        .toList();
  }

  // تحديث حالة الرسائل عند القراءة
  Future<void> markAsRead(String chatRoomId, String userId) async {
    // تحديث الرسائل
    await supabase
        .from('messages')
        .update({'status': 'read'})
        .eq('chat_room_id', chatRoomId)
        .eq('receiver_id', userId);

    // تحديث آخر وقت قراءة في الـ ChatRoom
    await supabase
        .from('chat_rooms')
        .update({
          'last_read': {userId: DateTime.now().toUtc().toIso8601String()},
        })
        .eq('id', chatRoomId);
  }
}
