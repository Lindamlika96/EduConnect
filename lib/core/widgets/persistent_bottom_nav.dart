import 'package:flutter/material.dart';
import 'package:educonnect_mobile/core/utils/session_manager.dart';
import 'package:educonnect_mobile/core/db/app_database.dart';
import '../../../features/users/presentation/pages/profile_page.dart';
import '../../../features/users/presentation/pages/edit_profile_page.dart';
import '../../../features/users/presentation/pages/settings_page.dart';

/// ============================
/// 💠 Classe représentant un onglet
/// ============================
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

/// ============================
/// 💠 Scaffold avec une seule BottomBar persistante
/// ============================
class PersistentBottomBarScaffold extends StatefulWidget {
  final List<PersistentTabItem> items;
  final ValueNotifier<int> tabController; // 👈 permet de changer d’onglet dynamiquement

  const PersistentBottomBarScaffold({
    super.key,
    required this.items,
    required this.tabController,
  });

  @override
  State<PersistentBottomBarScaffold> createState() =>
      _PersistentBottomBarScaffoldState();
}

class _PersistentBottomBarScaffoldState
    extends State<PersistentBottomBarScaffold> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.tabController,
      builder: (context, selectedTab, _) {
        return Scaffold(
          body: IndexedStack(
            index: selectedTab,
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
            currentIndex: selectedTab,
            onTap: (index) => widget.tabController.value = index,
            selectedItemColor: const Color(0xFF0066FF),
            unselectedItemColor: Colors.grey,
            items: widget.items
                .map((item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.title,
            ))
                .toList(),
          ),
        );
      },
    );
  }
}

/// ============================
/// 💠 Page principale avec logique de navigation et callbacks
/// ============================
class PersistentBottomNavPage extends StatefulWidget {
  const PersistentBottomNavPage({super.key});

  @override
  State<PersistentBottomNavPage> createState() =>
      _PersistentBottomNavPageState();
}

class _PersistentBottomNavPageState extends State<PersistentBottomNavPage> {
  final _tab1navigatorKey = GlobalKey<NavigatorState>();
  final _tab2navigatorKey = GlobalKey<NavigatorState>();
  final _tab3navigatorKey = GlobalKey<NavigatorState>();

  final ValueNotifier<int> _tabController = ValueNotifier<int>(0); // 👈 contrôle actif
  List<PersistentTabItem>? _items;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 🔹 Charger les données utilisateur depuis SQLite
  Future<void> _loadUserData() async {
    final email = await SessionManager.getSessionEmail();
    if (email == null) return;

    final db = await AppDatabase.database;
    final result =
    await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (result.isEmpty) return;

    final userData = result.first;

    setState(() {
      _items = [
        /// 🧩 Onglet 1 : Profil
        PersistentTabItem(
          tab: ProfilePage(email: email),
          icon: Icons.person_outline,
          title: 'Profil',
          navigatorkey: _tab1navigatorKey,
        ),

        /// 🧩 Onglet 2 : Modifier
        PersistentTabItem(
          tab: FutureBuilder<Map<String, dynamic>?>(
            future: _getUserData(email),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return EditProfilePage(
                userData: snapshot.data!,
                onProfileUpdated: () {
                  // ✅ Recharge les données et bascule vers l’onglet Profil
                  _loadUserData();
                  _tabController.value = 0; // 👉 retour direct à "Profil"
                },
              );
            },
          ),
          icon: Icons.edit_note_outlined,
          title: 'Modifier',
          navigatorkey: _tab2navigatorKey,
        ),

        /// 🧩 Onglet 3 : Paramètres
        PersistentTabItem(
          tab: const SettingsPage2(),
          icon: Icons.settings_outlined,
          title: 'Paramètres',
          navigatorkey: _tab3navigatorKey,
        ),
      ];
    });
  }

  /// 🔹 Récupère toujours les données les plus récentes
  Future<Map<String, dynamic>?> _getUserData(String email) async {
    final db = await AppDatabase.database;
    final result =
    await db.query('users', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty ? result.first : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_items == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ Une seule BottomBar, aucun doublon
    return PersistentBottomBarScaffold(
      items: _items!,
      tabController: _tabController,
    );
  }
}
