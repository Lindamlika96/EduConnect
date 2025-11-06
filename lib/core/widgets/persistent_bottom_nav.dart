import 'package:flutter/material.dart';
import '../../../features/users/presentation/pages/profile_page.dart';
import '../../../features/users/presentation/pages/edit_profile_page.dart';
import '../../../features/users/presentation/pages/settings_page.dart';

// ============================
// 💠 Classes de base
// ============================

class PersistentTabItem {
  final Widget tab;
  final GlobalKey<NavigatorState>? navigatorkey;
  final String title;
  final IconData icon;

  PersistentTabItem({
    required this.tab,
    this.navigatorkey,
    required this.title,
    required this.icon,
  });
}

class PersistentBottomBarScaffold extends StatefulWidget {
  final List<PersistentTabItem> items;

  const PersistentBottomBarScaffold({super.key, required this.items});

  @override
  State<PersistentBottomBarScaffold> createState() =>
      _PersistentBottomBarScaffoldState();
}

class _PersistentBottomBarScaffoldState
    extends State<PersistentBottomBarScaffold> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (val, result) async {
        if (widget.items[_selectedTab].navigatorkey?.currentState?.canPop() ??
            false) {
          widget.items[_selectedTab].navigatorkey?.currentState?.pop();
          return;
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedTab,
          children: widget.items
              .map(
                (page) => Navigator(
              key: page.navigatorkey,
              onGenerateInitialRoutes: (navigator, initialRoute) {
                return [MaterialPageRoute(builder: (context) => page.tab)];
              },
            ),
          )
              .toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (index) => setState(() => _selectedTab = index),
          selectedItemColor: const Color(0xFF0066FF),
          unselectedItemColor: Colors.grey,
          items: widget.items
              .map((item) =>
              BottomNavigationBarItem(icon: Icon(item.icon), label: item.title))
              .toList(),
        ),
      ),
    );
  }
}

// ============================
// 💠 Wrapper principal
// ============================

class PersistentBottomNavPage extends StatelessWidget {
  final _tab1navigatorKey = GlobalKey<NavigatorState>();
  final _tab2navigatorKey = GlobalKey<NavigatorState>();
  final _tab3navigatorKey = GlobalKey<NavigatorState>();

  PersistentBottomNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentBottomBarScaffold(
      items: [
        PersistentTabItem(
          tab: const ProfilePage(email: 'lindamlika865@gmail.com'),
          icon: Icons.person_outline,
          title: 'Profil',
          navigatorkey: _tab1navigatorKey,
        ),
        PersistentTabItem(
          tab: const EditProfilePage(),
          icon: Icons.edit_note_outlined,
          title: 'Modifier',
          navigatorkey: _tab2navigatorKey,
        ),
        PersistentTabItem(
          tab: const SettingsPage2(),
          icon: Icons.settings_outlined,
          title: 'Paramètres',
          navigatorkey: _tab3navigatorKey,
        ),
      ],
    );
  }
}
