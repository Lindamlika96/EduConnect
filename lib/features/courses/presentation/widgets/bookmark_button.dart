import 'package:flutter/material.dart';

class BookmarkButton extends StatelessWidget {
  final bool bookmarked;
  final VoidCallback? onPressed;
  const BookmarkButton({super.key, required this.bookmarked, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
    );
  }
}