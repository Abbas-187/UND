import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_filter.freezed.dart';
part 'inventory_filter.g.dart';

@freezed
abstract class InventoryFilter with _$InventoryFilter {
  const factory InventoryFilter({
    @Default('') String searchQuery,
    @Default(false) bool showLowStock,
    @Default(false) bool showNeedsReorder,
    @Default(false) bool showExpiringSoon,
    String? selectedCategory,
    String? selectedLocation,
  }) = _InventoryFilter;

  factory InventoryFilter.fromJson(Map<String, dynamic> json) =>
      _$InventoryFilterFromJson(json);
}
