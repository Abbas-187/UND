import 'package:flutter/material.dart';
import '../providers/supplier_provider.dart';

class SupplierFilterBar extends StatefulWidget {
  final SupplierFilter filter;
  final Function(SupplierFilter) onFilterChanged;

  const SupplierFilterBar({
    Key? key,
    required this.filter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<SupplierFilterBar> createState() => _SupplierFilterBarState();
}

class _SupplierFilterBarState extends State<SupplierFilterBar> {
  late TextEditingController _searchController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filter.searchQuery);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final newFilter = widget.filter.copyWith(
      searchQuery: _searchController.text,
    );
    widget.onFilterChanged(newFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search suppliers',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.filter_list),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ],
          ),
        ),
        if (_isExpanded) _buildFilterOptions(),
      ],
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active/Inactive filter
          Row(
            children: [
              Text(
                'Status:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('All'),
                selected: widget.filter.isActive == null,
                onSelected: (selected) {
                  if (selected) {
                    final newFilter = widget.filter.copyWith(isActive: null);
                    widget.onFilterChanged(newFilter);
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Active'),
                selected: widget.filter.isActive == true,
                onSelected: (selected) {
                  if (selected) {
                    final newFilter = widget.filter.copyWith(isActive: true);
                    widget.onFilterChanged(newFilter);
                  }
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Inactive'),
                selected: widget.filter.isActive == false,
                onSelected: (selected) {
                  if (selected) {
                    final newFilter = widget.filter.copyWith(isActive: false);
                    widget.onFilterChanged(newFilter);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rating filter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Min Rating: ${widget.filter.minRating?.toStringAsFixed(1) ?? "0.0"}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: widget.filter.minRating ?? 0.0,
                min: 0,
                max: 5,
                divisions: 10,
                label: (widget.filter.minRating ?? 0.0).toStringAsFixed(1),
                onChanged: (value) {
                  final newFilter = widget.filter.copyWith(minRating: value);
                  widget.onFilterChanged(newFilter);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Categories filter (simplified for now)
          Text(
            'Categories:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildCategoryChip('Produce'),
              _buildCategoryChip('Dairy'),
              _buildCategoryChip('Meat'),
              _buildCategoryChip('Bakery'),
              _buildCategoryChip('Beverages'),
              _buildCategoryChip('Cleaning'),
            ],
          ),

          const SizedBox(height: 16),

          // Reset button
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                _searchController.text = '';
                widget.onFilterChanged(SupplierFilter());
              },
              child: const Text('Reset Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected =
        widget.filter.selectedCategories?.contains(category) ?? false;

    return FilterChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        final currentCategories =
            List<String>.from(widget.filter.selectedCategories ?? []);

        if (selected) {
          currentCategories.add(category);
        } else {
          currentCategories.remove(category);
        }

        final newFilter =
            widget.filter.copyWith(selectedCategories: currentCategories);
        widget.onFilterChanged(newFilter);
      },
    );
  }
}
