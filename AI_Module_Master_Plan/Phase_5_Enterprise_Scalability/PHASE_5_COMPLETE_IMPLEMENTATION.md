# Phase 5: Enterprise Scalability
## Complete 4-Week Implementation Plan (Weeks 17-20)

### 🎯 **Phase 5 Objectives**
- ✅ Distributed computing architecture
- ✅ Global deployment & scaling
- ✅ Load balancing & auto-scaling
- ✅ Multi-region data synchronization
- ✅ Containerization & orchestration
- ✅ AI performance optimization
- ✅ Monitoring & observability

---

## 📅 **Week-by-Week Implementation Schedule**

### **Week 17: Distributed Computing Architecture**
#### **Day 113-115: Microservices Architecture**
```yaml
Tasks:
  - AI service decomposition
  - Microservices design
  - Service communication
  - API gateway implementation

Files to Create:
  - lib/features/ai/distributed/service_registry.dart
  - lib/features/ai/distributed/api_gateway.dart
  - lib/features/ai/distributed/service_discovery.dart
  - lib/features/ai/distributed/circuit_breaker.dart
```

#### **Day 116-119: Distributed Processing**
```yaml
Tasks:
  - Task distribution system
  - Distributed caching
  - Message queuing
  - Async processing pipeline

Files to Create:
  - lib/features/ai/distributed/task_distributor.dart
  - lib/features/ai/distributed/distributed_cache.dart
  - lib/features/ai/distributed/message_queue.dart
  - lib/features/ai/distributed/async_pipeline.dart
```

### **Week 18: Containerization & Orchestration**
#### **Day 120-122: Containerization**
```yaml
Tasks:
  - Docker containerization
  - Container registry setup
  - Container security
  - CI/CD pipeline integration

Files to Create:
  - docker/ai_service/Dockerfile
  - docker/ml_service/Dockerfile
  - docker/api_gateway/Dockerfile
  - docker-compose.yml
```

#### **Day 123-126: Kubernetes Orchestration**
```yaml
Tasks:
  - Kubernetes manifests
  - Service deployment
  - Pod auto-scaling
  - Resource management

Files to Create:
  - kubernetes/ai_service_deployment.yaml
  - kubernetes/ml_service_deployment.yaml
  - kubernetes/api_gateway_deployment.yaml
  - kubernetes/auto_scaling.yaml
```

### **Week 19: Global Deployment & Multi-Region**
#### **Day 127-129: Global Load Balancing**
```yaml
Tasks:
  - Global load balancer
  - Geographic routing
  - Traffic management
  - Latency optimization

Files to Create:
  - lib/features/ai/global/load_balancer.dart
  - lib/features/ai/global/geo_router.dart
  - lib/features/ai/global/traffic_manager.dart
  - lib/features/ai/global/latency_optimizer.dart
```

#### **Day 130-133: Multi-Region Synchronization**
```yaml
Tasks:
  - Data replication system
  - Conflict resolution
  - Consistency management
  - Geo-distributed caching

Files to Create:
  - lib/features/ai/global/data_replicator.dart
  - lib/features/ai/global/conflict_resolver.dart
  - lib/features/ai/global/consistency_manager.dart
  - lib/features/ai/global/geo_cache.dart
```

### **Week 20: Performance Optimization & Monitoring**
#### **Day 134-136: AI Performance Optimization**
```yaml
Tasks:
  - Model quantization
  - Inference optimization
  - Batch processing
  - Hardware acceleration

Files to Create:
  - lib/features/ai/performance/model_quantizer.dart
  - lib/features/ai/performance/inference_optimizer.dart
  - lib/features/ai/performance/batch_processor.dart
  - lib/features/ai/performance/hardware_accelerator.dart
```

#### **Day 137-140: Monitoring & Observability**
```yaml
Tasks:
  - Metrics collection
  - Distributed tracing
  - Logging infrastructure
  - Performance dashboards

Files to Create:
  - lib/features/ai/monitoring/metrics_collector.dart
  - lib/features/ai/monitoring/distributed_tracer.dart
  - lib/features/ai/monitoring/logging_service.dart
  - lib/features/ai/monitoring/performance_dashboard.dart
```

