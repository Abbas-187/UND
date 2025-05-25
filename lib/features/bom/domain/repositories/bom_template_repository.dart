import '../entities/bom_template.dart';

abstract class BomTemplateRepository {
  // Basic CRUD operations
  Future<List<BomTemplate>> getAllTemplates();
  Future<BomTemplate?> getTemplateById(String id);
  Future<String> createTemplate(BomTemplate template);
  Future<void> updateTemplate(BomTemplate template);
  Future<void> deleteTemplate(String id);

  // Search and filtering
  Future<List<BomTemplate>> searchTemplates({
    String? query,
    TemplateCategory? category,
    TemplateComplexity? complexity,
    List<String>? tags,
    bool? isPublic,
    String? createdBy,
  });

  Future<List<BomTemplate>> getTemplatesByCategory(TemplateCategory category);
  Future<List<BomTemplate>> getPopularTemplates({int limit = 10});
  Future<List<BomTemplate>> getRecentTemplates({int limit = 10});
  Future<List<BomTemplate>> getMyTemplates(String userId);

  // Template management
  Future<void> duplicateTemplate(String templateId, String newName);
  Future<void> publishTemplate(String templateId);
  Future<void> unpublishTemplate(String templateId);
  Future<void> incrementUsageCount(String templateId);
  Future<void> rateTemplate(String templateId, double rating);

  // Version management
  Future<List<BomTemplate>> getTemplateVersions(String templateId);
  Future<String> createTemplateVersion(
      String templateId, BomTemplate newVersion);
  Future<void> setActiveVersion(String templateId, String versionId);

  // Import/Export
  Future<void> importTemplates(List<BomTemplate> templates);
  Future<List<BomTemplate>> exportTemplates(List<String> templateIds);

  // Validation
  Future<List<String>> validateTemplate(BomTemplate template);
  Future<bool> isTemplateNameUnique(String name, {String? excludeId});

  // Statistics
  Future<Map<String, dynamic>> getTemplateStatistics();
  Future<Map<String, int>> getUsageStatistics(String templateId);
}
