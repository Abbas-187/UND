# Phase 2: Workflow Enhancement & Mobile Optimization
## Duration: 6-8 weeks | Priority: High | Risk: Medium

### Overview
Phase 2 enhances the procurement workflow with flexible approval processes, mobile optimization, and improved user experience. This phase builds upon the analytics foundation from Phase 1 and introduces adaptive workflows without breaking existing functionality.

### Objectives
- Implement flexible, configurable approval workflows
- Add mobile-responsive design and PWA capabilities
- Enhance user experience with modern UI components
- Introduce bulk operations and advanced search
- Add real-time notifications and collaboration features

### Technical Approach
- **Extend existing workflow entities** with configuration support
- **Leverage existing biometric authentication** for enhanced security
- **Build responsive UI components** using existing theme system
- **Enhance existing notification system** with real-time updates
- **Maintain full backward compatibility** with current workflows

---

## Week 1-2: Flexible Workflow Engine

### 1.1 Create Workflow Configuration System
**File**: `lib/features/procurement/domain/entities/workflow_configuration.dart`

```dart
@freezed
class WorkflowConfiguration with _$WorkflowConfiguration {
  const factory WorkflowConfiguration({
    required String id,
    required String name,
    required List<ApprovalStage> stages,
    required List<WorkflowRule> rules,
    @Default(true) bool isActive,
    @Default([]) List<String> applicableCategories,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) = _WorkflowConfiguration;

  factory WorkflowConfiguration.fromJson(Map<String, dynamic> json) =>
      _$WorkflowConfigurationFromJson(json);
}

@freezed
class WorkflowRule with _$WorkflowRule {
  const factory WorkflowRule({
    required String id,
    required WorkflowCondition condition,
    required WorkflowAction action,
    required int priority,
    @Default(true) bool isActive,
  }) = _WorkflowRule;

  factory WorkflowRule.fromJson(Map<String, dynamic> json) =>
      _$WorkflowRuleFromJson(json);
}

@freezed
class WorkflowCondition with _$WorkflowCondition {
  const factory WorkflowCondition({
    required ConditionType type,
    required String field,
    required ConditionOperator operator,
    required dynamic value,
    List<WorkflowCondition>? subConditions,
    LogicalOperator? logicalOperator,
  }) = _WorkflowCondition;

  factory WorkflowCondition.fromJson(Map<String, dynamic> json) =>
      _$WorkflowConditionFromJson(json);
}

enum ConditionType { amount, category, supplier, urgency, custom }
enum ConditionOperator { equals, greaterThan, lessThan, contains, in_ }
enum LogicalOperator { and, or }

@freezed
class WorkflowAction with _$WorkflowAction {
  const factory WorkflowAction({
    required ActionType type,
    Map<String, dynamic>? parameters,
  }) = _WorkflowAction;

  factory WorkflowAction.fromJson(Map<String, dynamic> json) =>
      _$WorkflowActionFromJson(json);
}

enum ActionType { 
  skipStage, 
  addStage, 
  changeApprover, 
  setParallelApproval, 
  autoApprove,
  escalate,
  notify
}
```

### 1.2 Enhanced Approval Workflow Engine
**File**: `lib/features/procurement/domain/services/enhanced_approval_workflow_service.dart`

