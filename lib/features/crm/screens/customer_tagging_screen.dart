import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerTaggingScreen extends StatefulWidget {

  const CustomerTaggingScreen(
      {super.key,
      required this.customer,
      required this.availableTags,
      required this.onTagsUpdated});
  final Customer customer;
  final List<String> availableTags;
  final void Function(List<String> tags) onTagsUpdated;

  @override
  State<CustomerTaggingScreen> createState() => _CustomerTaggingScreenState();
}

class _CustomerTaggingScreenState extends State<CustomerTaggingScreen> {
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = List<String>.from(widget.customer.tags);
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
    widget.onTagsUpdated(_selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tag Customer')),
      body: ListView(
        children: widget.availableTags.map((tag) {
          final selected = _selectedTags.contains(tag);
          return ListTile(
            title: Text(tag),
            trailing: selected
                ? Icon(Icons.check_box)
                : Icon(Icons.check_box_outline_blank),
            onTap: () => _toggleTag(tag),
          );
        }).toList(),
      ),
    );
  }
}
