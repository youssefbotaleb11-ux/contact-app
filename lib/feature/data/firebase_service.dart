import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_app/feature/data/model/contact_user.dart';

class FirebaseService {
  // دالة لجلب كل جهات الاتصال من قاعدة البيانات مع ربط الـ Document ID
  static Future<List<ContactUser>> getAllContacts() async {
    var collection = FirebaseFirestore.instance.collection("Contact");
    var querySnapshot = await collection.get();
    
    List<ContactUser> users = querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return ContactUser.fromJson(data, doc.id);
    }).toList();

    return users;
  }
}