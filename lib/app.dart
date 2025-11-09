import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:educonnect_mobile/features/courses/presentation/pages/course_list_page.dart';
// import 'package:educonnect_mobile/features/quizzes/presentation/pages/welcome_page.dart'; // décommente pour tester WelcomePage

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
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(
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

      home: const CourseListPage(), // ou WelcomePage(...) pour tester
    );
  }
}
