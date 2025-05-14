import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track the screen title of the currently selected route
final selectedScreenTitleProvider = StateProvider<String>((ref) => 'Home');
