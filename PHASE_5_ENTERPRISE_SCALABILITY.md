# Phase 5: Enterprise Integration & Scalability
## Duration: 12-16 weeks | Priority: Low | Risk: Medium

### Overview
Phase 5 focuses on enterprise-grade integration capabilities and scalability enhancements. This phase transforms the procurement module into a fully integrated enterprise solution that can handle large-scale operations, complex integrations, and advanced enterprise requirements.

### Objectives
- Implement enterprise-grade API gateway and microservices architecture
- Add advanced ERP and third-party system integrations
- Create multi-tenant and multi-company support
- Implement advanced security and compliance frameworks
- Add enterprise reporting and business intelligence
- Create disaster recovery and high availability solutions

### Technical Approach
- **Migrate to microservices architecture** while maintaining existing functionality
- **Implement API gateway** for secure external integrations
- **Add enterprise security layers** including SSO and advanced authentication
- **Create scalable data architecture** with distributed databases
- **Maintain backward compatibility** with existing systems

---

## Week 1-4: Microservices Architecture & API Gateway

### 1.1 Microservices Architecture Design
**File**: `lib/core/microservices/procurement_microservice.dart`

```dart
class ProcurementMicroservice {
  final ServiceRegistry _serviceRegistry;
  final MessageBroker _messageBroker;
  final ConfigurationManager _configManager;
  final HealthCheckService _healthCheck;
  final Logger _logger;

  ProcurementMicroservice({
    required ServiceRegistry serviceRegistry,
    required MessageBroker messageBroker,
    required ConfigurationManager configManager,
    required HealthCheckService healthCheck,
    required Logger logger,
  }) : _serviceRegistry = serviceRegistry,
       _messageBroker = messageBroker,
       _configManager = configManager,
       _healthCheck = healthCheck,
       _logger = logger;

  /// Initialize microservice
  Future<void> initialize() async {
    try {
      // Register service with discovery
      await _serviceRegistry.register(ServiceDefinition(
        name: 'procurement-service',
        version: '1.0.0',
        endpoints: [
          '/api/v1/purchase-orders',
          '/api/v1/suppliers',
          '/api/v1/analytics',
          '/api/v1/workflows',
        ],
        healthCheckEndpoint: '/health',
        metadata: {
          'capabilities': ['purchase_orders', 'supplier_management', 'analytics'],
          'dependencies': ['inventory-service', 'finance-service'],
        },
      ));

      // Setup message broker subscriptions
      await _setupMessageSubscriptions();

      // Initialize health checks
      await _setupHealthChecks();

      // Load configuration
      await _loadConfiguration();

      _logger.i('Procurement microservice initialized successfully');
    } catch (error) {
      _logger.e('Failed to initialize procurement microservice: $error');
      rethrow;
    }
  }

  /// Setup message broker subscriptions
  Future<void> _setupMessageSubscriptions() async {
    // Subscribe to inventory events
    await _messageBroker.subscribe(
      topic: 'inventory.stock.low',
      handler: _handleLowStockEvent,
    );

    // Subscribe to production events
    await _messageBroker.subscribe(
      topic: 'production.schedule.changed',
      handler: _handleProductionScheduleChange,
    );

    // Subscribe to finance events
    await _messageBroker.subscribe(
      topic: 'finance.budget.updated',
      handler: _handleBudgetUpdate,
    );

    // Subscribe to supplier events
    await _messageBroker.subscribe(
      topic: 'supplier.status.changed',
      handler: _handleSupplierStatusChange,
    );
  }

  /// Handle low stock events from inventory service
  Future<void> _handleLowStockEvent(Message message) async {
    try {
      final event = LowStockEvent.fromJson(message.payload);
      
      // Trigger automatic reorder if configured
      final autoReorderService = GetIt.instance<AutoReorderService>();
      await autoReorderService.processLowStockEvent(event);

      // Publish procurement event
      await _messageBroker.publish(
        topic: 'procurement.reorder.triggered',
        message: Message(
          id: Uuid().v4(),
          payload: {
            'itemId': event.itemId,
            'currentStock': event.currentQuantity,
            'reorderPoint': event.reorderPoint,
            'triggeredAt': DateTime.now().toIso8601String(),
          },
          timestamp: DateTime.now(),
        ),
      );
    } catch (error) {
      _logger.e('Error handling low stock event: $error');
    }
  }

  /// Setup health checks
  Future<void> _setupHealthChecks() async {
    _healthCheck.addCheck('database', () async {
      // Check database connectivity
      return await _checkDatabaseHealth();
    });

    _healthCheck.addCheck('external_apis', () async {
      // Check external API connectivity
      return await _checkExternalAPIsHealth();
    });

    _healthCheck.addCheck('message_broker', () async {
      // Check message broker connectivity
      return await _messageBroker.healthCheck();
    });

    _healthCheck.addCheck('dependencies', () async {
      // Check dependent services
      return await _checkDependentServices();
    });
  }

  /// Check dependent services health
  Future<HealthStatus> _checkDependentServices() async {
    final dependencies = ['inventory-service', 'finance-service', 'user-service'];
    final healthStatuses = <String, bool>{};

    for (final dependency in dependencies) {
      try {
        final service = await _serviceRegistry.discover(dependency);
        if (service != null) {
          final health = await _checkServiceHealth(service);
          healthStatuses[dependency] = health.isHealthy;
        } else {
          healthStatuses[dependency] = false;
        }
      } catch (error) {
        healthStatuses[dependency] = false;
      }
    }

    final allHealthy = healthStatuses.values.every((status) => status);
    
    return HealthStatus(
      isHealthy: allHealthy,
      details: healthStatuses,
      timestamp: DateTime.now(),
    );
  }
}

@freezed
class ServiceDefinition with _$ServiceDefinition {
  const factory ServiceDefinition({
    required String name,
    required String version,
    required List<String> endpoints,
    required String healthCheckEndpoint,
    required Map<String, dynamic> metadata,
  }) = _ServiceDefinition;

  factory ServiceDefinition.fromJson(Map<String, dynamic> json) =>
      _$ServiceDefinitionFromJson(json);
}

@freezed
class HealthStatus with _$HealthStatus {
  const factory HealthStatus({
    required bool isHealthy,
    required Map<String, dynamic> details,
    required DateTime timestamp,
  }) = _HealthStatus;
}
```

### 1.2 API Gateway Implementation
**File**: `lib/core/api_gateway/procurement_api_gateway.dart`

