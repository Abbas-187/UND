import 'package:flutter/material.dart';

/// A generic searchable dropdown widget for selecting an item from a list.
/// As the user types, the list is filtered in real time.
class SearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T) onSelected;
  final String hintText;
  final T? initialValue;
  final bool enabled;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
    required this.hintText,
    this.initialValue,
    this.enabled = true,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  late List<T> _filteredItems;
  late TextEditingController _controller;
  T? _selectedItem;
  bool _dropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _filteredItems = widget.items;
    _selectedItem = widget.initialValue;
    if (_selectedItem != null) {
      _controller.text = widget.itemLabel(_selectedItem!);
    }
  }

  @override
  void didUpdateWidget(covariant SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _filteredItems = widget.items;
    }
    if (widget.initialValue != oldWidget.initialValue) {
      _selectedItem = widget.initialValue;
      if (_selectedItem != null) {
        _controller.text = widget.itemLabel(_selectedItem!);
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => widget
              .itemLabel(item)
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      _dropdownOpen = true;
    });
  }

  void _onItemSelected(T item) {
    setState(() {
      _selectedItem = item;
      _controller.text = widget.itemLabel(item);
      _dropdownOpen = false;
    });
    widget.onSelected(item);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _controller.clear();
                        _filteredItems = widget.items;
                        _selectedItem = null;
                        _dropdownOpen = true;
                      });
                      widget.onSelected.call(_selectedItem as T);
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            isDense: true,
          ),
          onChanged: _onSearchChanged,
          onTap: () {
            setState(() {
              _dropdownOpen = true;
            });
          },
          readOnly: !widget.enabled,
        ),
        if (_dropdownOpen && widget.enabled)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _filteredItems.isEmpty
                ? const ListTile(title: Text('No results'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return ListTile(
                        title: Text(widget.itemLabel(item)),
                        onTap: () => _onItemSelected(item),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
