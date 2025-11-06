import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final double rating;
  final VoidCallback? onTap;
  const CourseCard({super.key, required this.title, required this.rating, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text('⭐ ${rating.toStringAsFixed(1)}'),
      onTap: onTap,
    );
  }
}
