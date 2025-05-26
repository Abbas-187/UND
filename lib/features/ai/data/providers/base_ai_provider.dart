import '../../domain/entities/ai_provider.dart';
import '../../domain/entities/ai_request.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_context.dart';
import '../../domain/entities/ai_capability.dart';

// This class can serve as a base for common provider functionalities
// or enforce a stricter contract than the AIProvider interface.
// For now, it will be a simple abstract class implementing AIProvider.
abstract class BaseAIProvider implements AIProvider {
  @override
  String get name;
  @override
  String get version;
  @override
  AICapabilitySet get capabilities;
  @override
  bool get isAvailable;
  @override
  Map<String, dynamic> get configuration;

  // Common initialization logic can be added here if needed.
  @override
  Future<bool> initialize() async => true; // Default implementation

  // Common disposal logic.
  @override
  Future<void> dispose() async {} // Default implementation
}
