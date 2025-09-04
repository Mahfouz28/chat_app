import 'package:chat_app/data/model/chat_messege_model.dart';
import 'package:chat_app/data/model/chat_mode_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepo {
  final supabase = Supabase.instance.client;

  /// جلب أو إنشاء غرفة
  Future<ChatRoomModel> getOrCreateRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    final userIds = [currentUserId, otherUserId]..sort();
    final roomId = userIds.join('_');

    // البحث عن الغرفة
    final existingRoom = await supabase
        .from('chat_rooms')
        .select()
        .eq('id', roomId)
        .maybeSingle();

    // جلب أسماء المستخدمين
    final usersData = await supabase
        .from('users')
        .select('id, username')
        .inFilter('id', userIds);

    final participantsName = {
      for (var user in usersData)
        user['id'] as String: user['username'] as String,
    };

    if (existingRoom != null) {
      // تحديث participants_name لو ناقص
      final existingNames = Map<String, String>.from(
        existingRoom['participants_name'] ?? {},
      );
      if (!mapEquals(existingNames, participantsName)) {
        await supabase
            .from('chat_rooms')
            .update({'participants_name': participantsName})
            .eq('id', roomId);
        existingRoom['participants_name'] = participantsName;
      }
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
      'last_message': null,
      'last_message_time': null,
      'last_message_status': 'read',
    };

    final insertedRoom = await supabase
        .from('chat_rooms')
        .insert(newRoom)
        .select()
        .maybeSingle();

    return ChatRoomModel.fromSupabase(insertedRoom ?? newRoom);
  }

  /// إرسال رسالة
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

    final insertedMessage = await supabase
        .from('messages')
        .insert(message)
        .select()
        .maybeSingle();

    // تحديث آخر رسالة في chat_rooms
    await supabase
        .from('chat_rooms')
        .update({
          'last_message': content,
          'last_message_time': DateTime.now().toUtc().toIso8601String(),
          'last_message_status': 'sent',
        })
        .eq('id', chatRoomId);

    return ChatMessageModel.fromSupabase(insertedMessage ?? message);
  }

  /// الاستماع للرسائل RealTime
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

  /// جلب الرسائل القديمة
  Future<List<ChatMessageModel>> getMessages(String chatRoomId) async {
    final response = await supabase
        .from('messages')
        .select()
        .eq('chat_room_id', chatRoomId)
        .order('created_at', ascending: true);

    return response
        .map<ChatMessageModel>((m) => ChatMessageModel.fromSupabase(m))
        .toList();
  }

  /// تحديث حالة الرسالة عند القراءة
  Future<void> markAsRead(
    String messageId,
    String userId,
    String chatRoomId,
  ) async {
    try {
      // جلب الرسالة نفسها من جدول messages
      final message = await supabase
          .from('messages')
          .select('status, seen_by')
          .eq('id', messageId)
          .maybeSingle();

      if (message == null) return;

      final seenBy =
          (message['seen_by'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      bool needsUpdate = false;

      // إضافة المستخدم لقائمة من قرأ الرسالة
      if (!seenBy.contains(userId)) {
        seenBy.add(userId);
        needsUpdate = true;
      }

      // تحديث حالة الرسالة إذا لم تكن read
      if (message['status'] != 'read') {
        needsUpdate = true;
      }

      if (needsUpdate) {
        await supabase
            .from('messages')
            .update({'status': 'read', 'seen_by': seenBy})
            .eq('id', messageId);
      }

      // تحديث حالة آخر رسالة في chat_rooms
      await supabase
          .from('chat_rooms')
          .update({'last_message_status': 'read'})
          .eq('id', chatRoomId);
      print('markAsRead: Message $messageId marked as read by $userId');
    } catch (e) {
      print("Error in markAsRead: $e");
    }
  }
}