---

## 🎯 **Success Metrics & Testing**

### **Phase 5 Success Criteria**
```yaml
Technical Metrics:
  - Distributed architecture: ✅ Microservices + API Gateway
  - Service resilience: 99.99% uptime across regions
  - Load balancing efficiency: < 10ms routing decisions
  - Auto-scaling response: < 30 seconds to scale
  - Container deployment: 100% containerized services
  - Multi-region latency: < 100ms cross-region sync

Functional Metrics:
  - Global deployment: ✅ Multi-region availability
  - Container orchestration: ✅ Kubernetes automation
  - Data consistency: 100% data integrity across regions
  - High availability: No single points of failure
  - Performance optimization: 50% reduced inference time
  - Observability: Complete metrics visibility

Business Metrics:
  - Global scalability: Support for 10,000+ concurrent users
  - Enterprise SLA: 99.99% availability
  - Cost optimization: 40% reduced infrastructure costs
  - Geographic expansion: Support for all major regions
  - Performance at scale: Consistent response times
  - Operational efficiency: 80% reduction in manual operations
```

### **Testing Strategy**
```yaml
Scalability Tests:
  - Load testing with 10,000+ simulated users
  - Auto-scaling verification
  - Multi-region traffic distribution
  - Burst capacity testing

Resilience Tests:
  - Chaos engineering experiments
  - Region failure scenarios
  - Service degradation handling
  - Network partition simulation

Performance Tests:
  - Global latency benchmarks
  - Cross-region synchronization
  - AI inference optimization
  - Resource utilization efficiency

Operational Tests:
  - Deployment automation
  - Monitoring effectiveness
  - Alert response workflows
  - Remediation verification
```

This comprehensive Phase 5 implementation transforms the AI module into a truly enterprise-grade, globally scalable system with distributed architecture, containerization, orchestration, and advanced performance optimization! 🚀

---

## 🔧 **Complete Code Implementation**

