import 'package:flutter/material.dart';
import 'package:educonnect_mobile/core/widgets/dummy_widget.dart';

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
      // ⛔️ supprime 'const' ici
      home: Scaffold(
        appBar: AppBar(title: const Text('EduConnect')),
        body: const DummyWidget(),
      ),
    );
  }
}
