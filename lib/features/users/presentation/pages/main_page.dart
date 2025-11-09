import 'package:flutter/material.dart';
import '../../../../core/widgets/Drawer3.dart';
import '../../../../core/widgets/responsive_navbar.dart';
import '../../../../core/utils/session_manager.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 800;

    return FutureBuilder<String?>(
      future: SessionManager.getSessionEmail(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final email = snapshot.data ?? "";

        return Scaffold(
          appBar: isLargeScreen
              ? PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child:  ResponsiveNavBar(),
          )
              : null,
          body: isLargeScreen
              ? const Center(child: Text("Bienvenue sur EduConnect 👋"))
              : DrawerNavigationPage(email: email), // ✅ nouvelle navigation
        );
      },
    );
  }
}
