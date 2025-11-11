import 'package:flutter/material.dart';
import 'features/events/routes.dart';
import 'features/events/presentation/pages/events_home_page.dart';

/// =============================================================
/// EduConnectApp — Application principale
/// Contient la configuration globale du thème + routes.
/// =============================================================
class EduConnectApp extends StatelessWidget {
  const EduConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduConnect',
      debugShowCheckedModeBanner: false,

      // 🎨 Thème global
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0066FF),
        scaffoldBackgroundColor: const Color(0xFFEFF4FF),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),

      // 🏠 Page d’accueil = module Events
      home: const EventsHomePage(),

      // 🧭 Définition des routes du module
      routes: {
        ...EventsRoutes.map,
      },
    );
  }
}
