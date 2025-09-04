import 'package:chat_app/config/image/app_image.dart';
import 'package:chat_app/data/repo/auth_repo.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int opacity = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        opacity = 1;
      });

      Future.delayed(const Duration(seconds: 2), () async {
        await _navigateNext();
      });
    });
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;
    await AuthRepository().checkAuth(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: opacity.toDouble(),
          child: Image.asset(AppImage.splashLogo, width: 250, height: 250),
        ),
      ),
    );
  }
}