### **1. Service Registry (service_registry.dart)**
```dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ServiceHealth {
  healthy,
  degraded,
  unhealthy,
  unknown
}

enum ServiceType {
  aiGateway,
  universalAI,
  mlInference,
  computerVision,
  nlpProcessor,
  patternRecognition,
  distributedCache,
  messageQueue,
  dataProcessor
}

class ServiceEndpoint {
  final String id;
  final String name;
  final String baseUrl;
  final ServiceType type;
  final Map<String, String> metadata;
  final int version;
  final ServiceHealth health;
  final DateTime lastHeartbeat;
  final Map<String, dynamic> capabilities;
  final Map<String, double> performanceMetrics;
  
  ServiceEndpoint({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.type,
    this.metadata = const {},
    required this.version,
    this.health = ServiceHealth.unknown,
    DateTime? lastHeartbeat,
    this.capabilities = const {},
    this.performanceMetrics = const {},
  }) : lastHeartbeat = lastHeartbeat ?? DateTime.now();
  
  ServiceEndpoint copyWith({
    String? id,
    String? name,
    String? baseUrl,
    ServiceType? type,
    Map<String, String>? metadata,
    int? version,
    ServiceHealth? health,
    DateTime? lastHeartbeat,
    Map<String, dynamic>? capabilities,
    Map<String, double>? performanceMetrics,
  }) {
    return ServiceEndpoint(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      version: version ?? this.version,
      health: health ?? this.health,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
      capabilities: capabilities ?? this.capabilities,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
    );
  }
  
  bool get isHealthy => health == ServiceHealth.healthy;
  
  bool get isActive => 
      DateTime.now().difference(lastHeartbeat).inSeconds < 60 && 
      (health == ServiceHealth.healthy || health == ServiceHealth.degraded);
      
  double get responseTime => performanceMetrics['responseTime'] ?? 0.0;
  
  double get errorRate => performanceMetrics['errorRate'] ?? 0.0;
  
  double get cpuUsage => performanceMetrics['cpuUsage'] ?? 0.0;
  
  double get memoryUsage => performanceMetrics['memoryUsage'] ?? 0.0;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'baseUrl': baseUrl,
      'type': type.toString(),
      'metadata': metadata,
      'version': version,
      'health': health.toString(),
      'lastHeartbeat': lastHeartbeat.toIso8601String(),
      'capabilities': capabilities,
      'performanceMetrics': performanceMetrics,
    };
  }
  
  factory ServiceEndpoint.fromJson(Map<String, dynamic> json) {
    return ServiceEndpoint(
      id: json['id'],
      name: json['name'],
      baseUrl: json['baseUrl'],
      type: _parseServiceType(json['type']),
      metadata: Map<String, String>.from(json['metadata'] ?? {}),
      version: json['version'],
      health: _parseServiceHealth(json['health']),
      lastHeartbeat: DateTime.parse(json['lastHeartbeat']),
      capabilities: json['capabilities'] ?? {},
      performanceMetrics: Map<String, double>.from(json['performanceMetrics'] ?? {}),
    );
  }
  
  static ServiceType _parseServiceType(String type) {
    return ServiceType.values.firstWhere(
      (e) => e.toString() == type,
      orElse: () => ServiceType.aiGateway,
    );
  }
  
  static ServiceHealth _parseServiceHealth(String health) {
    return ServiceHealth.values.firstWhere(
      (e) => e.toString() == health,
      orElse: () => ServiceHealth.unknown,
    );
  }
}

class ServiceRegistry {
  final Map<String, ServiceEndpoint> _services = {};
  final Map<ServiceType, List<ServiceEndpoint>> _servicesByType = {};
  final StreamController<ServiceEndpoint> _serviceUpdates = 
      StreamController<ServiceEndpoint>.broadcast();
  final StreamController<String> _serviceRemovals = 
      StreamController<String>.broadcast();
  
  Timer? _cleanupTimer;
  final http.Client _httpClient;
  final String _registryUrl;
  bool _isInitialized = false;
  
  ServiceRegistry({
    required String registryUrl,
    http.Client? httpClient,
  }) : _registryUrl = registryUrl,
       _httpClient = httpClient ?? http.Client() {
    _startCleanupTimer();
  }
  
  Future<bool> initialize() async {
    try {
      await _syncWithCentralRegistry();
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Failed to initialize service registry: $e');
      _isInitialized = false;
      return false;
    }
  }
  
  Future<void> registerService(ServiceEndpoint service) async {
    _services[service.id] = service;
    
    _servicesByType.putIfAbsent(service.type, () => [])
                   .add(service);
    
    _serviceUpdates.add(service);
    
    // Sync with central registry
    try {
      await _httpClient.post(
        Uri.parse('$_registryUrl/services'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(service.toJson()),
      );
    } catch (e) {
      print('Failed to register service with central registry: $e');
      // Continue with local registration even if central sync fails
    }
  }
  
  Future<void> updateServiceHealth(
    String serviceId,
    ServiceHealth health,
    Map<String, double> metrics,
  ) async {
    final service = _services[serviceId];
    if (service == null) return;
    
    final updatedService = service.copyWith(
      health: health,
      lastHeartbeat: DateTime.now(),
      performanceMetrics: {...service.performanceMetrics, ...metrics},
    );
    
    _services[serviceId] = updatedService;
    
    // Update in type mapping
    final typeServices = _servicesByType[service.type];
    if (typeServices != null) {
      final index = typeServices.indexWhere((s) => s.id == serviceId);
      if (index >= 0) {
        typeServices[index] = updatedService;
      }
    }
    
    _serviceUpdates.add(updatedService);
    
    // Sync with central registry
    try {
      await _httpClient.put(
        Uri.parse('$_registryUrl/services/$serviceId/health'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'health': health.toString(),
          'metrics': metrics,
        }),
      );
    } catch (e) {
      print('Failed to update service health in central registry: $e');
    }
  }
  
  Future<void> deregisterService(String serviceId) async {
    final service = _services.remove(serviceId);
    if (service == null) return;
    
    final typeServices = _servicesByType[service.type];
    if (typeServices != null) {
      typeServices.removeWhere((s) => s.id == serviceId);
      if (typeServices.isEmpty) {
        _servicesByType.remove(service.type);
      }
    }
    
    _serviceRemovals.add(serviceId);
    
    // Sync with central registry
    try {
      await _httpClient.delete(
        Uri.parse('$_registryUrl/services/$serviceId'),
      );
    } catch (e) {
      print('Failed to deregister service from central registry: $e');
    }
  }
  
  List<ServiceEndpoint> getServicesByType(ServiceType type) {
    return _servicesByType[type]?.where((s) => s.isActive).toList() ?? [];
  }
  
  ServiceEndpoint? getServiceById(String serviceId) {
    return _services[serviceId];
  }
  
  List<ServiceEndpoint> getAllServices() {
    return _services.values.toList();
  }
  
  List<ServiceEndpoint> getHealthyServicesByType(ServiceType type) {
    return getServicesByType(type).where((s) => s.isHealthy).toList();
  }
  
  Future<ServiceEndpoint?> discoverOptimalService(
    ServiceType type,
    Map<String, dynamic> requirements,
  ) async {
    final candidates = getHealthyServicesByType(type);
    if (candidates.isEmpty) return null;
    
    // Filter by capabilities
    final capable = candidates.where((s) {
      for (final req in requirements.entries) {
        if (!s.capabilities.containsKey(req.key) || 
            s.capabilities[req.key] != req.value) {
          return false;
        }
      }
      return true;
    }).toList();
    
    if (capable.isEmpty) return null;
    
    // Sort by performance metrics
    capable.sort((a, b) {
      // Lower response time is better
      final responseTimeDiff = a.responseTime - b.responseTime;
      if (responseTimeDiff.abs() > 50) { // If difference is significant
        return responseTimeDiff < 0 ? -1 : 1;
      }
      
      // Lower error rate is better
      final errorRateDiff = a.errorRate - b.errorRate;
      if (errorRateDiff.abs() > 0.01) { // If difference is significant
        return errorRateDiff < 0 ? -1 : 1;
      }
      
      // Lower resource usage is better
      final resourceUsageDiff = 
          (a.cpuUsage + a.memoryUsage) - (b.cpuUsage + b.memoryUsage);
      return resourceUsageDiff < 0 ? -1 : 1;
    });
    
    return capable.first;
  }
  
  bool isServiceTypeAvailable(ServiceType type) {
    return getHealthyServicesByType(type).isNotEmpty;
  }
  
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(Duration(minutes: 1), (_) {
      _cleanupInactiveServices();
    });
  }
  
  void _cleanupInactiveServices() {
    final now = DateTime.now();
    final inactiveServiceIds = <String>[];
    
    for (final service in _services.values) {
      final inactiveDuration = now.difference(service.lastHeartbeat);
      if (inactiveDuration.inMinutes > 5) {
        inactiveServiceIds.add(service.id);
      }
    }
    
    for (final id in inactiveServiceIds) {
      deregisterService(id);
    }
  }
  
  Future<void> _syncWithCentralRegistry() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_registryUrl/services'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        
        // Clear existing data
        _services.clear();
        _servicesByType.clear();
        
        // Add services from central registry
        for (final item in data) {
          final service = ServiceEndpoint.fromJson(item);
          _services[service.id] = service;
          _servicesByType.putIfAbsent(service.type, () => []).add(service);
        }
      } else {
        throw Exception('Failed to sync with central registry: ${response.statusCode}');
      }
    } catch (e) {
      print('Error syncing with central registry: $e');
      rethrow;
    }
  }
  
  // Public getters
  Stream<ServiceEndpoint> get serviceUpdates => _serviceUpdates.stream;
  Stream<String> get serviceRemovals => _serviceRemovals.stream;
  
  bool get isInitialized => _isInitialized;
  
  int get totalServices => _services.length;
  
  int get healthyServices => _services.values.where((s) => s.isHealthy).length;
  
  double get healthPercentage => 
      totalServices > 0 ? (healthyServices / totalServices) * 100 : 0.0;
  
  // Cleanup
  void dispose() {
    _cleanupTimer?.cancel();
    _serviceUpdates.close();
    _serviceRemovals.close();
    _httpClient.close();
  }
}

// Riverpod provider
final serviceRegistryProvider = Provider<ServiceRegistry>((ref) {
  final registry = ServiceRegistry(
    registryUrl: 'https://api.dairymanagement.com/registry',
  );
  
  ref.onDispose(() {
    registry.dispose();
  });
  
  return registry;
});
```

