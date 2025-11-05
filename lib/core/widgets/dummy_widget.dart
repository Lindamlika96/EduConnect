import 'package:flutter/material.dart';

class DummyWidget extends StatelessWidget {
  const DummyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'DummyWidget ready',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}
