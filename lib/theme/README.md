# App Theme System

This directory contains the theming system for the application. It provides a consistent look and feel across the app, with support for both light and dark themes.

## Files

- `app_colors.dart` - Contains all color constants used in the app
- `app_theme.dart` - Main theme configuration with Material Theme setup
- `app_theme_extensions.dart` - Custom theme extensions for specialized components

## Using the Theme

### Basic Usage

In your `main.dart` or where you setup the app:

```dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme(const Locale('en')),
      darkTheme: AppTheme.darkTheme(const Locale('en')),
      themeMode: ThemeMode.system, // or ThemeMode.light/dark
      // ...
    );
  }
}
```

### Using Theme Extensions

Theme extensions provide specialized styling for status-based components (success, warning, information) and custom buttons.

```dart
// Access status colors
final statusColors = Theme.of(context).extension<StatusColors>();
Container(
  color: statusColors?.success, // Success background
  child: Text(
    'Success Message',
    style: TextStyle(color: statusColors?.onSuccess),
  ),
);

// Use custom button styles
final buttonStyles = Theme.of(context).extension<CustomButtonStyles>();
ElevatedButton(
  style: buttonStyles?.successButton,
  onPressed: () {},
  child: Text('Success Action'),
)
```

## Language Support

The theme system automatically selects appropriate fonts based on the app's locale:
- Arabic: Noto Sans Arabic
- Hindi: Noto Sans Devanagari
- Others: Noto Sans

## Customization

To customize theme elements:

1. Update colors in `app_colors.dart`
2. Modify theme settings in `app_theme.dart`
3. Add additional theme extensions in `app_theme_extensions.dart` 