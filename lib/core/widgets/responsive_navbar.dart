import 'package:flutter/material.dart';
import 'package:educonnect_mobile/features/users/presentation/pages/profile_page.dart';
import 'package:educonnect_mobile/features/users/presentation/pages/settings_page.dart';
import 'package:educonnect_mobile/features/users/presentation/pages/login_page.dart';
import 'package:educonnect_mobile/core/utils/session_manager.dart';


class ResponsiveNavBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ResponsiveNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 800;

    return Theme(
      data: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0066FF),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0066FF),
          elevation: 0,
          titleSpacing: 0,
          leading: isLargeScreen
              ? null
              : IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "EduConnect",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                if (isLargeScreen)
                  Expanded(child: _navBarItems(context, isLargeScreen)),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.person, color: Color(0xFF0066FF)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage(email: '')),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        drawer: isLargeScreen ? null : _drawer(context),
        body: const Center(child: Text("Bienvenue sur EduConnect")),
      ),
    );
  }

  Widget _drawer(BuildContext context) => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: _menuItems(context)
          .map((item) => ListTile(
        leading: Icon(item['icon'] as IconData),
        title: Text(item['title'] as String),
        onTap: item['onTap'] as VoidCallback,
      ))
          .toList(),
    ),
  );

  Widget _navBarItems(BuildContext context, bool isLargeScreen) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: _menuItems(context)
        .map(
          (item) => InkWell(
        onTap: item['onTap'] as VoidCallback,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 24.0, horizontal: 18),
          child: Text(
            item['title'] as String,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    )
        .toList(),
  );

  List<Map<String, dynamic>> _menuItems(BuildContext context) => [
    {
      'title': 'Accueil',
      'icon': Icons.home_outlined,
      'onTap': () {
        // Exemple : page des cours
        Navigator.pushNamed(context, '/courses');
      },
    },
    {
      'title': 'Courses',
      'icon': Icons.book_outlined,
      'onTap': () {
        Navigator.pushNamed(context, '/courses');
      },
    },
    {
      'title': 'Quiz',
      'icon': Icons.quiz_outlined,
      'onTap': () {
        Navigator.pushNamed(context, '/quiz');
      },
    },
    {
      'title': 'Profil',
      'icon': Icons.person_outline,
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage(email: '')),
        );
      },
    },
    {
      'title': 'Paramètres',
      'icon': Icons.settings_outlined,
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsPage2()),
        );
      },
    },
    {
      'title': 'Déconnexion',
      'icon': Icons.logout,
      'onTap': () async {
        await SessionManager.clearSession();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
          );
        }
      },
    },
  ];
}
