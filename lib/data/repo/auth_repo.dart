// lib/data/repo/auth_repo.dart
import 'package:chat_app/data/model/user_model.dart';
import 'package:chat_app/presentation/screens/auth/login_screen.dart';
import 'package:chat_app/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final supabase = Supabase.instance.client;

  AuthRepository();

  Future<void> checkAuth(BuildContext context) async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  // -------------------- Sign Up --------------------
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String userName,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception(
          "Sign up failed: ${response.session?.user.id ?? "Unknown error"}",
        );
      }

      final userModel = UserModel(
        id: response.user!.id,
        fullName: fullName,
        email: email,
        username: userName,
        phoneNumber: phone,
        fcmToken: '',
      );

      await saveUserData(userModel);
      return userModel;
    } on AuthException catch (e) {
      if (e.statusCode == "400") {
        throw Exception("Invalid sign-up data: ${e.message}");
      } else if (e.statusCode == "422") {
        throw Exception("Weak password or invalid email format");
      } else if (e.statusCode == "409") {
        throw Exception("This email is already registered");
      }
      throw Exception("Sign up error: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected sign up error: $e");
    }
  }

  // -------------------- Sign In --------------------
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception("Invalid email or password");
      }

      final userData = await getUserData(response.user!.id);
      if (userData == null) {
        throw Exception("User data not found in database");
      }

      return userData;
    } on AuthException catch (e) {
      if (e.statusCode == "400") {
        throw Exception("Invalid request: ${e.message}");
      } else if (e.statusCode == "401") {
        throw Exception("Unauthorized: Wrong email or password");
      } else if (e.statusCode == "403") {
        throw Exception("Forbidden: ${e.message}");
      }
      throw Exception("Sign in error: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected sign in error: $e");
    }
  }

  // -------------------- Get User Data --------------------
  Future<UserModel?> getUserData(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromSupabase(response);
    } on PostgrestException catch (e) {
      if (e.code == "PGRST116") {
        throw Exception("User not found");
      }
      throw Exception("DB error: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected error fetching user: $e");
    }
  }

  // -------------------- Save User Data --------------------
  Future<void> saveUserData(UserModel user) async {
    try {
      final response = await supabase
          .from('users')
          .upsert(user.toMap(), onConflict: 'id');

      if (response.error != null) {
        throw Exception("Failed to save user: ${response.error!.message}");
      }
    } on PostgrestException catch (e) {
      if (e.code == "23505") {
        throw Exception("Duplicate entry: ${e.message}");
      }
      throw Exception("Save user DB error: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected save user error: $e");
    }
  }

  // -------------------- Sign Out --------------------
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception("Sign out failed: ${e.message}");
    } catch (e) {
      throw Exception("Unexpected sign out error: $e");
    }
  }
}
