import '../entities/bill_of_materials.dart';
import '../entities/bom_item.dart';
import '../entities/bom_template.dart';
import '../repositories/bom_repository.dart';
import '../repositories/bom_template_repository.dart';

class BomTemplateUseCase {

  BomTemplateUseCase(this._templateRepository, this._bomRepository);
  final BomTemplateRepository _templateRepository;
  final BomRepository _bomRepository;

  // Template CRUD operations
  Future<List<BomTemplate>> getAllTemplates() async {
    return await _templateRepository.getAllTemplates();
  }

  Future<BomTemplate?> getTemplateById(String id) async {
    return await _templateRepository.getTemplateById(id);
  }

  Future<String> createTemplate(BomTemplate template) async {
    // Validate template before creation
    final validationErrors =
        await _templateRepository.validateTemplate(template);
    if (validationErrors.isNotEmpty) {
      throw Exception(
          'Template validation failed: ${validationErrors.join(', ')}');
    }

    // Check name uniqueness
    final isUnique =
        await _templateRepository.isTemplateNameUnique(template.name);
    if (!isUnique) {
      throw Exception('Template name already exists');
    }

    return await _templateRepository.createTemplate(template);
  }

  Future<void> updateTemplate(BomTemplate template) async {
    // Validate template before update
    final validationErrors =
        await _templateRepository.validateTemplate(template);
    if (validationErrors.isNotEmpty) {
      throw Exception(
          'Template validation failed: ${validationErrors.join(', ')}');
    }

    // Check name uniqueness (excluding current template)
    final isUnique = await _templateRepository.isTemplateNameUnique(
      template.name,
      excludeId: template.id,
    );
    if (!isUnique) {
      throw Exception('Template name already exists');
    }

    await _templateRepository.updateTemplate(template);
  }

  Future<void> deleteTemplate(String id) async {
    await _templateRepository.deleteTemplate(id);
  }

  // Search and filtering
  Future<List<BomTemplate>> searchTemplates({
    String? query,
    TemplateCategory? category,
    TemplateComplexity? complexity,
    List<String>? tags,
    bool? isPublic,
    String? createdBy,
  }) async {
    return await _templateRepository.searchTemplates(
      query: query,
      category: category,
      complexity: complexity,
      tags: tags,
      isPublic: isPublic,
      createdBy: createdBy,
    );
  }

  Future<List<BomTemplate>> getTemplatesByCategory(
      TemplateCategory category) async {
    return await _templateRepository.getTemplatesByCategory(category);
  }

  Future<List<BomTemplate>> getPopularTemplates({int limit = 10}) async {
    return await _templateRepository.getPopularTemplates(limit: limit);
  }

  Future<List<BomTemplate>> getRecentTemplates({int limit = 10}) async {
    return await _templateRepository.getRecentTemplates(limit: limit);
  }

  Future<List<BomTemplate>> getMyTemplates(String userId) async {
    return await _templateRepository.getMyTemplates(userId);
  }

  // Template management
  Future<void> duplicateTemplate(String templateId, String newName) async {
    // Check if new name is unique
    final isUnique = await _templateRepository.isTemplateNameUnique(newName);
    if (!isUnique) {
      throw Exception('Template name already exists');
    }

    await _templateRepository.duplicateTemplate(templateId, newName);
  }

  Future<void> publishTemplate(String templateId) async {
    await _templateRepository.publishTemplate(templateId);
  }

  Future<void> unpublishTemplate(String templateId) async {
    await _templateRepository.unpublishTemplate(templateId);
  }

  Future<void> rateTemplate(String templateId, double rating) async {
    if (rating < 0 || rating > 5) {
      throw Exception('Rating must be between 0 and 5');
    }
    await _templateRepository.rateTemplate(templateId, rating);
  }

