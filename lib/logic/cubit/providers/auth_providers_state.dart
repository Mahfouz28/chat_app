import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvidersState {}

class AuthProvidersInitial extends AuthProvidersState {}

class AuthProvidersLoading extends AuthProvidersState {}

class AuthProvidersSuccess extends AuthProvidersState {
  final Session session;
  AuthProvidersSuccess(this.session);
}

class AuthProvidersError extends AuthProvidersState {
  final String error;
  AuthProvidersError(this.error);
}