```dart
class ProcurementAPIGateway {
  final AuthenticationService _authService;
  final RateLimitingService _rateLimiter;
  final RequestValidationService _validator;
  final ResponseTransformationService _transformer;
  final AuditService _auditService;
  final Logger _logger;

  ProcurementAPIGateway({
    required AuthenticationService authService,
    required RateLimitingService rateLimiter,
    required RequestValidationService validator,
    required ResponseTransformationService transformer,
    required AuditService auditService,
    required Logger logger,
  }) : _authService = authService,
       _rateLimiter = rateLimiter,
       _validator = validator,
       _transformer = transformer,
       _auditService = auditService,
       _logger = logger;

  /// Handle incoming API requests
  Future<APIResponse> handleRequest(APIRequest request) async {
    final requestId = Uuid().v4();
    final startTime = DateTime.now();

    try {
      // Log incoming request
      _logger.i('Processing request $requestId: ${request.method} ${request.path}');

      // Rate limiting check
      await _checkRateLimit(request);

      // Authentication and authorization
      final authContext = await _authenticateRequest(request);

      // Request validation
      await _validateRequest(request, authContext);

      // Route to appropriate service
      final response = await _routeRequest(request, authContext);

      // Transform response
      final transformedResponse = await _transformer.transform(response, authContext);

      // Audit logging
      await _auditRequest(request, transformedResponse, authContext, requestId);

      // Log successful completion
      final duration = DateTime.now().difference(startTime);
      _logger.i('Request $requestId completed in ${duration.inMilliseconds}ms');

      return transformedResponse;

    } catch (error) {
      // Error handling and logging
      final duration = DateTime.now().difference(startTime);
      _logger.e('Request $requestId failed after ${duration.inMilliseconds}ms: $error');

      // Audit failed request
      await _auditFailedRequest(request, error, requestId);

      return _createErrorResponse(error, requestId);
    }
  }

  /// Check rate limiting
  Future<void> _checkRateLimit(APIRequest request) async {
    final clientId = _extractClientId(request);
    final isAllowed = await _rateLimiter.isAllowed(
      clientId: clientId,
      endpoint: request.path,
      method: request.method,
    );

    if (!isAllowed) {
      throw RateLimitExceededException('Rate limit exceeded for client $clientId');
    }
  }

  /// Authenticate request
  Future<AuthenticationContext> _authenticateRequest(APIRequest request) async {
    final authHeader = request.headers['Authorization'];
    
    if (authHeader == null) {
      throw UnauthorizedException('Missing authorization header');
    }

    // Support multiple authentication methods
    if (authHeader.startsWith('Bearer ')) {
      return await _authService.validateJWTToken(authHeader.substring(7));
    } else if (authHeader.startsWith('ApiKey ')) {
      return await _authService.validateApiKey(authHeader.substring(7));
    } else {
      throw UnauthorizedException('Unsupported authentication method');
    }
  }

  /// Route request to appropriate service
  Future<APIResponse> _routeRequest(
    APIRequest request,
    AuthenticationContext authContext,
  ) async {
    final route = _determineRoute(request.path);
    
    switch (route.service) {
      case 'purchase-orders':
        return await _routeToPurchaseOrderService(request, authContext, route);
      case 'suppliers':
        return await _routeToSupplierService(request, authContext, route);
      case 'analytics':
        return await _routeToAnalyticsService(request, authContext, route);
      case 'workflows':
        return await _routeToWorkflowService(request, authContext, route);
      default:
        throw NotFoundException('Service not found: ${route.service}');
    }
  }

  /// Route to purchase order service
  Future<APIResponse> _routeToPurchaseOrderService(
    APIRequest request,
    AuthenticationContext authContext,
    RouteInfo route,
  ) async {
    final poService = GetIt.instance<PurchaseOrderService>();
    
    switch (request.method) {
      case 'GET':
        if (route.resourceId != null) {
          final po = await poService.getPurchaseOrder(route.resourceId!);
          return APIResponse.success(data: po?.toJson());
        } else {
          final filters = _extractFilters(request.queryParameters);
          final pos = await poService.getPurchaseOrders(filters: filters);
          return APIResponse.success(data: pos.map((po) => po.toJson()).toList());
        }
      
      case 'POST':
        final poData = request.body as Map<String, dynamic>;
        final po = PurchaseOrder.fromJson(poData);
        final createdPO = await poService.createPurchaseOrder(po, authContext.userId);
        return APIResponse.success(
          data: createdPO.toJson(),
          statusCode: 201,
        );
      
      case 'PUT':
        if (route.resourceId == null) {
          throw BadRequestException('Resource ID required for PUT operation');
        }
        final poData = request.body as Map<String, dynamic>;
        final po = PurchaseOrder.fromJson(poData);
        final updatedPO = await poService.updatePurchaseOrder(route.resourceId!, po);
        return APIResponse.success(data: updatedPO.toJson());
      
      case 'DELETE':
        if (route.resourceId == null) {
          throw BadRequestException('Resource ID required for DELETE operation');
        }
        await poService.deletePurchaseOrder(route.resourceId!);
        return APIResponse.success(statusCode: 204);
      
      default:
        throw MethodNotAllowedException('Method ${request.method} not allowed');
    }
  }

  /// Create error response
  APIResponse _createErrorResponse(dynamic error, String requestId) {
    if (error is APIException) {
      return APIResponse.error(
        message: error.message,
        statusCode: error.statusCode,
        errorCode: error.errorCode,
        requestId: requestId,
      );
    } else {
      return APIResponse.error(
        message: 'Internal server error',
        statusCode: 500,
        errorCode: 'INTERNAL_ERROR',
        requestId: requestId,
      );
    }
  }

  /// Audit request
  Future<void> _auditRequest(
    APIRequest request,
    APIResponse response,
    AuthenticationContext authContext,
    String requestId,
  ) async {
    await _auditService.logAPIAccess(
      AuditLog(
        id: requestId,
        userId: authContext.userId,
        action: '${request.method} ${request.path}',
        resource: _extractResourceFromPath(request.path),
        timestamp: DateTime.now(),
        ipAddress: request.clientIP,
        userAgent: request.headers['User-Agent'],
        statusCode: response.statusCode,
        details: {
          'request_size': request.body?.toString().length ?? 0,
          'response_size': response.data?.toString().length ?? 0,
        },
      ),
    );
  }
}

@freezed
class APIRequest with _$APIRequest {
  const factory APIRequest({
    required String method,
    required String path,
    required Map<String, String> headers,
    required Map<String, String> queryParameters,
    required String clientIP,
    dynamic body,
  }) = _APIRequest;
}

@freezed
class APIResponse with _$APIResponse {
  const factory APIResponse({
    required int statusCode,
    required Map<String, String> headers,
    dynamic data,
    String? message,
    String? errorCode,
    String? requestId,
  }) = _APIResponse;

  factory APIResponse.success({
    dynamic data,
    int statusCode = 200,
    Map<String, String>? headers,
  }) = _APIResponseSuccess;

  factory APIResponse.error({
    required String message,
    required int statusCode,
    required String errorCode,
    String? requestId,
  }) = _APIResponseError;
}

@freezed
class RouteInfo with _$RouteInfo {
  const factory RouteInfo({
    required String service,
    String? resourceId,
    String? action,
    Map<String, String>? parameters,
  }) = _RouteInfo;
}
```

