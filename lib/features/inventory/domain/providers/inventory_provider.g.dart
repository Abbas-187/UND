// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryFilter _$InventoryFilterFromJson(Map<String, dynamic> json) =>
    _InventoryFilter(
      searchQuery: json['search_query'] as String? ?? '',
      showLowStock: json['show_low_stock'] as bool? ?? false,
      showNeedsReorder: json['show_needs_reorder'] as bool? ?? false,
      showExpiringSoon: json['show_expiring_soon'] as bool? ?? false,
      selectedCategory: json['selected_category'] as String?,
      selectedLocation: json['selected_location'] as String?,
    );

Map<String, dynamic> _$InventoryFilterToJson(_InventoryFilter instance) =>
    <String, dynamic>{
      'search_query': instance.searchQuery,
      'show_low_stock': instance.showLowStock,
      'show_needs_reorder': instance.showNeedsReorder,
      'show_expiring_soon': instance.showExpiringSoon,
      'selected_category': instance.selectedCategory,
      'selected_location': instance.selectedLocation,
    };
