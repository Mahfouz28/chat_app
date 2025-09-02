import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepo {
  Future<List<Map<String, dynamic>>> fetchUserChatRooms(String userId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('chat_rooms')
        .select()
        .contains('participants', [userId])
        .limit(1000);

    final data = response as List<dynamic>;
    print(data);

    return List<Map<String, dynamic>>.from(response);
  }
}
