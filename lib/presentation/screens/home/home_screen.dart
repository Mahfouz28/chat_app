import 'package:chat_app/core/common/snackBar.dart';
import 'package:chat_app/data/model/user_model.dart';
import 'package:chat_app/data/repo/auth_repo.dart';
import 'package:chat_app/data/repo/contacts_repo.dart';
import 'package:chat_app/data/repo/chat_repo.dart';
import 'package:chat_app/presentation/screens/auth/login_screen.dart';
import 'package:chat_app/presentation/screens/chat/chat_messge_screen.dart';
import 'package:chat_app/services_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/logic/cubit/chat/chat_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final String _currentUserId;
  late final ContactsRepo contactsRepo;
  late final ChatRepo chatRepo;

  List<Map<String, dynamic>> _chatRooms = [];

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser!.id;
    chatRepo = sl<ChatRepo>();
    contactsRepo = sl<ContactsRepo>();
    _subscribeChatRooms();
  }

  void _subscribeChatRooms() {
    Supabase.instance.client
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .listen((rooms) {
          if (!mounted) return;

          final myRooms = rooms
              .where(
                (room) => (room['participants'] as List<dynamic>).contains(
                  _currentUserId,
                ),
              )
              .toList();

          setState(() {
            _chatRooms = myRooms;
          });
        });
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
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No Contacts'));
                    }

                    final contacts = snapshot.data!;
                    return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (_) => ChatCubit(chatRepo),
                                  child: ChatMessgeScreen(
                                    receviedId: contact.id,
                                    receviedName: contact.fullName,
                                  ),
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

  /// Helper to check last message status for styling
  bool isLastMessageRead(Map<String, dynamic> room) {
    return room['last_message_status'] == 'sent';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => showContactsList(context),
        child: const Icon(Icons.messenger, size: 25, color: Colors.white),
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
                              onPressed: () => Navigator.of(context).pop(),
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
                                    builder: (_) => const LoginScreen(),
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
                  icon: const Icon(Icons.logout_outlined),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _chatRooms.length,
                itemBuilder: (context, index) {
                  final room = _chatRooms[index];
                  final participantsMap = Map<String, String>.from(
                    room['participants_name'] ?? {},
                  );
                  final otherParticipantName = participantsMap.entries
                      .firstWhere(
                        (entry) => entry.key != _currentUserId,
                        orElse: () => const MapEntry('', 'No Name'),
                      )
                      .value;

                  final lastMessageRead = isLastMessageRead(room);

                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            otherParticipantName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              room['last_message_time'] != null
                                  ? TimeOfDay.fromDateTime(
                                      DateTime.parse(
                                        room['last_message_time'],
                                      ).toLocal(),
                                    ).format(context)
                                  : '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Text(
                      room['last_message'] ?? 'Say hi to your new friend',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: lastMessageRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: lastMessageRead ? Colors.grey : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      final otherId = participantsMap.keys.firstWhere(
                        (id) => id != _currentUserId,
                      );
                      final otherName = participantsMap[otherId] ?? 'No Name';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) =>
                                ChatCubit(chatRepo)
                                  ..loadChat(_currentUserId, otherId),
                            child: ChatMessgeScreen(
                              receviedId: otherId,
                              receviedName: otherName,
                            ),
                          ),
                        ),
                      );
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
