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
      emit(AuthProvidersError(e.toString()));
    }
  }

  void _initDeepLinks() {
    _appLinks.uriLinkStream.listen((uri) async {
      if (uri.toString().contains('login-callback')) {
        final session = _supabase.auth.currentSession;
        if (session != null) {
          emit(AuthProvidersSuccess(session));
        } else {
          emit(AuthProvidersError("No session returned"));
        }
      }
    });
  }
}
