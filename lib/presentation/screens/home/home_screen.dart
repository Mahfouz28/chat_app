import 'package:chat_app/data/model/user_model.dart';
import 'package:chat_app/data/repo/contacts_repo.dart';
import 'package:chat_app/services_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  late final ContactsRepo contactsRepo;

  @override
  void initState() {
    contactsRepo = sl<ContactsRepo>();
    super.initState();
  }

  void showContactsList(BuildContext context) async {
    final hasPermission = await contactsRepo.requestContactsPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Contacts permission denied")));
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0.r),
          child: Column(
            children: [
              Text(
                'Contacts',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              FutureBuilder<List<UserModel>>(
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
                    // ⬅ مهم جداً علشان مايحصلش overflow
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton(
        onPressed: () {
          showContactsList(context);
        },
        child: Icon(Icons.messenger, size: 25, color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0.r, vertical: 28.r),
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
                IconButton(onPressed: () {}, icon: Icon(Icons.logout_outlined)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
