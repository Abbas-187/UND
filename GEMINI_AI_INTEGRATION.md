# Gemini AI Integration & Continuous Learning
## Overview: Smart Procurement with Gemini API

This document outlines the integration of Google's Gemini API into your procurement module, enabling intelligent decision-making and continuous learning from your company's data.

### Key Features
- **Real-time AI insights** using Gemini API
- **Continuous learning** from procurement patterns
- **Context-aware recommendations** based on company history
- **Privacy-first approach** with local data processing
- **Incremental model improvement** over time

---

## 1. Gemini API Service Implementation

### 1.1 Core Gemini Service
**File**: `lib/core/ai/gemini_ai_service.dart`

```dart
class GeminiAIService {
  final String _apiKey;
  final Dio _dio;
  final Logger _logger;
  final CacheManager _cacheManager;
  final CompanyDataService _companyDataService;

  GeminiAIService({
    required String apiKey,
    required Dio dio,
    required Logger logger,
    required CacheManager cacheManager,
    required CompanyDataService companyDataService,
  }) : _apiKey = apiKey,
       _dio = dio,
       _logger = logger,
       _cacheManager = cacheManager,
       _companyDataService = companyDataService;

  /// Generate procurement insights using Gemini
  Future<ProcurementInsight> generateProcurementInsight({
    required String query,
    required ProcurementContext context,
    bool useCompanyData = true,
  }) async {
    try {
      // Build context-aware prompt
      final prompt = await _buildContextualPrompt(query, context, useCompanyData);
      
      // Call Gemini API
      final response = await _callGeminiAPI(prompt);
      
      // Parse and structure response
      final insight = await _parseGeminiResponse(response, context);
      
      // Store interaction for learning
      await _storeInteractionForLearning(query, context, insight);
      
      return insight;
      
    } catch (error) {
      _logger.e('Error generating procurement insight: $error');
      rethrow;
    }
  }

  /// Analyze supplier performance with AI
  Future<SupplierAnalysis> analyzeSupplierPerformance({
    required String supplierId,
    required int analysisMonths,
  }) async {
    // Get company's historical data for this supplier
    final supplierHistory = await _companyDataService.getSupplierHistory(
      supplierId: supplierId,
      months: analysisMonths,
    );

    // Build analysis prompt with company context
    final prompt = await _buildSupplierAnalysisPrompt(supplierId, supplierHistory);
    
    final response = await _callGeminiAPI(prompt);
    
    return SupplierAnalysis.fromGeminiResponse(response, supplierHistory);
  }

  /// Smart contract review using Gemini
  Future<ContractReview> reviewContract({
    required String contractText,
    required ContractType contractType,
  }) async {
    // Get company's contract patterns and preferences
    final companyContractPatterns = await _companyDataService.getContractPatterns(contractType);
    
    final prompt = await _buildContractReviewPrompt(
      contractText,
      contractType,
      companyContractPatterns,
    );
    
    final response = await _callGeminiAPI(prompt);
    
    return ContractReview.fromGeminiResponse(response);
  }

  /// Build contextual prompt with company data
  Future<String> _buildContextualPrompt(
    String query,
    ProcurementContext context,
    bool useCompanyData,
  ) async {
    final promptBuilder = StringBuffer();
    
    // Base system prompt
    promptBuilder.writeln('''
You are an expert procurement AI assistant for a dairy management company. 
You have deep knowledge of procurement best practices, supplier management, 
cost optimization, and risk assessment.

Current Context:
- Company: ${context.companyName}
- Department: ${context.department}
- Budget Period: ${context.budgetPeriod}
- Current Date: ${DateTime.now().toIso8601String()}
''');

    if (useCompanyData) {
      // Add company-specific context
      final companyInsights = await _getCompanyInsights(context);
      promptBuilder.writeln('\nCompany Historical Insights:');
      promptBuilder.writeln(companyInsights);
      
      // Add recent procurement patterns
      final recentPatterns = await _getRecentProcurementPatterns(context);
      promptBuilder.writeln('\nRecent Procurement Patterns:');
      promptBuilder.writeln(recentPatterns);
      
      // Add supplier performance data
      final supplierPerformance = await _getSupplierPerformanceSummary(context);
      promptBuilder.writeln('\nSupplier Performance Summary:');
      promptBuilder.writeln(supplierPerformance);
    }

    // Add the actual query
    promptBuilder.writeln('\nUser Query: $query');
    
    promptBuilder.writeln('''
Please provide a detailed, actionable response that:
1. Addresses the specific query
2. Considers the company's historical data and patterns
3. Provides specific recommendations with reasoning
4. Includes risk assessment where relevant
5. Suggests next steps or actions

Format your response as structured JSON with the following fields:
- summary: Brief overview of your analysis
- recommendations: Array of specific recommendations
- risks: Array of identified risks
- nextActions: Array of suggested next steps
- confidence: Confidence level (0-100)
- reasoning: Detailed explanation of your analysis
''');

    return promptBuilder.toString();
  }

  /// Call Gemini API with retry logic
  Future<Map<String, dynamic>> _callGeminiAPI(String prompt) async {
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final response = await _dio.post(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': _apiKey,
            },
          ),
          data: {
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.7,
              'topK': 40,
              'topP': 0.95,
              'maxOutputTokens': 2048,
            },
            'safetySettings': [
              {
                'category': 'HARM_CATEGORY_HARASSMENT',
                'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
              },
              {
                'category': 'HARM_CATEGORY_HATE_SPEECH',
                'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
              },
              {
                'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
                'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
              },
              {
                'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
              }
            ]
          },
        );

        if (response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Gemini API error: ${response.statusCode}');
        }

      } catch (error) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Failed to call Gemini API after $maxRetries retries: $error');
        }
        
        // Exponential backoff
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }

    throw Exception('Unexpected error in Gemini API call');
  }

  /// Store interaction for continuous learning
  Future<void> _storeInteractionForLearning(
    String query,
    ProcurementContext context,
    ProcurementInsight insight,
  ) async {
    final interaction = AIInteraction(
      id: Uuid().v4(),
      query: query,
      context: context,
      response: insight,
      timestamp: DateTime.now(),
      userId: context.userId,
      feedback: null, // Will be updated when user provides feedback
    );

    // Store in Firestore for learning
    await FirebaseFirestore.instance
        .collection('ai_interactions')
        .doc(interaction.id)
        .set(interaction.toJson());

    // Update company learning patterns
    await _updateCompanyLearningPatterns(interaction);
  }
}

@freezed
class ProcurementInsight with _$ProcurementInsight {
  const factory ProcurementInsight({
    required String summary,
    required List<AIRecommendation> recommendations,
    required List<AIRisk> risks,
    required List<String> nextActions,
    required double confidence,
    required String reasoning,
    required DateTime generatedAt,
    String? id,
  }) = _ProcurementInsight;

  factory ProcurementInsight.fromJson(Map<String, dynamic> json) =>
      _$ProcurementInsightFromJson(json);
}

@freezed
class AIRecommendation with _$AIRecommendation {
  const factory AIRecommendation({
    required String title,
    required String description,
    required RecommendationPriority priority,
    required double impact,
    required String reasoning,
    List<String>? actionItems,
  }) = _AIRecommendation;

  factory AIRecommendation.fromJson(Map<String, dynamic> json) =>
      _$AIRecommendationFromJson(json);
}

@freezed
class ProcurementContext with _$ProcurementContext {
  const factory ProcurementContext({
    required String companyName,
    required String department,
    required String budgetPeriod,
    required String userId,
    Map<String, dynamic>? additionalContext,
  }) = _ProcurementContext;
}

enum RecommendationPriority { low, medium, high, urgent }
```

