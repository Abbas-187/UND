import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../../data/services/offline_ai_service.dart';
import '../../../data/services/edge_computing_service.dart';

/// Offline AI widget providing intelligent functionality without internet connectivity
/// Includes local AI models, cached responses, and edge computing capabilities
class OfflineAIWidget extends StatefulWidget {
  final bool enableLocalModels;
  final bool enableCachedResponses;
  final bool enableEdgeComputing;
  final String? fallbackMessage;

  const OfflineAIWidget({
    Key? key,
    this.enableLocalModels = true,
    this.enableCachedResponses = true,
    this.enableEdgeComputing = true,
    this.fallbackMessage,
  }) : super(key: key);

  @override
  State<OfflineAIWidget> createState() => _OfflineAIWidgetState();
}

class _OfflineAIWidgetState extends State<OfflineAIWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _syncController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;

  final OfflineAIService _offlineService = OfflineAIService();
  final EdgeComputingService _edgeService = EdgeComputingService();
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _responseController = ScrollController();

  bool _isOffline = false;
  bool _isProcessing = false;
  bool _isSyncing = false;
  String _connectionStatus = 'Online';
  List<OfflineResponse> _responses = [];
  Map<String, dynamic> _offlineCapabilities = {};
  List<String> _cachedQueries = [];
  int _pendingSyncCount = 0;

  // Offline AI models status
  Map<String, ModelStatus> _modelStatus = {};
  double _downloadProgress = 0.0;
  bool _isDownloadingModels = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeOfflineCapabilities();
    _checkConnectivity();
    _loadCachedData();
    _startConnectivityMonitoring();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _syncController.dispose();
    _queryController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _syncController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _syncController, curve: Curves.linear));

    _animationController.forward();
  }

  void _initializeOfflineCapabilities() async {
    try {
      _offlineCapabilities = await _offlineService.getCapabilities();
      _modelStatus = await _offlineService.getModelStatus();

      setState(() {});
    } catch (e) {
      debugPrint('Error initializing offline capabilities: $e');
    }
  }

  void _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      setState(() {
        _isOffline = result.isEmpty;
        _connectionStatus = _isOffline ? 'Offline' : 'Online';
      });
    } catch (_) {
      setState(() {
        _isOffline = true;
        _connectionStatus = 'Offline';
      });
    }
  }

  void _startConnectivityMonitoring() {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _checkConnectivity();
        if (!_isOffline && _pendingSyncCount > 0) {
          _syncPendingResponses();
        }
      }
    });
  }

  void _loadCachedData() async {
    try {
      final cached = await _offlineService.getCachedResponses();
      final queries = await _offlineService.getCachedQueries();

      setState(() {
        _responses = cached;
        _cachedQueries = queries;
      });
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildConnectionStatus(),
            Expanded(
              child: _buildMainContent(),
            ),
            _buildInputSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isOffline
              ? [const Color(0xFFFF6B35), const Color(0xFFFF8E53)]
              : [const Color(0xFF00E5FF), const Color(0xFF0072FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isOffline ? Icons.wifi_off : Icons.wifi,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOffline ? 'Offline AI Assistant' : 'AI Assistant',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isOffline
                      ? 'Working with local AI models'
                      : 'Connected to cloud AI',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (_pendingSyncCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                '$_pendingSyncCount pending',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isOffline ? const Color(0xFFFF6B35) : const Color(0xFF4CAF50),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isOffline ? Colors.orange : Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $_connectionStatus',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (_isOffline) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Using offline capabilities: ${_getOfflineCapabilitiesText()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_isSyncing)
            RotationTransition(
              turns: _rotateAnimation,
              child: const Icon(
                Icons.sync,
                color: Color(0xFF00E5FF),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isDownloadingModels) {
      return _buildModelDownloadProgress();
    }

    return Column(
      children: [
        if (widget.enableLocalModels) _buildModelStatus(),
        Expanded(child: _buildResponsesList()),
        if (_isOffline) _buildOfflineFeatures(),
      ],
    );
  }

  Widget _buildModelDownloadProgress() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.download,
            color: Color(0xFF00E5FF),
            size: 64,
          ),
          const SizedBox(height: 24),
          const Text(
            'Downloading AI Models',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This may take a few minutes...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: _downloadProgress,
            backgroundColor: const Color(0xFF2A2F3E),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
          ),
          const SizedBox(height: 12),
          Text(
            '${(_downloadProgress * 100).toInt()}% complete',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelStatus() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2F3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Local AI Models',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ..._modelStatus.entries
              .map((entry) => _buildModelStatusItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildModelStatusItem(String modelName, ModelStatus status) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case ModelStatus.available:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Available';
        break;
      case ModelStatus.downloading:
        statusColor = Colors.orange;
        statusIcon = Icons.download;
        statusText = 'Downloading';
        break;
      case ModelStatus.notDownloaded:
        statusColor = Colors.grey;
        statusIcon = Icons.cloud_download;
        statusText = 'Not Downloaded';
        break;
      case ModelStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Error';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              modelName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
            ),
          ),
          if (status == ModelStatus.notDownloaded)
            IconButton(
              onPressed: () => _downloadModel(modelName),
              icon: const Icon(Icons.download,
                  color: Color(0xFF00E5FF), size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildResponsesList() {
    if (_responses.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _responseController,
      padding: const EdgeInsets.all(16),
      itemCount: _responses.length,
      itemBuilder: (context, index) {
        final response = _responses[index];
        return _buildResponseCard(response);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isOffline ? Icons.offline_bolt : Icons.chat_bubble_outline,
            color: Colors.white60,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _isOffline ? 'Offline AI Ready' : 'Start a conversation',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isOffline
                ? 'Ask questions using local AI models'
                : 'Ask me anything about your warehouse',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white40,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponseCard(OfflineResponse response) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: response.isFromCache
              ? const Color(0xFFFF9800)
              : const Color(0xFF2A2F3E),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  response.query,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                children: [
                  if (response.isFromCache)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'CACHED',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (!response.isSynced)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'PENDING',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            response.response,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                response.source,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
              Text(
                _formatTimestamp(response.timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineFeatures() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF6B35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Offline Features',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip(
                  'Cached Responses', Icons.storage, Colors.orange),
              _buildFeatureChip('Local Models', Icons.memory, Colors.blue),
              _buildFeatureChip('Edge Computing', Icons.computer, Colors.green),
              _buildFeatureChip(
                  'Smart Predictions', Icons.smart_toy, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F2E),
        border: Border(
          top: BorderSide(color: Color(0xFF2A2F3E)),
        ),
      ),
      child: Column(
        children: [
          if (_cachedQueries.isNotEmpty) _buildQuickQueries(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E1A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF2A2F3E)),
                  ),
                  child: TextField(
                    controller: _queryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: _isOffline
                          ? 'Ask offline AI...'
                          : 'Ask me anything...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _processQuery,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _processQuery(_queryController.text);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isOffline
                          ? [const Color(0xFFFF6B35), const Color(0xFFFF8E53)]
                          : [const Color(0xFF00E5FF), const Color(0xFF0072FF)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQueries() {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _cachedQueries.take(5).length,
        itemBuilder: (context, index) {
          final query = _cachedQueries[index];
          return GestureDetector(
            onTap: () {
              _queryController.text = query;
              _processQuery(query);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2F3E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00E5FF)),
              ),
              child: Text(
                query.length > 20 ? '${query.substring(0, 20)}...' : query,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF00E5FF),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Event handlers
  void _processQuery(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      OfflineResponse response;

      if (_isOffline) {
        // Use offline AI service
        response = await _offlineService.processQuery(query.trim());
      } else {
        // Use regular AI service but cache the response
        response = await _processOnlineQuery(query.trim());
        await _offlineService.cacheResponse(response);
      }

      setState(() {
        _responses.add(response);
        _queryController.clear();

        if (!_isOffline && !response.isSynced) {
          _pendingSyncCount++;
        }
      });

      _scrollToBottom();
    } catch (e) {
      _showErrorSnackBar('Failed to process query: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<OfflineResponse> _processOnlineQuery(String query) async {
    // This would typically call the online AI service
    // For demo purposes, returning a mock response
    return OfflineResponse(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      query: query,
      response: 'This is a response from the online AI service.',
      source: 'Online AI',
      timestamp: DateTime.now(),
      isFromCache: false,
      isSynced: true,
    );
  }

  void _downloadModel(String modelName) async {
    setState(() {
      _isDownloadingModels = true;
      _downloadProgress = 0.0;
      _modelStatus[modelName] = ModelStatus.downloading;
    });

    try {
      await _offlineService.downloadModel(
        modelName,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      setState(() {
        _modelStatus[modelName] = ModelStatus.available;
        _isDownloadingModels = false;
      });

      _showSuccessSnackBar('Model $modelName downloaded successfully');
    } catch (e) {
      setState(() {
        _modelStatus[modelName] = ModelStatus.error;
        _isDownloadingModels = false;
      });

      _showErrorSnackBar('Failed to download model: $e');
    }
  }

  void _syncPendingResponses() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    _syncController.repeat();

    try {
      await _offlineService.syncPendingResponses();

      setState(() {
        _pendingSyncCount = 0;
        // Update responses to mark them as synced
        for (final response in _responses) {
          if (!response.isSynced) {
            response.isSynced = true;
          }
        }
      });

      _showSuccessSnackBar('Responses synced successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to sync responses: $e');
    } finally {
      setState(() {
        _isSyncing = false;
      });

      _syncController.stop();
    }
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      if (_responseController.hasClients) {
        _responseController.animateTo(
          _responseController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getOfflineCapabilitiesText() {
    final capabilities = <String>[];
    if (widget.enableLocalModels) capabilities.add('Local Models');
    if (widget.enableCachedResponses) capabilities.add('Cached Responses');
    if (widget.enableEdgeComputing) capabilities.add('Edge Computing');

    return capabilities.isEmpty ? 'None' : capabilities.join(', ');
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Data Models
class OfflineResponse {
  final String id;
  final String query;
  final String response;
  final String source;
  final DateTime timestamp;
  final bool isFromCache;
  bool isSynced;

  OfflineResponse({
    required this.id,
    required this.query,
    required this.response,
    required this.source,
    required this.timestamp,
    required this.isFromCache,
    required this.isSynced,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'response': response,
      'source': source,
      'timestamp': timestamp.toIso8601String(),
      'isFromCache': isFromCache,
      'isSynced': isSynced,
    };
  }

  factory OfflineResponse.fromJson(Map<String, dynamic> json) {
    return OfflineResponse(
      id: json['id'],
      query: json['query'],
      response: json['response'],
      source: json['source'],
      timestamp: DateTime.parse(json['timestamp']),
      isFromCache: json['isFromCache'],
      isSynced: json['isSynced'],
    );
  }
}

enum ModelStatus {
  available,
  downloading,
  notDownloaded,
  error,
}
