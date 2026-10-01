import 'package:contact_app/feature/view/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:contact_app/firebase_options.dart'; // استدعاء ملف الـ options

// متغير عالمي (Global Notifier) عشان نتحكم في الثيم من أي مكان في التطبيق بسهولة
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تمرير الـ options عشان الاتصال يتم بثبات وبدون أي مشاكل
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'abo taleb Contacts',
          // الثيم الفاتح (Light Mode)
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              surface: Colors.grey[100]!,
            ),
          ),
          // الثيم الداكن (Dark Mode)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              surface: Colors.grey[850]!,
            ),
          ),
          themeMode: currentTheme, // بيتحدث تلقائياً حسب الاختيار
          home: const HomeScreen(),
        );
      },
    );
  }
}