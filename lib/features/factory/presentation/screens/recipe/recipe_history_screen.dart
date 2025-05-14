import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/recipe_model.dart';

class RecipeHistoryScreen extends StatelessWidget {
  const RecipeHistoryScreen(
      {super.key, required this.recipeId, required this.history});
  final String recipeId;
  final List<dynamic> history;

  @override
  Widget build(BuildContext context) {
    final entries = history.cast<RecipeHistoryEntry>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe History'),
      ),
      body: entries.isEmpty
          ? const Center(child: Text('No history available'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, i) => _HistoryEntryTile(entry: entries[i]),
            ),
    );
  }
}

class _HistoryEntryTile extends StatefulWidget {
  const _HistoryEntryTile({required this.entry});
  final RecipeHistoryEntry entry;

  @override
  State<_HistoryEntryTile> createState() => _HistoryEntryTileState();
}

class _HistoryEntryTileState extends State<_HistoryEntryTile> {
  bool expanded = false;

  Map<String, dynamic> _diff(
      Map<String, dynamic>? before, Map<String, dynamic>? after) {
    if (before == null || after == null) return {};
    final diff = <String, Map<String, dynamic>>{};
    for (final key in {...before.keys, ...after.keys}) {
      if (before[key] != after[key]) {
        diff[key] = {'before': before[key], 'after': after[key]};
      }
    }
    return diff;
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final diff = _diff(entry.before, entry.after);
    return Card(
      child: ExpansionTile(
        title: Text('${entry.action} by ${entry.user}'),
        subtitle: Text(DateFormat.yMd().add_jm().format(entry.timestamp)),
        initiallyExpanded: expanded,
        onExpansionChanged: (val) => setState(() => expanded = val),
        children: [
          if (entry.note != null && entry.note!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Note: ${entry.note}'),
            ),
          if (diff.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Changed Fields:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...diff.entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.key}: ',
                                style: const TextStyle(color: Colors.blue)),
                            Expanded(
                              child: Text(
                                  'from ${jsonEncode(e.value['before'])} to ${jsonEncode(e.value['after'])}',
                                  style: const TextStyle(
                                      color: Colors.deepOrange)),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          if (diff.isEmpty && entry.before != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Before: ${jsonEncode(entry.before)}'),
            ),
          if (diff.isEmpty && entry.after != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('After: ${jsonEncode(entry.after)}'),
            ),
        ],
      ),
    );
  }
}