### 1.2 Company Data Learning Service
**File**: `lib/core/ai/company_data_service.dart`

```dart
class CompanyDataService {
  final FirebaseFirestore _firestore;
  final AnalyticsRepository _analyticsRepository;
  final Logger _logger;

  CompanyDataService({
    required FirebaseFirestore firestore,
    required AnalyticsRepository analyticsRepository,
    required Logger logger,
  }) : _firestore = firestore,
       _analyticsRepository = analyticsRepository,
       _logger = logger;

  /// Get company's procurement insights based on historical data
  Future<String> getCompanyInsights(ProcurementContext context) async {
    final insights = StringBuffer();

    // Spending patterns
    final spendingPatterns = await _getSpendingPatterns();
    insights.writeln('Spending Patterns: $spendingPatterns');

    // Supplier preferences
    final supplierPreferences = await _getSupplierPreferences();
    insights.writeln('Supplier Preferences: $supplierPreferences');

    // Seasonal trends
    final seasonalTrends = await _getSeasonalTrends();
    insights.writeln('Seasonal Trends: $seasonalTrends');

    // Risk tolerance
    final riskTolerance = await _getRiskTolerance();
    insights.writeln('Risk Tolerance: $riskTolerance');

    return insights.toString();
  }

  /// Get recent procurement patterns for AI context
  Future<String> getRecentProcurementPatterns(ProcurementContext context) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: 90)); // Last 3 months

    // Get recent purchase orders
    final recentPOs = await _analyticsRepository.getPurchaseOrderAnalytics(
      startDate: startDate,
      endDate: endDate,
    );

    // Analyze patterns
    final patterns = StringBuffer();
    
    // Average order value
    final avgOrderValue = recentPOs.fold<double>(0, (sum, po) => sum + po.totalAmount) / recentPOs.length;
    patterns.writeln('Average Order Value: \$${avgOrderValue.toStringAsFixed(2)}');

    // Most frequent suppliers
    final supplierFrequency = <String, int>{};
    for (final po in recentPOs) {
      supplierFrequency[po.supplierName] = (supplierFrequency[po.supplierName] ?? 0) + 1;
    }
    final topSuppliers = supplierFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    patterns.writeln('Top Suppliers: ${topSuppliers.take(5).map((e) => '${e.key} (${e.value} orders)').join(', ')}');

    // Category distribution
    final categorySpend = await _getCategorySpendDistribution(startDate, endDate);
    patterns.writeln('Category Spend Distribution: $categorySpend');

    return patterns.toString();
  }

  /// Learn from user feedback to improve AI responses
  Future<void> learnFromFeedback({
    required String interactionId,
    required AIFeedback feedback,
  }) async {
    try {
      // Update the interaction with feedback
      await _firestore
          .collection('ai_interactions')
          .doc(interactionId)
          .update({
        'feedback': feedback.toJson(),
        'feedbackTimestamp': DateTime.now().toIso8601String(),
      });

      // Extract learning patterns
      await _extractLearningPatterns(interactionId, feedback);

      // Update company AI preferences
      await _updateCompanyAIPreferences(feedback);

    } catch (error) {
      _logger.e('Error learning from feedback: $error');
    }
  }

  /// Extract learning patterns from interactions
  Future<void> _extractLearningPatterns(String interactionId, AIFeedback feedback) async {
    // Get the interaction
    final interactionDoc = await _firestore
        .collection('ai_interactions')
        .doc(interactionId)
        .get();

    if (!interactionDoc.exists) return;

    final interaction = AIInteraction.fromJson(interactionDoc.data()!);

    // Analyze what worked well or poorly
    final learningPattern = LearningPattern(
      id: Uuid().v4(),
      interactionId: interactionId,
      queryType: _categorizeQuery(interaction.query),
      contextFactors: _extractContextFactors(interaction.context),
      responseQuality: feedback.rating,
      whatWorked: feedback.whatWorked,
      whatDidntWork: feedback.whatDidntWork,
      improvementSuggestions: feedback.suggestions,
      timestamp: DateTime.now(),
    );

    // Store learning pattern
    await _firestore
        .collection('learning_patterns')
        .doc(learningPattern.id)
        .set(learningPattern.toJson());

    // Update aggregated learning insights
    await _updateAggregatedLearning(learningPattern);
  }

  /// Update company AI preferences based on feedback
  Future<void> _updateCompanyAIPreferences(AIFeedback feedback) async {
    final preferencesRef = _firestore.collection('company_ai_preferences').doc('current');
    
    await _firestore.runTransaction((transaction) async {
      final preferencesDoc = await transaction.get(preferencesRef);
      
      Map<String, dynamic> preferences;
      if (preferencesDoc.exists) {
        preferences = preferencesDoc.data()!;
      } else {
        preferences = {
          'responseStyle': 'detailed',
          'riskTolerance': 'medium',
          'preferredRecommendationTypes': <String>[],
          'learningMetrics': {
            'totalInteractions': 0,
            'averageRating': 0.0,
            'improvementAreas': <String, int>{},
          },
        };
      }

      // Update learning metrics
      final metrics = preferences['learningMetrics'] as Map<String, dynamic>;
      final totalInteractions = (metrics['totalInteractions'] as int) + 1;
      final currentAvgRating = metrics['averageRating'] as double;
      final newAvgRating = ((currentAvgRating * (totalInteractions - 1)) + feedback.rating) / totalInteractions;

      metrics['totalInteractions'] = totalInteractions;
      metrics['averageRating'] = newAvgRating;

      // Track improvement areas
      if (feedback.rating < 3) {
        final improvementAreas = Map<String, int>.from(metrics['improvementAreas'] as Map);
        for (final area in feedback.improvementAreas) {
          improvementAreas[area] = (improvementAreas[area] ?? 0) + 1;
        }
        metrics['improvementAreas'] = improvementAreas;
      }

      // Update response style preferences
      if (feedback.preferredResponseStyle != null) {
        preferences['responseStyle'] = feedback.preferredResponseStyle;
      }

      transaction.set(preferencesRef, preferences);
    });
  }

  /// Get company's learned preferences for AI responses
  Future<CompanyAIPreferences> getCompanyAIPreferences() async {
    final preferencesDoc = await _firestore
        .collection('company_ai_preferences')
        .doc('current')
        .get();

    if (preferencesDoc.exists) {
      return CompanyAIPreferences.fromJson(preferencesDoc.data()!);
    }

    // Return default preferences
    return CompanyAIPreferences.defaultPreferences();
  }
}

@freezed
class AIFeedback with _$AIFeedback {
  const factory AIFeedback({
    required double rating, // 1-5 scale
    required List<String> whatWorked,
    required List<String> whatDidntWork,
    required List<String> suggestions,
    required List<String> improvementAreas,
    String? preferredResponseStyle,
    Map<String, dynamic>? additionalFeedback,
  }) = _AIFeedback;

  factory AIFeedback.fromJson(Map<String, dynamic> json) =>
      _$AIFeedbackFromJson(json);
}

@freezed
class LearningPattern with _$LearningPattern {
  const factory LearningPattern({
    required String id,
    required String interactionId,
    required String queryType,
    required Map<String, dynamic> contextFactors,
    required double responseQuality,
    required List<String> whatWorked,
    required List<String> whatDidntWork,
    required List<String> improvementSuggestions,
    required DateTime timestamp,
  }) = _LearningPattern;

  factory LearningPattern.fromJson(Map<String, dynamic> json) =>
      _$LearningPatternFromJson(json);
}

@freezed
class CompanyAIPreferences with _$CompanyAIPreferences {
  const factory CompanyAIPreferences({
    required String responseStyle,
    required String riskTolerance,
    required List<String> preferredRecommendationTypes,
    required Map<String, dynamic> learningMetrics,
    DateTime? lastUpdated,
  }) = _CompanyAIPreferences;

  factory CompanyAIPreferences.fromJson(Map<String, dynamic> json) =>
      _$CompanyAIPreferencesFromJson(json);

  factory CompanyAIPreferences.defaultPreferences() => CompanyAIPreferences(
    responseStyle: 'detailed',
    riskTolerance: 'medium',
    preferredRecommendationTypes: ['cost_optimization', 'risk_mitigation', 'supplier_diversification'],
    learningMetrics: {
      'totalInteractions': 0,
      'averageRating': 0.0,
      'improvementAreas': <String, int>{},
    },
    lastUpdated: DateTime.now(),
  );
}
```

