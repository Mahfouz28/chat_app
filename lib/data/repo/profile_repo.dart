import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/data/model/user_model.dart';

class ProfileRepo {
  final supabase = Supabase.instance.client;

  /// ✅ جلب بروفايل المستخدم
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        return UserModel.fromSupabase(data);
      }
      return null;
    } on PostgrestException catch (e) {
      throw Exception("Database error [${e.code}]: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load profile: $e");
    }
  }

  /// ✅ تحديث بيانات البروفايل
  Future<bool> updateUserProfile({
    required String userId,
    String? fullName,
    String? username,
    String? phoneNumber,
  }) async {
    try {
      final updateData = {
        if (fullName != null) 'full_name': fullName,
        if (username != null) 'username': username,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      };

      await supabase.from('users').update(updateData).eq('id', userId);
      return true;
    } on PostgrestException catch (e) {
      throw Exception("Database error [${e.code}]: ${e.message}");
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }

  /// ✅ حذف الحساب (ممكن تعمل Cascade في DB)
  Future<bool> deleteAccount(String userId) async {
    try {
      await supabase.from('users').delete().eq('id', userId);
      return true;
    } on PostgrestException catch (e) {
      throw Exception("Database error [${e.code}]: ${e.message}");
    } catch (e) {
      throw Exception("Failed to delete account: $e");
    }
  }
}
