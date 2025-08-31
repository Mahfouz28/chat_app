import 'package:chat_app/data/model/user_model.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactsRepo {
  String get currentUserId => Supabase.instance.client.auth.currentUser!.id;

  /// طلب صلاحية الوصول للـ Contacts
  Future<bool> requestContactsPermission() async {
    return await FlutterContacts.requestPermission();
  }

  /// Helper: توحيد صيغة أرقام التليفون
  String normalizePhone(String phone) {
    return phone
        .replaceAll(RegExp(r'\s+'), '') // يشيل المسافات
        .replaceAll('-', '') // يشيل الشرطة
        .replaceAll('(', '') // يشيل قوس
        .replaceAll(')', '')
        .replaceFirst(RegExp(r'^\+20'), '0'); // يخلي +20 تبقى 0
  }

  /// جلب الكونتاكتس اللي متسجلين في الـ DB
  Future<List<UserModel>> getRegisteredContacts() async {
    try {
      // تأكد أن في صلاحية
      final hasPermission = await requestContactsPermission();
      if (!hasPermission) {
        throw Exception("Contacts permission denied");
      }

      // جلب الكونتاكتس من الجهاز
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      final phoneNumbers = contacts
          .where((c) => c.phones.isNotEmpty)
          .map((c) => normalizePhone(c.phones.first.number))
          .toSet(); // set علشان السرعة وتفادي التكرار

      // جلب المستخدمين من Supabase
      final response = await Supabase.instance.client.from('users').select();

      final users = (response as List<dynamic>).map(
        (doc) => UserModel.fromSupabase(doc as Map<String, dynamic>),
      );

      // فلترة المستخدمين اللي أرقامهم موجودة في الكونتاكتس
      final matchedUsers = users.where((user) {
        return phoneNumbers.contains(normalizePhone(user.phoneNumber)) &&
            user.id != currentUserId;
      }).toList();

      return matchedUsers;
    } catch (e, st) {
      print('Error getting registered users: $e');
      print(st);
      return [];
    }
  }
}
