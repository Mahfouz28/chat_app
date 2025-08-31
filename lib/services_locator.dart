import 'package:chat_app/data/repo/contacts_repo.dart';
import 'package:get_it/get_it.dart';
import 'package:chat_app/data/repo/auth_repo.dart';

final sl = GetIt.instance;

void init() {
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
  sl.registerLazySingleton(() => ContactsRepo());
}
