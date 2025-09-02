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
      // User is signed in → go to main/home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // User is not signed in → go to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  // تسجيل مستخدم جديد
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String userName,
  }) async {
    try {
      // إنشاء مستخدم في Supabase Auth
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // إنشاء UserModel (بدون password لأنه مش بيتخزن في جدول users)
      final userModel = UserModel(
        id: user.id,
        fullName: fullName,
        email: email,
        username: userName,
        phoneNumber: phone,
        fcmToken: '',
      );

      // حفظ بيانات المستخدم في جدول users
      await saveUserData(userModel);

      return userModel;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // تسجيل الدخول
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // تسجيل دخول في Supabase Auth
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Invalid email or password');
      }

      // جلب بيانات المستخدم من جدول users
      final userData = await getUserData(user.id);

      if (userData == null) {
        throw Exception('User data not found in database');
      }

      return userData;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // جلب بيانات المستخدم حسب ID
  Future<UserModel?> getUserData(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromSupabase(response);
    } catch (e) {
      throw Exception('فشل في جلب بيانات المستخدم: $e');
    }
  }

  // حفظ بيانات المستخدم في Supabase
  Future<void> saveUserData(UserModel user) async {
    try {
      await supabase
          .from('users')
          .upsert(
            user.toMap(),
            onConflict: 'id', // لو موجود يتعمله Update
          );
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }
}
