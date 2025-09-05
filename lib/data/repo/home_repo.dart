import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepo {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchUserChatRooms(String userId) async {
    try {
      final response = await supabase
          .from('chat_rooms')
          .select()
          .contains('participants', [userId])
          .order('last_message_time', ascending: false) // أحدث الشاتات فوق
          .limit(1000);

      // تحويل النتيجة إلى List<Map>
      return List<Map<String, dynamic>>.from(response as List);
    } on PostgrestException catch (e) {
      // Error من قاعدة البيانات
      throw Exception("Database error [${e.code}]: ${e.message}");
    } catch (e) {
      // أي Error تاني
      throw Exception("Failed to fetch chat rooms: $e");
    }
  }
}
