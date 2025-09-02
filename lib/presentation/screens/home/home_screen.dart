import 'package:chat_app/core/common/snackBar.dart';
import 'package:chat_app/data/model/user_model.dart';
import 'package:chat_app/data/repo/auth_repo.dart';
import 'package:chat_app/data/repo/contacts_repo.dart';
import 'package:chat_app/data/repo/home_repo.dart';
import 'package:chat_app/presentation/screens/auth/login_screen.dart';
import 'package:chat_app/presentation/screens/chat/chat_messge_screen.dart';
import 'package:chat_app/services_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  late final String _currentUserId;
  late final ContactsRepo contactsRepo;
  late final HomeRepo homeRepo;
  List<Map<String, dynamic>> _chatRooms = [];

  @override
  void initState() {
    _currentUserId = Supabase.instance.client.auth.currentUser!.id;
    homeRepo = sl<HomeRepo>();
    contactsRepo = sl<ContactsRepo>();
    _fetchChatRooms();
    super.initState();
  }

  Future<void> _fetchChatRooms() async {
    try {
      _chatRooms = await homeRepo.fetchUserChatRooms(_currentUserId);

      // Debug print لكل الغرف
      print("==== User Chat Rooms ====");
      print("=======Current User ID: $_currentUserId==============");
      for (var room in _chatRooms) {
        print("=========Room ID: ${room['id']}============");
        print("===========Name: ${room['name']}============");
        print("=======Last Message: ${room['last_message']}=======");
        print(
          "=======Last Message Time: ${room['last_message_time']}=========",
        );
        print(
          "=================Participants Name: ${room['participants_name']}===========",
        );
        print("----------------------------");
      }

      setState(() {
        _chatRooms;
      });
    } catch (e) {
      print("Error fetching chat rooms: $e");
    }
  }

  void showContactsList(BuildContext context) async {
    final hasPermission = await contactsRepo.requestContactsPermission();
    if (!hasPermission) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: "Contacts permission denied",
        isError: true,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0.r),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contacts',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: FutureBuilder<List<UserModel>>(
                  future: contactsRepo.getRegisteredContacts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No Contacts'));
                    }

                    final contacts = snapshot.data!;

                    return Expanded(
                      child: ListView.builder(
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatMessgeScreen(
                                    receviedId: contact.id,
                                    receviedName: contact.fullName,
                                  ),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(.2),
                              child: Text(
                                contact.fullName.isNotEmpty
                                    ? contact.fullName[0].toUpperCase()
                                    : "?",
                              ),
                            ),
                            title: Text(contact.fullName),
                            subtitle: Text(contact.phoneNumber),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          showContactsList(context);
        },
        child: Icon(Icons.messenger, size: 25, color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0.r, vertical: 40.r),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chats',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text("Sign Out"),
                          content: const Text(
                            "Are you sure you want to sign out?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                await AuthRepository().signOut();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                                AppSnackBar.show(
                                  context,
                                  message: "Sign out successfully!",
                                );
                              },
                              child: const Text("Sign Out"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.logout_outlined),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _chatRooms.length,
                itemBuilder: (context, index) {
                  final room = _chatRooms[index];

                  return ListTile(
                    title: Text(room['name'] ?? 'No Name'), // لو الاسم فاضي
                    subtitle: Text(
                      room['last_message'] ?? 'No messages yet',
                    ), // لو الرسالة فاضية
                    onTap: () {
                      // افتح شاشة الدردشة هنا
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
