import 'dart:io';

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
    try {
      final userIds = [currentUserId, otherUserId]..sort();
      final roomId = userIds.join('_');

      final existingRoom = await supabase
          .from('chat_rooms')
          .select()
          .eq('id', roomId)
          .maybeSingle();

      final usersData = await supabase
          .from('users')
          .select('id, username')
          .inFilter('id', userIds);

      final participantsName = {
        for (var user in usersData)
          user['id'] as String: user['username'] as String,
      };

      if (existingRoom != null) {
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
    } on PostgrestException catch (e) {
      throw Exception("Database error [${e.code}]: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error in getOrCreateRoom: $e");
    }
  }

  /// إرسال رسالة
  Future<ChatMessageModel> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String content,
    String type = 'text',
  }) async {
    try {
      final message = {
        'chat_room_id': chatRoomId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'type': type,
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

      await supabase
          .from('chat_rooms')
          .update({
            'last_message': content,
            'last_message_time': DateTime.now().toUtc().toIso8601String(),
            'last_message_status': 'sent',
          })
          .eq('id', chatRoomId);

      return ChatMessageModel.fromSupabase(insertedMessage ?? message);
    } on PostgrestException catch (e) {
      throw Exception("Failed to send message [${e.code}]: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error in sendMessage: $e");
    }
  }

  /// الاستماع للرسائل RealTime
  Stream<List<ChatMessageModel>> listenMessages(String chatRoomId) {
    try {
      return supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('chat_room_id', chatRoomId)
          .order('created_at', ascending: true)
          .map(
            (rows) =>
                rows.map((row) => ChatMessageModel.fromSupabase(row)).toList(),
          );
    } catch (e) {
      throw Exception("Error listening to messages: $e");
    }
  }

  /// جلب الرسائل القديمة
  Future<List<ChatMessageModel>> getMessages(String chatRoomId) async {
    try {
      final response = await supabase
          .from('messages')
          .select()
          .eq('chat_room_id', chatRoomId)
          .order('created_at', ascending: true);

      return response
          .map<ChatMessageModel>((m) => ChatMessageModel.fromSupabase(m))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception("Failed to fetch messages [${e.code}]: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error in getMessages: $e");
    }
  }

  /// تحديث حالة الرسالة عند القراءة
  Future<void> markAsRead(
    String messageId,
    String userId,
    String chatRoomId,
  ) async {
    try {
      final message = await supabase
          .from('messages')
          .select('id, status, seen_by, created_at')
          .eq('id', messageId)
          .maybeSingle();

      if (message == null) return;

      final seenBy = (message['seen_by'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();

      final newSeenBy = seenBy.contains(userId) ? seenBy : [...seenBy, userId];

      await supabase
          .from('messages')
          .update({'status': 'read', 'seen_by': newSeenBy})
          .eq('id', messageId);

      final lastMessage = await supabase
          .from('messages')
          .select('id, status')
          .eq('chat_room_id', chatRoomId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (lastMessage != null) {
        await supabase
            .from('chat_rooms')
            .update({'last_message_status': lastMessage['status']})
            .eq('id', chatRoomId);
      }
    } on PostgrestException catch (e) {
      throw Exception(
        "Failed to mark message as read [${e.code}]: ${e.message}",
      );
    } catch (e) {
      throw Exception("Unexpected error in markAsRead: $e");
    }
  }

  /// تحديث جميع الرسائل الغير مقروءة دفعة واحدة
  Future<void> markMessagesAsReadBatch(String chatRoomId, String userId) async {
    try {
      final unreadMessages = await supabase
          .from('messages')
          .select('id, seen_by, status, sender_id')
          .eq('chat_room_id', chatRoomId)
          .neq('sender_id', userId)
          .neq('status', 'read');

      final updatedIds = <String>[];

      for (var msg in unreadMessages) {
        final seenBy = (msg['seen_by'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        if (!seenBy.contains(userId)) {
          updatedIds.add(msg['id'] as String);
        }
      }

      if (updatedIds.isNotEmpty) {
        await supabase
            .from('messages')
            .update({
              'status': 'read',
              'seen_by': Supabase.instance.client.rpc(
                'array_append',
                params: {
                  'column': 'seen_by',
                  'value': [userId],
                },
              ),
            })
            .filter('id', 'in', updatedIds);
      }

      final lastMessage = await supabase
          .from('messages')
          .select('id, status')
          .eq('chat_room_id', chatRoomId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (lastMessage != null) {
        await supabase
            .from('chat_rooms')
            .update({'last_message_status': lastMessage['status']})
            .eq('id', chatRoomId);
      }
    } on PostgrestException catch (e) {
      throw Exception(
        "Failed to batch mark messages as read [${e.code}]: ${e.message}",
      );
    } catch (e) {
      throw Exception("Unexpected error in markMessagesAsReadBatch: $e");
    }
  }

  Future<void> updateChatRoomLastMessageStatus(String id, String name) async {
    // TODO: Implement with proper error handling if needed
  }

  Future<String> uplodeVoiceFile({
    required File file,
    required String pathInBucket,
    int signedUrlDurationSeconds = 3600,
  }) async {
    try {
      // Ensure the path starts with 'voices/' to match the existing folder
      final fullPath =
          'voices/$pathInBucket'; // Adjust if pathInBucket already includes 'voices/'
      print('Uploading to bucket: chat-voices, path: $fullPath');
      await supabase.storage.from('chat-voices').upload(fullPath, file);

      // Determine the URL based on bucket privacy
      if (signedUrlDurationSeconds > 0) {
        final signedUrl = await supabase.storage
            .from('chat-voices')
            .createSignedUrl(fullPath, signedUrlDurationSeconds);
        if (signedUrl.isNotEmpty) {
          return signedUrl;
        }
      }

      // Fallback to public URL for public buckets
      final publicUrl = supabase.storage
          .from('chat-voices')
          .getPublicUrl(fullPath);
      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      throw Exception("Failed to upload voice file: $e");
    }
  }

  Future<void> sendVoiceMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required File file,
  }) async {
    try {
      // 1. ارفع الملف للصوتيات
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final path = 'voices/$chatRoomId/$fileName';

      final storage = Supabase.instance.client.storage.from('chat-voices');

      await storage.upload(path, file);

      final url = storage.getPublicUrl(path);

      // 2. خزّن الرسالة في DB
      final response = await Supabase.instance.client
          .from('messages')
          .insert({
            'chat_room_id': chatRoomId,
            'sender_id': senderId,
            'receiver_id': receiverId,
            'content': url, // لينك الصوت
            'type': 'voice', // ثبات النوع
            'status': 'sent',
          })
          .select()
          .single();

      print("Voice message sent: $response");
    } catch (e) {
      throw Exception("Failed to send voice message: $e");
    }
  }
}
