import 'package:chat_app/core/common/custom_text_botton.dart';
import 'package:chat_app/core/common/custom_text_field.dart';
import 'package:chat_app/core/common/snackbar.dart';
import 'package:chat_app/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/data/repo/auth_repo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  Future<void> handleSignUp() async {
    if (formKey.currentState!.validate()) {
      try {
        await AuthRepository().signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          fullName: nameController.text.trim(),
          phone: phoneNumberController.text.trim(),
          userName: usernameController.text.trim(),
        );
        AppSnackBar.show(context, message: 'Account created successfully!');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } catch (e) {
        AppSnackBar.show(context, message: e.toString(), isError: true);
      }
    } else {
      debugPrint('Form validation Failed');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    phoneNumberController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(28.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                20.verticalSpace,
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                10.verticalSpace,
                Text(
                  'please fill the form to continue',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
                20.verticalSpace,

                /// Full name
                CustomTextFormField(
                  controller: nameController,
                  hintText: 'Full Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value.length < 3) return 'At least 3 characters';
                    return null;
                  },
                ),
                16.verticalSpace,

                /// Username
                CustomTextFormField(
                  controller: usernameController,
                  hintText: 'Username',
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value.length < 3) return 'At least 3 characters';
                    return null;
                  },
                ),
                16.verticalSpace,

                /// Email
                CustomTextFormField(
                  controller: emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                ),
                16.verticalSpace,

                /// Phone
                CustomTextFormField(
                  controller: phoneNumberController,
                  hintText: 'Phone',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                      return 'Invalid phone number';
                    }
                    return null;
                  },
                ),
                16.verticalSpace,

                /// Password
                CustomTextFormField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: !isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value.length < 6) return 'At least 6 characters';
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Must contain at least 1 uppercase letter';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Must contain at least 1 number';
                    }
                    return null;
                  },
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
                ),

                const SizedBox(height: 20),

                /// Submit button
                CustomButton(text: 'Create Account', onPressed: handleSignUp),

                20.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
