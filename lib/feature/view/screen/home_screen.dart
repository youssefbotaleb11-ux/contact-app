import 'package:contact_app/feature/view/screen/new_contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_app/feature/data/model/contact_user.dart';
import 'package:contact_app/main.dart';
import 'package:shimmer/shimmer.dart'; // مكتبة الـ Shimmer

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ContactUser> users = [];
  List<ContactUser> filteredUsers = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllContact();
    searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // دالة الفلترة الفورية (البحث المحلي السريع)
  void _filterContacts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((contact) {
        String name = contact.name?.toLowerCase() ?? '';
        String phone = contact.phone ?? '';
        return name.contains(query) || phone.contains(query);
      }).toList();
    });
  }

  // جلب البيانات من الفايربيس (تم توحيد اسم الكولكشن إلى "contacts")
  Future<void> getAllContact() async {
    setState(() {
      isLoading = true;
    });

    try {
      var collection = FirebaseFirestore.instance.collection("contacts");
      var querySnapshot = await collection.get();
      
      users.clear();
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        users.add(ContactUser.fromJson(data, doc.id));
      }
      filteredUsers = List.from(users);
    } catch (e) {
      // التعامل مع الخطأ إن وجد
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // رسالة تأكيد الحذف الاحترافية (Confirmation Dialog)
  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Contact"),
          content: const Text("Are you sure you want to delete this contact?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseFirestore.instance
                    .collection("contacts")
                    .doc(id)
                    .delete();
                getAllContact();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("abo taleb Contacts"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // زرار تبديل الثيم
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 2. شريط البحث الفوري (Real-time Search Bar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: isLoading
                ? // 1. تأثير الـ Shimmer أثناء التحميل
                  Shimmer.fromColors(
                      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                      child: ListView.builder(
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const CircleAvatar(backgroundColor: Colors.white),
                              title: Container(width: 100, height: 14, color: Colors.white),
                              subtitle: Container(width: 60, height: 12, color: Colors.white),
                            ),
                          );
                        },
                      ),
                    )
                : // 4. ميزة السحب للتحديث (Pull-to-Refresh)
                  RefreshIndicator(
                      onRefresh: getAllContact,
                      child: filteredUsers.isEmpty
                          ? const Center(child: Text("No contacts found"))
                          : ListView.builder(
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    title: Text(filteredUsers[index].name ?? ""),
                                    subtitle: Text(filteredUsers[index].phone ?? ""),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      // 3. تأكيد الحذف قبل التنفيذ
                                      onPressed: () {
                                        var id = filteredUsers[index].id;
                                        if (id != null) {
                                          _showDeleteDialog(id);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewContactScreen(),
            ),
          );
          // إذا تم الحفظ بنجاح، قم بتحديث القائمة فوراً
          if (result == true) {
            getAllContact();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}