import 'package:chat_app/data/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AuthProviders {
  final supabase = Supabase.instance.client;
  final uuid = Uuid(); // For generating unique IDs

  Future<UserModel> signInWithGoogle() async {
    try {
      // Sign in with Google OAuth
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.chatapp://login-callback',
      );

      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception("Google Sign-In failed: No user returned");
      }

      // Check if user exists in the 'users' table
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('id', user.id) // Use Auth ID here
          .maybeSingle();

      if (existingUser != null) {
        return UserModel.fromSupabase(existingUser);
      } else {
        // Create a new user using Supabase Auth ID
        final fullName =
            user.userMetadata?['full_name'] ?? user.email?.split('@')[0];
        final username = fullName?.replaceAll(' ', '_');

        final newUser = await supabase
            .from('users')
            .insert({
              'id': user.id, // IMPORTANT: use Auth user ID
              'full_name': fullName,
              'email': user.email,
              'username': username,
              'phone_number': '',
              'fcm_token': '',
              'block_users': [],
              'is_online': false,
              'last_seen': DateTime.now().toUtc().toIso8601String(),
              'created_at': DateTime.now().toUtc().toIso8601String(),
            })
            .select()
            .single();

        return UserModel.fromSupabase(newUser);
      }
    } on AuthException catch (e) {
      throw Exception("Google Sign-In failed: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }
}
