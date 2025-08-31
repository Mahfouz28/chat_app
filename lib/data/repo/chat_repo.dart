import 'package:chat_app/data/model/chat_mode_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepo {
  final chatRoom = Supabase.instance.client.from('chat_room'); //  الجدول الصح
  final usersTable = Supabase.instance.client.from('users'); //  جدول المستخدمين

  Future<ChatModeModel> getOrCreateChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    final user = [currentUserId, otherUserId];
    user.sort(); // عشان يكون نفس الـ id دايمًا بغض النظر عن الترتيب
    final roomId = user.join('_');

    // check if room already exists
    final roomDoc = await chatRoom.select().eq('id', roomId).maybeSingle();
    if (roomDoc != null) {
      return ChatModeModel.fromSupabase(roomDoc);
    }

    //  get user data from users table
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

    //  create new chat room
    final newRoom = ChatModeModel(
      id: roomId,
      participants: user,
      participantsName: participantsName,
      lastRead: {currentUserId: DateTime.now(), otherUserId: DateTime.now()},
    );

    // save it in Supabase
    await chatRoom.insert(newRoom.toMap());

    return newRoom;
  }
}
