import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/data/model/user_model.dart';

class AuthProvidersState {}

class AuthProvidersInitial extends AuthProvidersState {}

class AuthProvidersLoading extends AuthProvidersState {}

// Updated to hold UserModel
class AuthProvidersSuccess extends AuthProvidersState {
  final UserModel user;
  AuthProvidersSuccess(this.user);
}

class AuthProvidersError extends AuthProvidersState {
  final String error;
  AuthProvidersError(this.error);
}
