import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 🌍 Core
import 'core/routing/app_scaffold.dart';

// 🔹 Modules Users
import 'features/users/presentation/pages/login_page.dart';
import 'features/users/presentation/pages/register_page.dart';
import 'features/users/presentation/pages/splash_screen.dart';
import 'features/users/presentation/pages/settings_page.dart';
import 'features/users/presentation/pages/main_page.dart';

// 🔹 Modules Courses
import 'features/courses/courses_page.dart';
import 'features/courses/presentation/pages/course_detail_page.dart';
import 'features/courses/presentation/pages/course_pdf_page.dart';
import 'features/courses/presentation/pages/home_courses_page.dart';
import 'features/courses/presentation/pages/my_courses_page.dart';
import 'features/courses/presentation/pages/bookmarks_page.dart';
import 'features/courses/presentation/pages/course_list_page.dart';

// 🔹 Modules Quiz & Events
import 'features/quizzes/domain/entities/quiz.dart';
import 'features/quizzes/domain/presentation/pages/welcome_page.dart';
import 'features/events/events_page.dart'; // ✅ On garde cette version uniquement

// 🔹 Placeholders
import 'features/placeholders/placeholder_pages.dart'; // ⚠️ Conserve pour les autres, plus pour Events

class EduConnectApp extends StatelessWidget {
  const EduConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduConnect',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: const Color(0xFF0066FF),
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
          primary: const Color(0xFF0066FF),
          secondary: const Color(0xFF00C6FF),
          onPrimary: Colors.white,
          surface: Colors.white,
          background: const Color(0xFFF5F9FF),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0066FF),
            textStyle: GoogleFonts.poppins(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 6,
          ),
        ),
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        useMaterial3: true,
      ),

      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0066FF),
          secondary: Color(0xFF00C6FF),
          onPrimary: Colors.white,
          surface: Colors.grey,
          background: Colors.black,
        ),
      ),

      themeMode: ThemeMode.system,
      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) => MainHomePage(),
        '/settings': (context) => const SettingsPage2(),

        // 🔸 Modules
        '/courses': (context) => const HomeCoursesPage(),

        // 🧠 Quiz : arguments par défaut pour test (sera remplacé plus tard par args dynamiques)
        '/quiz': (context) {
          final quiz = Quiz(id: 1, courseId: 1, title: 'Quiz de test');
          return WelcomePage(
            quiz: quiz,
            duration: 10,
            questionCount: 10,
            userId: 1,
          );
        },

        '/events': (context) => const EventsPage(),

        // 🔸 Scaffold général
        '/home': (context) => const AppScaffold(),

        // 🔸 Cours
        '/my_courses': (context) => const MyCoursesPage(),
        '/bookmarks': (context) => const BookmarksPage(),
        '/course_list': (context) => const CourseListPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/course/detail') {
          final args = settings.arguments;
          if (args is int) {
            return MaterialPageRoute(
              builder: (_) => CourseDetailPage(courseId: args, userId: 1),
            );
          }
          if (args is Map) {
            final int courseId = args['courseId'] as int;
            final int userId =
            (args['userId'] is int) ? args['userId'] as int : 1;
            return MaterialPageRoute(
              builder: (_) =>
                  CourseDetailPage(courseId: courseId, userId: userId),
            );
          }
          return _errorRoute(
            'Arguments invalides pour /course/detail.',
          );
        }

        if (settings.name == '/course/pdf') {
          final args = settings.arguments as Map?;
          if (args == null ||
              !args.containsKey('courseId') ||
              !args.containsKey('path') ||
              !args.containsKey('userId')) {
            return _errorRoute('Arguments manquants pour /course/pdf.');
          }
          final int courseId = args['courseId'] as int;
          final String path = args['path'] as String;
          final int userId = args['userId'] as int;

          return MaterialPageRoute(
            builder: (_) =>
                CoursePdfPage(courseId: courseId, path: path, userId: userId),
          );
        }

        return null;
      },
    );
  }

  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Erreur de navigation')),
        body: Center(child: Text(message)),
      ),
    );
  }
}