```dart
class EnhancedApprovalWorkflowService {
  final WorkflowConfigurationRepository _configRepository;
  final BiometricValidator _biometricValidator;
  final NotificationService _notificationService;
  final Logger _logger;

  const EnhancedApprovalWorkflowService({
    required WorkflowConfigurationRepository configRepository,
    required BiometricValidator biometricValidator,
    required NotificationService notificationService,
    required Logger logger,
  }) : _configRepository = configRepository,
       _biometricValidator = biometricValidator,
       _notificationService = notificationService,
       _logger = logger;

  /// Determines the appropriate workflow for a purchase order
  Future<WorkflowConfiguration> determineWorkflow(PurchaseOrder order) async {
    final configurations = await _configRepository.getActiveConfigurations();
    
    for (final config in configurations) {
      if (await _evaluateWorkflowRules(order, config.rules)) {
        _logger.i('Selected workflow: ${config.name} for PO: ${order.poNumber}');
        return config;
      }
    }
    
    // Fallback to default workflow (existing 2-stage)
    return _getDefaultWorkflow();
  }

  /// Evaluates workflow rules against a purchase order
  Future<bool> _evaluateWorkflowRules(
    PurchaseOrder order, 
    List<WorkflowRule> rules
  ) async {
    for (final rule in rules.where((r) => r.isActive)) {
      if (await _evaluateCondition(order, rule.condition)) {
        return true;
      }
    }
    return false;
  }

  /// Evaluates a single condition
  Future<bool> _evaluateCondition(
    PurchaseOrder order, 
    WorkflowCondition condition
  ) async {
    switch (condition.type) {
      case ConditionType.amount:
        return _evaluateAmountCondition(order.totalAmount, condition);
      case ConditionType.category:
        return _evaluateCategoryCondition(order.items, condition);
      case ConditionType.supplier:
        return _evaluateSupplierCondition(order.supplierId, condition);
      case ConditionType.urgency:
        return _evaluateUrgencyCondition(order, condition);
      case ConditionType.custom:
        return _evaluateCustomCondition(order, condition);
    }
  }

  /// Processes approval with enhanced workflow
  Future<PurchaseOrderApprovalHistory> processEnhancedApproval(
    PurchaseOrderApprovalHistory approvalHistory,
    String userId,
    String userName,
    ApprovalStatus decision,
    String? notes,
    String userRole,
  ) async {
    // Get workflow configuration
    final order = await _getPurchaseOrder(approvalHistory.purchaseOrderId);
    final workflow = await determineWorkflow(order);
    
    // Validate user permissions for current stage
    final currentStage = workflow.stages.firstWhere(
      (stage) => stage.id == approvalHistory.currentStage.toString(),
      orElse: () => throw Exception('Invalid workflow stage'),
    );
    
    if (!_canUserApproveStage(userRole, currentStage)) {
      throw UnauthorizedApprovalException(
        'User $userName does not have permission to approve this stage'
      );
    }

    // Enhanced biometric validation
    if (decision == ApprovalStatus.approved && currentStage.requiresBiometric) {
      final biometricResult = await _biometricValidator.validateWithContext(
        'Approve Purchase Order ${order.poNumber}',
        userId: userId,
        context: {
          'poNumber': order.poNumber,
          'amount': order.totalAmount,
          'stage': currentStage.name,
        },
      );

      if (!biometricResult.isValid) {
        throw Exception('Biometric validation failed: ${biometricResult.error}');
      }
    }

    // Create approval action
    final action = ApprovalAction(
      id: const Uuid().v4(),
      purchaseOrderId: approvalHistory.purchaseOrderId,
      userId: userId,
      userName: userName,
      timestamp: DateTime.now(),
      decision: decision,
      notes: notes,
      stage: ApprovalStage.values.firstWhere(
        (s) => s.toString() == currentStage.id,
      ),
      isBiometricallyValidated: decision == ApprovalStatus.approved,
    );

    // Determine next stage based on workflow
    final nextStage = _determineNextStageFromWorkflow(
      workflow, 
      currentStage, 
      decision, 
      order
    );

    // Send notifications
    await _sendWorkflowNotifications(order, action, nextStage);

    // Update approval history
    return approvalHistory.copyWith(
      actions: [...approvalHistory.actions, action],
      currentStage: nextStage,
      currentStatus: _determineStatusFromStage(nextStage, decision),
      lastUpdated: DateTime.now(),
    );
  }

  /// Parallel approval processing
  Future<List<PurchaseOrderApprovalHistory>> processParallelApprovals(
    List<ParallelApprovalRequest> requests
  ) async {
    final results = <PurchaseOrderApprovalHistory>[];
    
    // Process approvals concurrently
    final futures = requests.map((request) => 
      processEnhancedApproval(
        request.approvalHistory,
        request.userId,
        request.userName,
        request.decision,
        request.notes,
        request.userRole,
      )
    );

    final approvalResults = await Future.wait(futures);
    
    // Check if all parallel approvals are complete
    for (int i = 0; i < requests.length; i++) {
      final result = approvalResults[i];
      final request = requests[i];
      
      if (_isParallelStageComplete(result, request.parallelStageId)) {
        // Move to next stage if all parallel approvals are done
        final nextStage = _getNextStageAfterParallel(result);
        results.add(result.copyWith(currentStage: nextStage));
      } else {
        results.add(result);
      }
    }

    return results;
  }
}

@freezed
class ParallelApprovalRequest with _$ParallelApprovalRequest {
  const factory ParallelApprovalRequest({
    required PurchaseOrderApprovalHistory approvalHistory,
    required String userId,
    required String userName,
    required ApprovalStatus decision,
    required String userRole,
    required String parallelStageId,
    String? notes,
  }) = _ParallelApprovalRequest;
}
```

