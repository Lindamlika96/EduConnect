import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final double value; // 0..5
  const RatingBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text('⭐ ${value.toStringAsFixed(1)}');
  }
}
