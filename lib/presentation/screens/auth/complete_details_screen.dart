import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chat_app/core/common/custom_text_botton.dart';
import 'package:chat_app/core/common/custom_text_field.dart';
import 'package:chat_app/core/common/snackbar.dart';
import 'package:chat_app/presentation/screens/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompleteDetailsScreen extends StatefulWidget {
  final String email;
  final String fullName;

  const CompleteDetailsScreen({
    super.key,
    required this.email,
    required this.fullName,
  });

  @override
  State<CompleteDetailsScreen> createState() => _CompleteDetailsScreenState();
}

class _CompleteDetailsScreenState extends State<CompleteDetailsScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Prefill email and full name from Google
    emailController.text = widget.email;
    nameController.text = widget.fullName;
  }

  Future<void> handleSignUp() async {
    if (!formKey.currentState!.validate()) return;

    try {
      final supabase = Supabase.instance.client;
      // Insert user data into Supabase table
      await supabase.from('users').insert({
        'email': emailController.text.trim(),
        'full_name': nameController.text.trim(),
        'username': usernameController.text.trim(),
        'phone_number': phoneController.text.trim(),
      });

      AppSnackBar.show(context, message: 'Account created successfully!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } catch (e) {
      AppSnackBar.show(context, message: e.toString(), isError: true);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(28.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.verticalSpace,
              Text(
                'Complete Your Details',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              10.verticalSpace,
              Text(
                'Please fill the remaining fields to continue',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              20.verticalSpace,

              /// Full Name (readonly)
              CustomTextFormField(
                controller: nameController,
                hintText: 'Full Name',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
                obscureText: false,
              ),
              16.verticalSpace,

              /// Email (readonly)
              CustomTextFormField(
                controller: emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
                obscureText: false,
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

              /// Phone
              CustomTextFormField(
                controller: phoneController,
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

              const SizedBox(height: 20),
              CustomButton(text: 'Create Account', onPressed: handleSignUp),
            ],
          ),
        ),
      ),
    );
  }
}