### 1.3 Workflow Configuration Repository
**File**: `lib/features/procurement/data/repositories/workflow_configuration_repository_impl.dart`

```dart
class WorkflowConfigurationRepositoryImpl implements WorkflowConfigurationRepository {
  final FirebaseFirestore _firestore;
  final SmartCache _cache;

  WorkflowConfigurationRepositoryImpl(this._firestore, this._cache);

  @override
  Future<List<WorkflowConfiguration>> getActiveConfigurations() async {
    const cacheKey = 'active_workflow_configurations';
    final cached = _cache.get<List<WorkflowConfiguration>>(cacheKey);
    if (cached != null) return cached;

    final snapshot = await _firestore
        .collection('workflow_configurations')
        .where('isActive', isEqualTo: true)
        .orderBy('priority', descending: true)
        .get();

    final configurations = snapshot.docs
        .map((doc) => WorkflowConfiguration.fromJson({
              ...doc.data(),
              'id': doc.id,
            }))
        .toList();

    _cache.set(cacheKey, configurations, ttl: const Duration(hours: 1));
    return configurations;
  }

  @override
  Future<WorkflowConfiguration> createConfiguration(
    WorkflowConfiguration configuration
  ) async {
    final docRef = _firestore.collection('workflow_configurations').doc();
    
    final configWithId = configuration.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(configWithId.toJson());
    
    // Invalidate cache
    _cache.invalidatePattern('workflow_configurations');
    
    return configWithId;
  }

  @override
  Future<void> updateConfiguration(WorkflowConfiguration configuration) async {
    await _firestore
        .collection('workflow_configurations')
        .doc(configuration.id)
        .update({
          ...configuration.copyWith(updatedAt: DateTime.now()).toJson(),
        });

    // Invalidate cache
    _cache.invalidatePattern('workflow_configurations');
  }
}
```

---

## Week 3-4: Mobile Optimization & PWA

### 2.1 Responsive Design System
**File**: `lib/features/procurement/presentation/widgets/responsive_layout.dart`

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobile;
        } else if (constraints.maxWidth < 1200) {
          return tablet ?? desktop;
        } else {
          return desktop;
        }
      },
    );
  }
}

class ProcurementResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ProcurementResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildMobileBottomNav(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 250,
          child: _buildSideNavigation(context),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: _buildSideNavigation(context),
        ),
        Expanded(child: child),
      ],
    );
  }
}
```

### 2.2 Mobile-Optimized Purchase Order Creation
**File**: `lib/features/procurement/presentation/screens/mobile_po_create_screen.dart`

```dart
class MobilePOCreateScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MobilePOCreateScreen> createState() => _MobilePOCreateScreenState();
}

