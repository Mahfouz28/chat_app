import 'package:chat_app/data/model/chat_messege_model.dart';
import 'package:chat_app/data/model/chat_mode_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepo {
  final chatRoomTable = Supabase.instance.client.from('chat_rooms');
  final usersTable = Supabase.instance.client.from('users');

  Future<ChatModeModel> getOrCreateChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    final userIds = [currentUserId, otherUserId]..sort();
    final roomId = userIds.join('_');

    final roomDoc = await chatRoomTable.select().eq('id', roomId).maybeSingle();

    if (roomDoc != null) {
      return ChatModeModel.fromSupabase(roomDoc);
    }

    final currentUserData = await usersTable
        .select()
        .eq('id', currentUserId)
        .maybeSingle();
    final otherUserData = await usersTable
        .select()
        .eq('id', otherUserId)
        .maybeSingle();

    if (currentUserData == null || otherUserData == null) {
      throw Exception("User data not found");
    }

    final participantsName = <String, String>{
      currentUserId: (currentUserData['full_name'] ?? '').toString(),
      otherUserId: (otherUserData['full_name'] ?? '').toString(),
    };

    final newRoom = ChatModeModel(
      id: roomId,
      participants: userIds,
      participantsName: participantsName,
      lastRead: {currentUserId: DateTime.now(), otherUserId: DateTime.now()},
    );

    await chatRoomTable.insert(newRoom.toMap());

    return newRoom;
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final supabase = Supabase.instance.client;

    await supabase
        .from('messages')
        .insert({
          'chat_room_id': chatRoomId,
          'sender_id': senderId,
          'receiver_id': receiverId,
          'content': content,
          'type': type.name,
          'status': 'sent',
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    await supabase
        .from('chat_rooms')
        .update({
          'last_message': content,
          'last_message_time': DateTime.timestamp().toIso8601String(),
        })
        .eq('id', chatRoomId);
  }

  Stream<List<ChatMessageModel>> listenMessages(String chatRoomId) {
    final supabase = Supabase.instance.client;

    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_room_id', chatRoomId)
        .order('created_at')
        .map((data) => data.map(ChatMessageModel.fromSupabase).toList());
  }

  Future<List<ChatMessageModel>> getMessages(String chatRoomId) async {
    final response = await Supabase.instance.client
        .from('messages')
        .select()
        .eq('chat_room_id', chatRoomId)
        .order('created_at', ascending: true);

    return response
        .map<ChatMessageModel>((m) => ChatMessageModel.fromSupabase(m))
        .toList();
  }
}
