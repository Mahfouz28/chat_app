import 'package:chat_app/core/common/snackBar.dart';
import 'package:chat_app/logic/cubit/profile/profile_state.dart';
import 'package:chat_app/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/logic/cubit/profile/profile_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final userNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().fetchUserProfile(widget.userId);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          nameController.text = state.user.fullName;
          phoneController.text = state.user.phoneNumber;
          userNameController.text = state.user.username;
        } else if (state is ProfileError &&
            state.errorMessage != "User not found") {
          AppSnackBar.show(context, message: state.errorMessage, isError: true);
        } else if (state is ProfileLoaded) {
          AppSnackBar.show(context, message: "Profile updated successfully!");
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 0),
                const Text("Edit Profile"),
                IconButton(
                  onPressed: () {
                    context.read<ProfileCubit>().updateUserProfile(
                      userId: widget.userId,
                      fullName: nameController.text.trim(),
                      phoneNumber: phoneController.text.trim(),
                      username: userNameController.text.trim(),
                    );
                    context.read<ProfileCubit>().fetchUserProfile(
                      widget.userId,
                    );
                    Navigator.pop(
                      context,
                      true,
                    ); // رجّع true كإشارة إن فيه تحديث
                  },
                  icon: const Icon(Icons.done, color: Colors.lightBlue),
                ),
              ],
            ),
          ),
          body: BlocConsumer<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileLoaded) {
                final user = state.user;
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          20.verticalSpace,
                          // صورة البروفايل
                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 70.r,
                                  backgroundColor: const Color(0xffD9D9D9),
                                  child: Text(
                                    user.fullName[0].toUpperCase(),
                                    style: TextStyle(fontSize: 40.sp),
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  bottom: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      // هنا ممكن تضيف اختيار صورة
                                    },
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.lightBlue,
                                      child: Icon(
                                        Icons.edit,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          20.verticalSpace,
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  user.fullName,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                  ),
                                ),
                                Text(
                                  user.username,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          30.verticalSpace,

                          // Email ثابت
                          Text(
                            "Your Email",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          8.verticalSpace,
                          outlinedEmptyBox(
                            width: double.infinity,
                            height: 50.h,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.email,
                                    color: Colors.lightBlue,
                                  ),
                                  8.horizontalSpace,
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          20.verticalSpace,

                          // Phone Number (قابل للتعديل)
                          Text(
                            "Phone Number",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          8.verticalSpace,
                          TextField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.phone,
                                color: Colors.lightBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          20.verticalSpace,

                          Text(
                            "Full Name",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          8.verticalSpace,
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.person,
                                color: Colors.lightBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          20.verticalSpace,

                          Text(
                            "Username",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          8.verticalSpace,
                          TextField(
                            controller: userNameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.phone,
                                color: Colors.lightBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          30.verticalSpace,

                          // Logout
                          GestureDetector(
                            onTap: () {
                              context.read<ProfileCubit>().deleteAccount(
                                widget.userId,
                              );
                            },
                            child: outlinedEmptyBox(
                              borderColor: Colors.red,
                              width: double.infinity,
                              height: 50.h,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    10.horizontalSpace,
                                    Text(
                                      'Delete account',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (state is ProfileError) {
                print(state.errorMessage);
                return Center(child: Text("Error: ${state.errorMessage}"));
              }
              return const Center(child: CircularProgressIndicator());
            },
            listener: (BuildContext context, ProfileState state) {
              if (state is ProfileDeleted) {
                // بعد حذف الحساب، نعيد المستخدم إلى شاشة تسجيل الدخول
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
                AppSnackBar.show(
                  context,
                  message:
                      "Account deleted successfully! Please sign up again.",
                  isError: false,
                );
              }
              if (state is ProfileError &&
                  state.errorMessage != "User not found") {
                AppSnackBar.show(
                  context,
                  message: state.errorMessage,
                  isError: true,
                );
              }
            },
          ),
        );
      },
    );
  }
}

Widget outlinedEmptyBox({
  double width = 200,
  double height = 120,
  double borderRadius = 12,
  double borderWidth = 1,
  Color borderColor = Colors.lightBlue,
  final child,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: borderWidth),
    ),
    child: child,
  );
}
