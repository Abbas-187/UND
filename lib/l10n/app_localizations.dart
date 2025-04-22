import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
      'settings': 'Settings',
      'language': 'Language',
      'notifications': 'Notifications',
      'appearance': 'Appearance',
      'pushNotifications': 'Push Notifications',
      'receivePushNotifications': 'Receive push notifications',
      'emailNotifications': 'Email Notifications',
      'receiveEmailNotifications': 'Receive email notifications',
      'darkMode': 'Dark Mode',
      'enableDarkMode': 'Enable dark mode',
      // Home screen and modules
      'welcomeToUndManager': 'Welcome to UND App',
      'dairyManagementSolution': 'Your comprehensive dairy management solution',
      'modules': 'Modules',
      'screens': 'Screens',
      'noScreensAvailable': 'No screens available in this module',
      'close': 'Close',
      // Module names
      'inventory': 'Inventory',
      'factory': 'Factory',
      'milkReception': 'Milk Reception',
      'procurement': 'Procurement',
      'analytics': 'Analytics',
      'forecasting': 'Forecasting',
      // Screen names - Inventory
      'inventoryDashboard': 'Inventory Dashboard',
      'inventoryAlerts': 'Inventory Alerts',
      'inventoryMovementsScreen': 'Inventory Movements',
      'createMovement': 'Create Movement',
      'inventoryBatchScanner': 'Batch Scanner',
      // Screen names - Factory
      'productionExecutions': 'Production Executions',
      'createProductionExecution': 'Create Production Execution',
      'equipmentMaintenance': 'Equipment Maintenance',
      'createMaintenanceRecord': 'Create Maintenance Record',
      // Screen names - Milk Reception
      'milkReceptionScreen': 'Milk Reception',
      'milkQualityTests': 'Quality Tests',
      // Screen names - Procurement
      'purchaseOrders': 'Purchase Orders',
      'createPurchaseOrder': 'Create Purchase Order',
      'suppliers': 'Suppliers',
      // Screen names - Analytics
      'analyticsDashboard': 'Analytics Dashboard',
      // Screen names - Forecasting
      'forecastingList': 'Forecasting List',
      'forecastingCreate': 'Create Forecast',
      'forecastingDashboard': 'Forecasting Dashboard',
      // Screen descriptions - Inventory
      'inventoryDashboardDesc': 'Overview of inventory status and metrics',
      'inventoryAlertsDesc': 'Low stock and expiry alerts for inventory items',
      'inventoryMovementsDesc': 'Track and manage inventory movements',
      'createMovementDesc': 'Create a new inventory movement',
      'inventoryBatchScannerDesc': 'Scan barcodes to track inventory batches',
      'inventorySettingsDesc': 'Configure inventory management settings',
      // Screen descriptions - Factory
      'productionExecutionsDesc': 'Manage production runs and processes',
      'createProductionExecutionDesc': 'Schedule a new production execution',
      'equipmentMaintenanceDesc': 'Track and schedule equipment maintenance',
      'createMaintenanceRecordDesc': 'Add a new maintenance record',
      // Screen descriptions - Milk Reception
      'milkReceptionDesc': 'Manage milk reception from suppliers',
      'milkQualityTestsDesc': 'Track quality tests for received milk',
      // Screen descriptions - Procurement
      'purchaseOrdersDesc': 'Manage purchase orders',
      'createPurchaseOrderDesc': 'Create a new purchase order',
      'suppliersDesc': 'Manage supplier information',
      // Screen descriptions - Analytics
      'analyticsDashboardDesc': 'Business intelligence and analytics',
      // Screen descriptions - Forecasting
      'forecastingDesc': 'View all forecasts',
      'forecastingCreateDesc': 'Create a new forecast',
      'forecastingDashboardDesc': 'Forecast metrics and analysis',
      // Movement history screen
      'movementHistory': 'Movement History',
      'itemMovementHistory': '{itemName} - Movement History',
      'category': 'Category',
      'currentStock': 'Current Stock',
      'totalIn': 'Total In',
      'totalOut': 'Total Out',
      'netChange': 'Net Change',
      'movementsRecorded': '{count} movements recorded',
      'noMovementHistoryAvailable': 'No movement history available',
      'errorLoadingData': 'Error loading data: {error}',
      'error': 'Error: {error}',
      'stockAdded': 'Stock Added',
      'stockRemoved': 'Stock Removed',
      'reason': 'Reason: {reason}',
      'date': 'Date: {datetime}',
      // Movement details page
      'movementDetails': 'Movement Details',
      'generatePdf': 'Generate PDF',
      'share': 'Share',
      'errorLoadingMovementDetails': 'Error loading movement details',
      'id': 'ID: {id}',
      'locations': 'Locations',
      'source': 'Source:',
      'destination': 'Destination:',
      'notAvailable': 'N/A',
      'personnel': 'Personnel',
      'initiatedBy': 'Initiated by:',
      'reviewedBy': 'Reviewed by:',
      'notes': 'Notes',
      'referenceDocuments': 'Reference Documents',
      'itemsSingular': 'Items (1 item)',
      'itemsPlural': 'Items ({count} items)',
      'batch': 'Batch: {batch}',
      'production': 'Production: {date}',
      'expiration': 'Expiration: {date}',
      'approve': 'Approve',
      'reject': 'Reject',
      // Movement approval dialog
      'approveMovement': 'Approve Movement',
      'rejectMovement': 'Reject Movement',
      'aboutToApprove': 'You are about to approve movement {id}.',
      'aboutToReject': 'You are about to reject movement {id}.',
      'approverId': 'Approver ID',
      'approverIdRequired': 'Approver ID is required',
      'approverName': 'Approver Name',
      'approverNameRequired': 'Approver name is required',
      'additionalNotes': 'Additional Notes (Optional)',
      'rejectionReason': 'Reason for Rejection',
      'provideRejectionReason': 'Please provide a reason for rejection',
      'cancel': 'Cancel',
      'movementSuccessfullyApproved': 'Movement successfully approved',
      'movementSuccessfullyRejected': 'Movement successfully rejected',
      // Inventory Dashboard
      'inventoryManagement': 'Inventory Management',
      'monitorAndManageInventory':
          'Monitor and manage your inventory movements',
      'recentMovements': 'Recent Movements',
      'viewAll': 'View All',
      'noRecentMovements': 'No recent movements',
      'pendingApprovals': 'Pending Approvals',
      'criticalMovements': 'Critical Movements',
      'movementTrends': 'Movement Trends',
      'viewAllMovements': 'View All Movements',
      'refreshData': 'Refresh Data',
      'pending': 'Pending',
      'approved': 'Approved',
      'rejected': 'Rejected',
      'unknown': 'Unknown',
      'review': 'Review',
      'reviewItems': 'Review Items',

      // Inventory Transfer
      'addItems': 'Add Items',
      'reviewAndSubmit': 'Review & Submit',
      'save': 'SAVE',
      'adjust': 'ADJUST',
      'removeItems': 'Remove Items',
      'addAttribute': 'Add Attribute',
      'add': 'ADD',

      // Units
      'kilogram': 'kg',
      'piece': 'pc',
      'box': 'box',

      // Batch scanner
      'bothBarcodeAndQr': 'Both Barcode & QR',
      'addedItem': 'Added item {itemId} to batch',

      // Inventory Analytics Dashboard
      'inventoryAnalyticsDashboard': 'Inventory Analytics',
      'valueByCategory': 'Value by Category',
      'topMovingItems': 'Top Moving Items',
      'slowMovingItems': 'Slow Moving Items',
      'inventoryTrends': 'Inventory Trends',
      'inventoryHealth': 'Inventory Health',
      'lowStockItems': 'Low Stock Items',
      'expiringItems': 'Expiring Items',
      'itemsToReorder': 'Items to Reorder',
      'stockLevels': 'Stock Levels',
      'seeDetails': 'See Details',
      'currencySymbol': '﷼',
      'outOfStock': 'Out of Stock',
      'unitsPerMonth': 'Units/Month',
      'showMore': 'Show more',
      'noItemsFound': 'No items found',
      'deleteItem': 'Delete Item',
      'confirmDeletion': 'Confirm Deletion',
      'confirmDeleteItem': 'Are you sure you want to delete {itemName}?',

      // Inventory Reports Screen
      'inventoryReports': 'Inventory Reports',
      'generateReport': 'Generate Report',
      'reportType': 'Report Type',
      'movementReport': 'Movement Report',
      'valuationReport': 'Valuation Report',
      'stockLevelReport': 'Stock Level Report',
      'expiryReport': 'Expiry Report',
      'locationReport': 'Location Report',
      'dateRange': 'Date Range',
      'selectStartDate': 'Select Start Date',
      'selectEndDate': 'Select End Date',
      'reportFormat': 'Report Format',
      'downloadAsPdf': 'Download as PDF',
      'downloadAsExcel': 'Download as Excel',
      'shareReport': 'Share Report',
      'reportOptions': 'Report Options',
      'includeImages': 'Include Images',
      'includeCharts': 'Include Charts',
      'includeDetails': 'Include Details',
      'selectLocations': 'Select Locations',
      'selectCategories': 'Select Categories',
      'reportCreated': 'Report created successfully',

      // Filter dialog strings
      'filterAdjustments': 'Filter Adjustments',
      'startDate': 'Start Date',
      'endDate': 'End Date',
      'any': 'Any',
      'adjustmentTypeLabel': 'Adjustment Type',
      'allTypes': 'All Types',
      'statusLabel': 'Status',
      'allStatuses': 'All Statuses',
      'itemAndCategory': 'Item and Category',
      'itemId': 'Item ID',
      'categoryId': 'Category ID',
      'clearAll': 'Clear All',
      'applyFilters': 'Apply Filters',
      'pendingApproval': 'Pending Approval',

      // Adjustment details strings
      'previousStock': 'Previous Quantity',
      'adjustedStock': 'Adjusted Quantity',
      'reasonNotes': 'Reason and Notes',
      'performedBy': 'Performed By',
      'approvedDate': 'Approved On',
      'additionalInfo': 'Additional Information',

      // Adjustment statistics strings
      'adjustmentsByType': 'Adjustments by Type',
      'quantityByType': 'Quantity by Type',
      'units': 'units',

      // Inventory Settings Screen
      'inventorySettings': 'Inventory Settings',
      'generalSettings': 'General Settings',
      'defaultUnit': 'Default Unit',
      'defaultLocation': 'Default Location',
      'lowStockThreshold': 'Low Stock Threshold',
      'reorderSettings': 'Reorder Settings',
      'automaticReorder': 'Automatic Reorder',
      'reorderMethod': 'Reorder Method',
      'fixedReorderPoint': 'Fixed Reorder Point',
      'dynamicReorderPoint': 'Dynamic Reorder Point',
      'notificationSettings': 'Notification Settings',
      'lowStockNotifications': 'Low Stock Notifications',
      'expiryNotifications': 'Expiry Notifications',
      'expiryNotificationDays': 'Expiry Notification Days',
      'scanningSettings': 'Scanning Settings',
      'defaultScanType': 'Default Scan Type',
      'barcode': 'Barcode',
      'qrCode': 'QR Code',
      'autoGenerateBarcodes': 'Auto-generate Barcodes',
      'saveSettings': 'Save Settings',
      'settingsSaved': 'Settings saved successfully',

      // Inventory Adjustment History screen
      'inventoryAdjustmentHistory': 'Inventory Adjustment History',
      'refresh': 'Refresh',
      'searchAdjustments': 'Search Adjustments',
      'noAdjustmentsFound': 'No adjustments found',
      'createAdjustment': 'Create Adjustment',
      'adjustmentApprovedSuccessfully': 'Adjustment approved successfully',
      'adjustmentRejectedSuccessfully': 'Adjustment rejected successfully',
      'createAdjustmentNotImplemented': 'Create Adjustment not implemented',
      'from': 'From {date}',
      'to': 'To {date}',
      'type': 'Type: {type}',
      'status': 'Status: {status}',

      // Language Settings
      'languageSettings': 'Language Settings',
      'themeSettings': 'Theme Settings',
      'enableNotifications': 'Enable Notifications',
      'enableSounds': 'Enable Sounds',
      'enableVibration': 'Enable Vibration',
      'lightTheme': 'Light Theme',
      'darkTheme': 'Dark Theme',
      'systemTheme': 'System Default Theme',
      'themeSettingsSave': 'Save Settings',
      'themeSettingsSaved': 'Settings saved successfully',
      'moduleSettings': 'Module Settings',

      // Inventory details screen
      'item_category': 'Category',
      'item_minimumQuantity': 'Minimum Quantity',
      'item_reorderPoint': 'Reorder Point',
      'item_batchNumber': 'Batch Number',
      'item_expiryDate': 'Expiry Date',
      'item_lastUpdated': 'Last Updated',
      'item_statusAlerts': 'Status Alerts',
      'item_lowStockAlert': 'Low Stock',
      'item_lowStockDescription': 'Current quantity is below minimum level',
      'item_reorderNeeded': 'Reorder Needed',
      'item_reorderNeededDescription':
          'Current quantity is below reorder point',
      'item_expiringSoon': 'Expiring Soon',
      'item_expiringSoonDescription': 'Item will expire in {days} days',
      'item_additionalAttributes': 'Additional Attributes',
      'item_notFound': 'Item not found',
      'item_details': 'Item Details',

      // Inventory item card
      'item_expires': 'Expires',

      // Inventory analytics card
      'inventory_analytics': 'Inventory Analytics',

      // Create movement page
      'movement_from': 'From',
      'movement_to': 'To',
      'movement_items': 'Items',
      'movement_itemCount': '{count} {count, plural, one{item} other{items}}',
      'movement_noItemsAdded': 'No items added to this movement',

      // Inventory Alerts Screen
      'filterAlerts': 'Filter Alerts',
      'showHighPriority': 'Show High Priority',
      'showMediumPriority': 'Show Medium Priority',
      'showLowPriority': 'Show Low Priority',
      'lowStock': 'Low Stock',
      'expiredItems': 'Expired Items',
      'expiringSoon': 'Expiring Soon',
      'showAcknowledged': 'Show Acknowledged',
      'apply': 'Apply',
      'high': 'High',
      'medium': 'Medium',
      'low': 'Low',
      'total': 'Total',
      'refreshingAlerts': 'Refreshing alerts...',
      'alertAcknowledged': 'Alert {id} acknowledged',
      'viewingDetailsFor': 'Viewing details for {itemName}',
      'noAlertsAtThisTime': 'No alerts at this time.',
      'acknowledge': 'Acknowledge',
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
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'notifications': 'الإشعارات',
      'appearance': 'المظهر',
      'pushNotifications': 'الإشعارات الفورية',
      'receivePushNotifications': 'تلقي الإشعارات الفورية',
      'emailNotifications': 'إشعارات البريد الإلكتروني',
      'receiveEmailNotifications': 'تلقي إشعارات البريد الإلكتروني',
      'darkMode': 'الوضع الداكن',
      'enableDarkMode': 'تفعيل الوضع الداكن',
      // Home screen and modules
      'welcomeToUndManager': 'مرحبًا بك في مدير UND',
      'dairyManagementSolution': 'حل شامل لإدارة منتجات الألبان',
      'modules': 'الوحدات',
      'screens': 'الشاشات',
      'noScreensAvailable': 'لا توجد شاشات متاحة في هذه الوحدة',
      'close': 'إغلاق',
      // Module names
      'inventory': 'المخزون',
      'factory': 'المصنع',
      'milkReception': 'استقبال الحليب',
      'procurement': 'المشتريات',
      'analytics': 'التحليلات',
      'forecasting': 'التنبؤ',
      // Screen names - Inventory
      'inventoryDashboard': 'لوحة معلومات المخزون',
      'inventoryAlerts': 'تنبيهات المخزون',
      'inventoryMovementsScreen': 'حركات المخزون',
      'createMovement': 'إنشاء حركة',
      'inventoryBatchScanner': 'ماسح الباركود',
      // Screen names - Factory
      'productionExecutions': 'تنفيذ الإنتاج',
      'createProductionExecution': 'إنشاء تنفيذ إنتاج',
      'equipmentMaintenance': 'صيانة المعدات',
      'createMaintenanceRecord': 'إنشاء سجل صيانة',
      // Screen names - Milk Reception
      'milkReceptionScreen': 'استقبال الحليب',
      'milkQualityTests': 'اختبارات جودة الحليب',
      // Screen names - Procurement
      'purchaseOrders': 'طلبات الشراء',
      'createPurchaseOrder': 'إنشاء طلب شراء',
      'suppliers': 'الموردين',
      // Screen names - Analytics
      'analyticsDashboard': 'لوحة معلومات التحليلات',
      // Screen names - Forecasting
      'forecastingList': 'قائمة التنبؤات',
      'forecastingCreate': 'إنشاء تنبؤ',
      'forecastingDashboard': 'لوحة معلومات التنبؤ',
      // Screen descriptions - Inventory
      'inventoryDashboardDesc': 'نظرة عامة على حالة المخزون والمقاييس',
      'inventoryAlertsDesc': 'تنبيهات المخزون المنخفض وتواريخ انتهاء الصلاحية',
      'inventoryMovementsDesc': 'تتبع وإدارة حركات المخزون',
      'createMovementDesc': 'إنشاء حركة مخزون جديدة',
      'inventoryBatchScannerDesc': 'مسح الرموز الشريطية لتتبع دفعات المخزون',
      'inventorySettingsDesc': 'تكوين إعدادات إدارة المخزون',
      // Screen descriptions - Factory
      'productionExecutionsDesc': 'إدارة دورات وعمليات الإنتاج',
      'createProductionExecutionDesc': 'جدولة تنفيذ إنتاج جديد',
      'equipmentMaintenanceDesc': 'تتبع وجدولة صيانة المعدات',
      'createMaintenanceRecordDesc': 'إضافة سجل صيانة جديد',
      // Screen descriptions - Milk Reception
      'milkReceptionDesc': 'إدارة استلام الحليب من الموردين',
      'milkQualityTestsDesc': 'تتبع اختبارات الجودة للحليب المستلم',
      // Screen descriptions - Procurement
      'purchaseOrdersDesc': 'إدارة طلبات الشراء',
      'createPurchaseOrderDesc': 'إنشاء طلب شراء جديد',
      'suppliersDesc': 'إدارة معلومات الموردين',
      // Screen descriptions - Analytics
      'analyticsDashboardDesc': 'ذكاء الأعمال والتحليلات',
      // Screen descriptions - Forecasting
      'forecastingDesc': 'عرض جميع التنبؤات',
      'forecastingCreateDesc': 'إنشاء تنبؤ جديد',
      'forecastingDashboardDesc': 'مقاييس وتحليل التنبؤ',
      // Movement history screen
      'movementHistory': 'سجل الحركة',
      'itemMovementHistory': '{itemName} - سجل الحركة',
      'category': 'الفئة',
      'currentStock': 'المخزون الحالي',
      'totalIn': 'إجمالي الوارد',
      'totalOut': 'إجمالي الصادر',
      'netChange': 'صافي التغيير',
      'movementsRecorded': '{count} حركات مسجلة',
      'noMovementHistoryAvailable': 'لا يوجد سجل حركة متاح',
      'errorLoadingData': 'خطأ في تحميل البيانات: {error}',
      'error': 'خطأ: {error}',
      'stockAdded': 'تمت إضافة المخزون',
      'stockRemoved': 'تمت إزالة المخزون',
      'reason': 'السبب: {reason}',
      'date': 'التاريخ: {datetime}',
      // Movement details page
      'movementDetails': 'تفاصيل الحركة',
      'generatePdf': 'إنشاء PDF',
      'share': 'مشاركة',
      'errorLoadingMovementDetails': 'خطأ في تحميل تفاصيل الحركة',
      'id': 'المعرف: {id}',
      'locations': 'المواقع',
      'source': 'المصدر:',
      'destination': 'الوجهة:',
      'notAvailable': 'غير متوفر',
      'personnel': 'الموظفون',
      'initiatedBy': 'بدأ بواسطة:',
      'reviewedBy': 'تمت المراجعة بواسطة:',
      'notes': 'ملاحظات',
      'referenceDocuments': 'المستندات المرجعية',
      'itemsSingular': 'العناصر (عنصر واحد)',
      'itemsPlural': 'العناصر ({count} عناصر)',
      'batch': 'الدفعة: {batch}',
      'production': 'الإنتاج: {date}',
      'expiration': 'انتهاء الصلاحية: {date}',
      'approve': 'موافقة',
      'reject': 'رفض',
      // Movement approval dialog
      'approveMovement': 'الموافقة على الحركة',
      'rejectMovement': 'رفض الحركة',
      'aboutToApprove': 'أنت على وشك الموافقة على الحركة {id}.',
      'aboutToReject': 'أنت على وشك رفض الحركة {id}.',
      'approverId': 'معرف المعتمد',
      'approverIdRequired': 'معرف المعتمد مطلوب',
      'approverName': 'اسم المعتمد',
      'approverNameRequired': 'اسم المعتمد مطلوب',
      'additionalNotes': 'ملاحظات إضافية (اختياري)',
      'rejectionReason': 'سبب الرفض',
      'provideRejectionReason': 'يرجى تقديم سبب للرفض',
      'cancel': 'إلغاء',
      'movementSuccessfullyApproved': 'تمت الموافقة على الحركة بنجاح',
      'movementSuccessfullyRejected': 'تم رفض الحركة بنجاح',
      // Inventory Dashboard
      'inventoryManagement': 'إدارة المخزون',
      'monitorAndManageInventory': 'مراقبة وإدارة حركات المخزون',
      'recentMovements': 'الحركات الأخيرة',
      'viewAll': 'عرض الكل',
      'noRecentMovements': 'لا توجد حركات حديثة',
      'pendingApprovals': 'موافقات معلقة',
      'criticalMovements': 'حركات حرجة',
      'movementTrends': 'اتجاهات الحركة',
      'viewAllMovements': 'عرض جميع الحركات',
      'refreshData': 'تحديث البيانات',
      'pending': 'معلق',
      'approved': 'تمت الموافقة',
      'rejected': 'مرفوض',
      'unknown': 'غير معروف',
      'review': 'مراجعة',
      'reviewItems': 'مراجعة العناصر',

      // Inventory Transfer
      'addItems': 'إضافة عناصر',
      'reviewAndSubmit': 'مراجعة وإرسال',
      'save': 'حفظ',
      'adjust': 'تعديل',
      'removeItems': 'إزالة العناصر',
      'addAttribute': 'إضافة سمة',
      'add': 'إضافة',

      // Units
      'kilogram': 'كغم',
      'piece': 'قطعة',
      'box': 'صندوق',

      // Batch scanner
      'bothBarcodeAndQr': 'الباركود و QR معًا',
      'addedItem': 'تمت إضافة العنصر {itemId} إلى الدفعة',

      // Inventory Analytics Dashboard
      'inventoryAnalyticsDashboard': 'تحليلات المخزون',
      'valueByCategory': 'القيمة حسب الفئة',
      'topMovingItems': 'العناصر الأكثر حركة',
      'slowMovingItems': 'العناصر بطيئة الحركة',
      'inventoryTrends': 'اتجاهات المخزون',
      'inventoryHealth': 'صحة المخزون',
      'lowStockItems': 'العناصر منخفضة المخزون',
      'expiringItems': 'العناصر التي تنتهي صلاحيتها',
      'itemsToReorder': 'العناصر التي يجب إعادة طلبها',
      'stockLevels': 'مستويات المخزون',
      'seeDetails': 'عرض التفاصيل',
      'currencySymbol': 'ر.س',
      'outOfStock': 'نفذت الكمية',
      'unitsPerMonth': 'وحدة/شهر',
      'showMore': 'عرض المزيد',
      'noItemsFound': 'لم يتم العثور على أي عناصر',
      'deleteItem': 'حذف العنصر',
      'confirmDeletion': 'تأكيد الحذف',
      'confirmDeleteItem': 'هل أنت متأكد أنك تريد حذف {itemName}؟',

      // Inventory Reports Screen
      'inventoryReports': 'تقارير المخزون',
      'generateReport': 'إنشاء تقرير',
      'reportType': 'نوع التقرير',
      'movementReport': 'تقرير الحركة',
      'valuationReport': 'تقرير التقييم',
      'stockLevelReport': 'تقرير مستوى المخزون',
      'expiryReport': 'تقرير انتهاء الصلاحية',
      'locationReport': 'تقرير الموقع',
      'dateRange': 'النطاق الزمني',
      'selectStartDate': 'اختر تاريخ البداية',
      'selectEndDate': 'اختر تاريخ النهاية',
      'reportFormat': 'تنسيق التقرير',
      'downloadAsPdf': 'تنزيل كملف PDF',
      'downloadAsExcel': 'تنزيل كملف Excel',
      'shareReport': 'مشاركة التقرير',
      'reportOptions': 'خيارات التقرير',
      'includeImages': 'تضمين الصور',
      'includeCharts': 'تضمين الرسوم البيانية',
      'includeDetails': 'تضمين التفاصيل',
      'selectLocations': 'اختر المواقع',
      'selectCategories': 'اختر الفئات',
      'reportCreated': 'تم إنشاء التقرير بنجاح',

      // Inventory Settings Screen
      'inventorySettings': 'إعدادات المخزون',
      'generalSettings': 'الإعدادات العامة',
      'defaultUnit': 'الوحدة الافتراضية',
      'defaultLocation': 'الموقع الافتراضي',
      'lowStockThreshold': 'حد المخزون المنخفض',
      'reorderSettings': 'إعدادات إعادة الطلب',
      'automaticReorder': 'إعادة الطلب التلقائي',
      'reorderMethod': 'طريقة إعادة الطلب',
      'fixedReorderPoint': 'نقطة إعادة طلب ثابتة',
      'dynamicReorderPoint': 'نقطة إعادة طلب ديناميكية',
      'notificationSettings': 'إعدادات الإشعارات',
      'lowStockNotifications': 'إشعارات المخزون المنخفض',
      'expiryNotifications': 'إشعارات انتهاء الصلاحية',
      'expiryNotificationDays': 'أيام إشعار انتهاء الصلاحية',
      'scanningSettings': 'إعدادات المسح',
      'defaultScanType': 'نوع المسح الافتراضي',
      'barcode': 'الباركود',
      'qrCode': 'رمز QR',
      'autoGenerateBarcodes': 'إنشاء باركود تلقائيًا',
      'saveSettings': 'حفظ الإعدادات',
      'settingsSaved': 'تم حفظ الإعدادات بنجاح',

      // Inventory Adjustment History screen
      'inventoryAdjustmentHistory': 'سجل تعديل المخزون',
      'refresh': 'تحديث',
      'searchAdjustments': 'بحث عن تعديلات',
      'noAdjustmentsFound': 'لم يتم العثور على أي تعديلات',
      'createAdjustment': 'إنشاء تعديل',
      'adjustmentApprovedSuccessfully': 'تمت تعديل المخزون بنجاح',
      'adjustmentRejectedSuccessfully': 'تم رفض تعديل المخزون بنجاح',
      'createAdjustmentNotImplemented': 'إنشاء تعديل غير منفذ',
      'from': 'من {date}',
      'to': 'إلى {date}',
      'type': 'النوع: {type}',
      'status': 'الحالة: {status}',

      // Filter dialog getters
      'filterAdjustments': 'مرشحات التعديل',
      'startDate': 'تاريخ البداية',
      'endDate': 'تاريخ النهاية',
      'any': 'أي',
      'adjustmentTypeLabel': 'نوع التعديل',
      'allTypes': 'جميع الأنواع',
      'statusLabel': 'الحالة',
      'allStatuses': 'جميع الحالات',
      'itemAndCategory': 'العنصر والفئة',
      'itemId': 'معرف العنصر',
      'categoryId': 'معرف الفئة',
      'clearAll': 'مسح الكل',
      'applyFilters': 'تطبيق المرشحات',
      'pendingApproval': 'موافقة معلقة',

      // Adjustment details strings
      'previousStock': 'كمية مخزون سابقة',
      'adjustedStock': 'كمية مخزون معدلة',
      'reasonNotes': 'السبب والملاحظات',
      'performedBy': 'المتميز به',
      'approvedDate': 'تاريخ الموافقة',
      'additionalInfo': 'المعلومات الإضافية',

      // Language Settings
      'languageSettings': 'الإعدادات اللغوية',
      'themeSettings': 'الإعدادات المظهرية',
      'enableNotifications': 'تفعيل الإشعارات',
      'enableSounds': 'تفعيل الصوت',
      'enableVibration': 'تفعيل الاهتزاز',
      'lightTheme': 'الوضع الفاتح',
      'darkTheme': 'الوضع الداكن',
      'systemTheme': 'الوضع الافتراضي',
      'themeSettingsSave': 'حفظ الإعدادات',
      'themeSettingsSaved': 'تم حفظ الإعدادات بنجاح',
      'moduleSettings': 'الإعدادات الوحدة',

      // Inventory details screen
      'item_minimumQuantity': 'كمية الطلب الأدنى',
      'item_reorderPoint': 'نقطة الطلب',
      'item_batchNumber': 'رقم الدفعة',
      'item_expiryDate': 'تاريخ انتهاء الصلاحية',
      'item_lastUpdated': 'آخر تحديث',
      'item_statusAlerts': 'تنبيهات الحالة',
      'item_lowStockAlert': 'كمية منخفضة',
      'item_lowStockDescription': 'الكمية الحالية أقل من الكمية الأدنى',
      'item_reorderNeeded': 'يلزم الطلب',
      'item_reorderNeededDescription': 'الكمية الحالية أقل من نقطة الطلب',
      'item_expiringSoon': 'سينتهي صلاحيته',
      'item_expiringSoonDescription': 'سينتهي صلاحيته في {days} يوم',
      'item_additionalAttributes': 'السمات الإضافية',
      'item_notFound': 'العنصر غير موجود',
      'item_details': 'تفاصيل العنصر',

      // Inventory item card
      'item_expires': 'ينتهي',

      // Inventory analytics card
      'inventory_analytics': 'تحليل المخزون',

      // Create movement page
      'movement_from': 'من',
      'movement_to': 'إلى',
      'movement_items': 'العناصر',
      'movement_itemCount': '{count} {count, plural, one{عنصر} other{عناصر}}',
      'movement_noItemsAdded': 'لم يتم إضافة أي عناصر إلى هذه الحركة',

      // Inventory Alerts Screen
      'filterAlerts': 'تصفية التنبيهات',
      'showHighPriority': 'إظهار الأولوية العالية',
      'showMediumPriority': 'إظهار الأولوية المتوسطة',
      'showLowPriority': 'إظهار الأولوية المنخفضة',
      'lowStock': 'مخزون منخفض',
      'expiredItems': 'عناصر منتهية الصلاحية',
      'expiringSoon': 'قريبة من انتهاء الصلاحية',
      'showAcknowledged': 'إظهار المُستلمة',
      'apply': 'تطبيق',
      'high': 'عالية',
      'medium': 'متوسطة',
      'low': 'منخفضة',
      'total': 'الإجمالي',
      'refreshingAlerts': 'تحديث التنبيهات...',
      'alertAcknowledged': 'تم استلام التنبيه {id}',
      'viewingDetailsFor': 'عرض تفاصيل {itemName}',
      'noAlertsAtThisTime': 'لا توجد تنبيهات في الوقت الحالي.',
      'acknowledge': 'استلام',
    },
    'ur': {
      'inventoryMovements': 'اسٹاک کی منتقلی',
      'oldestFirst': 'پرانی پہلے',
      'newestFirst': 'نئی پہلے',
      'filter': 'فلٹر',
      'searchMovements': 'منتقلی تلاش کریں...',
      'location': 'مقام',
      'product': 'مصنوعات',
      'clearFilters': 'فلٹرز صاف کریں',
      'noMovementsMatchingFilters': 'آپ کے فلٹرز سے مماثل کوئی منتقلی نہیں',
      'noMovementsRecorded': 'ابھی تک کوئی منتقلی درج نہیں کی گئی',
      'errorLoadingMovements': 'منتقلی لوڈ کرنے میں خرابی',
      'retry': 'دوبارہ کوشش کریں',
      'newMovement': 'نئی منتقلی',
      'settings': 'ترتیبات',
      'language': 'زبان',
      'notifications': 'اطلاعات',
      'appearance': 'ظاہری شکل',
      'pushNotifications': 'فوری اطلاعات',
      'receivePushNotifications': 'فوری اطلاعات وصول کریں',
      'emailNotifications': 'ای میل اطلاعات',
      'receiveEmailNotifications': 'ای میل اطلاعات وصول کریں',
      'darkMode': 'ڈارک موڈ',
      'enableDarkMode': 'ڈارک موڈ فعال کریں',
      // Home screen and modules
      'welcomeToUndManager': 'UND منیجر میں خوش آمدید',
      'dairyManagementSolution': 'آپ کا جامع ڈیری مینجمنٹ حل',
      'modules': 'ماڈیولز',
      'screens': 'سکرینز',
      'noScreensAvailable': 'اس ماڈیول میں کوئی سکرین دستیاب نہیں ہے',
      'close': 'بند کریں',
      // Module names
      'inventory': 'انوینٹری',
      'factory': 'فیکٹری',
      'milkReception': 'دودھ کا استقبال',
      'procurement': 'خریداری',
      'analytics': 'تجزیات',
      'forecasting': 'پیشنگوئی',
      // Screen names - Inventory
      'inventoryDashboard': 'انوینٹری ڈیش بورڈ',
      'inventoryAlerts': 'انوینٹری الرٹس',
      'inventoryMovementsScreen': 'انوینٹری کی منتقلی',
      'createMovement': 'منتقلی بنائیں',
      'inventoryBatchScanner': 'بیچ سکینر',
      // Screen names - Factory
      'productionExecutions': 'پروڈکشن ایگزیکیوشنز',
      'createProductionExecution': 'پروڈکشن ایگزیکیوشن بنائیں',
      'equipmentMaintenance': 'آلات کی دیکھ بھال',
      'createMaintenanceRecord': 'دیکھ بھال ریکارڈ بنائیں',
      // Screen names - Milk Reception
      'milkReceptionScreen': 'دودھ وصولی ڈیش بورڈ',
      'milkQualityTests': 'معیار کی جانچ',
      // Screen names - Procurement
      'purchaseOrders': 'خریداری کے آرڈرز',
      'createPurchaseOrder': 'خریداری آرڈر بنائیں',
      'suppliers': 'سپلائرز',
      // Screen names - Analytics
      'analyticsDashboard': 'اینالیٹکس ڈیش بورڈ',
      // Screen names - Forecasting
      'forecastingList': 'پیشنگوئی کی فہرست',
      'forecastingCreate': 'پیشنگوئی بنائیں',
      'forecastingDashboard': 'پیشنگوئی ڈیش بورڈ',
      // Screen descriptions - Inventory
      'inventoryDashboardDesc': 'انوینٹری کی حالت اور میٹرکس کا جائزہ',
      'inventoryAlertsDesc': 'کم اسٹاک اور ختم ہونے والی تاریخوں کے الرٹس',
      'inventoryMovementsDesc': 'انوینٹری کی منتقلی کو ٹریک اور منظم کریں',
      'createMovementDesc': 'نئی انوینٹری منتقلی بنائیں',
      'inventoryBatchScannerDesc': 'بارکوڈ سکین کرکے بیچز کو ٹریک کریں',
      'inventorySettingsDesc': 'انوینٹری کی منتقلی کو ٹریک اور منظم کریں',
      // Screen descriptions - Factory
      'productionExecutionsDesc': 'پروڈکشن رنز اور عمل کا انتظام کریں',
      'createProductionExecutionDesc': 'نئی پروڈکشن ایگزیکیوشن شیڈول کریں',
      'equipmentMaintenanceDesc': 'آلات کی دیکھ بھال کو ٹریک اور شیڈول کریں',
      'createMaintenanceRecordDesc': 'نیا دیکھ بھال ریکارڈ شامل کریں',
      // Screen descriptions - Milk Reception
      'milkReceptionDesc': 'سپلائرز سے دودھ وصول کرنے کا انتظام',
      'milkQualityTestsDesc': 'معیار کی جانچ کو ٹریک اور شیڈول کریں',
      // Screen descriptions - Procurement
      'purchaseOrdersDesc': 'خریداری کے آرڈرز کا انتظام',
      'createPurchaseOrderDesc': 'نیا خریداری آرڈر بنائیں',
      'suppliersDesc': 'سپلائرز کی معلومات کا انتظام',
      // Screen descriptions - Analytics
      'analyticsDashboardDesc': 'کاروباری انٹیلیجنس اور تجزیات',
      // Screen descriptions - Forecasting
      'forecastingDesc': 'تمام پیشنگوئیاں دیکھیں',
      'forecastingCreateDesc': 'نئی پیشنگوئی بنائیں',
      'forecastingDashboardDesc': 'پیشنگوئی کے میٹرکس اور تجزیہ',
      // Movement history screen
      'movementHistory': 'حرکت کی تاریخ',
      'itemMovementHistory': '{itemName} - حرکت کی تاریخ',
      'category': 'زمرہ',
      'currentStock': 'موجودہ اسٹاک',
      'totalIn': 'کل داخل',
      'totalOut': 'کل خارج',
      'netChange': 'خالص تبدیلی',
      'movementsRecorded': '{count} حرکات ریکارڈ کی گئیں',
      'noMovementHistoryAvailable': 'کوئی حرکت کی تاریخ دستیاب نہیں ہے',
      'errorLoadingData': 'ڈیٹا لوڈ کرنے میں خرابی: {error}',
      'error': 'خرابی: {error}',
      'stockAdded': 'اسٹاک شامل کیا گیا',
      'stockRemoved': 'اسٹاک ہٹا دیا گیا',
      'reason': 'وجہ: {reason}',
      'date': 'تاریخ: {datetime}',
      // Movement details page
      'movementDetails': 'منتقلی کی تفصیلات',
      'generatePdf': 'PDF بنائیں',
      'share': 'شیئر کریں',
      'errorLoadingMovementDetails': 'منتقلی کی تفصیلات لوڈ کرنے میں خرابی',
      'id': 'شناخت: {id}',
      'locations': 'مقامات',
      'source': 'ماخذ:',
      'destination': 'منزل:',
      'notAvailable': 'دستیاب نہیں',
      'personnel': 'عملہ',
      'initiatedBy': 'شروع کیا:',
      'reviewedBy': 'جائزہ لیا:',
      'notes': 'نوٹس',
      'referenceDocuments': 'حوالہ دستاویزات',
      'itemsSingular': 'اشیاء (1 شے)',
      'itemsPlural': 'اشیاء ({count} اشیاء)',
      'batch': 'بیچ: {batch}',
      'production': 'پیداوار: {date}',
      'expiration': 'میعاد ختم: {date}',
      'approve': 'منظور کریں',
      'reject': 'مسترد کریں',
      // Movement approval dialog
      'approveMovement': 'منتقلی کو منظور کریں',
      'rejectMovement': 'منتقلی کو مسترد کریں',
      'aboutToApprove': 'آپ منتقلی {id} کو منظور کرنے والے ہیں۔',
      'aboutToReject': 'آپ منتقلی {id} کو مسترد کرنے والے ہیں۔',
      'approverId': 'منظور کنندہ کی شناخت',
      'approverIdRequired': 'منظور کنندہ کی شناخت درکار ہے',
      'approverName': 'منظور کنندہ کا نام',
      'approverNameRequired': 'منظور کنندہ کا نام درکار ہے',
      'additionalNotes': 'اضافی نوٹس (اختیاری)',
      'rejectionReason': 'مسترد کرنے کا سبب',
      'provideRejectionReason': 'براہ کرم مسترد کرنے کا سبب فراہم کریں',
      'cancel': 'منسوخ کریں',
      'movementSuccessfullyApproved': 'منتقلی کامیابی سے منظور کر دی گئی',
      'movementSuccessfullyRejected': 'منتقلی کامیابی سے مسترد کر دی گئی',
      // Inventory Dashboard
      'inventoryManagement': 'انوینٹری مینجمنٹ',
      'monitorAndManageInventory': 'مراقبة وإدارة حركات المخزون',
      'recentMovements': 'الحركات الأخيرة',
      'viewAll': 'عرض الكل',
      'noRecentMovements': 'لا توجد حركات حديثة',
      'pendingApprovals': 'موافقات معلقة',
      'criticalMovements': 'حركات حرجة',
      'movementTrends': 'اتجاهات الحركة',
      'viewAllMovements': 'عرض جميع الحركات',
      'refreshData': 'تحديث البيانات',
      'pending': 'معلق',
      'approved': 'تمت الموافقة',
      'rejected': 'مرفوض',
      'unknown': 'غير معروف',
      'review': 'مراجعة',
      'reviewItems': 'مراجعة العناصر',

      // Inventory Transfer
      'addItems': 'آئٹمز شامل کریں',
      'reviewAndSubmit': 'جائزہ لیں اور جمع کریں',
      'save': 'محفوظ کریں',
      'adjust': 'ایڈجسٹ کریں',
      'removeItems': 'آئٹمز ہٹائیں',
      'addAttribute': 'خصوصیت شامل کریں',
      'add': 'شامل کریں',

      // Units
      'kilogram': 'کلو',
      'piece': 'عدد',
      'box': 'ڈبہ',

      // Batch scanner
      'bothBarcodeAndQr': 'بارکوڈ اور QR دونوں',
      'addedItem': 'آئٹم {itemId} بیچ میں شامل کر دیا گیا',

      // Inventory Analytics Dashboard
      'inventoryAnalyticsDashboard': 'انوینٹری تجزیات',
      'valueByCategory': 'زمرہ کے حساب سے قیمت',
      'topMovingItems': 'زیادہ حرکت والی اشیاء',
      'slowMovingItems': 'سست حرکت والی اشیاء',
      'inventoryTrends': 'انوینٹری رجحانات',
      'inventoryHealth': 'انوینٹری صحت',
      'lowStockItems': 'کم اسٹاک والی اشیاء',
      'expiringItems': 'میعاد ختم ہونے والی اشیاء',
      'itemsToReorder': 'دوبارہ آرڈر کرنے والی اشیاء',
      'stockLevels': 'اسٹاک کی سطح',
      'seeDetails': 'تفصیلات دیکھیں',
      'currencySymbol': 'روپے',
      'outOfStock': 'اسٹاک میں نہیں',
      'unitsPerMonth': 'یونٹس/ماہ',
      'showMore': 'مزید دکھائیں',
      'noItemsFound': 'کوئی آئٹم نہیں ملا',
      'deleteItem': 'آئٹم حذف کریں',
      'confirmDeletion': 'حذف کرنے کی تصدیق کریں',
      'confirmDeleteItem': 'کیا آپ واقعی {itemName} کو حذف کرنا چاہتے ہیں؟',

      // Inventory Reports Screen
      'inventoryReports': 'انوینٹری رپورٹس',
      'generateReport': 'رپورٹ بنائیں',
      'reportType': 'رپورٹ کی قسم',
      'movementReport': 'حرکت کی رپورٹ',
      'valuationReport': 'قیمت کی رپورٹ',
      'stockLevelReport': 'اسٹاک لیول کی رپورٹ',
      'expiryReport': 'میعاد ختم ہونے کی رپورٹ',
      'locationReport': 'مقام کی رپورٹ',
      'dateRange': 'النطاق الزمني',
      'selectStartDate': 'اختر تاريخ البداية',
      'selectEndDate': 'اختر تاريخ النهاية',
      'reportFormat': 'تنسيق التقرير',
      'downloadAsPdf': 'تنزيل كملف PDF',
      'downloadAsExcel': 'تنزيل كملف Excel',
      'shareReport': 'مشاركة التقرير',
      'reportOptions': 'خيارات التقرير',
      'includeImages': 'تضمين الصور',
      'includeCharts': 'تضمين الرسوم البيانية',
      'includeDetails': 'تضمين التفاصيل',
      'selectLocations': 'اختر المواقع',
      'selectCategories': 'اختر الفئات',
      'reportCreated': 'تم إنشاء التقرير بنجاح',

      // Inventory Settings Screen
      'inventorySettings': 'انوینٹری ترتیبات',
      'generalSettings': 'عام ترتیبات',
      'defaultUnit': 'ڈیفالٹ یونٹ',
      'defaultLocation': 'ڈیفالٹ مقام',
      'lowStockThreshold': 'حد المخزون المنخفض',
      'reorderSettings': 'دوبارہ آرڈر کی ترتیبات',
      'automaticReorder': 'خودکار دوبارہ آرڈر',
      'reorderMethod': 'دوبارہ آرڈر کا طریقہ',
      'fixedReorderPoint': 'مقررہ دوبارہ آرڈر پوائنٹ',
      'dynamicReorderPoint': 'متحرک دوبارہ آرڈر پوائنٹ',
      'notificationSettings': 'اطلاعات کی ترتیبات',
      'lowStockNotifications': 'کم اسٹاک کی اطلاعات',
      'expiryNotifications': 'میعاد ختم ہونے کی اطلاع کے دن',
      'expiryNotificationDays': 'میعاد ختم ہونے کی اطلاع کے دن',
      'scanningSettings': 'اسکیننگ کی ترتیبات',
      'defaultScanType': 'ڈیفالٹ اسکین کی قسم',
      'barcode': 'بارکوڈ',
      'qrCode': 'رمز QR',
      'autoGenerateBarcodes': 'خودکار بارکوڈ تیار کریں',
      'saveSettings': 'ترتیبات محفوظ کریں',
      'settingsSaved': 'ترتیبات کامیابی سے محفوظ ہو گئیں',

      // Inventory Adjustment History screen
      'inventoryAdjustmentHistory': 'انوینٹری ایڈجسٹمنٹ ہسٹری',
      'refresh': 'ریفریش',
      'searchAdjustments': 'ایڈجسٹمنٹس تلاش کریں',
      'noAdjustmentsFound': 'کوئی ایڈجسٹمنٹ نہیں ملی',
      'createAdjustment': 'ایڈجسٹمنٹ بنائیں',
      'adjustmentApprovedSuccessfully': 'ایڈجسٹمنٹ کامیابی سے منظور کر دی گئی',
      'adjustmentRejectedSuccessfully': 'ایڈجسٹمنٹ کامیابی سے مسترد کر دی گئی',
      'createAdjustmentNotImplemented': 'إنشاء تعديل غير منفذ',
      'from': 'از {date}',
      'to': 'تا {date}',
      'type': 'قسم: {type}',
      'status': 'حالت: {status}',

      // Filter dialog getters
      'filterAdjustments': 'مرشحات التعديل',
      'startDate': 'تاريخ البداية',
      'endDate': 'تاريخ النهاية',
      'any': 'أي',
      'adjustmentTypeLabel': 'نوع التعديل',
      'allTypes': 'جميع الأنواع',
      'statusLabel': 'الحالة',
      'allStatuses': 'جميع الحالات',
      'itemAndCategory': 'العنصر والفئة',
      'itemId': 'معرف العنصر',
      'categoryId': 'معرف الفئة',
      'clearAll': 'مسح الكل',
      'applyFilters': 'تطبيق المرشحات',
      'pendingApproval': 'موافقة معلقة',

      // Adjustment details strings
      'previousStock': 'كمية مخزون سابقة',
      'adjustedStock': 'كمية مخزون معدلة',
      'reasonNotes': 'السبب والملاحظات',
      'performedBy': 'المتميز به',
      'approvedDate': 'تاريخ الموافقة',
      'additionalInfo': 'المعلومات الإضافية',

      // Language Settings
      'languageSettings': 'الإعدادات اللغوية',
      'themeSettings': 'الإعدادات المظهرية',
      'enableNotifications': 'تفعيل الإشعارات',
      'enableSounds': 'تفعيل الصوت',
      'enableVibration': 'تفعيل الاهتزاز',
      'lightTheme': 'الوضع الفاتح',
      'darkTheme': 'الوضع الداكن',
      'systemTheme': 'الوضع الافتراضي',
      'themeSettingsSave': 'حفظ الإعدادات',
      'themeSettingsSaved': 'تم حفظ الإعدادات بنجاح',
      'moduleSettings': 'الإعدادات الوحدة',

      // Inventory details screen
      'item_minimumQuantity': 'كمية الطلب الأدنى',
      'item_reorderPoint': 'نقطة الطلب',
      'item_batchNumber': 'رقم الدفعة',
      'item_expiryDate': 'تاريخ انتهاء الصلاحية',
      'item_lastUpdated': 'آخر تحديث',
      'item_statusAlerts': 'تنبيهات الحالة',
      'item_lowStockAlert': 'كمية منخفضة',
      'item_lowStockDescription': 'الكمية الحالية أقل من الكمية الأدنى',
      'item_reorderNeeded': 'يلزم الطلب',
      'item_reorderNeededDescription': 'الكمية الحالية أقل من نقطة الطلب',
      'item_expiringSoon': 'سينتهي صلاحيته',
      'item_expiringSoonDescription': 'سينتهي صلاحيته في {days} يوم',
      'item_additionalAttributes': 'السمات الإضافية',
      'item_notFound': 'العنصر غير موجود',
      'item_details': 'تفاصيل العنصر',

      // Inventory item card
      'item_expires': 'ينتهي',

      // Inventory analytics card
      'inventory_analytics': 'تحليل المخزون',

      // Create movement page
      'movement_from': 'من',
      'movement_to': 'إلى',
      'movement_items': 'العناصر',
      'movement_itemCount': '{count} {count, plural, one{عنصر} other{عناصر}}',
      'movement_noItemsAdded': 'لم يتم إضافة أي عناصر إلى هذه الحركة',

      // Inventory Alerts Screen
      'filterAlerts': 'تصفية التنبيهات',
      'showHighPriority': 'إظهار الأولوية العالية',
      'showMediumPriority': 'إظهار الأولوية المتوسطة',
      'showLowPriority': 'إظهار الأولوية المنخفضة',
      'lowStock': 'مخزون منخفض',
      'expiredItems': 'عناصر منتهية الصلاحية',
      'expiringSoon': 'قريبة من انتهاء الصلاحية',
      'showAcknowledged': 'إظهار المُستلمة',
      'apply': 'تطبيق',
      'high': 'عالية',
      'medium': 'متوسطة',
      'low': 'منخفضة',
      'total': 'الإجمالي',
      'refreshingAlerts': 'تحديث التنبيهات...',
      'alertAcknowledged': 'تم استلام التنبيه {id}',
      'viewingDetailsFor': 'عرض تفاصيل {itemName}',
      'noAlertsAtThisTime': 'لا توجد تنبيهات في الوقت الحالي.',
      'acknowledge': 'استلام',
    },
    'hi': {
      'inventoryMovements': 'स्टॉक आवाजाही',
      'oldestFirst': 'पुराना पहले',
      'newestFirst': 'नया पहले',
      'filter': 'फ़िल्टर',
      'searchMovements': 'आवाजाही खोजें...',
      'location': 'स्थान',
      'product': 'उत्पाद',
      'clearFilters': 'फ़िल्टर साफ़ करें',
      'noMovementsMatchingFilters':
          'आपके फ़िल्टर से मेल खाने वाली कोई आवाजाही नहीं',
      'noMovementsRecorded': 'अभी तक कोई आवाजाही दर्ज नहीं की गई',
      'errorLoadingMovements': 'आवाजाही लोड करने में त्रुटि',
      'retry': 'पुनः प्रयास करें',
      'newMovement': 'नई आवाजाही',
      'settings': 'सेटिंग्स',
      'language': 'भाषा',
      'notifications': 'सूचनाएं',
      'appearance': 'दिखावट',
      'pushNotifications': 'पुश सूचनाएं',
      'receivePushNotifications': 'पुश सूचनाएं प्राप्त करें',
      'emailNotifications': 'ईमेल सूचनाएं',
      'receiveEmailNotifications': 'ईमेल सूचनाएं प्राप्त करें',
      'darkMode': 'डार्क मोड',
      'enableDarkMode': 'डार्क मोड सक्षम करें',
      // Home screen and modules
      'welcomeToUndManager': 'UND मैनेजर में आपका स्वागत है',
      'dairyManagementSolution': 'आपका व्यापक डेयरी प्रबंधन समाधान',
      'modules': 'मॉड्यूल',
      'screens': 'स्क्रीन',
      'noScreensAvailable': 'इस मॉड्यूल में कोई स्क्रीन उपलब्ध नहीं है',
      'close': 'बंद करें',
      // Module names
      'inventory': 'इन्वेंटरी',
      'factory': 'फैक्टरी',
      'milkReception': 'दूध प्राप्ति',
      'procurement': 'खरीद',
      'analytics': 'विश्लेषण',
      'forecasting': 'अनुमान',
      // Screen names - Inventory
      'inventoryDashboard': 'इन्वेंटरी डैशबोर्ड',
      'inventoryAlerts': 'इन्वेंटरी अलर्ट',
      'inventoryMovementsScreen': 'इन्वेंटरी आवाजाही',
      'createMovement': 'आवाजाही बनाएं',
      'inventoryBatchScanner': 'बैच स्कैनर',
      // Screen names - Factory
      'productionExecutions': 'उत्पादन निष्पादन',
      'createProductionExecution': 'उत्पादन निष्पादन बनाएं',
      'equipmentMaintenance': 'उपकरण रखरखाव',
      'createMaintenanceRecord': 'रखरखाव रिकॉर्ड बनाएं',
      // Screen names - Milk Reception
      'milkReceptionScreen': 'दूध संग्रहण डैशबोर्ड',
      'milkQualityTests': 'गुणवत्ता परीक्षण',
      // Screen names - Procurement
      'purchaseOrders': 'खरीद आदेश',
      'createPurchaseOrder': 'खरीद आदेश बनाएं',
      'suppliers': 'आपूर्तिकर्ता',
      // Screen descriptions - Inventory
      'inventoryDashboardDesc': 'इन्वेंटरी स्थिति और मेट्रिक्स का अवलोकन',
      'inventoryAlertsDesc': 'कम स्टॉक और समाप्ति अलर्ट',
      'inventoryMovementsDesc': 'इन्वेंटरी आवाजाही को ट्रैक और प्रबंधित करें',
      'createMovementDesc': 'नई इन्वेंटरी आवाजाही बनाएं',
      'inventoryBatchScannerDesc': 'बारकोड स्कैन करके बैच ट्रैक करें',
      'inventorySettingsDesc':
          'इन्वेंटरी प्रबंधन के लिए सेटिंग्स को समायोजित करें',
      // Screen descriptions - Factory
      'productionExecutionsDesc': 'उत्पादन रन और प्रक्रियाओं का प्रबंधन',
      'createProductionExecutionDesc': 'नई उत्पादन निष्पादन बनाएं',
      'equipmentMaintenanceDesc': 'उपकरण रखरखाव को ट्रैक और शेड्यूल करें',
      'createMaintenanceRecordDesc': 'नया रखरखाव रिकॉर्ड जोड़ें',
      // Screen descriptions - Milk Reception
      'milkReceptionDesc': 'आपूर्तिकर्ताओं से दूध प्राप्ति का प्रबंधन',
      'milkQualityTestsDesc': 'गुणवत्ता परीक्षण को ट्रैक और शेड्यूल करें',
      // Screen descriptions - Procurement
      'purchaseOrdersDesc': 'खरीद आदेशों का प्रबंधन',
      'createPurchaseOrderDesc': 'नया खरीद आदेश बनाएं',
      'suppliersDesc': 'आपूर्तिकर्ता जानकारी का प्रबंधन',
      // Screen descriptions - Analytics
      'analyticsDashboardDesc': 'व्यावसायिक विश्लेषण और विश्लेषण',
      // Screen descriptions - Forecasting
      'forecastingDesc': 'सभी अनुमानों को देखें',
      'forecastingCreateDesc': 'नई अनुमान बनाएं',
      'forecastingDashboardDesc': 'अनुमान मीट्रिक्स और विश्लेषण',
      // Movement history screen
      'movementHistory': 'आवाजाही इतिहास',
      'itemMovementHistory': '{itemName} - आवाजाही इतिहास',
      'category': 'श्रेणी',
      'currentStock': 'वर्तमान स्टॉक',
      'totalIn': 'कुल आवक',
      'totalOut': 'कुल जावक',
      'netChange': 'शुद्ध परिवर्तन',
      'movementsRecorded': '{count} आवाजाहियां दर्ज की गईं',
      'noMovementHistoryAvailable': 'कोई आवाजाही इतिहास उपलब्ध नहीं है',
      'errorLoadingData': 'डेटा लोड करने में त्रुटि: {error}',
      'error': 'त्रुटि: {error}',
      'stockAdded': 'स्टॉक जोड़ा गया',
      'stockRemoved': 'स्टॉक हटाया गया',
      'reason': 'कारण: {reason}',
      'date': 'दिनांक: {datetime}',
      // Movement details page
      'movementDetails': 'आवाजाही विवरण',
      'generatePdf': 'PDF बनाएं',
      'share': 'साझा करें',
      'errorLoadingMovementDetails': 'आवाजाही विवरण लोड करने में त्रुटि',
      'id': 'आईडी: {id}',
      'locations': 'स्थान',
      'source': 'स्रोत:',
      'destination': 'गंतव्य:',
      'notAvailable': 'अनुपलब्ध',
      'personnel': 'कर्मचारी',
      'initiatedBy': 'शुरू किया:',
      'reviewedBy': 'समीक्षा की:',
      'notes': 'नोट्स',
      'referenceDocuments': 'संदर्भ दस्तावेज़',
      'itemsSingular': 'आइटम (1 आइटम)',
      'itemsPlural': 'आइटम ({count} आइटम)',
      'batch': 'बैच: {batch}',
      'production': 'पीड़न: {date}',
      'expiration': 'समाप्ति: {date}',
      'approve': 'स्वीकृत करें',
      'reject': 'अस्वीकार करें',
      // Movement approval dialog
      'approveMovement': 'आवाजाही को स्वीकृत करें',
      'rejectMovement': 'आवाजाही को अस्वीकार करें',
      'aboutToApprove': 'आप आवाजाही {id} को स्वीकृत करने वाले हैं।',
      'aboutToReject': 'आप आवाजाही {id} को अस्वीकार करने वाले हैं।',
      'approverId': 'स्वीकृतिकर्ता आईडी',
      'approverIdRequired': 'स्वीकृतिकर्ता आईडी आवश्यक है',
      'approverName': 'स्वीकृतिकर्ता का नाम',
      'approverNameRequired': 'स्वीकृतिकर्ता का नाम आवश्यक है',
      'additionalNotes': 'अतिरिक्त नोट्स (वैकल्पिक)',
      'rejectionReason': 'अस्वीकृति का कारण',
      'provideRejectionReason': 'कृपया अस्वीकृति का कारण प्रदान करें',
      'cancel': 'रद्द करें',
      'movementSuccessfullyApproved': 'आवाजाही सफलतापूर्वक स्वीकृत की गई',
      'movementSuccessfullyRejected': 'आवाजाही सफलतापूर्वक अस्वीकृत की गई',
      // Inventory Dashboard
      'inventoryManagement': 'इन्वेंटरी प्रबंधन',
      'monitorAndManageInventory':
          'अपनी इन्वेंटरी आवाजाही की निगरानी और प्रबंधन करें',
      'recentMovements': 'हाल की आवाजाही',
      'viewAll': 'सभी देखें',
      'noRecentMovements': 'कोई हालिया आवाजाही नहीं',
      'pendingApprovals': 'लंबित अनुमोदन',
      'criticalMovements': 'महत्वपूर्ण आवाजाही',
      'movementTrends': 'आवाजाही प्रवृत्तियां',
      'viewAllMovements': 'सभी आवाजाही देखें',
      'refreshData': 'डेटा रिफ्रेश करें',
      'pending': 'लंबित',
      'approved': 'स्वीकृत',
      'rejected': 'अस्वीकृत',
      'unknown': 'अज्ञात',
      'review': 'समीक्षा',
      'reviewItems': 'आइटम की समीक्षा करें',

      // Inventory Transfer
      'addItems': 'आइटम जोड़ें',
      'reviewAndSubmit': 'समीक्षा और जमा करें',
      'save': 'सहेजें',
      'adjust': 'समायोजित करें',
      'removeItems': 'आइटम हटाएं',
      'addAttribute': 'विशेषता जोड़ें',
      'add': 'जोड़ें',

      // Units
      'kilogram': 'किलो',
      'piece': 'नग',
      'box': 'बॉक्स',

      // Batch scanner
      'bothBarcodeAndQr': 'बारकोड और QR दोनों',
      'addedItem': 'आइटम {itemId} बैच में जोड़ा गया',

      // Inventory Analytics Dashboard
      'inventoryAnalyticsDashboard': 'इन्वेंटरी विश्लेषण',
      'valueByCategory': 'श्रेणी के अनुसार मूल्य',
      'topMovingItems': 'अधिक बिकने वाले आइटम',
      'slowMovingItems': 'स्टॉक में नहीं',
      'inventoryTrends': 'इन्वेंटरी प्रवृत्तियां',
      'inventoryHealth': 'इन्वेंटरी स्वास्थ्य',
      'lowStockItems': 'कम स्टॉक वाले आइटम',
      'expiringItems': 'समाप्त होने वाले आइटम',
      'itemsToReorder': 'पुनः ऑर्डर करने वाले आइटम',
      'stockLevels': 'स्टॉक स्तर',
      'seeDetails': 'विवरण देखें',
      'currencySymbol': '₹',
      'outOfStock': 'स्टॉक में नहीं',
      'unitsPerMonth': 'यूनिट/माह',
      'showMore': 'और देखें',
      'noItemsFound': 'कोई आइटम नहीं मिला',
      'deleteItem': 'आइटम हटाएं',
      'confirmDeletion': 'हटाने की पुष्टि करें',
      'confirmDeleteItem': 'क्या आप वाकई {itemName} को हटाना चाहते हैं?',

      // Inventory Reports Screen
      'inventoryReports': 'इन्वेंटरी रिपोर्ट',
      'generateReport': 'रिपोर्ट बनाएं',
      'reportType': 'रिपोर्ट प्रकार',
      'movementReport': 'मूवमेंट रिपोर्ट',
      'valuationReport': 'मूल्यांकन रिपोर्ट',
      'stockLevelReport': 'स्टॉक स्तर रिपोर्ट',
      'expiryReport': 'समाप्ति रिपोर्ट',
      'locationReport': 'स्थान रिपोर्ट',
      'dateRange': 'तिथि सीमा',
      'selectStartDate': 'प्रारंभ तिथि चुनें',
      'selectEndDate': 'अंतिम तिथि चुनें',
      'reportFormat': 'रिपोर्ट प्रारूप',
      'downloadAsPdf': 'PDF के रूप में डाउनलोड करें',
      'downloadAsExcel': 'Excel के रूप में डाउनलोड करें',
      'shareReport': 'रिपोर्ट साझा करें',
      'reportOptions': 'रिपोर्ट विकल्प',
      'includeImages': 'चित्र शामिल करें',
      'includeCharts': 'चार्ट शामिल करें',
      'includeDetails': 'विवरण शामिल करें',
      'selectLocations': 'स्थान चुनें',
      'selectCategories': 'श्रेणियां चुनें',
      'reportCreated': 'रिपोर्ट सफलतापूर्वक बनाई गई',

      // Inventory Adjustment History screen
      'inventoryAdjustmentHistory': 'स्टॉक आवाजाही',
      'refresh': 'अपड़त',
      'searchAdjustments': 'आवाजाही खोजें',
      'noAdjustmentsFound': 'कोई आवाजाही नहीं मिली',
      'createAdjustment': 'आवाजाही बनाएं',
      'adjustmentApprovedSuccessfully': 'आवाजाही सफलतापूर्वक स्वीकृत की गई',
      'adjustmentRejectedSuccessfully': 'आवाजाही सफलतापूर्वक अस्वीकृत की गई',
      'createAdjustmentNotImplemented': 'आवाजाही बनाने की कोई कार्य नहीं है',
      'from': 'से {date}',
      'to': 'तक {date}',
      'type': 'प्रकार: {type}',
      'status': 'अवस्था: {status}',

      // Filter dialog getters
      'filterAdjustments': 'मुख्य फ़िल्टर',
      'startDate': 'शुरू का तिथि',
      'endDate': 'समाप्ति का तिथि',
      'any': 'कोई',
      'adjustmentTypeLabel': 'फ़िल्टर का प्रकार',
      'allTypes': 'सभी प्रकार',
      'statusLabel': 'फ़िल्टर का अवस्था',
      'allStatuses': 'सभी अवस्थाएं',
      'itemAndCategory': 'वस्तु और श्रेणी',
      'itemId': 'वस्तु का आईडी',
      'categoryId': 'श्रेणी का आईडी',
      'clearAll': 'सभी साफ़ करें',
      'applyFilters': 'फ़िल्टर लागू करें',
      'pendingApproval': 'वर्तमान में विशेष अनुमोदन',

      // Adjustment details strings
      'previousStock': 'पिछली क्षमता',
      'adjustedStock': 'समायोजित क्षमता',
      'reasonNotes': 'कारण और टिप्पणियां',
      'performedBy': 'किया गया',
      'approvedDate': 'मुहूर्त पर मुहूर्त',
      'additionalInfo': 'अतिरिक्त जानकारी',

      // Language Settings
      'languageSettings': 'भाषा सेटिंग्स',
      'themeSettings': 'विशेष सेटिंग्स',
      'enableNotifications': 'सूचनाएं सक्रिय करें',
      'enableSounds': 'ध्वनि सक्रिय करें',
      'enableVibration': 'उठाव सक्रिय करें',
      'lightTheme': 'चमकदार विषय',
      'darkTheme': 'डार्क विषय',
      'systemTheme': 'सिस्टम डिफ़ॉल्ट विषय',
      'saveSettings': 'सेटिंग्स सहेजें',
      'settingsSaved': 'सेटिंग्स सफलतापूर्वक सहेजी गई',
      'moduleSettings': 'मॉड्यूल सेटिंग्स',

      // Inventory details screen
      'item_minimumQuantity': 'आवश्यक आयतन',
      'item_reorderPoint': 'आवश्यक आयतन',
      'item_batchNumber': 'आयतन का आयाम',
      'item_expiryDate': 'आयाम की तारीख',
      'item_lastUpdated': 'अंतिम अपड़त',
      'item_statusAlerts': 'अवस्था सूचनाएं',
      'item_lowStockAlert': 'कम स्टॉक',
      'item_lowStockDescription': 'वर्तमान आयतन न्यूनतम स्तर से कम है',
      'item_reorderNeeded': 'आवश्यक आयतन',
      'item_reorderNeededDescription': 'वर्तमान आयतन न्यूनतम स्तर से कम है',
      'item_expiringSoon': 'आयाम जल्द समाप्त हो रहा है',
      'item_expiringSoonDescription':
          'आयाम जल्द समाप्त हो रहा है {days} दिनों में',
      'item_additionalAttributes': 'अतिरिक्त विशेषताएं',
      'item_notFound': 'आइटम नहीं मिला',
      'item_details': 'आइटम की विवरण',

      // Inventory item card
      'item_expires': 'आयाम समाप्त हो रहा है',

      // Inventory analytics card
      'inventory_analytics': 'आयतन का विश्लेषण',

      // Create movement page
      'movement_from': 'से',
      'movement_to': 'तक',
      'movement_items': 'आइटम',
      'movement_itemCount': '{count} {count, plural, one{आइटम} other{आइटम}}',
      'movement_noItemsAdded': 'इस भरकार में कोई आइटम नहीं जोड़ा गया',

      // Inventory Alerts Screen
      'filterAlerts': 'फ़िल्टर आवाजाही',
      'showHighPriority': 'उच्च आवाजाही दिखाएं',
      'showMediumPriority': 'मध्यम आवाजाही दिखाएं',
      'showLowPriority': 'निम्न आवाजाही दिखाएं',
      'lowStock': 'कम स्टॉक',
      'expiredItems': 'खत्म होने वाली आवाजाही',
      'expiringSoon': 'जल्द खत्म होने वाली आवाजाही',
      'showAcknowledged': 'स्वीकृत आवाजाही दिखाएं',
      'apply': 'लागू करें',
      'high': 'उच्च',
      'medium': 'मध्यम',
      'low': 'निम्न',
      'total': 'कुल',
      'refreshingAlerts': 'आवाजाही अपड़त हो रही है...',
      'alertAcknowledged': 'आवाजाही {id} स्वीकृत की गई',
      'viewingDetailsFor': 'आवाजाही {itemName} के विवरण देखने के लिए',
      'noAlertsAtThisTime': 'इस समय कोई आवाजाही नहीं है।',
      'acknowledge': 'स्वीकृत करें',
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

  String get settings =>
      _localizedValues[locale.languageCode]?['settings'] ?? '';
  String get language =>
      _localizedValues[locale.languageCode]?['language'] ?? '';
  String get notifications =>
      _localizedValues[locale.languageCode]?['notifications'] ?? '';
  String get appearance =>
      _localizedValues[locale.languageCode]?['appearance'] ?? '';
  String get pushNotifications =>
      _localizedValues[locale.languageCode]?['pushNotifications'] ?? '';
  String get receivePushNotifications =>
      _localizedValues[locale.languageCode]?['receivePushNotifications'] ?? '';
  String get emailNotifications =>
      _localizedValues[locale.languageCode]?['emailNotifications'] ?? '';
  String get receiveEmailNotifications =>
      _localizedValues[locale.languageCode]?['receiveEmailNotifications'] ?? '';
  String get darkMode =>
      _localizedValues[locale.languageCode]?['darkMode'] ?? '';
  String get enableDarkMode =>
      _localizedValues[locale.languageCode]?['enableDarkMode'] ?? '';

  // Home screen getters
  String get welcomeToUndManager =>
      _localizedValues[locale.languageCode]?['welcomeToUndManager'] ?? '';
  String get dairyManagementSolution =>
      _localizedValues[locale.languageCode]?['dairyManagementSolution'] ?? '';
  String get modules => _localizedValues[locale.languageCode]?['modules'] ?? '';
  String get screens => _localizedValues[locale.languageCode]?['screens'] ?? '';
  String get noScreensAvailable =>
      _localizedValues[locale.languageCode]?['noScreensAvailable'] ?? '';
  String get close => _localizedValues[locale.languageCode]?['close'] ?? '';

  // Movement history screen getters
  String get movementHistory =>
      _localizedValues[locale.languageCode]?['movementHistory'] ?? '';
  String itemMovementHistory(String itemName) =>
      (_localizedValues[locale.languageCode]?['itemMovementHistory'] ?? '')
          .replaceAll('{itemName}', itemName);
  String get category =>
      _localizedValues[locale.languageCode]?['category'] ?? '';
  String get currentStock =>
      _localizedValues[locale.languageCode]?['currentStock'] ?? '';
  String get totalIn => _localizedValues[locale.languageCode]?['totalIn'] ?? '';
  String get totalOut =>
      _localizedValues[locale.languageCode]?['totalOut'] ?? '';
  String get netChange =>
      _localizedValues[locale.languageCode]?['netChange'] ?? '';
  String movementsRecorded(int count) =>
      (_localizedValues[locale.languageCode]?['movementsRecorded'] ?? '')
          .replaceAll('{count}', count.toString());
  String get noMovementHistoryAvailable =>
      _localizedValues[locale.languageCode]?['noMovementHistoryAvailable'] ??
      '';
  String errorLoadingData(String error) =>
      (_localizedValues[locale.languageCode]?['errorLoadingData'] ?? '')
          .replaceAll('{error}', error);
  String errorWithMessage(String error) =>
      (_localizedValues[locale.languageCode]?['error'] ?? '')
          .replaceAll('{error}', error);
  String get stockAdded =>
      _localizedValues[locale.languageCode]?['stockAdded'] ?? '';
  String get stockRemoved =>
      _localizedValues[locale.languageCode]?['stockRemoved'] ?? '';
  String reasonWithText(String reason) =>
      (_localizedValues[locale.languageCode]?['reason'] ?? '')
          .replaceAll('{reason}', reason);
  String dateWithValue(String datetime) =>
      (_localizedValues[locale.languageCode]?['date'] ?? '')
          .replaceAll('{datetime}', datetime);

  // Movement details page getters
  String get movementDetails =>
      _localizedValues[locale.languageCode]?['movementDetails'] ?? '';
  String get generatePdf =>
      _localizedValues[locale.languageCode]?['generatePdf'] ?? '';
  String get share => _localizedValues[locale.languageCode]?['share'] ?? '';
  String get errorLoadingMovementDetails =>
      _localizedValues[locale.languageCode]?['errorLoadingMovementDetails'] ??
      '';
  String idWithValue(String id) =>
      (_localizedValues[locale.languageCode]?['id'] ?? '')
          .replaceAll('{id}', id);
  String dateWithTimestamp(String date) =>
      (_localizedValues[locale.languageCode]?['date'] ?? '')
          .replaceAll('{date}', date);
  String get locations =>
      _localizedValues[locale.languageCode]?['locations'] ?? '';
  String get source => _localizedValues[locale.languageCode]?['source'] ?? '';
  String get destination =>
      _localizedValues[locale.languageCode]?['destination'] ?? '';
  String get notAvailable =>
      _localizedValues[locale.languageCode]?['notAvailable'] ?? '';
  String get personnel =>
      _localizedValues[locale.languageCode]?['personnel'] ?? '';
  String get initiatedBy =>
      _localizedValues[locale.languageCode]?['initiatedBy'] ?? '';
  String get reviewedBy =>
      _localizedValues[locale.languageCode]?['reviewedBy'] ?? '';
  String get notes => _localizedValues[locale.languageCode]?['notes'] ?? '';
  String get referenceDocuments =>
      _localizedValues[locale.languageCode]?['referenceDocuments'] ?? '';
  String itemsCount(int count) {
    if (count == 1) {
      return _localizedValues[locale.languageCode]?['itemsSingular'] ?? '';
    } else {
      return (_localizedValues[locale.languageCode]?['itemsPlural'] ?? '')
          .replaceAll('{count}', count.toString());
    }
  }

  String batchWithValue(String batch) =>
      (_localizedValues[locale.languageCode]?['batch'] ?? '')
          .replaceAll('{batch}', batch);
  String productionWithDate(String date) =>
      (_localizedValues[locale.languageCode]?['production'] ?? '')
          .replaceAll('{date}', date);
  String expirationWithDate(String date) =>
      (_localizedValues[locale.languageCode]?['expiration'] ?? '')
          .replaceAll('{date}', date);
  String get approve => _localizedValues[locale.languageCode]?['approve'] ?? '';
  String get reject => _localizedValues[locale.languageCode]?['reject'] ?? '';

  // Movement approval dialog getters
  String get approveMovement =>
      _localizedValues[locale.languageCode]?['approveMovement'] ?? '';
  String get rejectMovement =>
      _localizedValues[locale.languageCode]?['rejectMovement'] ?? '';
  String aboutToApprove(String id) =>
      (_localizedValues[locale.languageCode]?['aboutToApprove'] ?? '')
          .replaceAll('{id}', id);
  String aboutToReject(String id) =>
      (_localizedValues[locale.languageCode]?['aboutToReject'] ?? '')
          .replaceAll('{id}', id);
  String get approverId =>
      _localizedValues[locale.languageCode]?['approverId'] ?? '';
  String get approverIdRequired =>
      _localizedValues[locale.languageCode]?['approverIdRequired'] ?? '';
  String get approverName =>
      _localizedValues[locale.languageCode]?['approverName'] ?? '';
  String get approverNameRequired =>
      _localizedValues[locale.languageCode]?['approverNameRequired'] ?? '';
  String get additionalNotes =>
      _localizedValues[locale.languageCode]?['additionalNotes'] ?? '';
  String get rejectionReason =>
      _localizedValues[locale.languageCode]?['rejectionReason'] ?? '';
  String get provideRejectionReason =>
      _localizedValues[locale.languageCode]?['provideRejectionReason'] ?? '';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? '';
  String get movementSuccessfullyApproved =>
      _localizedValues[locale.languageCode]?['movementSuccessfullyApproved'] ??
      '';
  String get movementSuccessfullyRejected =>
      _localizedValues[locale.languageCode]?['movementSuccessfullyRejected'] ??
      '';
  String errorWithText(String error) =>
      (_localizedValues[locale.languageCode]?['error'] ?? '')
          .replaceAll('{error}', error);

  // Helper methods for dynamic key access
  String? getModuleName(String key) =>
      _localizedValues[locale.languageCode]?[key];

  String? getScreenName(String key) =>
      _localizedValues[locale.languageCode]?[key];

  String? getScreenDescription(String key) =>
      _localizedValues[locale.languageCode]?[key];

  // Inventory Dashboard getters
  String get inventoryDashboard =>
      _localizedValues[locale.languageCode]?['inventoryDashboard'] ?? '';
  String get inventoryAlerts =>
      _localizedValues[locale.languageCode]?['inventoryAlerts'] ?? '';
  String get inventoryManagement =>
      _localizedValues[locale.languageCode]?['inventoryManagement'] ?? '';
  String get monitorAndManageInventory =>
      _localizedValues[locale.languageCode]?['monitorAndManageInventory'] ?? '';
  String get recentMovements =>
      _localizedValues[locale.languageCode]?['recentMovements'] ?? '';
  String get viewAll => _localizedValues[locale.languageCode]?['viewAll'] ?? '';
  String get noRecentMovements =>
      _localizedValues[locale.languageCode]?['noRecentMovements'] ?? '';
  String get pendingApprovals =>
      _localizedValues[locale.languageCode]?['pendingApprovals'] ?? '';
  String get criticalMovements =>
      _localizedValues[locale.languageCode]?['criticalMovements'] ?? '';
  String get movementTrends =>
      _localizedValues[locale.languageCode]?['movementTrends'] ?? '';
  String get viewAllMovements =>
      _localizedValues[locale.languageCode]?['viewAllMovements'] ?? '';
  String get refreshData =>
      _localizedValues[locale.languageCode]?['refreshData'] ?? '';
  String get pending => _localizedValues[locale.languageCode]?['pending'] ?? '';
  String get approved =>
      _localizedValues[locale.languageCode]?['approved'] ?? '';
  String get rejected =>
      _localizedValues[locale.languageCode]?['rejected'] ?? '';
  String get unknown => _localizedValues[locale.languageCode]?['unknown'] ?? '';
  String get review => _localizedValues[locale.languageCode]?['review'] ?? '';
  String get reviewItems =>
      _localizedValues[locale.languageCode]?['reviewItems'] ?? '';

  // Inventory Transfer getters
  String get save => _localizedValues[locale.languageCode]?['save'] ?? '';
  String get addItems =>
      _localizedValues[locale.languageCode]?['addItems'] ?? '';
  String get reviewAndSubmit =>
      _localizedValues[locale.languageCode]?['reviewAndSubmit'] ?? '';
  String get adjust => _localizedValues[locale.languageCode]?['adjust'] ?? '';
  String get removeItems =>
      _localizedValues[locale.languageCode]?['removeItems'] ?? '';
  String get addAttribute =>
      _localizedValues[locale.languageCode]?['addAttribute'] ?? '';
  String get add => _localizedValues[locale.languageCode]?['add'] ?? '';

  // Units getters
  String get kilogram =>
      _localizedValues[locale.languageCode]?['kilogram'] ?? '';
  String get piece => _localizedValues[locale.languageCode]?['piece'] ?? '';
  String get box => _localizedValues[locale.languageCode]?['box'] ?? '';

  // Batch scanner getters
  String get bothBarcodeAndQr =>
      _localizedValues[locale.languageCode]?['bothBarcodeAndQr'] ?? '';
  String addedItemToBatch(String itemId) =>
      (_localizedValues[locale.languageCode]?['addedItem'] ?? '')
          .replaceAll('{itemId}', itemId);

  // Inventory Analytics Dashboard getters
  String get inventoryAnalyticsDashboard =>
      _localizedValues[locale.languageCode]?['inventoryAnalyticsDashboard'] ??
      '';
  String get valueByCategory =>
      _localizedValues[locale.languageCode]?['valueByCategory'] ?? '';
  String get topMovingItems =>
      _localizedValues[locale.languageCode]?['topMovingItems'] ?? '';
  String get slowMovingItems =>
      _localizedValues[locale.languageCode]?['slowMovingItems'] ?? '';
  String get inventoryTrends =>
      _localizedValues[locale.languageCode]?['inventoryTrends'] ?? '';
  String get inventoryHealth =>
      _localizedValues[locale.languageCode]?['inventoryHealth'] ?? '';
  String get lowStockItems =>
      _localizedValues[locale.languageCode]?['lowStockItems'] ?? '';
  String get expiringItems =>
      _localizedValues[locale.languageCode]?['expiringItems'] ?? '';
  String get itemsToReorder =>
      _localizedValues[locale.languageCode]?['itemsToReorder'] ?? '';
  String get stockLevels =>
      _localizedValues[locale.languageCode]?['stockLevels'] ?? '';
  String get seeDetails =>
      _localizedValues[locale.languageCode]?['seeDetails'] ?? '';
  String get currencySymbol =>
      _localizedValues[locale.languageCode]?['currencySymbol'] ?? '';
  String get outOfStock =>
      _localizedValues[locale.languageCode]?['outOfStock'] ?? '';
  String get unitsPerMonth =>
      _localizedValues[locale.languageCode]?['unitsPerMonth'] ?? '';
  String get showMore =>
      _localizedValues[locale.languageCode]?['showMore'] ?? '';
  String get noItemsFound =>
      _localizedValues[locale.languageCode]?['noItemsFound'] ?? '';
  String get deleteItem =>
      _localizedValues[locale.languageCode]?['deleteItem'] ?? '';
  String get confirmDeletion =>
      _localizedValues[locale.languageCode]?['confirmDeletion'] ?? '';
  String confirmDeleteItem(String itemName) =>
      (_localizedValues[locale.languageCode]?['confirmDeleteItem'] ?? '')
          .replaceAll('{itemName}', itemName);
  String get cancelButton =>
      _localizedValues[locale.languageCode]?['cancel'] ?? '';
  String get deleteButton =>
      _localizedValues[locale.languageCode]?['delete'] ?? '';

  // Inventory Reports Screen getters
  String get inventoryReports =>
      _localizedValues[locale.languageCode]?['inventoryReports'] ?? '';
  String get generateReport =>
      _localizedValues[locale.languageCode]?['generateReport'] ?? '';
  String get reportType =>
      _localizedValues[locale.languageCode]?['reportType'] ?? '';
  String get movementReport =>
      _localizedValues[locale.languageCode]?['movementReport'] ?? '';
  String get valuationReport =>
      _localizedValues[locale.languageCode]?['valuationReport'] ?? '';
  String get stockLevelReport =>
      _localizedValues[locale.languageCode]?['stockLevelReport'] ?? '';
  String get expiryReport =>
      _localizedValues[locale.languageCode]?['expiryReport'] ?? '';
  String get locationReport =>
      _localizedValues[locale.languageCode]?['locationReport'] ?? '';
  String get dateRange =>
      _localizedValues[locale.languageCode]?['dateRange'] ?? '';
  String get selectStartDate =>
      _localizedValues[locale.languageCode]?['selectStartDate'] ?? '';
  String get selectEndDate =>
      _localizedValues[locale.languageCode]?['selectEndDate'] ?? '';
  String get reportFormat =>
      _localizedValues[locale.languageCode]?['reportFormat'] ?? '';
  String get downloadAsPdf =>
      _localizedValues[locale.languageCode]?['downloadAsPdf'] ?? '';
  String get downloadAsExcel =>
      _localizedValues[locale.languageCode]?['downloadAsExcel'] ?? '';
  String get shareReport =>
      _localizedValues[locale.languageCode]?['shareReport'] ?? '';
  String get reportOptions =>
      _localizedValues[locale.languageCode]?['reportOptions'] ?? '';
  String get includeImages =>
      _localizedValues[locale.languageCode]?['includeImages'] ?? '';
  String get includeCharts =>
      _localizedValues[locale.languageCode]?['includeCharts'] ?? '';
  String get includeDetails =>
      _localizedValues[locale.languageCode]?['includeDetails'] ?? '';
  String get selectLocations =>
      _localizedValues[locale.languageCode]?['selectLocations'] ?? '';
  String get selectCategories =>
      _localizedValues[locale.languageCode]?['selectCategories'] ?? '';
  String get reportCreated =>
      _localizedValues[locale.languageCode]?['reportCreated'] ?? '';

  // Inventory Settings Screen getters
  String get inventorySettings =>
      _localizedValues[locale.languageCode]?['inventorySettings'] ?? '';
  String get generalSettings =>
      _localizedValues[locale.languageCode]?['generalSettings'] ?? '';
  String get defaultUnit =>
      _localizedValues[locale.languageCode]?['defaultUnit'] ?? '';
  String get defaultLocation =>
      _localizedValues[locale.languageCode]?['defaultLocation'] ?? '';
  String get lowStockThreshold =>
      _localizedValues[locale.languageCode]?['lowStockThreshold'] ?? '';
  String get reorderSettings =>
      _localizedValues[locale.languageCode]?['reorderSettings'] ?? '';
  String get automaticReorder =>
      _localizedValues[locale.languageCode]?['automaticReorder'] ?? '';
  String get reorderMethod =>
      _localizedValues[locale.languageCode]?['reorderMethod'] ?? '';
  String get fixedReorderPoint =>
      _localizedValues[locale.languageCode]?['fixedReorderPoint'] ?? '';
  String get dynamicReorderPoint =>
      _localizedValues[locale.languageCode]?['dynamicReorderPoint'] ?? '';
  String get notificationSettings =>
      _localizedValues[locale.languageCode]?['notificationSettings'] ?? '';
  String get lowStockNotifications =>
      _localizedValues[locale.languageCode]?['lowStockNotifications'] ?? '';
  String get expiryNotifications =>
      _localizedValues[locale.languageCode]?['expiryNotifications'] ?? '';
  String get expiryNotificationDays =>
      _localizedValues[locale.languageCode]?['expiryNotificationDays'] ?? '';
  String get scanningSettings =>
      _localizedValues[locale.languageCode]?['scanningSettings'] ?? '';
  String get defaultScanType =>
      _localizedValues[locale.languageCode]?['defaultScanType'] ?? '';
  String get barcode => _localizedValues[locale.languageCode]?['barcode'] ?? '';
  String get qrCode => _localizedValues[locale.languageCode]?['qrCode'] ?? '';
  String get autoGenerateBarcodes =>
      _localizedValues[locale.languageCode]?['autoGenerateBarcodes'] ?? '';
  String get saveSettings =>
      _localizedValues[locale.languageCode]?['saveSettings'] ?? '';
  String get settingsSaved =>
      _localizedValues[locale.languageCode]?['settingsSaved'] ?? '';

  // Inventory Adjustment History screen getters
  String get inventoryAdjustmentHistory =>
      _localizedValues[locale.languageCode]?['inventoryAdjustmentHistory'] ??
      '';
  String get searchAdjustments =>
      _localizedValues[locale.languageCode]?['searchAdjustments'] ?? '';
  String get noAdjustmentsFound =>
      _localizedValues[locale.languageCode]?['noAdjustmentsFound'] ?? '';
  String get createAdjustment =>
      _localizedValues[locale.languageCode]?['createAdjustment'] ?? '';
  String get adjustmentApprovedSuccessfully =>
      _localizedValues[locale.languageCode]
          ?['adjustmentApprovedSuccessfully'] ??
      '';
  String get adjustmentRejectedSuccessfully =>
      _localizedValues[locale.languageCode]
          ?['adjustmentRejectedSuccessfully'] ??
      '';
  String get createAdjustmentNotImplemented =>
      _localizedValues[locale.languageCode]
          ?['createAdjustmentNotImplemented'] ??
      '';
  String get reasonLabel => 'Reason';
  String from(String date) =>
      (_localizedValues[locale.languageCode]?['from'] ?? '')
          .replaceAll('{date}', date);
  String to(String date) => (_localizedValues[locale.languageCode]?['to'] ?? '')
      .replaceAll('{date}', date);
  String type(String typeValue) =>
      (_localizedValues[locale.languageCode]?['type'] ?? '')
          .replaceAll('{type}', typeValue);
  String status(String statusValue) =>
      (_localizedValues[locale.languageCode]?['status'] ?? '')
          .replaceAll('{status}', statusValue);

  // Filter dialog getters
  String get filterAdjustments =>
      _localizedValues[locale.languageCode]?['filterAdjustments'] ?? '';
  String get startDate =>
      _localizedValues[locale.languageCode]?['startDate'] ?? '';
  String get endDate => _localizedValues[locale.languageCode]?['endDate'] ?? '';
  String get any => _localizedValues[locale.languageCode]?['any'] ?? '';
  String get adjustmentTypeLabel =>
      _localizedValues[locale.languageCode]?['adjustmentTypeLabel'] ?? '';
  String get allTypes =>
      _localizedValues[locale.languageCode]?['allTypes'] ?? '';
  String get statusLabel =>
      _localizedValues[locale.languageCode]?['statusLabel'] ?? '';
  String get allStatuses =>
      _localizedValues[locale.languageCode]?['allStatuses'] ?? '';
  String get itemAndCategory =>
      _localizedValues[locale.languageCode]?['itemAndCategory'] ?? '';
  String get itemId => _localizedValues[locale.languageCode]?['itemId'] ?? '';
  String get categoryId =>
      _localizedValues[locale.languageCode]?['categoryId'] ?? '';
  String get clearAll =>
      _localizedValues[locale.languageCode]?['clearAll'] ?? '';
  String get applyFilters =>
      _localizedValues[locale.languageCode]?['applyFilters'] ?? '';
  String get pendingApproval =>
      _localizedValues[locale.languageCode]?['pendingApproval'] ?? '';

  // Adjustment details getters
  String get previousStock =>
      _localizedValues[locale.languageCode]?['previousStock'] ?? '';
  String get adjustedStock =>
      _localizedValues[locale.languageCode]?['adjustedStock'] ?? '';
  String get reasonNotes =>
      _localizedValues[locale.languageCode]?['reasonNotes'] ?? '';
  String get performedBy =>
      _localizedValues[locale.languageCode]?['performedBy'] ?? '';
  String get approvedDate =>
      _localizedValues[locale.languageCode]?['approvedDate'] ?? '';
  String get additionalInfo =>
      _localizedValues[locale.languageCode]?['additionalInfo'] ?? '';

  // Adjustment statistics getters
  String get adjustmentsByType =>
      _localizedValues[locale.languageCode]?['adjustmentsByType'] ?? '';
  String get quantityByType =>
      _localizedValues[locale.languageCode]?['quantityByType'] ?? '';
  String get units => _localizedValues[locale.languageCode]?['units'] ?? '';

  // Language Settings
  String get languageSettings =>
      _localizedValues[locale.languageCode]?['languageSettings'] ?? '';
  String get themeSettings =>
      _localizedValues[locale.languageCode]?['themeSettings'] ?? '';
  String get enableNotifications =>
      _localizedValues[locale.languageCode]?['enableNotifications'] ?? '';
  String get enableSounds =>
      _localizedValues[locale.languageCode]?['enableSounds'] ?? '';
  String get enableVibration =>
      _localizedValues[locale.languageCode]?['enableVibration'] ?? '';
  String get lightTheme =>
      _localizedValues[locale.languageCode]?['lightTheme'] ?? '';
  String get darkTheme =>
      _localizedValues[locale.languageCode]?['darkTheme'] ?? '';
  String get systemTheme =>
      _localizedValues[locale.languageCode]?['systemTheme'] ?? '';
  String get themeSettingsSave =>
      _localizedValues[locale.languageCode]?['themeSettingsSave'] ?? '';
  String get themeSettingsSaved =>
      _localizedValues[locale.languageCode]?['themeSettingsSaved'] ?? '';
  String get moduleSettings =>
      _localizedValues[locale.languageCode]?['moduleSettings'] ?? '';

  // Inventory details screen
  String get itemCategory =>
      _localizedValues[locale.languageCode]?['item_category'] ?? '';
  String get itemMinimumQuantity =>
      _localizedValues[locale.languageCode]?['item_minimumQuantity'] ?? '';
  String get itemReorderPoint =>
      _localizedValues[locale.languageCode]?['item_reorderPoint'] ?? '';
  String get itemBatchNumber =>
      _localizedValues[locale.languageCode]?['item_batchNumber'] ?? '';
  String get itemExpiryDate =>
      _localizedValues[locale.languageCode]?['item_expiryDate'] ?? '';
  String get itemLastUpdated =>
      _localizedValues[locale.languageCode]?['item_lastUpdated'] ?? '';
  String get itemStatusAlerts =>
      _localizedValues[locale.languageCode]?['item_statusAlerts'] ?? '';
  String get itemLowStockAlert =>
      _localizedValues[locale.languageCode]?['item_lowStockAlert'] ?? '';
  String get itemLowStockDescription =>
      _localizedValues[locale.languageCode]?['item_lowStockDescription'] ?? '';
  String get itemReorderNeeded =>
      _localizedValues[locale.languageCode]?['item_reorderNeeded'] ?? '';
  String get itemReorderNeededDescription =>
      _localizedValues[locale.languageCode]?['item_reorderNeededDescription'] ??
      '';
  String get itemExpiringSoon =>
      _localizedValues[locale.languageCode]?['item_expiringSoon'] ?? '';
  String itemExpiringSoonDescription(int days) =>
      (_localizedValues[locale.languageCode]?['item_expiringSoonDescription'] ??
              '')
          .replaceAll('{days}', days.toString());
  String get itemAdditionalAttributes =>
      _localizedValues[locale.languageCode]?['item_additionalAttributes'] ?? '';
  String get itemNotFound =>
      _localizedValues[locale.languageCode]?['item_notFound'] ?? '';
  String get itemDetails =>
      _localizedValues[locale.languageCode]?['item_details'] ?? '';

  // Inventory item card
  String get itemExpires =>
      _localizedValues[locale.languageCode]?['item_expires'] ?? '';

  // Inventory analytics card
  String get inventoryAnalytics =>
      _localizedValues[locale.languageCode]?['inventory_analytics'] ?? '';

  // Create movement page
  String get movementFrom =>
      _localizedValues[locale.languageCode]?['movement_from'] ?? '';
  String get movementTo =>
      _localizedValues[locale.languageCode]?['movement_to'] ?? '';
  String get movementItems =>
      _localizedValues[locale.languageCode]?['movement_items'] ?? '';
  String movementItemCount(int count) {
    return (_localizedValues[locale.languageCode]?['movement_itemCount'] ?? '')
        .replaceAll('{count}', count.toString());
  }

  String get movementNoItemsAdded =>
      _localizedValues[locale.languageCode]?['movement_noItemsAdded'] ?? '';

  // Inventory Alerts Screen
  String get filterAlerts =>
      _localizedValues[locale.languageCode]?['filterAlerts'] ?? '';
  String get showHighPriority =>
      _localizedValues[locale.languageCode]?['showHighPriority'] ?? '';
  String get showMediumPriority =>
      _localizedValues[locale.languageCode]?['showMediumPriority'] ?? '';
  String get showLowPriority =>
      _localizedValues[locale.languageCode]?['showLowPriority'] ?? '';
  String get lowStock =>
      _localizedValues[locale.languageCode]?['lowStock'] ?? '';
  String get expiredItems =>
      _localizedValues[locale.languageCode]?['expiredItems'] ?? '';
  String get expiringSoon =>
      _localizedValues[locale.languageCode]?['expiringSoon'] ?? '';
  String get showAcknowledged =>
      _localizedValues[locale.languageCode]?['showAcknowledged'] ?? '';
  String get apply => _localizedValues[locale.languageCode]?['apply'] ?? '';
  String get high => _localizedValues[locale.languageCode]?['high'] ?? '';
  String get medium => _localizedValues[locale.languageCode]?['medium'] ?? '';
  String get low => _localizedValues[locale.languageCode]?['low'] ?? '';
  String get total => _localizedValues[locale.languageCode]?['total'] ?? '';
  String get refreshingAlerts =>
      _localizedValues[locale.languageCode]?['refreshingAlerts'] ?? '';
  String alertAcknowledged(String id) =>
      (_localizedValues[locale.languageCode]?['alertAcknowledged'] ?? '')
          .replaceAll('{id}', id);
  String viewingDetailsFor(String itemName) =>
      (_localizedValues[locale.languageCode]?['viewingDetailsFor'] ?? '')
          .replaceAll('{itemName}', itemName);
  String get noAlertsAtThisTime =>
      _localizedValues[locale.languageCode]?['noAlertsAtThisTime'] ?? '';
  String get acknowledge =>
      _localizedValues[locale.languageCode]?['acknowledge'] ?? '';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'ur', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
