// lib/core/routing/app_scaffold.dart
import 'package:flutter/material.dart';

import '../../features/courses/presentation/pages/home_courses_page.dart';
import '../../features/courses/presentation/pages/my_courses_page.dart';
import '../../features/courses/presentation/pages/bookmarks_page.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _index = 0;

  // Pas d’import du module "users" de ton collègue.
  // On met un placeholder local pour le Profil.
  late final List<Widget> _pages = [
    const HomeCoursesPage(),   // Tous les cours
    const MyCoursesPage(),     // Mes cours (Complétés / En cours)
    const BookmarksPage(),     // Favoris
    const _DisabledTabPage(    // Profil (inactif)
      title: 'Profil',
      message: 'La page Profil sera intégrée lors de l\'intégration finale.',
    ),
  ];

  void _onTap(int i) {
    // Rendre l’onglet "Profil" inactif jusqu’à l’intégration.
    if (i == 3) {
      // Ne change pas d’onglet, affiche juste une info
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil : sera intégré plus tard.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Mes cours'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}

class _DisabledTabPage extends StatelessWidget {
  final String title;
  final String message;
  const _DisabledTabPage({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    // Cette page n’est jamais affichée car on bloque l’onglet au tap.
    // Elle existe juste pour compléter la structure.
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
