import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProviders {
  Future<void> signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.chatapp://login-callback',
      );
    } on AuthException catch (e) {
      if (e.statusCode == "400") {
        throw Exception("Invalid request to Google Sign-In: ${e.message}");
      } else if (e.statusCode == "401") {
        throw Exception("Unauthorized: Check your Google credentials");
      } else if (e.statusCode == "403") {
        throw Exception("Forbidden: ${e.message}");
      } else if (e.statusCode == "500") {
        throw Exception("Server error during Google Sign-In");
      }
      throw Exception("Google Sign-In failed: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected Google Sign-In error: $e");
    }
  }
}