---

## 2. Smart Procurement Features with Gemini

### 2.1 AI-Powered Purchase Order Assistant
**File**: `lib/features/procurement/presentation/widgets/ai_po_assistant.dart`

```dart
class AIPurchaseOrderAssistant extends ConsumerStatefulWidget {
  final PurchaseOrder? existingPO;
  final Function(PurchaseOrder) onPOGenerated;

  const AIPurchaseOrderAssistant({
    Key? key,
    this.existingPO,
    required this.onPOGenerated,
  }) : super(key: key);

  @override
  ConsumerState<AIPurchaseOrderAssistant> createState() => _AIPurchaseOrderAssistantState();
}

class _AIPurchaseOrderAssistantState extends ConsumerState<AIPurchaseOrderAssistant> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  'AI Purchase Order Assistant',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.help_outline),
                  onPressed: _showHelp,
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Chat interface
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Chat messages
                  Expanded(
                    child: ListView.builder(
                      controller: _chatScrollController,
                      padding: EdgeInsets.all(8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return ChatMessageWidget(message: message);
                      },
                    ),
                  ),
                  
                  // Input area
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _queryController,
                            decoration: InputDecoration(
                              hintText: 'Ask me anything about procurement...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onSubmitted: _sendMessage,
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          onPressed: _isLoading ? null : () => _sendMessage(_queryController.text),
                          icon: _isLoading 
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Quick action buttons
            Wrap(
              spacing: 8,
              children: [
                _buildQuickActionChip('Suggest suppliers for raw materials'),
                _buildQuickActionChip('Optimize this purchase order'),
                _buildQuickActionChip('Check budget compliance'),
                _buildQuickActionChip('Analyze supplier risks'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () => _sendMessage(text),
    );
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _queryController.clear();
    _scrollToBottom();

    try {
      // Get AI response
      final geminiService = ref.read(geminiAIServiceProvider);
      final context = ProcurementContext(
        companyName: 'Your Dairy Company',
        department: 'Procurement',
        budgetPeriod: '2024',
        userId: ref.read(currentUserProvider)?.id ?? 'unknown',
        additionalContext: {
          'existingPO': widget.existingPO?.toJson(),
          'currentScreen': 'purchase_order_creation',
        },
      );

      final insight = await geminiService.generateProcurementInsight(
        query: message,
        context: context,
      );

      setState(() {
        _messages.add(ChatMessage(
          text: insight.summary,
          isUser: false,
          timestamp: DateTime.now(),
          insight: insight,
        ));
      });

      // If the AI generated a complete PO, offer to use it
      if (insight.recommendations.any((r) => r.title.toLowerCase().contains('purchase order'))) {
        _showPOGenerationDialog(insight);
      }

    } catch (error) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error: ${error.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showPOGenerationDialog(ProcurementInsight insight) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate Purchase Order'),
        content: Text('The AI has suggested creating a purchase order. Would you like to generate it automatically?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generatePOFromInsight(insight);
            },
            child: Text('Generate PO'),
          ),
        ],
      ),
    );
  }

  void _generatePOFromInsight(ProcurementInsight insight) {
    // Extract PO details from AI recommendations
    // This would parse the AI response and create a PurchaseOrder object
    // Implementation depends on how you structure the AI responses
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('AI Assistant Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You can ask me about:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Supplier recommendations'),
            Text('• Cost optimization'),
            Text('• Risk assessment'),
            Text('• Budget compliance'),
            Text('• Market trends'),
            Text('• Contract analysis'),
            SizedBox(height: 16),
            Text('Example queries:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('"Find the best supplier for dairy equipment"'),
            Text('"Is this purchase within budget?"'),
            Text('"What are the risks with this supplier?"'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String text,
    required bool isUser,
    required DateTime timestamp,
    ProcurementInsight? insight,
    @Default(false) bool isError,
  }) = _ChatMessage;
}
```

