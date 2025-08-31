import 'package:chat_app/data/model/chat_mode_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepo {
  final chatRoomTable = Supabase.instance.client.from(
    'chat_rooms',
  ); // جدول الغرف
  final usersTable = Supabase.instance.client.from('users'); // جدول المستخدمين

  Future<ChatModeModel> getOrCreateChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    final userIds = [currentUserId, otherUserId];
    userIds.sort(); // نفس الـ id بغض النظر عن الترتيب
    final roomId = userIds.join('_');

    // check if room already exists
    final roomDoc = await chatRoomTable.select().eq('id', roomId).maybeSingle();

    if (roomDoc != null) {
      return ChatModeModel.fromSupabase(roomDoc);
    }

    // get user data
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

    // save in Supabase
    await chatRoomTable.insert(newRoom.toMap());

    return newRoom;
  }
}
