import 'package:chat_app/config/theme/app_theme.dart';
import 'package:chat_app/logic/cubit/chat/chat_cubit.dart';
import 'package:chat_app/presentation/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/data/repo/chat_repo.dart';
import 'package:chat_app/services_locator.dart';
import 'package:chat_app/core/subaBase/suba_base_keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SubaBaseKeys.projectURL,
    anonKey: SubaBaseKeys.apiKey,
  );

  init();

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (context) => ChatCubit(sl<ChatRepo>()))],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // You can use the library anywhere in the app even in theme
          theme: AppTheme.lightTheme,

          home: SplashScreen(),
        );
      },
    );
  }
}
