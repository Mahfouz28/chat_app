import 'package:bloc/bloc.dart';
import 'package:chat_app/data/repo/auth_repo.dart';
import 'package:chat_app/logic/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  // تسجيل مستخدم جديد
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String userName,
  }) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        userName: userName,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // تسجيل الدخول
  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signIn(
        email: email,
        password: password,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      emit(AuthInitial()); // رجع للحالة الأولى
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // جلب بيانات المستخدم
  Future<void> getUserData(String userId) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getUserData(userId);
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthFailure("User not found"));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