---

## Week 5-8: Enterprise ERP Integration

### 2.1 ERP Integration Framework
**File**: `lib/core/integrations/erp_integration_framework.dart`

```dart
class ERPIntegrationFramework {
  final Map<String, ERPConnector> _connectors = {};
  final DataMappingService _mappingService;
  final SynchronizationService _syncService;
  final ConflictResolutionService _conflictResolver;
  final Logger _logger;

  ERPIntegrationFramework({
    required DataMappingService mappingService,
    required SynchronizationService syncService,
    required ConflictResolutionService conflictResolver,
    required Logger logger,
  }) : _mappingService = mappingService,
       _syncService = syncService,
       _conflictResolver = conflictResolver,
       _logger = logger;

  /// Register ERP connector
  void registerConnector(String erpType, ERPConnector connector) {
    _connectors[erpType] = connector;
    _logger.i('Registered ERP connector for $erpType');
  }

  /// Initialize integration with specific ERP
  Future<void> initializeIntegration({
    required String erpType,
    required ERPConfiguration configuration,
  }) async {
    final connector = _connectors[erpType];
    if (connector == null) {
      throw Exception('No connector found for ERP type: $erpType');
    }

    try {
      // Initialize connector
      await connector.initialize(configuration);

      // Setup data mappings
      await _setupDataMappings(erpType, configuration);

      // Start synchronization
      await _startSynchronization(erpType);

      _logger.i('ERP integration initialized for $erpType');
    } catch (error) {
      _logger.e('Failed to initialize ERP integration for $erpType: $error');
      rethrow;
    }
  }

  /// Synchronize procurement data with ERP
  Future<SynchronizationResult> synchronizeProcurementData({
    required String erpType,
    required SynchronizationScope scope,
  }) async {
    final connector = _connectors[erpType];
    if (connector == null) {
      throw Exception('No connector found for ERP type: $erpType');
    }

    final result = SynchronizationResult(
      erpType: erpType,
      scope: scope,
      startTime: DateTime.now(),
    );

    try {
      // Synchronize purchase orders
      if (scope.includePurchaseOrders) {
        final poResult = await _synchronizePurchaseOrders(connector);
        result.addEntityResult('purchase_orders', poResult);
      }

      // Synchronize suppliers
      if (scope.includeSuppliers) {
        final supplierResult = await _synchronizeSuppliers(connector);
        result.addEntityResult('suppliers', supplierResult);
      }

      // Synchronize items/materials
      if (scope.includeItems) {
        final itemResult = await _synchronizeItems(connector);
        result.addEntityResult('items', itemResult);
      }

      // Synchronize budgets
      if (scope.includeBudgets) {
        final budgetResult = await _synchronizeBudgets(connector);
        result.addEntityResult('budgets', budgetResult);
      }

      result.endTime = DateTime.now();
      result.status = SynchronizationStatus.completed;

      _logger.i('ERP synchronization completed for $erpType');
      return result;

    } catch (error) {
      result.endTime = DateTime.now();
      result.status = SynchronizationStatus.failed;
      result.error = error.toString();

      _logger.e('ERP synchronization failed for $erpType: $error');
      return result;
    }
  }

  /// Synchronize purchase orders
  Future<EntitySyncResult> _synchronizePurchaseOrders(ERPConnector connector) async {
    final result = EntitySyncResult(entityType: 'purchase_orders');

    try {
      // Get local purchase orders that need sync
      final localPOs = await _getLocalPOsForSync();
      
      // Get ERP purchase orders
      final erpPOs = await connector.getPurchaseOrders();

      // Perform bidirectional sync
      for (final localPO in localPOs) {
        final erpPO = erpPOs.firstWhere(
          (po) => po.externalId == localPO.id,
          orElse: () => null,
        );

        if (erpPO == null) {
          // Create in ERP
          final mappedPO = await _mappingService.mapToERP(localPO, connector.erpType);
          final createdPO = await connector.createPurchaseOrder(mappedPO);
          
          // Update local PO with ERP ID
          await _updateLocalPOWithERPId(localPO.id, createdPO.id);
          result.created++;
        } else {
          // Check for conflicts and resolve
          final conflict = await _detectPOConflict(localPO, erpPO);
          if (conflict != null) {
            final resolution = await _conflictResolver.resolvePOConflict(conflict);
            await _applyConflictResolution(resolution);
            result.conflicts++;
          } else {
            // Update if needed
            if (_isPOUpdateNeeded(localPO, erpPO)) {
              final mappedPO = await _mappingService.mapToERP(localPO, connector.erpType);
              await connector.updatePurchaseOrder(erpPO.id, mappedPO);
              result.updated++;
            }
          }
        }
      }

      // Handle ERP POs not in local system
      for (final erpPO in erpPOs) {
        final localPO = localPOs.firstWhere(
          (po) => po.id == erpPO.externalId,
          orElse: () => null,
        );

        if (localPO == null) {
          // Import from ERP
          final mappedPO = await _mappingService.mapFromERP(erpPO, connector.erpType);
          await _createLocalPO(mappedPO);
          result.imported++;
        }
      }

      result.status = EntitySyncStatus.completed;
      return result;

    } catch (error) {
      result.status = EntitySyncStatus.failed;
      result.error = error.toString();
      return result;
    }
  }

  /// Setup data mappings for ERP
  Future<void> _setupDataMappings(String erpType, ERPConfiguration configuration) async {
    // Purchase Order mappings
    await _mappingService.setupMapping(
      sourceType: 'procurement.purchase_order',
      targetType: '$erpType.purchase_order',
      mappingRules: configuration.purchaseOrderMappings,
    );

    // Supplier mappings
    await _mappingService.setupMapping(
      sourceType: 'procurement.supplier',
      targetType: '$erpType.vendor',
      mappingRules: configuration.supplierMappings,
    );

    // Item mappings
    await _mappingService.setupMapping(
      sourceType: 'inventory.item',
      targetType: '$erpType.material',
      mappingRules: configuration.itemMappings,
    );
  }
}

/// SAP ERP Connector Implementation
class SAPERPConnector implements ERPConnector {
  final SAPClient _sapClient;
  final Logger _logger;

  SAPERPConnector({
    required SAPClient sapClient,
    required Logger logger,
  }) : _sapClient = sapClient,
       _logger = logger;

  @override
  String get erpType => 'SAP';

  @override
  Future<void> initialize(ERPConfiguration configuration) async {
    await _sapClient.connect(
      host: configuration.host,
      username: configuration.username,
      password: configuration.password,
      client: configuration.clientId,
    );
  }

  @override
  Future<List<ERPPurchaseOrder>> getPurchaseOrders({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final sapPOs = await _sapClient.callFunction(
      'BAPI_PO_GETITEMS',
      parameters: {
        'PURCHASEORDER': '',
        'ITEMS': 'X',
        'ACCOUNT_ASSIGNMENT': 'X',
        if (fromDate != null) 'CREATED_FROM': _formatSAPDate(fromDate),
        if (toDate != null) 'CREATED_TO': _formatSAPDate(toDate),
      },
    );

    return sapPOs.map((po) => _mapSAPPOToERP(po)).toList();
  }

  @override
  Future<ERPPurchaseOrder> createPurchaseOrder(ERPPurchaseOrder purchaseOrder) async {
    final result = await _sapClient.callFunction(
      'BAPI_PO_CREATE1',
      parameters: {
        'POHEADER': _mapERPPOToSAPHeader(purchaseOrder),
        'POITEM': _mapERPPOToSAPItems(purchaseOrder),
        'RETURN': [],
      },
    );

    if (result['RETURN'].any((msg) => msg['TYPE'] == 'E')) {
      final errors = result['RETURN']
          .where((msg) => msg['TYPE'] == 'E')
          .map((msg) => msg['MESSAGE'])
          .join(', ');
      throw Exception('SAP PO creation failed: $errors');
    }

    return purchaseOrder.copyWith(
      id: result['PURCHASEORDER'],
      externalId: purchaseOrder.id,
    );
  }

  @override
  Future<void> updatePurchaseOrder(String id, ERPPurchaseOrder purchaseOrder) async {
    await _sapClient.callFunction(
      'BAPI_PO_CHANGE',
      parameters: {
        'PURCHASEORDER': id,
        'POHEADER': _mapERPPOToSAPHeader(purchaseOrder),
        'POHEADERX': _createSAPChangeFlags(purchaseOrder),
        'RETURN': [],
      },
    );
  }

  /// Map SAP PO to ERP format
  ERPPurchaseOrder _mapSAPPOToERP(Map<String, dynamic> sapPO) {
    return ERPPurchaseOrder(
      id: sapPO['EBELN'],
      externalId: sapPO['EXTERNAL_ID'],
      number: sapPO['EBELN'],
      supplierCode: sapPO['LIFNR'],
      supplierName: sapPO['NAME1'],
      totalAmount: double.parse(sapPO['NETWR'] ?? '0'),
      currency: sapPO['WAERS'],
      createdDate: _parseSAPDate(sapPO['BEDAT']),
      status: _mapSAPStatus(sapPO['BSTYP']),
      items: _mapSAPItems(sapPO['ITEMS'] ?? []),
    );
  }
}

@freezed
class ERPConfiguration with _$ERPConfiguration {
  const factory ERPConfiguration({
    required String erpType,
    required String host,
    required String username,
    required String password,
    String? clientId,
    required Map<String, FieldMapping> purchaseOrderMappings,
    required Map<String, FieldMapping> supplierMappings,
    required Map<String, FieldMapping> itemMappings,
    Map<String, dynamic>? customSettings,
  }) = _ERPConfiguration;
}

@freezed
class SynchronizationResult with _$SynchronizationResult {
  const factory SynchronizationResult({
    required String erpType,
    required SynchronizationScope scope,
    required DateTime startTime,
    DateTime? endTime,
    @Default(SynchronizationStatus.running) SynchronizationStatus status,
    @Default({}) Map<String, EntitySyncResult> entityResults,
    String? error,
  }) = _SynchronizationResult;

  void addEntityResult(String entityType, EntitySyncResult result) {
    entityResults[entityType] = result;
  }
}

@freezed
class EntitySyncResult with _$EntitySyncResult {
  const factory EntitySyncResult({
    required String entityType,
    @Default(0) int created,
    @Default(0) int updated,
    @Default(0) int imported,
    @Default(0) int conflicts,
    @Default(EntitySyncStatus.running) EntitySyncStatus status,
    String? error,
  }) = _EntitySyncResult;
}

enum SynchronizationStatus { running, completed, failed, partial }
enum EntitySyncStatus { running, completed, failed }

abstract class ERPConnector {
  String get erpType;
  Future<void> initialize(ERPConfiguration configuration);
  Future<List<ERPPurchaseOrder>> getPurchaseOrders({DateTime? fromDate, DateTime? toDate});
  Future<ERPPurchaseOrder> createPurchaseOrder(ERPPurchaseOrder purchaseOrder);
  Future<void> updatePurchaseOrder(String id, ERPPurchaseOrder purchaseOrder);
}
```

