import 'package:chat_app/data/model/user_model.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactsRepo {
  String get currntUserId => Supabase.instance.client.auth.currentUser!.id;
  Future<bool> requestContcactsPremission() async {
    return await FlutterContacts.requestPermission();
  }

  Future<List<Map<String, dynamic>>> getRigisterContacts() async {
    try {
      // get device contacts with phone num
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      // extract phone nums and normalize them
      final phoneNumpers = contacts
          .where((contacts) => contacts.phones.isNotEmpty)
          .map((contact) {
            return {
              'name': contact.displayName,
              'phone': contact.phones.first.number,
              'photo': contact.photo,
            };
          })
          .toList();
      // Fetch all users from "users" table
      final userSnapShot = await Supabase.instance.client
          .from('users')
          .select();

      final registeredContacts = (userSnapShot as List)
          .map((doc) => UserModel.fromSupabase(doc))
          .toList();

      final matchContacts = phoneNumpers
          .where((contact) {
            final phoneNumper = contact['phone_number'];
            return registeredContacts.any(
              (user) =>
                  user.phoneNumber == phoneNumper && user.id != currntUserId,
            );
          })
          .map((contact) {
            final registardUser = registeredContacts.firstWhere(
              (user) => user.phoneNumber == contact['phone_number'],
            );
            return {
              'id': registardUser.id,
              'name': contact['full_name'],
              'phone': contact['phone_number'],
            };
          })
          .toList();
      return matchContacts;
    } catch (e) {
      print('Error giting regester users');
      return [];
    }
  }
}
