import 'package:chat_app/data/repo/profile_repo.dart';
import 'package:chat_app/logic/cubit/profile/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;

  ProfileCubit(this.profileRepo) : super(ProfileInitial());

  Future<void> fetchUserProfile(String userId) async {
    emit(ProfileLoading());
    try {
      final profileData = await profileRepo.getUserProfile(userId);
      if (profileData != null) {
        emit(ProfileLoaded(profileData));
      } else {
        emit(ProfileError("User not found"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? username,
    String? phoneNumber,
  }) async {
    emit(ProfileLoading());
    try {
      await profileRepo.updateUserProfile(
        userId: userId,
        fullName: fullName,
        username: username,
        phoneNumber: phoneNumber,
      );
      await fetchUserProfile(userId);
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> deleteAccount(String userId) async {
    emit(ProfileLoading());
    try {
      await profileRepo.deleteAccount(userId);
      emit(ProfileDeleted());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