class _MobilePOCreateScreenState extends ConsumerState<MobilePOCreateScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  final _formKey = GlobalKey<FormState>();
  final _basicInfoKey = GlobalKey<FormState>();
  final _itemsKey = GlobalKey<FormState>();
  final _reviewKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Purchase Order'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: Colors.grey[300],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentStep = index),
        children: [
          _buildBasicInfoStep(),
          _buildSupplierSelectionStep(),
          _buildItemsStep(),
          _buildReviewStep(),
        ],
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _basicInfoKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            
            // PO Number (auto-generated)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'PO Number',
                hintText: 'Auto-generated',
                enabled: false,
              ),
              initialValue: 'PO-${DateTime.now().millisecondsSinceEpoch}',
            ),
            const SizedBox(height: 16),
            
            // Request Date
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Request Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              controller: TextEditingController(
                text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            
            // Reason for Request
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reason for Request',
                hintText: 'Enter the reason for this purchase order',
              ),
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a reason for the request';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Intended Use
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Intended Use',
                hintText: 'How will these items be used?',
              ),
              maxLines: 2,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter the intended use';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Priority Selection
            DropdownButtonFormField<ProcurementPriority>(
              decoration: const InputDecoration(
                labelText: 'Priority',
              ),
              items: ProcurementPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(
                        _getPriorityIcon(priority),
                        color: _getPriorityColor(priority),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(priority.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                // Handle priority change
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a priority';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Supplier',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          
          // Search Bar
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search Suppliers',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Implement supplier search
            },
          ),
          const SizedBox(height: 16),
          
          // Supplier List
          Consumer(
            builder: (context, ref, child) {
              final suppliers = ref.watch(suppliersProvider);
              
              return suppliers.when(
                data: (supplierList) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: supplierList.length,
                  itemBuilder: (context, index) {
                    final supplier = supplierList[index];
                    return _buildSupplierCard(supplier);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error loading suppliers: $error'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(Supplier supplier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            supplier.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(supplier.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rating: ${supplier.rating}/5'),
            Text('Lead Time: ${supplier.leadTimeDays} days'),
          ],
        ),
        trailing: Radio<String>(
          value: supplier.id,
          groupValue: _selectedSupplierId,
          onChanged: (value) {
            setState(() {
              _selectedSupplierId = value;
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedSupplierId = supplier.id;
          });
        },
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            ElevatedButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black87,
              ),
            )
          else
            const SizedBox.shrink(),
          
          ElevatedButton.icon(
            onPressed: _currentStep < 3 ? _nextStep : _submitPO,
            icon: Icon(_currentStep < 3 ? Icons.arrow_forward : Icons.check),
            label: Text(_currentStep < 3 ? 'Next' : 'Submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2.3 Progressive Web App Configuration
**File**: `web/manifest.json`

```json
{
  "name": "Dairy Management - Procurement",
  "short_name": "DM Procurement",
  "description": "Procurement module for dairy management system",
  "start_url": "/procurement",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#2196F3",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ],
  "shortcuts": [
    {
      "name": "Create PO",
      "short_name": "New PO",
      "description": "Create a new purchase order",
      "url": "/procurement/purchase-orders/create",
      "icons": [
        {
          "src": "icons/shortcut-create.png",
          "sizes": "96x96"
        }
      ]
    },
    {
      "name": "Approvals",
      "short_name": "Approvals",
      "description": "View pending approvals",
      "url": "/procurement/po-approvals",
      "icons": [
        {
          "src": "icons/shortcut-approvals.png",
          "sizes": "96x96"
        }
      ]
    }
  ]
}
```

**File**: `web/sw.js` (Service Worker for offline capabilities)

```javascript
const CACHE_NAME = 'procurement-v1';
const urlsToCache = [
  '/',
  '/procurement',
  '/procurement/dashboard',
  '/procurement/analytics',
  '/static/js/main.js',
  '/static/css/main.css',
  '/manifest.json'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Return cached version or fetch from network
        return response || fetch(event.request);
      })
  );
});

// Background sync for offline PO creation
self.addEventListener('sync', (event) => {
  if (event.tag === 'background-sync-po') {
    event.waitUntil(syncPendingPOs());
  }
});

async function syncPendingPOs() {
  // Sync pending purchase orders when back online
  const pendingPOs = await getStoredPendingPOs();
  
  for (const po of pendingPOs) {
    try {
      await submitPOToServer(po);
      await removePendingPO(po.id);
    } catch (error) {
      console.error('Failed to sync PO:', error);
    }
  }
}
```

---

## Week 5-6: Enhanced User Experience

### 3.1 Bulk Operations System
**File**: `lib/features/procurement/presentation/screens/bulk_operations_screen.dart`

```dart
class BulkOperationsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<BulkOperationsScreen> createState() => _BulkOperationsScreenState();
}

class _BulkOperationsScreenState extends ConsumerState<BulkOperationsScreen> {
  final Set<String> _selectedPOs = {};
  BulkOperation? _selectedOperation;

  @override
  Widget build(BuildContext context) {
    final purchaseOrders = ref.watch(purchaseOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bulk Operations (${_selectedPOs.length} selected)'),
        actions: [
          if (_selectedPOs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => setState(() => _selectedPOs.clear()),
              tooltip: 'Clear Selection',
            ),
        ],
      ),
      body: Column(
        children: [
          // Bulk Operation Selector
          if (_selectedPOs.isNotEmpty) _buildOperationSelector(),
          
          // Purchase Orders List
          Expanded(
            child: purchaseOrders.when(
              data: (orders) => _buildPOList(orders),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedPOs.isNotEmpty && _selectedOperation != null
          ? FloatingActionButton.extended(
              onPressed: _executeBulkOperation,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Execute'),
            )
          : null,
    );
  }

  Widget _buildOperationSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Operation',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: BulkOperation.values.map((operation) {
              return ChoiceChip(
                label: Text(operation.displayName),
                selected: _selectedOperation == operation,
                onSelected: (selected) {
                  setState(() {
                    _selectedOperation = selected ? operation : null;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPOList(List<PurchaseOrder> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isSelected = _selectedPOs.contains(order.id);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  _selectedPOs.add(order.id);
                } else {
                  _selectedPOs.remove(order.id);
                }
              });
            },
            title: Text(order.poNumber),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Supplier: ${order.supplierName}'),
                Text('Amount: \$${order.totalAmount.toStringAsFixed(2)}'),
                Text('Status: ${order.status.displayName}'),
              ],
            ),
            secondary: _buildStatusChip(order.status),
          ),
        );
      },
    );
  }

  Future<void> _executeBulkOperation() async {
    if (_selectedOperation == null || _selectedPOs.isEmpty) return;

    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    try {
      final bulkService = ref.read(bulkOperationsServiceProvider);
      
      await bulkService.executeBulkOperation(
        operation: _selectedOperation!,
        purchaseOrderIds: _selectedPOs.toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bulk operation completed for ${_selectedPOs.length} purchase orders'
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _selectedPOs.clear();
          _selectedOperation = null;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

enum BulkOperation {
  approve,
  reject,
  cancel,
  export,
  updateStatus,
  assignApprover;

  String get displayName {
    switch (this) {
      case BulkOperation.approve:
        return 'Bulk Approve';
      case BulkOperation.reject:
        return 'Bulk Reject';
      case BulkOperation.cancel:
        return 'Bulk Cancel';
      case BulkOperation.export:
        return 'Export to Excel';
      case BulkOperation.updateStatus:
        return 'Update Status';
      case BulkOperation.assignApprover:
        return 'Assign Approver';
    }
  }
}
```

### 3.2 Advanced Search & Filtering
**File**: `lib/features/procurement/presentation/widgets/advanced_search_widget.dart`

```dart
class AdvancedSearchWidget extends ConsumerStatefulWidget {
  final Function(ProcurementSearchCriteria) onSearch;

  const AdvancedSearchWidget({super.key, required this.onSearch});

  @override
  ConsumerState<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends ConsumerState<AdvancedSearchWidget> {
  final _searchController = TextEditingController();
  final _criteria = ProcurementSearchCriteria();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Advanced Search'),
      leading: const Icon(Icons.search),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Text Search
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search PO Number, Supplier, or Items',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _criteria.textQuery = value;
                  _performSearch();
                },
              ),
              const SizedBox(height: 16),

              // Status Filter
              _buildMultiSelectChips<PurchaseOrderStatus>(
                title: 'Status',
                values: PurchaseOrderStatus.values,
                selectedValues: _criteria.statuses,
                onChanged: (statuses) {
                  _criteria.statuses = statuses;
                  _performSearch();
                },
                displayName: (status) => status.displayName,
              ),
              const SizedBox(height: 16),

              // Date Range
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'From Date',
                      value: _criteria.fromDate,
                      onChanged: (date) {
                        _criteria.fromDate = date;
                        _performSearch();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      label: 'To Date',
                      value: _criteria.toDate,
                      onChanged: (date) {
                        _criteria.toDate = date;
                        _performSearch();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount Range
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Min Amount',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _criteria.minAmount = double.tryParse(value);
                        _performSearch();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Max Amount',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _criteria.maxAmount = double.tryParse(value);
                        _performSearch();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Supplier Filter
              Consumer(
                builder: (context, ref, child) {
                  final suppliers = ref.watch(suppliersProvider);
                  
                  return suppliers.when(
                    data: (supplierList) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Supplier',
                        border: OutlineInputBorder(),
                      ),
                      value: _criteria.supplierId,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Suppliers'),
                        ),
                        ...supplierList.map((supplier) => DropdownMenuItem(
                          value: supplier.id,
                          child: Text(supplier.name),
                        )),
                      ],
                      onChanged: (value) {
                        _criteria.supplierId = value;
                        _performSearch();
                      },
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error loading suppliers'),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveSearchPreset,
                    icon: const Icon(Icons.bookmark),
                    label: const Text('Save Preset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectChips<T>({
    required String title,
    required List<T> values,
    required Set<T> selectedValues,
    required Function(Set<T>) onChanged,
    required String Function(T) displayName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: values.map((value) {
            final isSelected = selectedValues.contains(value);
            return FilterChip(
              label: Text(displayName(value)),
              selected: isSelected,
              onSelected: (selected) {
                final newSelection = Set<T>.from(selectedValues);
                if (selected) {
                  newSelection.add(value);
                } else {
                  newSelection.remove(value);
                }
                onChanged(newSelection);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _performSearch() {
    widget.onSearch(_criteria);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _criteria.clear();
    });
    _performSearch();
  }

  Future<void> _saveSearchPreset() async {
    final name = await _showSavePresetDialog();
    if (name != null && name.isNotEmpty) {
      final presetService = ref.read(searchPresetServiceProvider);
      await presetService.savePreset(name, _criteria);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search preset "$name" saved')),
        );
      }
    }
  }
}

class ProcurementSearchCriteria {
  String? textQuery;
  Set<PurchaseOrderStatus> statuses = {};
  DateTime? fromDate;
  DateTime? toDate;
  double? minAmount;
  double? maxAmount;
  String? supplierId;

  void clear() {
    textQuery = null;
    statuses.clear();
    fromDate = null;
    toDate = null;
    minAmount = null;
    maxAmount = null;
    supplierId = null;
  }

  Map<String, dynamic> toJson() => {
    'textQuery': textQuery,
    'statuses': statuses.map((s) => s.toString()).toList(),
    'fromDate': fromDate?.toIso8601String(),
    'toDate': toDate?.toIso8601String(),
    'minAmount': minAmount,
    'maxAmount': maxAmount,
    'supplierId': supplierId,
  };

  factory ProcurementSearchCriteria.fromJson(Map<String, dynamic> json) {
    final criteria = ProcurementSearchCriteria();
    criteria.textQuery = json['textQuery'];
    criteria.statuses = (json['statuses'] as List<dynamic>?)
        ?.map((s) => PurchaseOrderStatus.values.firstWhere(
              (status) => status.toString() == s,
            ))
        .toSet() ?? {};
    criteria.fromDate = json['fromDate'] != null 
        ? DateTime.parse(json['fromDate']) 
        : null;
    criteria.toDate = json['toDate'] != null 
        ? DateTime.parse(json['toDate']) 
        : null;
    criteria.minAmount = json['minAmount']?.toDouble();
    criteria.maxAmount = json['maxAmount']?.toDouble();
    criteria.supplierId = json['supplierId'];
    return criteria;
  }
}
```

---

## Week 7-8: Real-time Features & Collaboration

### 4.1 Real-time Notifications System
**File**: `lib/features/procurement/domain/services/procurement_notification_service.dart`

```dart
class ProcurementNotificationService {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  ProcurementNotificationService({
    required FirebaseFirestore firestore,
    required FirebaseMessaging messaging,
    required FlutterLocalNotificationsPlugin localNotifications,
  }) : _firestore = firestore,
       _messaging = messaging,
       _localNotifications = localNotifications;

  /// Stream of real-time procurement notifications
  Stream<List<ProcurementNotification>> watchNotifications(String userId) {
    return _firestore
        .collection('procurement_notifications')
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProcurementNotification.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  /// Send notification for PO approval request
  Future<void> sendApprovalNotification({
    required String recipientId,
    required PurchaseOrder purchaseOrder,
    required ApprovalStage stage,
  }) async {
    final notification = ProcurementNotification(
      id: '',
      type: NotificationType.approvalRequired,
      title: 'Purchase Order Approval Required',
      message: 'PO ${purchaseOrder.poNumber} requires your approval',
      recipientId: recipientId,
      relatedEntityId: purchaseOrder.id,
      relatedEntityType: 'purchase_order',
      priority: _getNotificationPriority(purchaseOrder),
      data: {
        'poNumber': purchaseOrder.poNumber,
        'supplierName': purchaseOrder.supplierName,
        'totalAmount': purchaseOrder.totalAmount,
        'stage': stage.toString(),
      },
      createdAt: DateTime.now(),
      isRead: false,
    );

    await _createNotification(notification);
    await _sendPushNotification(notification);
    await _showLocalNotification(notification);
  }

  /// Send notification for PO status change
  Future<void> sendStatusChangeNotification({
    required String recipientId,
    required PurchaseOrder purchaseOrder,
    required PurchaseOrderStatus oldStatus,
    required PurchaseOrderStatus newStatus,
  }) async {
    final notification = ProcurementNotification(
      id: '',
      type: NotificationType.statusChange,
      title: 'Purchase Order Status Updated',
      message: 'PO ${purchaseOrder.poNumber} status changed from ${oldStatus.displayName} to ${newStatus.displayName}',
      recipientId: recipientId,
      relatedEntityId: purchaseOrder.id,
      relatedEntityType: 'purchase_order',
      priority: NotificationPriority.medium,
      data: {
        'poNumber': purchaseOrder.poNumber,
        'oldStatus': oldStatus.toString(),
        'newStatus': newStatus.toString(),
      },
      createdAt: DateTime.now(),
      isRead: false,
    );

    await _createNotification(notification);
    await _sendPushNotification(notification);
  }

  /// Send bulk notification for multiple POs
  Future<void> sendBulkNotification({
    required List<String> recipientIds,
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    final futures = recipientIds.map((recipientId) {
      final notification = ProcurementNotification(
        id: '',
        type: type,
        title: title,
        message: message,
        recipientId: recipientId,
        relatedEntityId: '',
        relatedEntityType: 'bulk_operation',
        priority: NotificationPriority.medium,
        data: data ?? {},
        createdAt: DateTime.now(),
        isRead: false,
      );

      return _createNotification(notification);
    });

    await Future.wait(futures);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('procurement_notifications')
        .doc(notificationId)
        .update({'isRead': true, 'readAt': FieldValue.serverTimestamp()});
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    
    final snapshot = await _firestore
        .collection('procurement_notifications')
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> _createNotification(ProcurementNotification notification) async {
    await _firestore
        .collection('procurement_notifications')
        .add(notification.toJson());
  }

  Future<void> _sendPushNotification(ProcurementNotification notification) async {
    // Implementation for FCM push notification
    try {
      await _messaging.sendMessage(
        to: '/topics/user_${notification.recipientId}',
        data: {
          'title': notification.title,
          'body': notification.message,
          'type': notification.type.toString(),
          'data': jsonEncode(notification.data),
        },
      );
    } catch (e) {
      print('Failed to send push notification: $e');
    }
  }

  Future<void> _showLocalNotification(ProcurementNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'procurement_channel',
      'Procurement Notifications',
      channelDescription: 'Notifications for procurement activities',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.message,
      details,
      payload: jsonEncode(notification.toJson()),
    );
  }

  NotificationPriority _getNotificationPriority(PurchaseOrder purchaseOrder) {
    if (purchaseOrder.totalAmount > 10000) {
      return NotificationPriority.high;
    } else if (purchaseOrder.totalAmount > 5000) {
      return NotificationPriority.medium;
    } else {
      return NotificationPriority.low;
    }
  }
}

@freezed
class ProcurementNotification with _$ProcurementNotification {
  const factory ProcurementNotification({
    required String id,
    required NotificationType type,
    required String title,
    required String message,
    required String recipientId,
    required String relatedEntityId,
    required String relatedEntityType,
    required NotificationPriority priority,
    required Map<String, dynamic> data,
    required DateTime createdAt,
    required bool isRead,
    DateTime? readAt,
  }) = _ProcurementNotification;

  factory ProcurementNotification.fromJson(Map<String, dynamic> json) =>
      _$ProcurementNotificationFromJson(json);
}

enum NotificationType {
  approvalRequired,
  statusChange,
  deadlineReminder,
  bulkOperation,
  systemAlert,
}

enum NotificationPriority { low, medium, high, urgent }
```

### 4.2 Collaborative Comments System
**File**: `lib/features/procurement/presentation/widgets/po_comments_widget.dart`

```dart
class POCommentsWidget extends ConsumerStatefulWidget {
  final String purchaseOrderId;

  const POCommentsWidget({super.key, required this.purchaseOrderId});

  @override
  ConsumerState<POCommentsWidget> createState() => _POCommentsWidgetState();
}

class _POCommentsWidgetState extends ConsumerState<POCommentsWidget> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(poCommentsProvider(widget.purchaseOrderId));

    return Column(
      children: [
        // Comments Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.comment, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Comments & Discussion',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              comments.when(
                data: (commentList) => Chip(
                  label: Text('${commentList.length}'),
                  backgroundColor: Theme.of(context).primaryColor,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        // Comments List
        Expanded(
          child: comments.when(
            data: (commentList) => commentList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: commentList.length,
                    itemBuilder: (context, index) {
                      final comment = commentList[index];
                      return _buildCommentItem(comment);
                    },
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading comments: $error'),
            ),
          ),
        ),

        // Comment Input
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No comments yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the discussion by adding a comment',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(POComment comment) {
    final isCurrentUser = comment.authorId == ref.read(currentUserProvider)?.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              comment.authorName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Comment Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser 
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: isCurrentUser
                    ? Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author and Time
                  Row(
                    children: [
                      Text(
                        comment.authorName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser 
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimestamp(comment.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Comment Text
                  Text(
                    comment.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  // Attachments
                  if (comment.attachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildAttachments(comment.attachments),
                  ],

                  // Actions
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _replyToComment(comment),
                        icon: const Icon(Icons.reply, size: 16),
                        label: const Text('Reply'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: () => _editComment(comment),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                suffixIcon: IconButton(
                  onPressed: _attachFile,
                  icon: const Icon(Icons.attach_file),
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: _submitComment,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      final commentsService = ref.read(poCommentsServiceProvider);
      await commentsService.addComment(
        purchaseOrderId: widget.purchaseOrderId,
        content: content,
        attachments: [], // TODO: Handle attachments
      );

      _commentController.clear();
      
      // Scroll to bottom to show new comment
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }
}
```

---

## Testing & Deployment

### Integration Tests
**File**: `integration_test/phase2_workflow_test.dart`

```dart
void main() {
  group('Phase 2 Workflow Integration Tests', () {
    testWidgets('should create PO with flexible workflow', (tester) async {
      // Test flexible workflow creation
      await tester.pumpWidget(MyApp());
      
      // Navigate to PO creation
      await tester.tap(find.text('Procurement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create PO'));
      await tester.pumpAndSettle();
      
      // Fill form and verify workflow selection
      await tester.enterText(find.byKey(Key('po_amount')), '15000');
      await tester.pumpAndSettle();
      
      // Verify high-value workflow is selected
      expect(find.text('High-Value Approval Workflow'), findsOneWidget);
    });

    testWidgets('should handle mobile responsive layout', (tester) async {
      // Test mobile layout
      await tester.binding.setSurfaceSize(Size(400, 800));
      await tester.pumpWidget(MyApp());
      
      // Verify mobile navigation
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(Drawer), findsNothing);
    });

    testWidgets('should perform bulk operations', (tester) async {
      // Test bulk operations
      await setupTestPOs();
      
      await tester.pumpWidget(MyApp());
      await tester.tap(find.text('Bulk Operations'));
      await tester.pumpAndSettle();
      
      // Select multiple POs
      await tester.tap(find.byType(Checkbox).first);
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pumpAndSettle();
      
      // Execute bulk approval
      await tester.tap(find.text('Bulk Approve'));
      await tester.tap(find.text('Execute'));
      await tester.pumpAndSettle();
      
      // Verify success message
      expect(find.text('Bulk operation completed'), findsOneWidget);
    });
  });
}
```

### Performance Tests
**File**: `test/performance/phase2_performance_test.dart`

```dart
void main() {
  group('Phase 2 Performance Tests', () {
    test('workflow determination should complete within 100ms', () async {
      final service = EnhancedApprovalWorkflowService(
        configRepository: MockWorkflowConfigurationRepository(),
        biometricValidator: MockBiometricValidator(),
        notificationService: MockNotificationService(),
        logger: MockLogger(),
      );

      final stopwatch = Stopwatch()..start();
      
      await service.determineWorkflow(createTestPurchaseOrder());
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('bulk operations should handle 100 POs efficiently', () async {
      final service = BulkOperationsService();
      final poIds = List.generate(100, (i) => 'po_$i');

      final stopwatch = Stopwatch()..start();
      
      await service.executeBulkOperation(
        operation: BulkOperation.approve,
        purchaseOrderIds: poIds,
      );
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max
    });
  });
}
```

---

## Success Criteria

### Technical Metrics
- [ ] Flexible workflows support 5+ different approval paths
- [ ] Mobile responsive design works on screens 320px+ wide
- [ ] PWA installation and offline capabilities functional
- [ ] Bulk operations handle 100+ POs in <5 seconds
- [ ] Real-time notifications delivered within 2 seconds

### Business Metrics
- [ ] 60% reduction in approval cycle time for high-value POs
- [ ] 80% of users access procurement via mobile within 2 weeks
- [ ] 90% user satisfaction with new workflow flexibility
- [ ] 50% increase in collaboration through comments system

### User Experience
- [ ] Intuitive mobile navigation and touch interactions
- [ ] Seamless transition between desktop and mobile
- [ ] Clear visual feedback for all user actions
- [ ] Accessible design meeting WCAG 2.1 AA standards

---

*Phase 2 transforms the procurement module into a flexible, mobile-first system that adapts to modern work patterns while maintaining enterprise-grade security and reliability.* 