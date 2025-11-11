import 'package:flutter/material.dart';

class EventFilter extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const EventFilter({super.key, required this.onSearch});

  @override
  State<EventFilter> createState() => _EventFilterState();
}

class _EventFilterState extends State<EventFilter> {
  final _controller = TextEditingController();

  void _submit([String? _]) {
    widget.onSearch(_controller.text.trim());
  }

  void _clear() {
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Rechercher un événement…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
            icon: const Icon(Icons.close),
            onPressed: _clear,
          ),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => setState(() {}), // pour gérer l’icône clear
        onSubmitted: _submit,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
