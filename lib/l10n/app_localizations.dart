import 'package:flutter/material.dart';

class AppLocalizations {

  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(Locale('en'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'inventoryMovements': 'Inventory Movements',
      'oldestFirst': 'Oldest First',
      'newestFirst': 'Newest First',
      'filter': 'Filter',
      'searchMovements': 'Search movements...',
      'location': 'Location',
      'product': 'Product',
      'clearFilters': 'Clear Filters',
      'noMovementsMatchingFilters': 'No movements matching your filters',
      'noMovementsRecorded': 'No movements recorded yet',
      'errorLoadingMovements': 'Error loading movements',
      'retry': 'Retry',
      'newMovement': 'New Movement',
    },
    'ar': {
      'inventoryMovements': 'حركات المخزون',
      'oldestFirst': 'الأقدم أولاً',
      'newestFirst': 'الأحدث أولاً',
      'filter': 'تصفية',
      'searchMovements': 'البحث عن الحركات...',
      'location': 'الموقع',
      'product': 'المنتج',
      'clearFilters': 'مسح الفلاتر',
      'noMovementsMatchingFilters': 'لا توجد حركات مطابقة للفلاتر',
      'noMovementsRecorded': 'لم يتم تسجيل أي حركات بعد',
      'errorLoadingMovements': 'خطأ في تحميل الحركات',
      'retry': 'إعادة المحاولة',
      'newMovement': 'حركة جديدة',
    },
  };

  String get inventoryMovements =>
      _localizedValues[locale.languageCode]?['inventoryMovements'] ?? '';
  String get oldestFirst =>
      _localizedValues[locale.languageCode]?['oldestFirst'] ?? '';
  String get newestFirst =>
      _localizedValues[locale.languageCode]?['newestFirst'] ?? '';
  String get filter => _localizedValues[locale.languageCode]?['filter'] ?? '';
  String get searchMovements =>
      _localizedValues[locale.languageCode]?['searchMovements'] ?? '';
  String get location =>
      _localizedValues[locale.languageCode]?['location'] ?? '';
  String get product => _localizedValues[locale.languageCode]?['product'] ?? '';
  String get clearFilters =>
      _localizedValues[locale.languageCode]?['clearFilters'] ?? '';
  String get noMovementsMatchingFilters =>
      _localizedValues[locale.languageCode]?['noMovementsMatchingFilters'] ??
      '';
  String get noMovementsRecorded =>
      _localizedValues[locale.languageCode]?['noMovementsRecorded'] ?? '';
  String get errorLoadingMovements =>
      _localizedValues[locale.languageCode]?['errorLoadingMovements'] ?? '';
  String get retry => _localizedValues[locale.languageCode]?['retry'] ?? '';
  String get newMovement =>
      _localizedValues[locale.languageCode]?['newMovement'] ?? '';
}