---

## Week 9-12: Multi-Tenant Architecture

### 3.1 Multi-Tenant Data Architecture
**File**: `lib/core/multi_tenant/tenant_management_service.dart`

```dart
class TenantManagementService {
  final TenantRepository _tenantRepository;
  final DatabaseManager _databaseManager;
  final CacheManager _cacheManager;
  final SecurityService _securityService;
  final Logger _logger;

  TenantManagementService({
    required TenantRepository tenantRepository,
    required DatabaseManager databaseManager,
    required CacheManager cacheManager,
    required SecurityService securityService,
    required Logger logger,
  }) : _tenantRepository = tenantRepository,
       _databaseManager = databaseManager,
       _cacheManager = cacheManager,
       _securityService = securityService,
       _logger = logger;

  /// Create new tenant
  Future<Tenant> createTenant({
    required String name,
    required String domain,
    required TenantConfiguration configuration,
    required String adminUserId,
  }) async {
    try {
      // Validate tenant data
      await _validateTenantData(name, domain);

      // Create tenant record
      final tenant = Tenant(
        id: Uuid().v4(),
        name: name,
        domain: domain,
        status: TenantStatus.active,
        configuration: configuration,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        adminUserId: adminUserId,
      );

      // Setup tenant database schema
      await _setupTenantSchema(tenant);

      // Initialize tenant data
      await _initializeTenantData(tenant);

      // Setup tenant security
      await _setupTenantSecurity(tenant);

      // Save tenant
      final savedTenant = await _tenantRepository.createTenant(tenant);

      // Cache tenant data
      await _cacheManager.set('tenant:${tenant.id}', savedTenant);
      await _cacheManager.set('tenant:domain:${domain}', savedTenant);

      _logger.i('Created tenant: ${tenant.name} (${tenant.id})');
      return savedTenant;

    } catch (error) {
      _logger.e('Failed to create tenant $name: $error');
      rethrow;
    }
  }

  /// Get tenant by domain
  Future<Tenant?> getTenantByDomain(String domain) async {
    // Check cache first
    final cached = await _cacheManager.get<Tenant>('tenant:domain:$domain');
    if (cached != null) return cached;

    // Query database
    final tenant = await _tenantRepository.getTenantByDomain(domain);
    
    if (tenant != null) {
      // Cache for future requests
      await _cacheManager.set('tenant:domain:$domain', tenant);
      await _cacheManager.set('tenant:${tenant.id}', tenant);
    }

    return tenant;
  }

  /// Setup tenant database schema
  Future<void> _setupTenantSchema(Tenant tenant) async {
    final schemaName = 'tenant_${tenant.id.replaceAll('-', '_')}';
    
    // Create tenant schema
    await _databaseManager.createSchema(schemaName);

    // Create tenant-specific tables
    await _createTenantTables(schemaName);

    // Setup indexes
    await _createTenantIndexes(schemaName);

    // Setup permissions
    await _setupTenantPermissions(schemaName, tenant);
  }

  /// Create tenant-specific tables
  Future<void> _createTenantTables(String schemaName) async {
    final tables = [
      // Procurement tables
      '''
      CREATE TABLE $schemaName.purchase_orders (
        id UUID PRIMARY KEY,
        po_number VARCHAR(50) UNIQUE NOT NULL,
        supplier_id UUID NOT NULL,
        status VARCHAR(20) NOT NULL,
        total_amount DECIMAL(15,2) NOT NULL,
        created_at TIMESTAMP NOT NULL,
        updated_at TIMESTAMP NOT NULL,
        created_by UUID NOT NULL
      )
      ''',
      
      '''
      CREATE TABLE $schemaName.purchase_order_items (
        id UUID PRIMARY KEY,
        purchase_order_id UUID NOT NULL,
        item_id UUID NOT NULL,
        quantity DECIMAL(10,3) NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        total_price DECIMAL(15,2) NOT NULL,
        FOREIGN KEY (purchase_order_id) REFERENCES $schemaName.purchase_orders(id)
      )
      ''',
      
      '''
      CREATE TABLE $schemaName.suppliers (
        id UUID PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        code VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(255),
        phone VARCHAR(50),
        address JSONB,
        status VARCHAR(20) NOT NULL,
        created_at TIMESTAMP NOT NULL,
        updated_at TIMESTAMP NOT NULL
      )
      ''',
      
      '''
      CREATE TABLE $schemaName.procurement_analytics (
        id UUID PRIMARY KEY,
        metric_name VARCHAR(100) NOT NULL,
        metric_value DECIMAL(15,2) NOT NULL,
        metric_date DATE NOT NULL,
        dimensions JSONB,
        created_at TIMESTAMP NOT NULL
      )
      ''',
    ];

    for (final tableSQL in tables) {
      await _databaseManager.execute(tableSQL);
    }
  }

  /// Initialize tenant data
  Future<void> _initializeTenantData(Tenant tenant) async {
    final schemaName = 'tenant_${tenant.id.replaceAll('-', '_')}';

    // Create default procurement categories
    await _createDefaultCategories(schemaName);

    // Create default workflow configurations
    await _createDefaultWorkflows(schemaName);

    // Create default approval stages
    await _createDefaultApprovalStages(schemaName);

    // Setup default settings
    await _createDefaultSettings(schemaName, tenant.configuration);
  }

  /// Create default procurement categories
  Future<void> _createDefaultCategories(String schemaName) async {
    final categories = [
      {'name': 'Raw Materials', 'code': 'RAW_MAT', 'description': 'Raw materials for production'},
      {'name': 'Office Supplies', 'code': 'OFFICE', 'description': 'Office supplies and equipment'},
      {'name': 'Maintenance', 'code': 'MAINT', 'description': 'Maintenance and repair items'},
      {'name': 'Services', 'code': 'SERVICES', 'description': 'Professional services'},
    ];

    for (final category in categories) {
      await _databaseManager.execute('''
        INSERT INTO $schemaName.procurement_categories (id, name, code, description, created_at)
        VALUES (?, ?, ?, ?, ?)
      ''', [
        Uuid().v4(),
        category['name'],
        category['code'],
        category['description'],
        DateTime.now(),
      ]);
    }
  }
}

@freezed
class Tenant with _$Tenant {
  const factory Tenant({
    required String id,
    required String name,
    required String domain,
    required TenantStatus status,
    required TenantConfiguration configuration,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String adminUserId,
    Map<String, dynamic>? metadata,
  }) = _Tenant;

  factory Tenant.fromJson(Map<String, dynamic> json) =>
      _$TenantFromJson(json);
}

@freezed
class TenantConfiguration with _$TenantConfiguration {
  const factory TenantConfiguration({
    required String timezone,
    required String currency,
    required String language,
    @Default(TenantIsolationLevel.schema) TenantIsolationLevel isolationLevel,
    @Default({}) Map<String, dynamic> procurementSettings,
    @Default({}) Map<String, dynamic> integrationSettings,
    @Default({}) Map<String, dynamic> securitySettings,
    @Default({}) Map<String, dynamic> customSettings,
  }) = _TenantConfiguration;

  factory TenantConfiguration.fromJson(Map<String, dynamic> json) =>
      _$TenantConfigurationFromJson(json);
}

enum TenantStatus { active, suspended, inactive }
enum TenantIsolationLevel { shared, schema, database }
```

