import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProviders {
  Future<void> signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.chatapp://login-callback',
      );
    } catch (e) {
      throw Exception('Google Sign-In error: $e');
    }
  }
}