### **2. API Gateway (api_gateway.dart)**
```dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/ai_context.dart';
import 'service_registry.dart';
import 'circuit_breaker.dart';

enum RequestPriority {
  low,
  standard,
  high,
  critical
}

class APIRequest {
  final String id;
  final String path;
  final String method;
  final Map<String, dynamic> body;
  final Map<String, String> headers;
  final RequestPriority priority;
  final Duration timeout;
  final bool retry;
  final int maxRetries;
  final String? correlationId;
  final DateTime timestamp;
  final ServiceType targetService;
  
  APIRequest({
    required this.id,
    required this.path,
    required this.method,
    required this.body,
    required this.headers,
    this.priority = RequestPriority.standard,
    this.timeout = const Duration(seconds: 30),
    this.retry = true,
    this.maxRetries = 3,
    this.correlationId,
    DateTime? timestamp,
    required this.targetService,
  }) : timestamp = timestamp ?? DateTime.now();
}

class APIResponse {
  final String requestId;
  final int statusCode;
  final Map<String, dynamic> body;
  final Map<String, String> headers;
  final Duration latency;
  final bool success;
  final String? error;
  final String serviceName;
  final String serviceVersion;
  final DateTime timestamp;
  
  APIResponse({
    required this.requestId,
    required this.statusCode,
    required this.body,
    required this.headers,
    required this.latency,
    required this.success,
    this.error,
    required this.serviceName,
    required this.serviceVersion,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;
  
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'statusCode': statusCode,
      'body': body,
      'headers': headers,
      'latency': latency.inMilliseconds,
      'success': success,
      'error': error,
      'serviceName': serviceName,
      'serviceVersion': serviceVersion,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class APIGateway {
  final ServiceRegistry _serviceRegistry;
  final CircuitBreaker _circuitBreaker;
  final http.Client _httpClient;
  
  // Rate limiting
  final Map<String, int> _requestCounts = {};
  final Map<String, DateTime> _rateLimitResets = {};
  final Map<RequestPriority, int> _priorityLimits = {
    RequestPriority.low: 30,
    RequestPriority.standard: 60,
    RequestPriority.high: 100,
    RequestPriority.critical: 150,
  };
  
  // Request queue for throttling and prioritization
  final Map<RequestPriority, List<APIRequest>> _requestQueues = {
    RequestPriority.low: [],
    RequestPriority.standard: [],
    RequestPriority.high: [],
    RequestPriority.critical: [],
  };
  
  // Metrics
  int _totalRequests = 0;
  int _successfulRequests = 0;
  int _failedRequests = 0;
  final List<Duration> _latencies = [];
  final Map<ServiceType, int> _serviceRequests = {};
  
  // Processing control
  bool _isProcessing = false;
  Timer? _processingTimer;
  Timer? _metricsTimer;
  
  // Event streams
  final StreamController<APIResponse> _responseStream = 
      StreamController<APIResponse>.broadcast();
  
  APIGateway({
    required ServiceRegistry serviceRegistry,
    required CircuitBreaker circuitBreaker,
    http.Client? httpClient,
  }) : _serviceRegistry = serviceRegistry,
       _circuitBreaker = circuitBreaker,
       _httpClient = httpClient ?? http.Client() {
    _startProcessingTimer();
    _startMetricsTimer();
  }
  
  // Public API request methods
  Future<APIResponse> executeRequest(APIRequest request) async {
    _totalRequests++;
    _serviceRequests[request.targetService] = 
        (_serviceRequests[request.targetService] ?? 0) + 1;
    
    try {
      // Check rate limits
      if (_isRateLimited(request)) {
        return _createErrorResponse(
          request,
          429,
          'Rate limit exceeded',
          'Too many requests',
        );
      }
      
      // Check circuit breaker
      if (_circuitBreaker.isOpen(request.targetService.toString())) {
        return _createErrorResponse(
          request,
          503,
          'Service unavailable',
          'Circuit breaker is open',
        );
      }
      
      // Get service endpoint
      final service = await _serviceRegistry.discoverOptimalService(
        request.targetService,
        {},
      );
      
      if (service == null) {
        return _createErrorResponse(
          request,
          503,
          'Service unavailable',
          'No available service endpoints',
        );
      }
      
      // Execute request
      final stopwatch = Stopwatch()..start();
      
      try {
        final response = await _executeHttpRequest(request, service);
        stopwatch.stop();
        
        final apiResponse = APIResponse(
          requestId: request.id,
          statusCode: response.statusCode,
          body: _parseResponseBody(response),
          headers: response.headers,
          latency: stopwatch.elapsed,
          success: response.statusCode >= 200 && response.statusCode < 300,
          serviceName: service.name,
          serviceVersion: service.version.toString(),
        );
        
        // Update metrics
        _latencies.add(stopwatch.elapsed);
        if (apiResponse.isSuccess) {
          _successfulRequests++;
          _circuitBreaker.recordSuccess(request.targetService.toString());
        } else {
          _failedRequests++;
          _circuitBreaker.recordFailure(request.targetService.toString());
        }
        
        // Emit response
        _responseStream.add(apiResponse);
        
        return apiResponse;
      } catch (e) {
        stopwatch.stop();
        _failedRequests++;
        _circuitBreaker.recordFailure(request.targetService.toString());
        
        // Handle retries
        if (request.retry && request.maxRetries > 0) {
          return await _retryRequest(request, service, e.toString(), 1);
        }
        
        final errorResponse = _createErrorResponse(
          request,
          500,
          'Internal error',
          e.toString(),
          service: service,
          latency: stopwatch.elapsed,
        );
        _responseStream.add(errorResponse);
        return errorResponse;
      }
    } catch (e) {
      _failedRequests++;
      
      final errorResponse = _createErrorResponse(
        request,
        500,
        'Gateway error',
        e.toString(),
      );
      _responseStream.add(errorResponse);
      return errorResponse;
    }
  }
  
  Future<APIResponse> processAIRequest({
    required String requestId,
    required Map<String, dynamic> payload,
    required AIContext context,
    ServiceType? preferredService,
  }) async {
    // Determine best service for AI request
    final serviceType = preferredService ?? _determineBestAIService(payload, context);
    
    // Create API request
    final apiRequest = APIRequest(
      id: requestId,
      path: '/api/v1/process',
      method: 'POST',
      body: {
        'payload': payload,
        'context': context.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      },
      headers: {
        'Content-Type': 'application/json',
        'X-Correlation-ID': requestId,
        'X-Request-Priority': RequestPriority.high.toString(),
      },
      priority: RequestPriority.high,
      targetService: serviceType,
    );
    
    // Execute request
    return await executeRequest(apiRequest);
  }
  
  Future<APIResponse> queueRequest(APIRequest request) async {
    // Add to priority queue
    _requestQueues[request.priority]!.add(request);
    
    // Return a future that will complete when request is processed
    final completer = Completer<APIResponse>();
    
    // Set up listener for response
    final subscription = _responseStream.stream.listen((response) {
      if (response.requestId == request.id) {
        completer.complete(response);
      }
    });
    
    // Set timeout
    Timer(request.timeout, () {
      if (!completer.isCompleted) {
        _requestQueues[request.priority]!.removeWhere((r) => r.id == request.id);
        
        final timeoutResponse = _createErrorResponse(
          request,
          408,
          'Request timeout',
          'Request exceeded timeout of ${request.timeout.inSeconds} seconds',
        );
        
        completer.complete(timeoutResponse);
      }
    });
    
    // Clean up subscription when done
    completer.future.then((_) => subscription.cancel());
    
    return completer.future;
  }
  
  // Private helper methods
  Future<http.Response> _executeHttpRequest(
    APIRequest request,
    ServiceEndpoint service,
  ) async {
    final url = Uri.parse('${service.baseUrl}${request.path}');
    
    switch (request.method.toUpperCase()) {
      case 'GET':
        return await _httpClient.get(
          url,
          headers: request.headers,
        );
      case 'POST':
        return await _httpClient.post(
          url,
          headers: request.headers,
          body: json.encode(request.body),
        );
      case 'PUT':
        return await _httpClient.put(
          url,
          headers: request.headers,
          body: json.encode(request.body),
        );
      case 'DELETE':
        return await _httpClient.delete(
          url,
          headers: request.headers,
        );
      default:
        throw Exception('Unsupported HTTP method: ${request.method}');
    }
  }
  
  Future<APIResponse> _retryRequest(
    APIRequest request,
    ServiceEndpoint service,
    String error,
    int attempt,
  ) async {
    if (attempt > request.maxRetries) {
      return _createErrorResponse(
        request,
        500,
        'Max retries exceeded',
        'Failed after ${request.maxRetries} attempts: $error',
        service: service,
      );
    }
    
    // Exponential backoff
    final backoffMs = 100 * (1 << (attempt - 1));
    await Future.delayed(Duration(milliseconds: backoffMs));
    
    // Try with a different service if available
    final alternativeService = await _serviceRegistry.discoverOptimalService(
      request.targetService,
      {},
    );
    
    final targetService = alternativeService ?? service;
    
    try {
      final stopwatch = Stopwatch()..start();
      final response = await _executeHttpRequest(request, targetService);
      stopwatch.stop();
      
      final apiResponse = APIResponse(
        requestId: request.id,
        statusCode: response.statusCode,
        body: _parseResponseBody(response),
        headers: response.headers,
        latency: stopwatch.elapsed,
        success: response.statusCode >= 200 && response.statusCode < 300,
        serviceName: targetService.name,
        serviceVersion: targetService.version.toString(),
      );
      
      // Update metrics
      _latencies.add(stopwatch.elapsed);
      if (apiResponse.isSuccess) {
        _successfulRequests++;
        _circuitBreaker.recordSuccess(request.targetService.toString());
      } else {
        _failedRequests++;
        _circuitBreaker.recordFailure(request.targetService.toString());
        
        // Retry for certain status codes
        if (_shouldRetryStatusCode(response.statusCode)) {
          return await _retryRequest(
            request,
            targetService,
            'Status code: ${response.statusCode}',
            attempt + 1,
          );
        }
      }
      
      _responseStream.add(apiResponse);
      return apiResponse;
    } catch (e) {
      _failedRequests++;
      _circuitBreaker.recordFailure(request.targetService.toString());
      
      return await _retryRequest(
        request,
        targetService,
        e.toString(),
        attempt + 1,
      );
    }
  }
  
  bool _shouldRetryStatusCode(int statusCode) {
    // Retry server errors and certain client errors
    return statusCode >= 500 || statusCode == 429;
  }
  
  bool _isRateLimited(APIRequest request) {
    final clientId = request.headers['X-Client-ID'] ?? 'anonymous';
    final minute = DateTime.now().minute;
    final limitKey = '$clientId:$minute';
    
    // Reset counters for new minute
    if (!_rateLimitResets.containsKey(limitKey) || 
        _rateLimitResets[limitKey]!.minute != DateTime.now().minute) {
      _requestCounts[limitKey] = 0;
      _rateLimitResets[limitKey] = DateTime.now();
    }
    
    // Increment and check
    _requestCounts[limitKey] = (_requestCounts[limitKey] ?? 0) + 1;
    final priorityLimit = _priorityLimits[request.priority] ?? 60;
    
    return _requestCounts[limitKey]! > priorityLimit;
  }
  
  Map<String, dynamic> _parseResponseBody(http.Response response) {
    if (response.body.isEmpty) return {};
    
    try {
      return json.decode(response.body);
    } catch (e) {
      return {'raw_content': response.body};
    }
  }
  
  APIResponse _createErrorResponse(
    APIRequest request,
    int statusCode,
    String error,
    String details, {
    ServiceEndpoint? service,
    Duration? latency,
  }) {
    return APIResponse(
      requestId: request.id,
      statusCode: statusCode,
      body: {
        'error': error,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      },
      headers: {},
      latency: latency ?? Duration.zero,
      success: false,
      error: error,
      serviceName: service?.name ?? 'gateway',
      serviceVersion: service?.version.toString() ?? '1.0',
    );
  }
  
  ServiceType _determineBestAIService(Map<String, dynamic> payload, AIContext context) {
    // Analyze payload and context to route to appropriate service
    if (payload.containsKey('image')) {
      return ServiceType.computerVision;
    }
    
    if (payload.containsKey('document')) {
      return ServiceType.nlpProcessor;
    }
    
    if (payload.containsKey('timeSeries') || payload.containsKey('patterns')) {
      return ServiceType.patternRecognition;
    }
    
    // Default to universal AI service
    return ServiceType.universalAI;
  }
  
  void _startProcessingTimer() {
    _processingTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
      if (!_isProcessing) {
        _processNextRequest();
      }
    });
  }
  
  void _startMetricsTimer() {
    _metricsTimer = Timer.periodic(Duration(minutes: 1), (_) {
      _resetMetricsTimeBuckets();
    });
  }
  
  Future<void> _processNextRequest() async {
    if (_isProcessing) return;
    
    final request = _getNextRequest();
    if (request == null) return;
    
    _isProcessing = true;
    try {
      await executeRequest(request);
    } catch (e) {
      print('Error processing queued request: $e');
    } finally {
      _isProcessing = false;
    }
  }
  
  APIRequest? _getNextRequest() {
    // Process requests in priority order
    for (final priority in RequestPriority.values.reversed) {
      final queue = _requestQueues[priority]!;
      if (queue.isNotEmpty) {
        return queue.removeAt(0);
      }
    }
    return null;
  }
  
  void _resetMetricsTimeBuckets() {
    // Reset rate limiting counters every minute
    final currentMinute = DateTime.now().minute;
    _requestCounts.removeWhere((key, _) => 
        key.contains(':') && int.parse(key.split(':')[1]) != currentMinute);
  }
  
  // Public metrics methods
  Map<String, dynamic> getMetrics() {
    final avgLatency = _latencies.isEmpty ? 0 :
        _latencies.map((d) => d.inMilliseconds).reduce((a, b) => a + b) / _latencies.length;
    
    return {
      'total_requests': _totalRequests,
      'successful_requests': _successfulRequests,
      'failed_requests': _failedRequests,
      'success_rate': _totalRequests > 0 ? _successfulRequests / _totalRequests : 0,
      'average_latency_ms': avgLatency,
      'queue_depth': _getQueueDepth(),
      'service_distribution': _serviceRequests,
      'circuit_breaker_states': _circuitBreaker.getCircuitStates(),
    };
  }
  
  int _getQueueDepth() {
    return _requestQueues.values
        .map((queue) => queue.length)
        .reduce((a, b) => a + b);
  }
  
  // Public getters
  Stream<APIResponse> get responses => _responseStream.stream;
  
  bool get isHealthy => _serviceRegistry.healthPercentage > 70;
  
  int get queueDepth => _getQueueDepth();
  
  int get activeServices => _serviceRegistry.healthyServices;
  
  double get successRate => _totalRequests > 0 ? _successfulRequests / _totalRequests : 0;
  
  // Cleanup
  void dispose() {
    _processingTimer?.cancel();
    _metricsTimer?.cancel();
    _responseStream.close();
    _httpClient.close();
  }
}

// Riverpod provider
final apiGatewayProvider = Provider<APIGateway>((ref) {
  final serviceRegistry = ref.watch(serviceRegistryProvider);
  final circuitBreaker = ref.watch(circuitBreakerProvider);
  
  final gateway = APIGateway(
    serviceRegistry: serviceRegistry,
    circuitBreaker: circuitBreaker,
  );
  
  ref.onDispose(() {
    gateway.dispose();
  });
  
  return gateway;
});

// Circuit breaker provider (simplified reference)
final circuitBreakerProvider = Provider<CircuitBreaker>((ref) {
  return CircuitBreaker(
    failureThreshold: 5,
    resetTimeout: Duration(seconds: 30),
  );
});
``` 