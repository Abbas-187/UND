import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track the currently selected route in the UI
/// This is used when all navigation is redirected to the HomeScreen
/// to show which "virtual screen" is currently selected
final selectedRouteProvider = StateProvider<String>((ref) => '/');
