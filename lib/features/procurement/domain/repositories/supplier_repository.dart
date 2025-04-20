import '../../../../core/exceptions/result.dart';
import '../entities/supplier.dart';

/// Repository interface for supplier operations
abstract class SupplierRepository {
  /// Retrieves a supplier by its ID.
  ///
  /// [id] - ID of the supplier
  /// Returns the supplier or null if not found
  Future<Supplier?> getSupplierById(String id);

  /// Retrieves all active suppliers.
  ///
  /// Returns a list of active suppliers
  Future<List<Supplier>> getActiveSuppliers();

  /// Retrieves the preferred supplier for a specific item.
  ///
  /// [itemId] - ID of the item
  /// Returns the preferred supplier for the item
  Future<Supplier> getPreferredSupplierForItem(String itemId);

  /// Retrieves the price that a supplier charges for a specific item.
  ///
  /// [supplierId] - ID of the supplier
  /// [itemId] - ID of the item
  /// Returns the price per unit
  Future<double> getSupplierItemPrice(String supplierId, String itemId);

  /// Retrieves all suppliers that can provide a specific item.
  ///
  /// [itemId] - ID of the item
  /// Returns a list of suppliers that provide the item
  Future<List<Supplier>> getSuppliersForItem(String itemId);

  Future<List<Supplier>> getSuppliers();
}
