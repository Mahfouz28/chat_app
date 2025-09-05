import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/data/model/user_model.dart';

class ProfileRepo {
  final supabase = Supabase.instance.client;

  Future<UserModel?> getUserProfile(String userId) async {
    final data = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data != null) {
      return UserModel.fromSupabase(data);
    }
    return null;
  }

  Future<void> ubdateUserProfile({
    required String userId,
    String? fullName,
    String? username,
    String? phoneNumber,
  }) async {
    final ubdateData = {
      if (fullName != null) 'full_name': fullName,
      if (username != null) 'username': username,
      if (phoneNumber != null) 'phone_number': phoneNumber,
    };
    await supabase.from('users').update(ubdateData).eq('id', userId);
  }
}
