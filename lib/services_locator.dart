import 'package:chat_app/data/repo/chat_repo.dart';
import 'package:chat_app/data/repo/contacts_repo.dart';
import 'package:chat_app/data/repo/home_repo.dart';
import 'package:get_it/get_it.dart';
import 'package:chat_app/data/repo/auth_repo.dart';

final sl = GetIt.instance;

void serviceLocator() {
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
  sl.registerLazySingleton(() => ContactsRepo());
  sl.registerLazySingleton<ChatRepo>(() => ChatRepo());
  sl.registerLazySingleton<HomeRepo>(() => HomeRepo());
}
