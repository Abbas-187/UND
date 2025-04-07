# UI/UX Implementation Guidelines

## 1. Screen Structure
```dart
// Typical screen structure
Scaffold(
  appBar: AppBar(
    title: Text('Screen Title'),
    actions: [/* Common actions */],
  ),
  body: Column/Row/ListView(
    children: [
      // Screen content organized in widgets
    ],
  ),
  floatingActionButton: /* Optional FAB */,
)
```

## 2. State Management Integration
```dart
// Riverpod consumer widget example
Consumer(
  builder: (context, ref, child) {
    final state = ref.watch(provider);
    return /* UI based on state */;
  }
)
```

## 3. Theming System
```dart
// Theme access in widgets
Theme.of(context).colorScheme.primary
Theme.of(context).textTheme.headlineSmall
```

## 4. Responsive Design
```dart
// Responsive layout example
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return _wideLayout();
    } else {
      return _narrowLayout();
    }
  }
)
```

## 5. Common UI Patterns

### Lists with filtering:
```dart
Column(
  children: [
    SearchBar(onChanged: (query) => ref.read(filterProvider.notifier).updateSearch(query)),
    Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(items[index].name),
          subtitle: Text(items[index].description),
        ),
      ),
    ),
  ],
)
```

### Form Validation:
```dart
final formKey = GlobalKey<FormState>();

Form(
  key: formKey,
  child: Column(
    children: [
      TextFormField(
        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
      ),
      ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            // Submit form
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

## 6. Animation Guidelines
```dart
// Basic animation example
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: _expanded ? 200 : 100,
)
```

## 7. Accessibility Features
```dart
// Accessible widgets
Semantics(
  label: 'Important button',
  child: IconButton(
    onPressed: () {},
    icon: Icon(Icons.important),
  ),
)
```

## 8. Internationalization
```dart
// Localized text
Text(AppLocalizations.of(context)!.welcomeMessage)
```

## 9. UI Component Library

| Component       | Usage Guidelines                          | Code Reference           |
|-----------------|-------------------------------------------|--------------------------|
| AppButton       | Primary actions, max width 300px         | `lib/common/widgets/button.dart` |
| DataTable       | Tabular data presentation                 | Flutter Material         |
| SearchBar       | Filtering with debounce                   | `lib/common/widgets/search.dart` |

## 10. Screen States Documentation

```dart
// State handling example
if (state.isLoading) {
  return Center(child: CircularProgressIndicator());
} else if (state.hasError) {
  return ErrorView(onRetry: () => ref.refresh(provider));
} else {
  return _contentView(state.data);
}
```

## 11. Navigation Flow
```dart
// Navigation example
Navigator.pushNamed(context, '/supplier/details', arguments: supplierId);
```

## 12. Design Tokens

```dart
// Design constants
class AppDimens {
  static const cardPadding = 16.0;
  static const buttonHeight = 48.0;
  static const mobileBreakpoint = 600.0;
}
```

## 13. UI Testing Guidelines
```dart
testWidgets('Should show loading indicator', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [provider.overrideWithValue(LoadingState())],
      child: MaterialApp(home: SupplierScreen()),
    ),
  );
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## 14. Performance Considerations
- Use `const` widgets where possible
- Implement lazy loading for long lists
- Use `AutomaticKeepAliveClientMixin` for state preservation
- Optimize rebuilds with `Provider.select()`
