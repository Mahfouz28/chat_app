import 'package:chat_app/data/repo/auth_repo.dart';
import 'package:chat_app/presentation/screens/auth/login_screen.dart';
import 'package:chat_app/presentation/screens/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/logic/cubit/profile/profile_cubit.dart';
import 'package:chat_app/logic/cubit/profile/profile_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 0),
            Text("Profile"),
            IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            final user = state.user;
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  height: 139.h,
                                  width: 139.w,

                                  child: CircleAvatar(
                                    backgroundColor: Color(0xffD9D9D9),
                                    child: Text(
                                      user.fullName[0].toUpperCase(),
                                      style: TextStyle(fontSize: 40.sp),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 20,
                                  child: GestureDetector(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditProfileScreen(
                                                userId: widget.userId,
                                              ),
                                        ), // Pass the userId to EditProfileScreen
                                      );
                                      if (await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditProfileScreen(
                                                    userId: widget.userId,
                                                  ),
                                            ),
                                          ) ==
                                          true) {
                                        context
                                            .read<ProfileCubit>()
                                            .fetchUserProfile(widget.userId);
                                      }
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.lightBlue,
                                      child: Icon(
                                        Icons.edit,
                                        size: 26.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              user.fullName,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.username,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      14.verticalSpace,
                      Text(
                        'You Email',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      12.verticalSpace,
                      outlinedEmptyBox(
                        width: double.infinity,
                        height: 50.h,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.email, color: Colors.lightBlue),
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
                      14.verticalSpace,
                      Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      12.verticalSpace,
                      outlinedEmptyBox(
                        width: double.infinity,
                        height: 50.h,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.phone, color: Colors.lightBlue),
                              8.horizontalSpace,
                              Text(
                                user.phoneNumber,
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
                      14.verticalSpace,
                      Text(
                        'full Name',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      12.verticalSpace,
                      outlinedEmptyBox(
                        width: double.infinity,
                        height: 50.h,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.phone, color: Colors.lightBlue),
                              8.horizontalSpace,
                              Text(
                                user.fullName,
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
                      Text(
                        'Username',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      12.verticalSpace,
                      outlinedEmptyBox(
                        width: double.infinity,
                        height: 50.h,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.person, color: Colors.lightBlue),
                              8.horizontalSpace,
                              Text(
                                user.username,
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
                      30.verticalSpace,
                      GestureDetector(
                        onTap: () {
                          AuthRepository().signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: outlinedEmptyBox(
                          borderColor: Colors.red,
                          width: double.infinity,
                          height: 50.h,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_outlined,
                                  color: Colors.redAccent,
                                ),
                                96.horizontalSpace,
                                Center(
                                  child: Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
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
            return Center(child: Text("Error: ${state.errorMessage}"));
          }
          return const Center(child: Text("No data"));
        },
      ),
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
      color: Colors.transparent, // فارغة من جوّا
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: borderWidth),
    ),
    child: child,
  );
}
