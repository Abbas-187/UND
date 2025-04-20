import 'package:uuid/uuid.dart';
import '../entities/procurement_plan.dart';
import '../entities/purchase_order.dart';
import '../repositories/supplier_repository.dart';
import '../validation/po_validator.dart';

/// Service for generating purchase orders from procurement plans.
class PurchaseOrderGenerator {
  final SupplierRepository _supplierRepository;
  final POValidator _validator;
  final Uuid _uuid = const Uuid();

  PurchaseOrderGenerator({
    required SupplierRepository supplierRepository,
    required POValidator validator,
  })  : _supplierRepository = supplierRepository,
        _validator = validator;

  /// Generates purchase orders from a procurement plan.
  ///
  /// [plan] - The procurement plan to generate POs from
  /// [requestedBy] - User ID of the person requesting the POs
  /// [groupBySupplier] - Whether to group items by supplier
  /// Returns a list of generated purchase orders
  Future<List<PurchaseOrder>> generatePurchaseOrders({
    required ProcurementPlan plan,
    required String requestedBy,
    required bool groupBySupplier,
  }) async {
    if (plan.status != ProcurementPlanStatus.approved) {
      throw Exception(
          'Cannot generate purchase orders from an unapproved procurement plan');
    }

    if (plan.items.isEmpty) {
      throw Exception(
          'Cannot generate purchase orders from an empty procurement plan');
    }

    final List<PurchaseOrder> purchaseOrders = [];

    if (groupBySupplier) {
      // Group items by supplier
      final Map<String, List<ProcurementPlanItem>> itemsBySupplier = {};

      for (final item in plan.items) {
        final supplierId = item.preferredSupplierId;

        if (itemsBySupplier.containsKey(supplierId)) {
          itemsBySupplier[supplierId]!.add(item);
        } else {
          itemsBySupplier[supplierId] = [item];
        }
      }

      // Create a PO for each supplier
      for (final entry in itemsBySupplier.entries) {
        final supplierId = entry.key;
        final items = entry.value;

        final supplier = await _supplierRepository.getSupplierById(supplierId);

        if (supplier == null) {
          throw Exception('Supplier not found: $supplierId');
        }

        final po = await _createPurchaseOrder(
          planId: plan.id,
          requestedBy: requestedBy,
          supplierName: supplier.name,
          supplierId: supplierId,
          items: items,
          intendedUse: 'From procurement plan: ${plan.name}',
        );

        purchaseOrders.add(po);
      }
    } else {
      // Create a single PO with all items
      final po = await _createPurchaseOrder(
        planId: plan.id,
        requestedBy: requestedBy,
        supplierName: 'Multiple Suppliers',
        supplierId: 'multiple',
        items: plan.items,
        intendedUse: 'From procurement plan: ${plan.name}',
      );

      purchaseOrders.add(po);
    }

    return purchaseOrders;
  }

  /// Creates a single purchase order.
  Future<PurchaseOrder> _createPurchaseOrder({
    required String planId,
    required String requestedBy,
    required String supplierName,
    required String supplierId,
    required List<ProcurementPlanItem> items,
    required String intendedUse,
  }) async {
    final poItems = items
        .map((item) => PurchaseOrderItem(
              id: _uuid.v4(),
              itemId: item.itemId,
              itemName: item.itemName,
              quantity: item.quantity,
              unit: item.unit,
              unitPrice: item.estimatedUnitCost,
              totalPrice: item.estimatedTotalCost,
              requiredByDate: item.requiredByDate,
              notes: item.notes,
            ))
        .toList();

    final totalAmount = poItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    final po = PurchaseOrder(
      id: _uuid.v4(),
      procurementPlanId: planId,
      poNumber: _generatePONumber(),
      requestDate: DateTime.now(),
      requestedBy: requestedBy,
      supplierId: supplierId,
      supplierName: supplierName,
      status: PurchaseOrderStatus.draft,
      items: poItems,
      totalAmount: totalAmount,
      reasonForRequest: 'Procurement based on approved plan',
      intendedUse: intendedUse,
      quantityJustification: _generateQuantityJustification(items),
      supportingDocuments: [],
    );

    // Validate the PO
    final validationResult = await _validator.validate(po);
    if (!validationResult.isValid) {
      throw Exception(
          'Purchase order validation failed: ${validationResult.errors.join(', ')}');
    }

    return po;
  }

  /// Generates a PO number.
  String _generatePONumber() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = _uuid.v4().substring(0, 4);

    return 'PO-$year$month$day-$random';
  }

  /// Generates a quantity justification string.
  String _generateQuantityJustification(List<ProcurementPlanItem> items) {
    final buffer = StringBuffer();
    buffer.writeln('Quantities are based on the following production needs:');

    for (final item in items) {
      final months = 3; // Default to 3 months of production
      buffer.writeln('- ${item.itemName}: ${item.quantity} ${item.unit} '
          '(estimated to cover $months months of production)');
    }

    return buffer.toString();
  }
}
