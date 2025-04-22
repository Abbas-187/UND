import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/inventory_movement_type.dart';
import '../../providers/inventory_movement_providers.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/services/inventory_report_pdf_service.dart';
import '../../data/models/inventory_movement_model.dart';
import '../../domain/services/inventory_movement_service.dart';
import 'package:open_filex/open_filex.dart';
import '../../presentation/widgets/movement_report_charts.dart';
import 'package:flutter/foundation.dart';
import '../../../../utils/widget_to_image.dart';

// DEPRECATED: This screen is replaced by the new ReportScreen. Remove after migration is complete.
// class InventoryReportsScreen extends ConsumerStatefulWidget {
//   const InventoryReportsScreen({super.key});
//
//   @override
//   ConsumerState<InventoryReportsScreen> createState() =>
//       _InventoryReportsScreenState();
// }
//
// class _InventoryReportsScreenState
//     extends ConsumerState<InventoryReportsScreen> {
//   // ... existing code ...
// }
