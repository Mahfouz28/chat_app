import 'package:chat_app/data/model/user_model.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactsRepo {
  final supabase = Supabase.instance.client;

  String get currentUserId => supabase.auth.currentUser!.id;

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
      // 1- تأكد أن في صلاحية
      final hasPermission = await requestContactsPermission();
      if (!hasPermission) {
        throw Exception("Contacts permission denied");
      }

      // 2- جلب الكونتاكتس من الجهاز (كل الأرقام مش بس الأول)
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      final phoneNumbers = contacts
          .expand((c) => c.phones.map((p) => normalizePhone(p.number)))
          .toSet(); // Set علشان السرعة والتكرار

      if (phoneNumbers.isEmpty) return [];

      // 3- جلب المستخدمين من Supabase
      final response = await supabase.from('users').select();

      final users = (response as List<dynamic>)
          .map((doc) => UserModel.fromSupabase(doc as Map<String, dynamic>))
          .toList();

      // 4- فلترة المستخدمين اللي أرقامهم موجودة في الكونتاكتس (ماعدا المستخدم الحالي)
      final matchedUsers = users.where((user) {
        return phoneNumbers.contains(normalizePhone(user.phoneNumber)) &&
            user.id != currentUserId;
      }).toList();

      return matchedUsers;
    } on PostgrestException catch (e) {
      // لو فيه Error من قاعدة البيانات
      throw Exception("Database error [${e.code}]: ${e.message}");
    } catch (e) {
      throw Exception("Error getting registered contacts: $e");
    }
  }
}