### 2.2 AI Feedback Collection Widget
**File**: `lib/features/procurement/presentation/widgets/ai_feedback_widget.dart`

```dart
class AIFeedbackWidget extends ConsumerStatefulWidget {
  final String interactionId;
  final ProcurementInsight insight;

  const AIFeedbackWidget({
    Key? key,
    required this.interactionId,
    required this.insight,
  }) : super(key: key);

  @override
  ConsumerState<AIFeedbackWidget> createState() => _AIFeedbackWidgetState();
}

class _AIFeedbackWidgetState extends ConsumerState<AIFeedbackWidget> {
  double _rating = 3.0;
  final List<String> _whatWorked = [];
  final List<String> _whatDidntWork = [];
  final TextEditingController _suggestionsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How was this AI response?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            
            // Rating
            Text('Overall Rating:'),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 1.0,
                    max: 5.0,
                    divisions: 4,
                    label: _rating.round().toString(),
                    onChanged: (value) => setState(() => _rating = value),
                  ),
                ),
                Text('${_rating.round()}/5'),
              ],
            ),
            
            SizedBox(height: 16),
            
            // What worked well
            Text('What worked well?'),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                'Accurate recommendations',
                'Clear explanations',
                'Relevant to my needs',
                'Good risk assessment',
                'Helpful next steps',
              ].map((option) => FilterChip(
                label: Text(option),
                selected: _whatWorked.contains(option),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _whatWorked.add(option);
                    } else {
                      _whatWorked.remove(option);
                    }
                  });
                },
              )).toList(),
            ),
            
            SizedBox(height: 16),
            
            // What didn't work
            Text('What could be improved?'),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                'Too generic',
                'Missing context',
                'Unclear recommendations',
                'Poor risk analysis',
                'Not actionable',
              ].map((option) => FilterChip(
                label: Text(option),
                selected: _whatDidntWork.contains(option),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _whatDidntWork.add(option);
                    } else {
                      _whatDidntWork.remove(option);
                    }
                  });
                },
              )).toList(),
            ),
            
            SizedBox(height: 16),
            
            // Suggestions
            TextField(
              controller: _suggestionsController,
              decoration: InputDecoration(
                labelText: 'Additional suggestions (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            SizedBox(height: 16),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Submitting...'),
                        ],
                      )
                    : Text('Submit Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    setState(() => _isSubmitting = true);

    try {
      final feedback = AIFeedback(
        rating: _rating,
        whatWorked: _whatWorked,
        whatDidntWork: _whatDidntWork,
        suggestions: _suggestionsController.text.isNotEmpty 
            ? [_suggestionsController.text]
            : [],
        improvementAreas: _whatDidntWork,
      );

      final companyDataService = ref.read(companyDataServiceProvider);
      await companyDataService.learnFromFeedback(
        interactionId: widget.interactionId,
        feedback: feedback,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you for your feedback! This helps improve our AI.'),
          backgroundColor: Colors.green,
        ),
      );

      // Hide the feedback widget
      if (mounted) {
        Navigator.of(context).pop();
      }

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting feedback: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
```

