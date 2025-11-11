import 'package:flutter/material.dart';
import 'package:educonnect_mobile/core/utils/session_manager.dart';
import 'package:educonnect_mobile/features/users/presentation/pages/chatbot_page.dart';
import 'package:educonnect_mobile/core/widgets/Drawer3.dart';

// 🔹 ces pages sont encore à relier à tes modules existants :
import 'package:educonnect_mobile/features/courses/presentation/pages/home_courses_page.dart';
import 'package:educonnect_mobile/features/courses/presentation/pages/my_courses_page.dart';
import 'package:educonnect_mobile/features/courses/presentation/pages/bookmarks_page.dart';


class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _selectedIndex = 0;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    userEmail = await SessionManager.getSessionEmail();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeCoursesPage(),
      const MyCoursesPage(),
      const BookmarksPage(),
      const ChatBotPage(), // ✅ Assistant IA
      DrawerNavigationPage(email: userEmail ?? ""), // ✅ Profil
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("EduConnect"),
        backgroundColor: const Color(0xFF0066FF),
        foregroundColor: Colors.white,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0066FF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: "Cours",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            label: "Mes cours",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available_outlined),
            label: "Favoris",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: "Assistant",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
