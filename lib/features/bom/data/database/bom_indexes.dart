/// Database indexing optimization for BOM module
/// Provides index definitions and query optimization strategies
library;

/// Index definitions for BOM-related tables
class BomIndexes {
  /// Composite index for BOM search and filtering
  /// Optimizes queries that filter by status, type, product, and sort by date
  static const String bomSearchIndex = '''
    CREATE INDEX IF NOT EXISTS idx_bom_search 
    ON boms(status, bom_type, product_id, created_at DESC);
  ''';

  /// Index for BOM items by sequence and status
  /// Optimizes BOM item retrieval and ordering
  static const String bomItemsSequenceIndex = '''
    CREATE INDEX IF NOT EXISTS idx_bom_items_sequence 
    ON bom_items(bom_id, sequence_number, status);
  ''';

  /// Index for cost calculation queries
  /// Optimizes cost aggregation and analysis
  static const String bomItemsCostIndex = '''
    CREATE INDEX IF NOT EXISTS idx_bom_items_cost 
    ON bom_items(bom_id, status, cost_per_unit);
  ''';

  /// Index for integration queries
  /// Optimizes cross-module queries and lookups
  static const String bomIntegrationIndex = '''
    CREATE INDEX IF NOT EXISTS idx_bom_integration 
    ON boms(product_id, status, version);
  ''';

  /// Index for BOM hierarchy queries
  /// Optimizes parent-child BOM relationships
  static const String bomHierarchyIndex = '''
    CREATE INDEX IF NOT EXISTS idx_bom_hierarchy 
    ON bom_items(parent_bom_id, child_bom_id, status);
  ''';

  /// Index for supplier-related queries
  /// Optimizes supplier performance and cost analysis
  static const String bomSupplierIndex = '''
    CREATE INDEX IF NOT EXISTS idx_bom_supplier 
    ON bom_items(supplier_id, status, last_updated);
  ''';

  /// Index for inventory integration
  /// Optimizes inventory availability checks
  static const String bomInventoryIndex = '''
    CREATE INDEX IF NOT EXISTS idx_bom_inventory 
    ON bom_items(item_id, required_quantity, status);
  ''';

  /// Index for audit and history tracking
  /// Optimizes audit queries and change tracking
  static const String bomAuditIndex = '''
    CREATE INDEX IF NOT EXISTS idx_bom_audit 
    ON bom_audit_log(bom_id, action_type, created_at DESC);
  ''';

  /// Get all index creation statements
  static List<String> getAllIndexes() {
    return [
      bomSearchIndex,
      bomItemsSequenceIndex,
      bomItemsCostIndex,
      bomIntegrationIndex,
      bomHierarchyIndex,
      bomSupplierIndex,
      bomInventoryIndex,
      bomAuditIndex,
    ];
  }
}

/// Query optimization hints and strategies
class QueryOptimizer {
  /// Optimize BOM search queries with proper indexing hints
  static String optimizeBomSearchQuery({
    String? status,
    String? bomType,
    String? productId,
    int limit = 50,
    int offset = 0,
  }) {
    final conditions = <String>[];

    if (status != null) conditions.add('status = ?');
    if (bomType != null) conditions.add('bom_type = ?');
    if (productId != null) conditions.add('product_id = ?');

    final whereClause =
        conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';

    return '''
      SELECT * FROM boms 
      $whereClause
      ORDER BY created_at DESC
      LIMIT $limit OFFSET $offset;
    ''';
  }

  /// Optimize BOM items retrieval with cost calculation
  static String optimizeBomItemsWithCostQuery(String bomId) {
    return '''
      SELECT 
        bi.*,
        bi.quantity * bi.cost_per_unit as total_cost,
        ii.available_quantity,
        ii.unit_of_measure
      FROM bom_items bi
      LEFT JOIN inventory_items ii ON bi.item_id = ii.id
      WHERE bi.bom_id = ?
        AND bi.status = 'active'
      ORDER BY bi.sequence_number;
    ''';
  }

  /// Optimize BOM cost aggregation query
  static String optimizeBomCostAggregationQuery(String bomId) {
    return '''
      SELECT 
        COUNT(*) as total_items,
        SUM(quantity * cost_per_unit) as total_cost,
        AVG(cost_per_unit) as avg_unit_cost,
        MAX(cost_per_unit) as max_unit_cost,
        MIN(cost_per_unit) as min_unit_cost
      FROM bom_items 
      WHERE bom_id = ? 
        AND status = 'active';
    ''';
  }

