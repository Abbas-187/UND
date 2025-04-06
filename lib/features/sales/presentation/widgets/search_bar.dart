import 'package:flutter/material.dart';

class SalesSearchBar extends StatefulWidget {

  const SalesSearchBar({
    super.key,
    required this.hint,
    required this.onSearch,
    this.debounceDuration = const Duration(milliseconds: 500),
  });
  final String hint;
  final Function(String) onSearch;
  final Duration debounceDuration;

  @override
  State<SalesSearchBar> createState() => _SalesSearchBarState();
}

class _SalesSearchBarState extends State<SalesSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _showClearButton = false;
  // Debounce mechanism
  DateTime? _lastTyped;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _showClearButton = _controller.text.isNotEmpty;
      });
      // Debounce
      final now = DateTime.now();
      _lastTyped = now;
      Future.delayed(widget.debounceDuration, () {
        if (_lastTyped == now) {
          widget.onSearch(_controller.text);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _showClearButton
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onSearch(''); // Trigger search with empty query
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      ),
    );
  }
}