  // BOM creation from template
  Future<BillOfMaterials> createBomFromTemplate({
    required String templateId,
    required String bomCode,
    required String bomName,
    required String productId,
    required String productCode,
    required double baseQuantity,
    required String baseUnit,
    Map<String, double>? itemQuantityOverrides,
    Map<String, dynamic>? additionalMetadata,
  }) async {
    final template = await _templateRepository.getTemplateById(templateId);
    if (template == null) {
      throw Exception('Template not found');
    }

    // Increment usage count
    await _templateRepository.incrementUsageCount(templateId);

    // Create BOM first to get ID
    final bom = BillOfMaterials(
      id: '', // Will be generated
      bomCode: bomCode,
      bomName: bomName,
      productId: productId,
      productCode: productCode,
      productName: '', // Will be fetched
      bomType: BomType.production,
      version: '1.0',
      status: BomStatus.draft,
      baseQuantity: baseQuantity,
      baseUnit: baseUnit,
      totalCost: 0.0, // Will be calculated
      items: [], // Will be added after BOM creation
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save BOM to get ID
    final bomId = await _bomRepository.createBom(bom);

    // Convert template items to BOM items
    final bomItems = template.items.map((templateItem) {
      final quantity = itemQuantityOverrides?[templateItem.itemCode] ??
          templateItem.quantity;

      return BomItem(
        id: '', // Will be generated
        bomId: bomId,
        itemId: '', // Will be resolved from item code
        itemCode: templateItem.itemCode,
        itemName: templateItem.itemName,
        itemDescription: templateItem.description ?? '',
        itemType: _mapItemTypeToBomItemType(templateItem.itemType),
        quantity: quantity,
        unit: templateItem.unit,
        consumptionType: templateItem.isOptional
            ? ConsumptionType.optional
            : templateItem.isVariable
                ? ConsumptionType.variable
                : ConsumptionType.fixed,
        sequenceNumber: template.items.indexOf(templateItem) + 1,
        costPerUnit: 0.0, // Will be calculated
        totalCost: 0.0, // Will be calculated
        notes: templateItem.description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();

    // Update BOM with items
    final updatedBom = bom.copyWith(
      id: bomId,
      items: bomItems,
    );

    await _bomRepository.updateBom(updatedBom);
    return updatedBom;
  }

  BomItemType _mapItemTypeToBomItemType(String itemType) {
    switch (itemType.toLowerCase()) {
      case 'raw material':
      case 'raw':
        return BomItemType.rawMaterial;
      case 'packaging':
        return BomItemType.packaging;
      case 'semi-finished':
      case 'semi':
        return BomItemType.semiFinished;
      case 'finished':
        return BomItemType.finishedGood;
      case 'consumable':
        return BomItemType.consumable;
      case 'by-product':
        return BomItemType.byProduct;
      case 'co-product':
        return BomItemType.coProduct;
      default:
        return BomItemType.rawMaterial;
    }
  }

  // Template validation
  Future<List<String>> validateTemplate(BomTemplate template) async {
    final errors = <String>[];

    // Basic validation
    if (template.name.trim().isEmpty) {
      errors.add('Template name is required');
    }

    if (template.description.trim().isEmpty) {
      errors.add('Template description is required');
    }

    if (template.items.isEmpty) {
      errors.add('Template must have at least one item');
    }

    // Item validation
    for (int i = 0; i < template.items.length; i++) {
      final item = template.items[i];

      if (item.itemCode.trim().isEmpty) {
        errors.add('Item ${i + 1}: Item code is required');
      }

      if (item.itemName.trim().isEmpty) {
        errors.add('Item ${i + 1}: Item name is required');
      }

      if (item.quantity <= 0) {
        errors.add('Item ${i + 1}: Quantity must be greater than 0');
      }

      if (item.isVariable) {
        if (item.minQuantity < 0) {
          errors.add('Item ${i + 1}: Minimum quantity cannot be negative');
        }
        if (item.maxQuantity <= item.minQuantity) {
          errors.add(
              'Item ${i + 1}: Maximum quantity must be greater than minimum');
        }
        if (item.quantity < item.minQuantity ||
            item.quantity > item.maxQuantity) {
          errors.add(
              'Item ${i + 1}: Quantity must be between min and max values');
        }
      }
    }

    // Check for duplicate item codes
    final itemCodes = template.items.map((item) => item.itemCode).toList();
    final uniqueItemCodes = itemCodes.toSet();
    if (itemCodes.length != uniqueItemCodes.length) {
      errors.add('Duplicate item codes found in template');
    }

    // Custom validation rules
    for (final rule in template.validationRules) {
      final ruleErrors = await _validateCustomRule(template, rule);
      errors.addAll(ruleErrors);
    }

    return errors;
  }

  Future<List<String>> _validateCustomRule(
      BomTemplate template, String rule) async {
    final errors = <String>[];

    // Implement custom validation rules
    switch (rule) {
      case 'require_dairy_items':
        final hasDairyItems = template.items.any(
          (item) => item.itemType.toLowerCase().contains('dairy'),
        );
        if (!hasDairyItems) {
          errors.add('Template must contain at least one dairy item');
        }
        break;

      case 'max_items_50':
        if (template.items.length > 50) {
          errors.add('Template cannot have more than 50 items');
        }
        break;

      case 'require_packaging':
        final hasPackaging = template.items.any(
          (item) => item.itemType.toLowerCase().contains('packaging'),
        );
        if (!hasPackaging) {
          errors.add('Template must contain packaging items');
        }
        break;

      default:
        // Unknown rule - skip
        break;
    }

    return errors;
  }

  // Statistics and analytics
  Future<Map<String, dynamic>> getTemplateStatistics() async {
    return await _templateRepository.getTemplateStatistics();
  }

  Future<Map<String, int>> getUsageStatistics(String templateId) async {
    return await _templateRepository.getUsageStatistics(templateId);
  }

  // Import/Export
  Future<void> importTemplates(List<BomTemplate> templates) async {
    for (final template in templates) {
      final validationErrors = await validateTemplate(template);
      if (validationErrors.isNotEmpty) {
        throw Exception(
          'Template "${template.name}" validation failed: ${validationErrors.join(', ')}',
        );
      }
    }

    await _templateRepository.importTemplates(templates);
  }

  Future<List<BomTemplate>> exportTemplates(List<String> templateIds) async {
    return await _templateRepository.exportTemplates(templateIds);
  }

  // Version management
  Future<List<BomTemplate>> getTemplateVersions(String templateId) async {
    return await _templateRepository.getTemplateVersions(templateId);
  }

  Future<String> createTemplateVersion(
      String templateId, BomTemplate newVersion) async {
    final validationErrors = await validateTemplate(newVersion);
    if (validationErrors.isNotEmpty) {
      throw Exception(
          'Template validation failed: ${validationErrors.join(', ')}');
    }

    return await _templateRepository.createTemplateVersion(
        templateId, newVersion);
  }

  Future<void> setActiveVersion(String templateId, String versionId) async {
    await _templateRepository.setActiveVersion(templateId, versionId);
  }
}