### 3.2 Tenant-Aware Data Access Layer
**File**: `lib/core/multi_tenant/tenant_aware_repository.dart`

```dart
abstract class TenantAwareRepository<T> {
  final DatabaseManager _databaseManager;
  final TenantContext _tenantContext;
  final Logger _logger;

  TenantAwareRepository({
    required DatabaseManager databaseManager,
    required TenantContext tenantContext,
    required Logger logger,
  }) : _databaseManager = databaseManager,
       _tenantContext = tenantContext,
       _logger = logger;

  /// Get tenant-specific schema name
  String get schemaName {
    final tenantId = _tenantContext.currentTenant?.id;
    if (tenantId == null) {
      throw Exception('No tenant context available');
    }
    return 'tenant_${tenantId.replaceAll('-', '_')}';
  }

  /// Execute query with tenant context
  Future<List<Map<String, dynamic>>> query(
    String sql,
    List<dynamic>? parameters,
  ) async {
    final tenantAwareSQL = _addTenantContext(sql);
    return await _databaseManager.query(tenantAwareSQL, parameters);
  }

  /// Execute command with tenant context
  Future<int> execute(
    String sql,
    List<dynamic>? parameters,
  ) async {
    final tenantAwareSQL = _addTenantContext(sql);
    return await _databaseManager.execute(tenantAwareSQL, parameters);
  }

  /// Add tenant context to SQL
  String _addTenantContext(String sql) {
    // Replace table references with schema-qualified names
    return sql.replaceAllMapped(
      RegExp(r'\b(purchase_orders|suppliers|procurement_analytics)\b'),
      (match) => '$schemaName.${match.group(1)}',
    );
  }

  /// Validate tenant access
  void _validateTenantAccess() {
    if (_tenantContext.currentTenant == null) {
      throw Exception('No tenant context available');
    }

    if (_tenantContext.currentTenant!.status != TenantStatus.active) {
      throw Exception('Tenant is not active');
    }
  }

  // Abstract methods to be implemented by concrete repositories
  Future<T?> findById(String id);
  Future<List<T>> findAll({Map<String, dynamic>? filters});
  Future<T> create(T entity);
  Future<T> update(String id, T entity);
  Future<void> delete(String id);
}

class TenantAwarePurchaseOrderRepository extends TenantAwareRepository<PurchaseOrder> {
  TenantAwarePurchaseOrderRepository({
    required DatabaseManager databaseManager,
    required TenantContext tenantContext,
    required Logger logger,
  }) : super(
          databaseManager: databaseManager,
          tenantContext: tenantContext,
          logger: logger,
        );

  @override
  Future<PurchaseOrder?> findById(String id) async {
    _validateTenantAccess();

    final results = await query('''
      SELECT po.*, s.name as supplier_name
      FROM purchase_orders po
      LEFT JOIN suppliers s ON po.supplier_id = s.id
      WHERE po.id = ?
    ''', [id]);

    if (results.isEmpty) return null;

    return _mapToPurchaseOrder(results.first);
  }

  @override
  Future<List<PurchaseOrder>> findAll({Map<String, dynamic>? filters}) async {
    _validateTenantAccess();

    var sql = '''
      SELECT po.*, s.name as supplier_name
      FROM purchase_orders po
      LEFT JOIN suppliers s ON po.supplier_id = s.id
      WHERE 1=1
    ''';

    final parameters = <dynamic>[];

    // Apply filters
    if (filters != null) {
      if (filters['status'] != null) {
        sql += ' AND po.status = ?';
        parameters.add(filters['status']);
      }

      if (filters['supplier_id'] != null) {
        sql += ' AND po.supplier_id = ?';
        parameters.add(filters['supplier_id']);
      }

      if (filters['from_date'] != null) {
        sql += ' AND po.created_at >= ?';
        parameters.add(filters['from_date']);
      }

      if (filters['to_date'] != null) {
        sql += ' AND po.created_at <= ?';
        parameters.add(filters['to_date']);
      }
    }

    sql += ' ORDER BY po.created_at DESC';

    final results = await query(sql, parameters);
    return results.map(_mapToPurchaseOrder).toList();
  }

  @override
  Future<PurchaseOrder> create(PurchaseOrder entity) async {
    _validateTenantAccess();

    final id = Uuid().v4();
    final now = DateTime.now();

    await execute('''
      INSERT INTO purchase_orders (
        id, po_number, supplier_id, status, total_amount,
        created_at, updated_at, created_by
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      id,
      entity.poNumber,
      entity.supplierId,
      entity.status.toString(),
      entity.totalAmount,
      now,
      now,
      _tenantContext.currentUser?.id,
    ]);

    // Create purchase order items
    for (final item in entity.items) {
      await execute('''
        INSERT INTO purchase_order_items (
          id, purchase_order_id, item_id, quantity, unit_price, total_price
        ) VALUES (?, ?, ?, ?, ?, ?)
      ''', [
        Uuid().v4(),
        id,
        item.itemId,
        item.quantity,
        item.unitPrice,
        item.totalPrice,
      ]);
    }

    return entity.copyWith(id: id, createdAt: now, updatedAt: now);
  }

  @override
  Future<PurchaseOrder> update(String id, PurchaseOrder entity) async {
    _validateTenantAccess();

    final now = DateTime.now();

    await execute('''
      UPDATE purchase_orders SET
        supplier_id = ?, status = ?, total_amount = ?, updated_at = ?
      WHERE id = ?
    ''', [
      entity.supplierId,
      entity.status.toString(),
      entity.totalAmount,
      now,
      id,
    ]);

    return entity.copyWith(id: id, updatedAt: now);
  }

  @override
  Future<void> delete(String id) async {
    _validateTenantAccess();

    // Delete items first (foreign key constraint)
    await execute('DELETE FROM purchase_order_items WHERE purchase_order_id = ?', [id]);
    
    // Delete purchase order
    await execute('DELETE FROM purchase_orders WHERE id = ?', [id]);
  }

  PurchaseOrder _mapToPurchaseOrder(Map<String, dynamic> row) {
    return PurchaseOrder(
      id: row['id'],
      poNumber: row['po_number'],
      supplierId: row['supplier_id'],
      supplierName: row['supplier_name'],
      status: PurchaseOrderStatus.values.firstWhere(
        (s) => s.toString() == row['status'],
      ),
      totalAmount: row['total_amount'],
      createdAt: row['created_at'],
      updatedAt: row['updated_at'],
      items: [], // Load separately if needed
    );
  }
}

@freezed
class TenantContext with _$TenantContext {
  const factory TenantContext({
    Tenant? currentTenant,
    User? currentUser,
    Map<String, dynamic>? permissions,
  }) = _TenantContext;
}
```

