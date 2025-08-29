import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final String? labelText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.labelText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode, // ✅ ربط الـ FocusNode
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator, // ✅ التحقق (Validation)
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        // border: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(30.r),
        //   borderSide: const BorderSide(color: Colors.grey),
        // ),
        // enabledBorder: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(30.r),
        //   borderSide: const BorderSide(color: Colors.grey),
        // ),
        //  / focusedBorder: OutlineInputBorder(
        //     borderRadius: BorderRadius.circular(30.r),
        //     borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        //   ),
        errorBorder: OutlineInputBorder(
          // ✅ شكل الحقل لو فيه خطأ
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          // ✅ لو فيه خطأ والحقل عليه فوكس
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
