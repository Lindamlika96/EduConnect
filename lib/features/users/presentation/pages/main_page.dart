import 'package:flutter/material.dart';
import '../../../../core/widgets/persistent_bottom_nav.dart';
import '../../../../core/widgets/responsive_navbar.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 800;

    return Scaffold(
      appBar: isLargeScreen
          ? PreferredSize( // ✅ const supprimé ici
        preferredSize: const Size.fromHeight(65),
        child: ResponsiveNavBar(),
      )
          : null,
      body: isLargeScreen
          ? Center(child: Text("Bienvenue sur EduConnect 👋")) // ✅ const aussi supprimé
          : PersistentBottomNavPage(), // ✅ ta bottom bar mobile
    );
  }
}