---

## Week 13-16: Enterprise Security & Compliance

### 4.1 Advanced Security Framework
**File**: `lib/core/security/enterprise_security_service.dart`

```dart
class EnterpriseSecurityService {
  final EncryptionService _encryptionService;
  final AuditService _auditService;
  final ComplianceService _complianceService;
  final ThreatDetectionService _threatDetection;
  final Logger _logger;

  EnterpriseSecurityService({
    required EncryptionService encryptionService,
    required AuditService auditService,
    required ComplianceService complianceService,
    required ThreatDetectionService threatDetection,
    required Logger logger,
  }) : _encryptionService = encryptionService,
       _auditService = auditService,
       _complianceService = complianceService,
       _threatDetection = threatDetection,
       _logger = logger;

  /// Encrypt sensitive procurement data
  Future<String> encryptSensitiveData(
    String data,
    DataClassification classification,
  ) async {
    final encryptionKey = await _getEncryptionKey(classification);
    return await _encryptionService.encrypt(data, encryptionKey);
  }

  /// Decrypt sensitive procurement data
  Future<String> decryptSensitiveData(
    String encryptedData,
    DataClassification classification,
  ) async {
    final encryptionKey = await _getEncryptionKey(classification);
    return await _encryptionService.decrypt(encryptedData, encryptionKey);
  }

  /// Validate data access permissions
  Future<bool> validateDataAccess({
    required String userId,
    required String resourceType,
    required String resourceId,
    required AccessType accessType,
    required TenantContext tenantContext,
  }) async {
    try {
      // Check basic permissions
      final hasPermission = await _checkBasicPermissions(
        userId,
        resourceType,
        accessType,
        tenantContext,
      );

      if (!hasPermission) return false;

      // Check resource-specific permissions
      final hasResourceAccess = await _checkResourceAccess(
        userId,
        resourceType,
        resourceId,
        accessType,
        tenantContext,
      );

      if (!hasResourceAccess) return false;

      // Check compliance requirements
      final isCompliant = await _complianceService.validateAccess(
        userId: userId,
        resourceType: resourceType,
        resourceId: resourceId,
        accessType: accessType,
        tenantId: tenantContext.currentTenant?.id,
      );

      if (!isCompliant) return false;

      // Log access attempt
      await _auditService.logDataAccess(
        DataAccessLog(
          userId: userId,
          resourceType: resourceType,
          resourceId: resourceId,
          accessType: accessType,
          granted: true,
          timestamp: DateTime.now(),
          tenantId: tenantContext.currentTenant?.id,
        ),
      );

      return true;

    } catch (error) {
      _logger.e('Error validating data access: $error');
      
      // Log failed access attempt
      await _auditService.logDataAccess(
        DataAccessLog(
          userId: userId,
          resourceType: resourceType,
          resourceId: resourceId,
          accessType: accessType,
          granted: false,
          timestamp: DateTime.now(),
          tenantId: tenantContext.currentTenant?.id,
          error: error.toString(),
        ),
      );

      return false;
    }
  }

  /// Monitor for security threats
  Stream<SecurityThreat> monitorSecurityThreats() {
    return _threatDetection.watchThreats().where((threat) {
      // Filter for procurement-related threats
      return threat.category == ThreatCategory.dataAccess ||
             threat.category == ThreatCategory.privilegeEscalation ||
             threat.category == ThreatCategory.dataExfiltration;
    });
  }

  /// Generate compliance report
  Future<ComplianceReport> generateComplianceReport({
    required String tenantId,
    required DateTime startDate,
    required DateTime endDate,
    required List<ComplianceFramework> frameworks,
  }) async {
    final report = ComplianceReport(
      tenantId: tenantId,
      reportPeriod: DateRange(startDate, endDate),
      frameworks: frameworks,
      generatedAt: DateTime.now(),
    );

    for (final framework in frameworks) {
      final assessment = await _assessFrameworkCompliance(
        tenantId,
        framework,
        startDate,
        endDate,
      );
      report.addFrameworkAssessment(framework, assessment);
    }

    return report;
  }

  /// Assess compliance with specific framework
  Future<FrameworkAssessment> _assessFrameworkCompliance(
    String tenantId,
    ComplianceFramework framework,
    DateTime startDate,
    DateTime endDate,
  ) async {
    switch (framework) {
      case ComplianceFramework.sox:
        return await _assessSOXCompliance(tenantId, startDate, endDate);
      case ComplianceFramework.gdpr:
        return await _assessGDPRCompliance(tenantId, startDate, endDate);
      case ComplianceFramework.iso27001:
        return await _assessISO27001Compliance(tenantId, startDate, endDate);
      case ComplianceFramework.hipaa:
        return await _assessHIPAACompliance(tenantId, startDate, endDate);
      default:
        throw Exception('Unsupported compliance framework: $framework');
    }
  }

  /// Assess SOX compliance
  Future<FrameworkAssessment> _assessSOXCompliance(
    String tenantId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final controls = <ComplianceControl>[];

    // Control 1: Segregation of duties
    final segregationControl = await _assessSegregationOfDuties(tenantId, startDate, endDate);
    controls.add(segregationControl);

    // Control 2: Authorization controls
    final authorizationControl = await _assessAuthorizationControls(tenantId, startDate, endDate);
    controls.add(authorizationControl);

    // Control 3: Data integrity
    final dataIntegrityControl = await _assessDataIntegrity(tenantId, startDate, endDate);
    controls.add(dataIntegrityControl);

    // Control 4: Audit trail
    final auditTrailControl = await _assessAuditTrail(tenantId, startDate, endDate);
    controls.add(auditTrailControl);

    final overallScore = controls.fold<double>(
      0.0,
      (sum, control) => sum + control.score,
    ) / controls.length;

    return FrameworkAssessment(
      framework: ComplianceFramework.sox,
      overallScore: overallScore,
      controls: controls,
      complianceLevel: _scoreToComplianceLevel(overallScore),
      assessedAt: DateTime.now(),
    );
  }

  /// Assess GDPR compliance
  Future<FrameworkAssessment> _assessGDPRCompliance(
    String tenantId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final controls = <ComplianceControl>[];

    // Control 1: Data protection by design
    final dataProtectionControl = await _assessDataProtectionByDesign(tenantId);
    controls.add(dataProtectionControl);

    // Control 2: Consent management
    final consentControl = await _assessConsentManagement(tenantId, startDate, endDate);
    controls.add(consentControl);

    // Control 3: Data subject rights
    final dataSubjectRightsControl = await _assessDataSubjectRights(tenantId, startDate, endDate);
    controls.add(dataSubjectRightsControl);

    // Control 4: Data breach notification
    final breachNotificationControl = await _assessBreachNotification(tenantId, startDate, endDate);
    controls.add(breachNotificationControl);

    final overallScore = controls.fold<double>(
      0.0,
      (sum, control) => sum + control.score,
    ) / controls.length;

    return FrameworkAssessment(
      framework: ComplianceFramework.gdpr,
      overallScore: overallScore,
      controls: controls,
      complianceLevel: _scoreToComplianceLevel(overallScore),
      assessedAt: DateTime.now(),
    );
  }
}

@freezed
class ComplianceReport with _$ComplianceReport {
  const factory ComplianceReport({
    required String tenantId,
    required DateRange reportPeriod,
    required List<ComplianceFramework> frameworks,
    required DateTime generatedAt,
    @Default({}) Map<ComplianceFramework, FrameworkAssessment> assessments,
  }) = _ComplianceReport;

  void addFrameworkAssessment(
    ComplianceFramework framework,
    FrameworkAssessment assessment,
  ) {
    assessments[framework] = assessment;
  }
}

@freezed
class FrameworkAssessment with _$FrameworkAssessment {
  const factory FrameworkAssessment({
    required ComplianceFramework framework,
    required double overallScore,
    required List<ComplianceControl> controls,
    required ComplianceLevel complianceLevel,
    required DateTime assessedAt,
  }) = _FrameworkAssessment;
}

@freezed
class ComplianceControl with _$ComplianceControl {
  const factory ComplianceControl({
    required String name,
    required String description,
    required double score,
    required ControlStatus status,
    required List<String> findings,
    required List<String> recommendations,
  }) = _ComplianceControl;
}

enum ComplianceFramework { sox, gdpr, iso27001, hipaa, pci }
enum ComplianceLevel { nonCompliant, partiallyCompliant, compliant, fullyCompliant }
enum ControlStatus { effective, ineffective, needsImprovement }
enum DataClassification { public, internal, confidential, restricted }
enum AccessType { read, write, delete, admin }
```

