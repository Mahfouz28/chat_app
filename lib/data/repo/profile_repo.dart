import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/data/model/user_model.dart';

class ProfileRepo {
  final supabase = Supabase.instance.client;

  Future<UserModel?> getUserProfile(String userId) async {
    final data = await supabase
        .from('users') // 👈 اتأكد إن اسم الجدول صح
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data != null) {
      return UserModel.fromSupabase(data);
    }
    return null;
  }
}
