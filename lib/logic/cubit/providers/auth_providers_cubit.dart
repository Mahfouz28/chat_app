import 'package:chat_app/data/model/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/logic/cubit/providers/auth_providers_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

class AuthProvidersCubit extends Cubit<AuthProvidersState> {
  AuthProvidersCubit() : super(AuthProvidersInitial()) {
    _initDeepLinks();
  }

  final _supabase = Supabase.instance.client;
  final _appLinks = AppLinks();

  Future<void> signInWithGoogle() async {
    emit(AuthProvidersLoading());
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.chatapp://login-callback',
      );
    } catch (e) {
      emit(AuthProvidersError("Google Sign-In failed: $e"));
    }
  }

  void _initDeepLinks() {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      if (session != null) {
        final user = session.user;
        emit(AuthProvidersLoading());

        try {
          // Check if user exists by Supabase Auth ID
          final existingUser = await _supabase
              .from('users')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          late Map<String, dynamic> userData;

          if (existingUser != null) {
            userData = existingUser;
          } else {
            final fullName =
                user.userMetadata?['full_name'] ?? user.email?.split('@')[0];
            final username = fullName?.replaceAll(' ', '_');

            final newUser = await _supabase
                .from('users')
                .insert({
                  'id': user.id,
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

            userData = newUser;
          }

          final userModel = UserModel.fromSupabase(userData);
          emit(AuthProvidersSuccess(userModel));
        } catch (e) {
          emit(AuthProvidersError("DB error: $e"));
        }
      }
    });
  }
}