---

## Testing & Deployment

### Enterprise Integration Tests
**File**: `integration_test/phase5_enterprise_test.dart`

```dart
void main() {
  group('Phase 5 Enterprise Integration Tests', () {
    testWidgets('should handle multi-tenant data isolation', (tester) async {
      // Setup multiple tenants
      await setupMultipleTenants();
      
      // Test tenant A data access
      await switchToTenant('tenant_a');
      await tester.pumpWidget(MyApp());
      
      // Verify only tenant A data is visible
      expect(find.text('Tenant A PO-001'), findsOneWidget);
      expect(find.text('Tenant B PO-001'), findsNothing);
      
      // Switch to tenant B
      await switchToTenant('tenant_b');
      await tester.pumpAndSettle();
      
      // Verify only tenant B data is visible
      expect(find.text('Tenant B PO-001'), findsOneWidget);
      expect(find.text('Tenant A PO-001'), findsNothing);
    });

    testWidgets('should integrate with ERP systems', (tester) async {
      // Setup ERP integration
      await setupERPIntegration();
      
      await tester.pumpWidget(MyApp());
      
      // Create PO in app
      await tester.tap(find.text('Create PO'));
      await tester.pumpAndSettle();
      
      // Fill PO details
      await tester.enterText(find.byKey(Key('supplier')), 'Test Supplier');
      await tester.enterText(find.byKey(Key('amount')), '1000');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      
      // Verify ERP synchronization
      final erpPO = await getERPPurchaseOrder('PO-001');
      expect(erpPO, isNotNull);
      expect(erpPO.supplierName, equals('Test Supplier'));
    });

    testWidgets('should enforce enterprise security', (tester) async {
      // Setup security context
      await setupSecurityContext();
      
      await tester.pumpWidget(MyApp());
      
      // Try to access restricted data
      await tester.tap(find.text('Confidential Reports'));
      await tester.pumpAndSettle();
      
      // Verify access denied
      expect(find.text('Access Denied'), findsOneWidget);
      
      // Login with admin privileges
      await loginAsAdmin();
      await tester.tap(find.text('Confidential Reports'));
      await tester.pumpAndSettle();
      
      // Verify access granted
      expect(find.text('Confidential Reports'), findsOneWidget);
    });
  });
}
```