---

## 3. Riverpod Providers Setup

### 3.1 AI Service Providers
**File**: `lib/core/providers/ai_providers.dart`

```dart
// Gemini API Service Provider
final geminiAIServiceProvider = Provider<GeminiAIService>((ref) {
  return GeminiAIService(
    apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
    dio: ref.read(dioProvider),
    logger: ref.read(loggerProvider),
    cacheManager: ref.read(cacheManagerProvider),
    companyDataService: ref.read(companyDataServiceProvider),
  );
});

// Company Data Service Provider
final companyDataServiceProvider = Provider<CompanyDataService>((ref) {
  return CompanyDataService(
    firestore: FirebaseFirestore.instance,
    analyticsRepository: ref.read(analyticsRepositoryProvider),
    logger: ref.read(loggerProvider),
  );
});

// AI Interactions Stream Provider
final aiInteractionsProvider = StreamProvider.family<List<AIInteraction>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('ai_interactions')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => AIInteraction.fromJson(doc.data()))
          .toList());
});

// Company AI Preferences Provider
final companyAIPreferencesProvider = FutureProvider<CompanyAIPreferences>((ref) async {
  final companyDataService = ref.read(companyDataServiceProvider);
  return await companyDataService.getCompanyAIPreferences();
});

// Learning Analytics Provider
final learningAnalyticsProvider = FutureProvider<LearningAnalytics>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('learning_patterns')
      .orderBy('timestamp', descending: true)
      .limit(100)
      .get();

  final patterns = snapshot.docs
      .map((doc) => LearningPattern.fromJson(doc.data()))
      .toList();

  return LearningAnalytics.fromPatterns(patterns);
});
```

