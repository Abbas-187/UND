import 'package:flutter/material.dart';
import 'app_localizations.dart'; // Import AppLocalizations

/// Extension to add a safe getText method to AppLocalizations
extension AppLocalizationsExtension on AppLocalizations {
  /// Gets a localized string by key, or returns the key itself with formatting if the key is missing
  String getText(String key, [Map<String, dynamic>? args]) {
    try {
      // For messages with parameters, handle them separately
      if (args != null && args.isNotEmpty) {
        // This part is approximated, adjust based on your actual AppLocalizations implementation
        // For messages like 'errorLoadingItems'
        return key + ': ' + args.toString();
      }

      // For regular messages without parameters
      switch (key) {
        case 'inventoryList':
          return 'Inventory List';
        case 'addNewItem':
          return 'Add New Item';
        case 'noItemsFound':
          return 'No items found';
        case 'errorLoadingItems':
          return 'Error loading items';
        case 'searchInventory':
          return 'Search inventory...';
        case 'filterByCategory':
          return 'Category';
        case 'filterBySubCategory':
          return 'Sub-category';
        case 'filterByLocation':
          return 'Location';
        case 'filterBySupplier':
          return 'Supplier';
        case 'filterOptions':
          return 'Filter Options';
        case 'clearAllFilters':
          return 'Clear All';
        case 'lowStock':
          return 'Low Stock';
        case 'needsReorder':
          return 'Needs Reorder';
        case 'expiringSoonShort':
          return 'Expiring Soon';
        case 'clearSelection':
          return 'Clear selection';
        default:
          return key; // Return the key itself as fallback
      }
    } catch (e) {
      return key; // Return the key itself if anything goes wrong
    }
  }
}
