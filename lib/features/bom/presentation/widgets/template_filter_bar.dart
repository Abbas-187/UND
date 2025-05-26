import 'package:flutter/material.dart';
import '../../domain/entities/bom_template.dart';

class TemplateFilterBar extends StatelessWidget {

  const TemplateFilterBar({
    super.key,
    required this.selectedCategory,
    required this.selectedComplexity,
    required this.selectedTags,
    required this.showOnlyPublic,
    required this.showOnlyMine,
    required this.onCategoryChanged,
    required this.onComplexityChanged,
    required this.onTagsChanged,
    required this.onPublicToggled,
    required this.onMineToggled,
  });
  final TemplateCategory? selectedCategory;
  final TemplateComplexity? selectedComplexity;
  final List<String> selectedTags;
  final bool showOnlyPublic;
  final bool showOnlyMine;
  final Function(TemplateCategory?) onCategoryChanged;
  final Function(TemplateComplexity?) onComplexityChanged;
  final Function(List<String>) onTagsChanged;
  final Function(bool) onPublicToggled;
  final Function(bool) onMineToggled;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Category Filter
          _buildCategoryFilter(context),
          const SizedBox(width: 12),

          // Complexity Filter
          _buildComplexityFilter(context),
          const SizedBox(width: 12),

          // Visibility Filters
          _buildVisibilityFilters(context),
          const SizedBox(width: 12),

          // Clear Filters
          if (_hasActiveFilters()) _buildClearFiltersButton(context),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return PopupMenuButton<TemplateCategory?>(
      itemBuilder: (context) => [
        const PopupMenuItem<TemplateCategory?>(
          value: null,
          child: Text('All Categories'),
        ),
        ...TemplateCategory.values.map(
          (category) => PopupMenuItem<TemplateCategory?>(
            value: category,
            child: Text(_formatCategoryName(category)),
          ),
        ),
      ],
      onSelected: onCategoryChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedCategory != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(20),
          color: selectedCategory != null
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category,
              size: 16,
              color: selectedCategory != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              selectedCategory?.name.toUpperCase() ?? 'CATEGORY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selectedCategory != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: selectedCategory != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplexityFilter(BuildContext context) {
    return PopupMenuButton<TemplateComplexity?>(
      itemBuilder: (context) => [
        const PopupMenuItem<TemplateComplexity?>(
          value: null,
          child: Text('All Complexities'),
        ),
        ...TemplateComplexity.values.map(
          (complexity) => PopupMenuItem<TemplateComplexity?>(
            value: complexity,
            child: Text(_formatComplexityName(complexity)),
          ),
        ),
      ],
      onSelected: onComplexityChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedComplexity != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(20),
          color: selectedComplexity != null
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.speed,
              size: 16,
              color: selectedComplexity != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              selectedComplexity?.name.toUpperCase() ?? 'COMPLEXITY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selectedComplexity != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: selectedComplexity != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityFilters(BuildContext context) {
    return Row(
      children: [
        // Public Templates Filter
        FilterChip(
          label: const Text('Public'),
          selected: showOnlyPublic,
          onSelected: onPublicToggled,
          avatar: Icon(
            Icons.public,
            size: 16,
            color: showOnlyPublic
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
        ),
        const SizedBox(width: 8),

        // My Templates Filter
        FilterChip(
          label: const Text('Mine'),
          selected: showOnlyMine,
          onSelected: onMineToggled,
          avatar: Icon(
            Icons.person,
            size: 16,
            color: showOnlyMine
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ],
    );
  }

  Widget _buildClearFiltersButton(BuildContext context) {
    return TextButton.icon(
      onPressed: _clearAllFilters,
      icon: const Icon(Icons.clear_all, size: 16),
      label: const Text('Clear'),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  bool _hasActiveFilters() {
    return selectedCategory != null ||
        selectedComplexity != null ||
        selectedTags.isNotEmpty ||
        showOnlyPublic ||
        showOnlyMine;
  }

  void _clearAllFilters() {
    onCategoryChanged(null);
    onComplexityChanged(null);
    onTagsChanged([]);
    onPublicToggled(false);
    onMineToggled(false);
  }

  String _formatCategoryName(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.dairy:
        return 'Dairy';
      case TemplateCategory.packaging:
        return 'Packaging';
      case TemplateCategory.processing:
        return 'Processing';
      case TemplateCategory.quality:
        return 'Quality';
      case TemplateCategory.maintenance:
        return 'Maintenance';
      case TemplateCategory.custom:
        return 'Custom';
    }
  }

  String _formatComplexityName(TemplateComplexity complexity) {
    switch (complexity) {
      case TemplateComplexity.simple:
        return 'Simple';
      case TemplateComplexity.intermediate:
        return 'Intermediate';
      case TemplateComplexity.advanced:
        return 'Advanced';
      case TemplateComplexity.expert:
        return 'Expert';
    }
  }
}