---

## 4. Environment Configuration

### 4.1 Environment Variables
**File**: `.env`

```env
# Gemini API Configuration
GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_MODEL=gemini-pro
GEMINI_MAX_TOKENS=2048

# Firebase Configuration (if not already set)
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_API_KEY=your_api_key

# AI Learning Configuration
AI_LEARNING_ENABLED=true
AI_FEEDBACK_COLLECTION=true
AI_CONTINUOUS_LEARNING=true
```

### 4.2 Pubspec Dependencies
**File**: `pubspec.yaml`

```yaml
dependencies:
  # Existing dependencies...
  
  # AI and HTTP
  dio: ^5.3.2
  google_generative_ai: ^0.2.2
  
  # JSON and serialization
  json_annotation: ^4.8.1
  
  # Environment variables
  flutter_dotenv: ^5.1.0

dev_dependencies:
  # Existing dev dependencies...
  
  # Code generation
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

---

## 5. Usage Examples

### 5.1 Basic AI Query
```dart
// In your widget or service
final geminiService = ref.read(geminiAIServiceProvider);

final insight = await geminiService.generateProcurementInsight(
  query: "What's the best supplier for dairy packaging materials?",
  context: ProcurementContext(
    companyName: "ABC Dairy",
    department: "Procurement",
    budgetPeriod: "2024",
    userId: currentUser.id,
  ),
);

