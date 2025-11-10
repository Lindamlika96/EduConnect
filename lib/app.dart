import 'package:flutter/material.dart';

// 🔹 Pages utilisateur
import 'features/users/presentation/pages/login_page.dart';
import 'features/users/presentation/pages/register_page.dart';
import 'features/users/presentation/pages/splash_screen.dart';
import 'features/users/presentation/pages/settings_page.dart';

// 🔹 Page principale avec BottomNavigationBar
import 'features/users/presentation/pages/main_page.dart';

// 🔹 Pages placeholders (ex: cours, quiz)
import 'features/placeholders/placeholder_pages.dart';

class EduConnectApp extends StatelessWidget {
  const EduConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0066FF),
        useMaterial3: true,
      ),

      // 🏁 Écran d’accueil (Splash avant redirection)
      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // 🧭 Page principale avec BottomNavigationBar
        '/main': (context) => MainHomePage(), // ✅ corrigé : pas de const ici

        // ⚙️ Autres pages
        '/settings': (context) => const SettingsPage2(),
        '/courses': (context) => const CoursesPage(),
        '/quiz': (context) => const QuizPage(),
      },
    );
  }
}
