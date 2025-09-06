import 'package:chat_app/config/image/app_svg.dart';
import 'package:chat_app/core/common/custom_text_botton.dart';
import 'package:chat_app/core/common/custom_text_field.dart';
import 'package:chat_app/core/common/snackBar.dart';
import 'package:chat_app/data/repo/auth_repo.dart';
import 'package:chat_app/logic/cubit/auth/auth_cubit.dart';
import 'package:chat_app/logic/cubit/auth/auth_state.dart';
import 'package:chat_app/presentation/screens/auth/complete_details_screen.dart';
import 'package:chat_app/presentation/screens/auth/sign_up_screen.dart';
import 'package:chat_app/presentation/screens/home/home_screen.dart';
import 'package:chat_app/logic/cubit/providers/auth_providers_cubit.dart';
import 'package:chat_app/logic/cubit/providers/auth_providers_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider(create: (_) => AuthProvidersCubit()),
      ],
      child: Scaffold(
        body: BlocListener<AuthProvidersCubit, AuthProvidersState>(
          listener: (context, state) {
            if (state is AuthProvidersSuccess) {
              if (state.user.fullName.isNotEmpty) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                );
              } else {
                // New user → complete details
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompleteDetailsScreen(
                      email: state.user.email,
                      fullName: state.user.fullName,
                    ),
                  ),
                );
              }
            } else if (state is AuthProvidersError) {
              AppSnackBar.show(context, message: state.error, isError: true);
            }
          },
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
                AppSnackBar.show(context, message: "Login Successful!");
              } else if (state is AuthFailure) {
                AppSnackBar.show(context, message: state.error, isError: true);
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  Form(
                    key: formKey,
                    child: Padding(
                      padding: EdgeInsets.all(28.r),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 69.h),
                            Text(
                              'Welcome Back',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'Sign in to continue',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: Colors.grey),
                            ),
                            SizedBox(height: 20.h),
                            CustomTextFormField(
                              hintText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),
                            CustomTextFormField(
                              hintText: 'Password',
                              obscureText: !isPasswordVisible,
                              controller: passwordController,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 30.h),
                            CustomButton(
                              text: state is AuthLoading
                                  ? "Signing in..."
                                  : "Sign in",
                              onPressed: state is AuthLoading
                                  ? () {}
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        context.read<AuthCubit>().signIn(
                                          email: emailController.text.trim(),
                                          password: passwordController.text
                                              .trim(),
                                        );
                                      }
                                    },
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Don\'t have an account?',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text('Sign up'),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 30,
                                  child: SvgPicture.asset(
                                    AppSvg.facebook,
                                    height: 50,
                                    width: 50,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                BlocBuilder<
                                  AuthProvidersCubit,
                                  AuthProvidersState
                                >(
                                  builder: (context, state) {
                                    return InkWell(
                                      onTap: state is AuthProvidersLoading
                                          ? null
                                          : () {
                                              context
                                                  .read<AuthProvidersCubit>()
                                                  .signInWithGoogle();
                                            },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 24,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: state is AuthProvidersLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Text(
                                                "Sign in with Google",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (state is AuthLoading)
                    Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