// Use the insight
print(insight.summary);
for (final recommendation in insight.recommendations) {
  print("${recommendation.title}: ${recommendation.description}");
}
```

### 5.2 Supplier Analysis
```dart
final analysis = await geminiService.analyzeSupplierPerformance(
  supplierId: "supplier_123",
  analysisMonths: 6,
);

print("Supplier Score: ${analysis.overallScore}");
print("Recommendations: ${analysis.recommendations.join(', ')}");
```

### 5.3 Contract Review
```dart
final contractText = await extractTextFromPDF(contractFile);

final review = await geminiService.reviewContract(
  contractText: contractText,
  contractType: ContractType.supply,
);

print("Contract Risk Level: ${review.riskLevel}");
print("Key Issues: ${review.issues.join(', ')}");
```

---

## 6. Privacy and Security Considerations

### 6.1 Data Privacy
- **Local Processing**: Sensitive data is processed locally before sending to Gemini
- **Data Anonymization**: Personal identifiers are removed from AI queries
- **Selective Sharing**: Only necessary context is shared with Gemini API
- **Audit Trail**: All AI interactions are logged for compliance

### 6.2 Security Measures
- **API Key Security**: Gemini API keys stored securely in environment variables
- **Request Validation**: All inputs validated before sending to AI
- **Response Sanitization**: AI responses are sanitized before display
- **Rate Limiting**: API calls are rate-limited to prevent abuse

---

This integration provides a powerful, learning AI system that gets smarter over time while maintaining privacy and security. The system learns from your company's specific procurement patterns and user feedback to provide increasingly relevant and accurate insights! 🚀 