  /// Optimize supplier performance query for BOM items
  static String optimizeSupplierPerformanceQuery(String supplierId) {
    return '''
      SELECT 
        s.name as supplier_name,
        COUNT(bi.id) as total_items,
        AVG(bi.cost_per_unit) as avg_cost,
        AVG(bi.lead_time_days) as avg_lead_time,
        COUNT(CASE WHEN bi.status = 'active' THEN 1 END) as active_items
      FROM bom_items bi
      JOIN suppliers s ON bi.supplier_id = s.id
      WHERE bi.supplier_id = ?
        AND bi.created_at >= DATE('now', '-90 days')
      GROUP BY s.id, s.name;
    ''';
  }

  /// Optimize inventory availability check for BOM
  static String optimizeInventoryAvailabilityQuery(String bomId) {
    return '''
      SELECT 
        bi.item_id,
        bi.item_code,
        bi.item_name,
        bi.quantity as required_quantity,
        COALESCE(ii.available_quantity, 0) as available_quantity,
        CASE 
          WHEN COALESCE(ii.available_quantity, 0) >= bi.quantity 
          THEN 'sufficient' 
          ELSE 'shortage' 
        END as availability_status,
        (bi.quantity - COALESCE(ii.available_quantity, 0)) as shortage_quantity
      FROM bom_items bi
      LEFT JOIN inventory_items ii ON bi.item_id = ii.id
      WHERE bi.bom_id = ?
        AND bi.status = 'active'
      ORDER BY availability_status, shortage_quantity DESC;
    ''';
  }
}

/// Database performance monitoring utilities
class PerformanceMonitor {
  /// Monitor query execution time
  static Future<T> monitorQuery<T>(
    String queryName,
    Future<T> Function() queryFunction,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await queryFunction();
      stopwatch.stop();

      _logQueryPerformance(queryName, stopwatch.elapsedMilliseconds, true);
      return result;
    } catch (e) {
      stopwatch.stop();
      _logQueryPerformance(queryName, stopwatch.elapsedMilliseconds, false);
      rethrow;
    }
  }

  /// Log query performance metrics
  static void _logQueryPerformance(
    String queryName,
    int executionTimeMs,
    bool success,
  ) {
    final status = success ? 'SUCCESS' : 'FAILED';
    print('QUERY_PERF: $queryName - ${executionTimeMs}ms - $status');

    // In production, this would send metrics to monitoring service
    if (executionTimeMs > 1000) {
      print(
          'WARNING: Slow query detected - $queryName took ${executionTimeMs}ms');
    }
  }

  /// Get query performance recommendations
  static List<String> getPerformanceRecommendations() {
    return [
      'Use composite indexes for multi-column WHERE clauses',
      'Limit result sets with LIMIT clause',
      'Use EXISTS instead of IN for subqueries',
      'Avoid SELECT * in production queries',
      'Use prepared statements for repeated queries',
      'Consider query result caching for frequently accessed data',
      'Monitor and analyze slow query logs regularly',
      'Use EXPLAIN QUERY PLAN to analyze query execution',
    ];
  }
}

/// Index maintenance utilities
class IndexMaintenance {
  /// Check if indexes exist and are being used
  static Future<Map<String, bool>> checkIndexUsage() async {
    // This would typically query database statistics
    // For now, return mock data
    return {
      'idx_bom_search': true,
      'idx_bom_items_sequence': true,
      'idx_bom_items_cost': true,
      'idx_bom_integration': true,
      'idx_bom_hierarchy': false, // Example: not being used
      'idx_bom_supplier': true,
      'idx_bom_inventory': true,
      'idx_bom_audit': true,
    };
  }

  /// Get index size and performance statistics
  static Future<Map<String, Map<String, dynamic>>> getIndexStatistics() async {
    // Mock statistics - in production this would query actual DB stats
    return {
      'idx_bom_search': {
        'size_mb': 2.5,
        'rows_examined': 1250,
        'selectivity': 0.85,
        'last_used': DateTime.now().subtract(Duration(minutes: 5)),
      },
      'idx_bom_items_sequence': {
        'size_mb': 1.8,
        'rows_examined': 890,
        'selectivity': 0.92,
        'last_used': DateTime.now().subtract(Duration(minutes: 2)),
      },
      'idx_bom_items_cost': {
        'size_mb': 1.2,
        'rows_examined': 650,
        'selectivity': 0.78,
        'last_used': DateTime.now().subtract(Duration(hours: 1)),
      },
    };
  }

  /// Recommend index optimizations
  static Future<List<String>> getIndexOptimizationRecommendations() async {
    final usage = await checkIndexUsage();
    final recommendations = <String>[];

    for (final entry in usage.entries) {
      if (!entry.value) {
        recommendations.add(
          'Consider dropping unused index: ${entry.key}',
        );
      }
    }

    recommendations.addAll([
      'Review query patterns monthly for new index opportunities',
      'Monitor index selectivity and update statistics regularly',
      'Consider partial indexes for large tables with filtered queries',
      'Evaluate composite index column order based on query patterns',
    ]);

    return recommendations;
  }
}