### Performance Tests
**File**: `test/performance/phase5_performance_test.dart`

```dart
void main() {
  group('Phase 5 Performance Tests', () {
    test('multi-tenant queries should scale linearly', () async {
      final repository = TenantAwarePurchaseOrderRepository(
        databaseManager: MockDatabaseManager(),
        tenantContext: MockTenantContext(),
        logger: MockLogger(),
      );

      // Test with increasing number of tenants
      for (int tenantCount = 10; tenantCount <= 1000; tenantCount *= 10) {
        await setupTenants(tenantCount);
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 100; i++) {
          await repository.findAll();
        }
        
        stopwatch.stop();
        
        final avgTime = stopwatch.elapsedMilliseconds / 100;
        expect(avgTime, lessThan(tenantCount * 0.1)); // Linear scaling
      }
    });

    test('ERP synchronization should handle large datasets', () async {
      final erpService = ERPIntegrationFramework(
        mappingService: MockDataMappingService(),
        syncService: MockSynchronizationService(),
        conflictResolver: MockConflictResolutionService(),
        logger: MockLogger(),
      );

      // Test with 10,000 purchase orders
      await setupLargeDataset(10000);
      
      final stopwatch = Stopwatch()..start();
      
      final result = await erpService.synchronizeProcurementData(
        erpType: 'SAP',
        scope: SynchronizationScope.all(),
      );
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(300000)); // 5 minutes max
      expect(result.status, equals(SynchronizationStatus.completed));
    });

    test('security validation should be performant', () async {
      final securityService = EnterpriseSecurityService(
        encryptionService: MockEncryptionService(),
        auditService: MockAuditService(),
        complianceService: MockComplianceService(),
        threatDetection: MockThreatDetectionService(),
        logger: MockLogger(),
      );

      final stopwatch = Stopwatch()..start();
      
      // Test 1000 access validations
      for (int i = 0; i < 1000; i++) {
        await securityService.validateDataAccess(
          userId: 'user_$i',
          resourceType: 'purchase_order',
          resourceId: 'po_$i',
          accessType: AccessType.read,
          tenantContext: createTestTenantContext(),
        );
      }
      
      stopwatch.stop();
      
      final avgTime = stopwatch.elapsedMilliseconds / 1000;
      expect(avgTime, lessThan(10)); // <10ms per validation
    });
  });
}
```

---

## Success Criteria

### Technical Metrics
- [ ] Multi-tenant data isolation with 100% accuracy
- [ ] ERP synchronization handles 10,000+ records in <5 minutes
- [ ] API gateway processes 1000+ requests/second
- [ ] Security validation completes in <10ms per request
- [ ] Microservices achieve 99.9% uptime

### Business Metrics
- [ ] Support for 100+ concurrent tenants
- [ ] Real-time ERP synchronization with <1% data loss
- [ ] Enterprise security compliance (SOX, GDPR, ISO27001)
- [ ] 50% reduction in integration development time
- [ ] 99.99% data availability and integrity

### Enterprise Readiness
- [ ] Horizontal scaling to 10,000+ users
- [ ] Disaster recovery with <4 hour RTO
- [ ] Multi-region deployment capability
- [ ] Enterprise-grade monitoring and alerting
- [ ] Comprehensive audit trails and compliance reporting

---

*Phase 5 completes the transformation of the procurement module into a world-class, enterprise-ready solution capable of supporting large-scale operations with the highest levels of security, compliance, and performance.* 