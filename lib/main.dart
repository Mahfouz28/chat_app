import 'package:chat_app/config/theme/app_theme.dart';
import 'package:chat_app/data/repo/profile_repo.dart';
import 'package:chat_app/logic/cubit/chat/chat_cubit.dart';
import 'package:chat_app/logic/cubit/profile/profile_cubit.dart';
import 'package:chat_app/presentation/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/data/repo/chat_repo.dart';
import 'package:chat_app/services_locator.dart';
import 'package:chat_app/core/subaBase/suba_base_keys.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // نستنى Supabase يخلص
  await Supabase.initialize(
    url: SubaBaseKeys.projectURL,
    anonKey: SubaBaseKeys.apiKey,
  );

  // هنا نستدعي init اللي في services_locator.dart
  serviceLocator();

  runApp(const MyAppProviders());
}

class MyAppProviders extends StatelessWidget {
  const MyAppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChatCubit(sl<ChatRepo>())),
        BlocProvider(create: (context) => ProfileCubit(ProfileRepo())),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
