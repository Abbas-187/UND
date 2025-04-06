import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/supplier_contract.dart';

class SupplierContractModel {

  SupplierContractModel({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.contractNumber,
    required this.contractType,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.value,
    required this.currency,
    required this.isActive,
    required this.autoRenew,
    required this.renewalNoticeDays,
    this.terms,
    required this.attachments,
    required this.pricingSchedule,
    required this.tags,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.searchTerms,
  });

  // Convert Firestore document to SupplierContractModel
  factory SupplierContractModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupplierContractModel(
      id: doc.id,
      supplierId: data['supplierId'] ?? '',
      supplierName: data['supplierName'] ?? '',
      contractNumber: data['contractNumber'] ?? '',
      contractType: data['contractType'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      value: (data['value'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'USD',
      isActive: data['isActive'] ?? true,
      autoRenew: data['autoRenew'] ?? false,
      renewalNoticeDays: data['renewalNoticeDays'] ?? 30,
      terms: data['terms'],
      attachments: List<Map<String, dynamic>>.from(data['attachments'] ?? []),
      pricingSchedule:
          List<Map<String, dynamic>>.from(data['pricingSchedule'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      searchTerms: List<String>.from(data['searchTerms'] ?? []),
    );
  }

  // Convert domain entity to data model
  factory SupplierContractModel.fromDomain(SupplierContract contract) {
    return SupplierContractModel(
      id: contract.id,
      supplierId: contract.supplierId,
      supplierName: contract.supplierName,
      contractNumber: contract.contractNumber,
      contractType: contract.contractType,
      title: contract.title,
      description: contract.description,
      startDate: contract.startDate,
      endDate: contract.endDate,
      value: contract.value,
      currency: contract.currency,
      isActive: contract.isActive,
      autoRenew: contract.autoRenew,
      renewalNoticeDays: contract.renewalNoticeDays,
      terms: contract.terms,
      attachments: contract.attachments,
      pricingSchedule: contract.pricingSchedule,
      tags: contract.tags,
      notes: contract.notes,
      createdAt: contract.createdAt,
      updatedAt: contract.updatedAt,
      searchTerms: _generateSearchTerms(
        contract.title,
        contract.contractNumber,
        contract.supplierName,
        contract.tags,
      ),
    );
  }
  final String id;
  final String supplierId;
  final String supplierName;
  final String contractNumber;
  final String contractType;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double value;
  final String currency;
  final bool isActive;
  final bool autoRenew;
  final int renewalNoticeDays;
  final Map<String, dynamic>? terms;
  final List<Map<String, dynamic>> attachments;
  final List<Map<String, dynamic>> pricingSchedule;
  final List<String> tags;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> searchTerms;

  // Convert data model to domain entity
  SupplierContract toDomain() {
    return SupplierContract(
      id: id,
      supplierId: supplierId,
      supplierName: supplierName,
      contractNumber: contractNumber,
      contractType: contractType,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      value: value,
      currency: currency,
      isActive: isActive,
      autoRenew: autoRenew,
      renewalNoticeDays: renewalNoticeDays,
      terms: terms,
      attachments: attachments,
      pricingSchedule: pricingSchedule,
      tags: tags,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'supplierName': supplierName,
      'contractNumber': contractNumber,
      'contractType': contractType,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'value': value,
      'currency': currency,
      'isActive': isActive,
      'autoRenew': autoRenew,
      'renewalNoticeDays': renewalNoticeDays,
      'terms': terms,
      'attachments': attachments,
      'pricingSchedule': pricingSchedule,
      'tags': tags,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'searchTerms': searchTerms,
    };
  }

  SupplierContractModel copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    String? contractNumber,
    String? contractType,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? value,
    String? currency,
    bool? isActive,
    bool? autoRenew,
    int? renewalNoticeDays,
    Map<String, dynamic>? terms,
    List<Map<String, dynamic>>? attachments,
    List<Map<String, dynamic>>? pricingSchedule,
    List<String>? tags,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? searchTerms,
  }) {
    return SupplierContractModel(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      contractNumber: contractNumber ?? this.contractNumber,
      contractType: contractType ?? this.contractType,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      value: value ?? this.value,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      autoRenew: autoRenew ?? this.autoRenew,
      renewalNoticeDays: renewalNoticeDays ?? this.renewalNoticeDays,
      terms: terms ?? this.terms,
      attachments: attachments ?? this.attachments,
      pricingSchedule: pricingSchedule ?? this.pricingSchedule,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      searchTerms: searchTerms ?? this.searchTerms,
    );
  }

  // Generate search terms for better searchability
  static List<String> _generateSearchTerms(
    String title,
    String contractNumber,
    String supplierName,
    List<String> tags,
  ) {
    final searchTerms = <String>[];

    // Add full title and contract number
    searchTerms.add(title.toLowerCase());
    searchTerms.add(contractNumber.toLowerCase());
    searchTerms.add(supplierName.toLowerCase());

    // Add title parts
    final titleParts = title.toLowerCase().split(' ');
    searchTerms.addAll(titleParts);

    // Add tags
    for (final tag in tags) {
      searchTerms.add(tag.toLowerCase());
    }

    // Add partial matches for title (for typeahead search)
    for (final part in titleParts) {
      if (part.length > 3) {
        for (int i = 3; i < part.length; i++) {
          searchTerms.add(part.substring(0, i));
        }
      }
    }

    // Remove duplicates
    return searchTerms.toSet().toList();
  }
}
