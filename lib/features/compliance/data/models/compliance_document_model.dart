import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of compliance documents in a dairy factory
enum DocumentType {
  sop, // Standard Operating Procedure
  quality_manual, // Quality Manual
  haccp_plan, // HACCP Plan
  certificate, // Certificate (organic, kosher, etc.)
  regulatory_approval, // Regulatory Approval
  training_record, // Training Record
  sanitation_procedure, // Sanitation Procedure
  maintenance_procedure, // Maintenance Procedure
  calibration_record, // Calibration Record
  specification, // Product or Material Specification
  risk_assessment, // Risk Assessment
  other // Other document type
}

/// Approval status for compliance documents
enum ApprovalStatus {
  draft,
  under_review,
  approved,
  rejected,
  obsolete,
  pending_revision
}

/// Information about document approver
class ApproverInfo {

  const ApproverInfo({
    required this.approverId,
    required this.approverName,
    required this.role,
    required this.approvalDate,
    this.comments,
    this.digitalSignature,
    required this.approved,
  });

  factory ApproverInfo.fromJson(Map<String, dynamic> json) {
    return ApproverInfo(
      approverId: json['approverId'] as String,
      approverName: json['approverName'] as String,
      role: json['role'] as String,
      approvalDate: json['approvalDate'] is Timestamp
          ? (json['approvalDate'] as Timestamp).toDate()
          : DateTime.parse(json['approvalDate'] as String),
      comments: json['comments'] as String?,
      digitalSignature: json['digitalSignature'] as String?,
      approved: json['approved'] as bool,
    );
  }
  final String approverId;
  final String approverName;
  final String role;
  final DateTime approvalDate;
  final String? comments;
  final String? digitalSignature;
  final bool approved;

  Map<String, dynamic> toJson() {
    return {
      'approverId': approverId,
      'approverName': approverName,
      'role': role,
      'approvalDate': approvalDate.toIso8601String(),
      'comments': comments,
      'digitalSignature': digitalSignature,
      'approved': approved,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'approvalDate': Timestamp.fromDate(approvalDate),
    };
  }

  ApproverInfo copyWith({
    String? approverId,
    String? approverName,
    String? role,
    DateTime? approvalDate,
    String? comments,
    String? digitalSignature,
    bool? approved,
  }) {
    return ApproverInfo(
      approverId: approverId ?? this.approverId,
      approverName: approverName ?? this.approverName,
      role: role ?? this.role,
      approvalDate: approvalDate ?? this.approvalDate,
      comments: comments ?? this.comments,
      digitalSignature: digitalSignature ?? this.digitalSignature,
      approved: approved ?? this.approved,
    );
  }
}

/// Version information for document control
class DocumentVersion {

  const DocumentVersion({
    required this.versionNumber,
    required this.effectiveDate,
    this.obsoleteDate,
    required this.modifiedBy,
    this.changeReason,
    this.changeSummary,
    required this.documentUrl,
    required this.isCurrent,
    this.approvals,
  });

  factory DocumentVersion.fromJson(Map<String, dynamic> json) {
    // Parse DateTime fields
    final effectiveDate = json['effectiveDate'] is Timestamp
        ? (json['effectiveDate'] as Timestamp).toDate()
        : DateTime.parse(json['effectiveDate'] as String);

    DateTime? obsoleteDate;
    if (json['obsoleteDate'] != null) {
      obsoleteDate = json['obsoleteDate'] is Timestamp
          ? (json['obsoleteDate'] as Timestamp).toDate()
          : DateTime.parse(json['obsoleteDate'] as String);
    }

    // Parse approvals list
    List<ApproverInfo>? approvals;
    if (json['approvals'] != null) {
      approvals = (json['approvals'] as List)
          .map((approval) =>
              ApproverInfo.fromJson(approval as Map<String, dynamic>))
          .toList();
    }

    return DocumentVersion(
      versionNumber: json['versionNumber'] as String,
      effectiveDate: effectiveDate,
      obsoleteDate: obsoleteDate,
      modifiedBy: json['modifiedBy'] as String,
      changeReason: json['changeReason'] as String?,
      changeSummary: json['changeSummary'] as String?,
      documentUrl: json['documentUrl'] as String,
      isCurrent: json['isCurrent'] as bool,
      approvals: approvals,
    );
  }
  final String versionNumber;
  final DateTime effectiveDate;
  final DateTime? obsoleteDate;
  final String modifiedBy;
  final String? changeReason;
  final String? changeSummary;
  final String documentUrl;
  final bool isCurrent;
  final List<ApproverInfo>? approvals;

  Map<String, dynamic> toJson() {
    // Convert approvals list if present
    List<Map<String, dynamic>>? approvalsJson;
    if (approvals != null) {
      approvalsJson = approvals!.map((approval) => approval.toJson()).toList();
    }

    return {
      'versionNumber': versionNumber,
      'effectiveDate': effectiveDate.toIso8601String(),
      'obsoleteDate': obsoleteDate?.toIso8601String(),
      'modifiedBy': modifiedBy,
      'changeReason': changeReason,
      'changeSummary': changeSummary,
      'documentUrl': documentUrl,
      'isCurrent': isCurrent,
      'approvals': approvalsJson,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime fields to Timestamp
    final effectiveDateTimestamp = Timestamp.fromDate(effectiveDate);
    final obsoleteDateTimestamp =
        obsoleteDate != null ? Timestamp.fromDate(obsoleteDate!) : null;

    // Convert approvals to Firestore format if present
    List<Map<String, dynamic>>? approvalsFirestore;
    if (approvals != null) {
      approvalsFirestore =
          approvals!.map((approval) => approval.toFirestore()).toList();
    }

    return {
      ...json,
      'effectiveDate': effectiveDateTimestamp,
      'obsoleteDate': obsoleteDateTimestamp,
      'approvals': approvalsFirestore,
    };
  }

  DocumentVersion copyWith({
    String? versionNumber,
    DateTime? effectiveDate,
    DateTime? obsoleteDate,
    String? modifiedBy,
    String? changeReason,
    String? changeSummary,
    String? documentUrl,
    bool? isCurrent,
    List<ApproverInfo>? approvals,
  }) {
    return DocumentVersion(
      versionNumber: versionNumber ?? this.versionNumber,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      obsoleteDate: obsoleteDate ?? this.obsoleteDate,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      changeReason: changeReason ?? this.changeReason,
      changeSummary: changeSummary ?? this.changeSummary,
      documentUrl: documentUrl ?? this.documentUrl,
      isCurrent: isCurrent ?? this.isCurrent,
      approvals: approvals ?? this.approvals,
    );
  }
}

/// Regulatory authority information
class RegulatoryReference {

  const RegulatoryReference({
    required this.authorityName,
    this.authorityCode,
    this.regulationTitle,
    this.regulationNumber,
    this.section,
    this.details,
    this.complianceRequirements,
  });

  factory RegulatoryReference.fromJson(Map<String, dynamic> json) {
    return RegulatoryReference(
      authorityName: json['authorityName'] as String,
      authorityCode: json['authorityCode'] as String?,
      regulationTitle: json['regulationTitle'] as String?,
      regulationNumber: json['regulationNumber'] as String?,
      section: json['section'] as String?,
      details: json['details'] as String?,
      complianceRequirements: json['complianceRequirements'] as String?,
    );
  }
  final String authorityName;
  final String? authorityCode;
  final String? regulationTitle;
  final String? regulationNumber;
  final String? section;
  final String? details;
  final String? complianceRequirements;

  Map<String, dynamic> toJson() {
    return {
      'authorityName': authorityName,
      'authorityCode': authorityCode,
      'regulationTitle': regulationTitle,
      'regulationNumber': regulationNumber,
      'section': section,
      'details': details,
      'complianceRequirements': complianceRequirements,
    };
  }

  RegulatoryReference copyWith({
    String? authorityName,
    String? authorityCode,
    String? regulationTitle,
    String? regulationNumber,
    String? section,
    String? details,
    String? complianceRequirements,
  }) {
    return RegulatoryReference(
      authorityName: authorityName ?? this.authorityName,
      authorityCode: authorityCode ?? this.authorityCode,
      regulationTitle: regulationTitle ?? this.regulationTitle,
      regulationNumber: regulationNumber ?? this.regulationNumber,
      section: section ?? this.section,
      details: details ?? this.details,
      complianceRequirements:
          complianceRequirements ?? this.complianceRequirements,
    );
  }
}

/// Audit record for compliance document
class AuditRecord {

  const AuditRecord({
    required this.auditId,
    required this.auditDate,
    required this.auditorId,
    required this.auditorName,
    this.auditType,
    this.findings,
    required this.compliant,
    this.nonComplianceDetails,
    this.correctiveActions,
    this.followUpDate,
    this.resolution,
    this.auditReport,
  });

  factory AuditRecord.fromJson(Map<String, dynamic> json) {
    // Parse DateTime fields
    final auditDate = json['auditDate'] is Timestamp
        ? (json['auditDate'] as Timestamp).toDate()
        : DateTime.parse(json['auditDate'] as String);

    DateTime? followUpDate;
    if (json['followUpDate'] != null) {
      followUpDate = json['followUpDate'] is Timestamp
          ? (json['followUpDate'] as Timestamp).toDate()
          : DateTime.parse(json['followUpDate'] as String);
    }

    // Parse string lists
    List<String>? correctiveActions;
    if (json['correctiveActions'] != null) {
      correctiveActions = List<String>.from(json['correctiveActions'] as List);
    }

    return AuditRecord(
      auditId: json['auditId'] as String,
      auditDate: auditDate,
      auditorId: json['auditorId'] as String,
      auditorName: json['auditorName'] as String,
      auditType: json['auditType'] as String?,
      findings: json['findings'] as String?,
      compliant: json['compliant'] as bool,
      nonComplianceDetails: json['nonComplianceDetails'] as String?,
      correctiveActions: correctiveActions,
      followUpDate: followUpDate,
      resolution: json['resolution'] as String?,
      auditReport: json['auditReport'] as String?,
    );
  }
  final String auditId;
  final DateTime auditDate;
  final String auditorId;
  final String auditorName;
  final String? auditType;
  final String? findings;
  final bool compliant;
  final String? nonComplianceDetails;
  final List<String>? correctiveActions;
  final DateTime? followUpDate;
  final String? resolution;
  final String? auditReport;

  Map<String, dynamic> toJson() {
    return {
      'auditId': auditId,
      'auditDate': auditDate.toIso8601String(),
      'auditorId': auditorId,
      'auditorName': auditorName,
      'auditType': auditType,
      'findings': findings,
      'compliant': compliant,
      'nonComplianceDetails': nonComplianceDetails,
      'correctiveActions': correctiveActions,
      'followUpDate': followUpDate?.toIso8601String(),
      'resolution': resolution,
      'auditReport': auditReport,
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime fields to Timestamp
    final auditDateTimestamp = Timestamp.fromDate(auditDate);
    final followUpDateTimestamp =
        followUpDate != null ? Timestamp.fromDate(followUpDate!) : null;

    return {
      ...json,
      'auditDate': auditDateTimestamp,
      'followUpDate': followUpDateTimestamp,
    };
  }

  AuditRecord copyWith({
    String? auditId,
    DateTime? auditDate,
    String? auditorId,
    String? auditorName,
    String? auditType,
    String? findings,
    bool? compliant,
    String? nonComplianceDetails,
    List<String>? correctiveActions,
    DateTime? followUpDate,
    String? resolution,
    String? auditReport,
  }) {
    return AuditRecord(
      auditId: auditId ?? this.auditId,
      auditDate: auditDate ?? this.auditDate,
      auditorId: auditorId ?? this.auditorId,
      auditorName: auditorName ?? this.auditorName,
      auditType: auditType ?? this.auditType,
      findings: findings ?? this.findings,
      compliant: compliant ?? this.compliant,
      nonComplianceDetails: nonComplianceDetails ?? this.nonComplianceDetails,
      correctiveActions: correctiveActions ?? this.correctiveActions,
      followUpDate: followUpDate ?? this.followUpDate,
      resolution: resolution ?? this.resolution,
      auditReport: auditReport ?? this.auditReport,
    );
  }
}

/// Main compliance document model for dairy factory
class ComplianceDocumentModel {

  const ComplianceDocumentModel({
    this.id,
    required this.documentCode,
    required this.title,
    required this.documentType,
    required this.description,
    this.owner,
    this.department,
    required this.issueDate,
    this.expiryDate,
    required this.approvalStatus,
    required this.versions,
    this.currentVersion,
    this.applicableProductIds,
    this.applicableProcessIds,
    this.regulatoryReferences,
    this.relatedDocuments,
    this.auditHistory,
    required this.confidential,
    this.accessLevel,
    this.storageLocation,
    this.notes,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    required this.reviewCycleMonths,
    this.nextReviewDate,
    this.reviewReminder,
  });

  factory ComplianceDocumentModel.fromJson(Map<String, dynamic> json) {
    // Parse enums
    final documentTypeValue = json['documentType'] as String;
    final documentType = DocumentType.values.firstWhere(
      (e) => e.toString().split('.').last == documentTypeValue,
      orElse: () => DocumentType.other,
    );

    final approvalStatusValue = json['approvalStatus'] as String;
    final approvalStatus = ApprovalStatus.values.firstWhere(
      (e) => e.toString().split('.').last == approvalStatusValue,
      orElse: () => ApprovalStatus.draft,
    );

    // Parse versions list
    final versionsList = (json['versions'] as List)
        .map((version) =>
            DocumentVersion.fromJson(version as Map<String, dynamic>))
        .toList();

    // Parse current version if present
    DocumentVersion? currentVersion;
    if (json['currentVersion'] != null) {
      currentVersion = DocumentVersion.fromJson(
          json['currentVersion'] as Map<String, dynamic>);
    } else {
      // If not explicitly provided, find the current version from versions list
      final currentVersions = versionsList.where((v) => v.isCurrent).toList();
      if (currentVersions.isNotEmpty) {
        currentVersion = currentVersions.first;
      }
    }

    // Parse regulatory references if present
    List<RegulatoryReference>? regulatoryReferences;
    if (json['regulatoryReferences'] != null) {
      regulatoryReferences = (json['regulatoryReferences'] as List)
          .map((reference) =>
              RegulatoryReference.fromJson(reference as Map<String, dynamic>))
          .toList();
    }

    // Parse audit history if present
    List<AuditRecord>? auditHistory;
    if (json['auditHistory'] != null) {
      auditHistory = (json['auditHistory'] as List)
          .map((audit) => AuditRecord.fromJson(audit as Map<String, dynamic>))
          .toList();
    }

    // Parse string lists
    List<String>? applicableProductIds;
    if (json['applicableProductIds'] != null) {
      applicableProductIds =
          List<String>.from(json['applicableProductIds'] as List);
    }

    List<String>? applicableProcessIds;
    if (json['applicableProcessIds'] != null) {
      applicableProcessIds =
          List<String>.from(json['applicableProcessIds'] as List);
    }

    List<String>? relatedDocuments;
    if (json['relatedDocuments'] != null) {
      relatedDocuments = List<String>.from(json['relatedDocuments'] as List);
    }

    // Parse DateTime fields
    final issueDate = json['issueDate'] is Timestamp
        ? (json['issueDate'] as Timestamp).toDate()
        : DateTime.parse(json['issueDate'] as String);

    DateTime? expiryDate;
    if (json['expiryDate'] != null) {
      expiryDate = json['expiryDate'] is Timestamp
          ? (json['expiryDate'] as Timestamp).toDate()
          : DateTime.parse(json['expiryDate'] as String);
    }

    final createdAt = json['createdAt'] is Timestamp
        ? (json['createdAt'] as Timestamp).toDate()
        : DateTime.parse(json['createdAt'] as String);

    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      updatedAt = json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] as String);
    }

    DateTime? nextReviewDate;
    if (json['nextReviewDate'] != null) {
      nextReviewDate = json['nextReviewDate'] is Timestamp
          ? (json['nextReviewDate'] as Timestamp).toDate()
          : DateTime.parse(json['nextReviewDate'] as String);
    }

    return ComplianceDocumentModel(
      id: json['id'] as String?,
      documentCode: json['documentCode'] as String,
      title: json['title'] as String,
      documentType: documentType,
      description: json['description'] as String,
      owner: json['owner'] as String?,
      department: json['department'] as String?,
      issueDate: issueDate,
      expiryDate: expiryDate,
      approvalStatus: approvalStatus,
      versions: versionsList,
      currentVersion: currentVersion,
      applicableProductIds: applicableProductIds,
      applicableProcessIds: applicableProcessIds,
      regulatoryReferences: regulatoryReferences,
      relatedDocuments: relatedDocuments,
      auditHistory: auditHistory,
      confidential: json['confidential'] as bool,
      accessLevel: json['accessLevel'] as String?,
      storageLocation: json['storageLocation'] as String?,
      notes: json['notes'] as String?,
      createdAt: createdAt,
      createdBy: json['createdBy'] as String,
      updatedAt: updatedAt,
      updatedBy: json['updatedBy'] as String?,
      reviewCycleMonths: json['reviewCycleMonths'] as int,
      nextReviewDate: nextReviewDate,
      reviewReminder: json['reviewReminder'] as String?,
    );
  }

  /// Factory method to convert from Firestore document
  factory ComplianceDocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Add the document ID to the data
    final jsonWithId = {
      ...data,
      'id': doc.id,
    };

    return ComplianceDocumentModel.fromJson(jsonWithId);
  }
  final String? id;
  final String documentCode;
  final String title;
  final DocumentType documentType;
  final String description;
  final String? owner;
  final String? department;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final ApprovalStatus approvalStatus;
  final List<DocumentVersion> versions;
  final DocumentVersion? currentVersion;
  final List<String>? applicableProductIds;
  final List<String>? applicableProcessIds;
  final List<RegulatoryReference>? regulatoryReferences;
  final List<String>? relatedDocuments;
  final List<AuditRecord>? auditHistory;
  final bool confidential;
  final String? accessLevel;
  final String? storageLocation;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final int reviewCycleMonths;
  final DateTime? nextReviewDate;
  final String? reviewReminder;

  Map<String, dynamic> toJson() {
    // Convert versions list
    final versionsJson = versions.map((v) => v.toJson()).toList();

    // Convert currentVersion if present
    final currentVersionJson = currentVersion?.toJson();

    // Convert regulatory references if present
    List<Map<String, dynamic>>? regulatoryReferencesJson;
    if (regulatoryReferences != null) {
      regulatoryReferencesJson =
          regulatoryReferences!.map((r) => r.toJson()).toList();
    }

    // Convert audit history if present
    List<Map<String, dynamic>>? auditHistoryJson;
    if (auditHistory != null) {
      auditHistoryJson = auditHistory!.map((a) => a.toJson()).toList();
    }

    return {
      'id': id,
      'documentCode': documentCode,
      'title': title,
      'documentType': documentType.toString().split('.').last,
      'description': description,
      'owner': owner,
      'department': department,
      'issueDate': issueDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'approvalStatus': approvalStatus.toString().split('.').last,
      'versions': versionsJson,
      'currentVersion': currentVersionJson,
      'applicableProductIds': applicableProductIds,
      'applicableProcessIds': applicableProcessIds,
      'regulatoryReferences': regulatoryReferencesJson,
      'relatedDocuments': relatedDocuments,
      'auditHistory': auditHistoryJson,
      'confidential': confidential,
      'accessLevel': accessLevel,
      'storageLocation': storageLocation,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt?.toIso8601String(),
      'updatedBy': updatedBy,
      'reviewCycleMonths': reviewCycleMonths,
      'nextReviewDate': nextReviewDate?.toIso8601String(),
      'reviewReminder': reviewReminder,
    };
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();

    // Convert DateTime fields to Timestamp
    final issueDateTimestamp = Timestamp.fromDate(issueDate);
    final expiryDateTimestamp =
        expiryDate != null ? Timestamp.fromDate(expiryDate!) : null;
    final createdAtTimestamp = Timestamp.fromDate(createdAt);
    final updatedAtTimestamp =
        updatedAt != null ? Timestamp.fromDate(updatedAt!) : null;
    final nextReviewDateTimestamp =
        nextReviewDate != null ? Timestamp.fromDate(nextReviewDate!) : null;

    // Convert complex objects to Firestore format
    final versionsFirestore = versions.map((v) => v.toFirestore()).toList();
    final currentVersionFirestore = currentVersion?.toFirestore();

    List<Map<String, dynamic>>? regulatoryReferencesFirestore;
    if (regulatoryReferences != null) {
      regulatoryReferencesFirestore =
          regulatoryReferences!.map((r) => r.toJson()).toList();
    }

    List<Map<String, dynamic>>? auditHistoryFirestore;
    if (auditHistory != null) {
      auditHistoryFirestore =
          auditHistory!.map((a) => a.toFirestore()).toList();
    }

    return {
      ...json,
      'issueDate': issueDateTimestamp,
      'expiryDate': expiryDateTimestamp,
      'createdAt': createdAtTimestamp,
      'updatedAt': updatedAtTimestamp,
      'nextReviewDate': nextReviewDateTimestamp,
      'versions': versionsFirestore,
      'currentVersion': currentVersionFirestore,
      'regulatoryReferences': regulatoryReferencesFirestore,
      'auditHistory': auditHistoryFirestore,
    };
  }

  ComplianceDocumentModel copyWith({
    String? id,
    String? documentCode,
    String? title,
    DocumentType? documentType,
    String? description,
    String? owner,
    String? department,
    DateTime? issueDate,
    DateTime? expiryDate,
    ApprovalStatus? approvalStatus,
    List<DocumentVersion>? versions,
    DocumentVersion? currentVersion,
    List<String>? applicableProductIds,
    List<String>? applicableProcessIds,
    List<RegulatoryReference>? regulatoryReferences,
    List<String>? relatedDocuments,
    List<AuditRecord>? auditHistory,
    bool? confidential,
    String? accessLevel,
    String? storageLocation,
    String? notes,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
    int? reviewCycleMonths,
    DateTime? nextReviewDate,
    String? reviewReminder,
  }) {
    return ComplianceDocumentModel(
      id: id ?? this.id,
      documentCode: documentCode ?? this.documentCode,
      title: title ?? this.title,
      documentType: documentType ?? this.documentType,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      department: department ?? this.department,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      versions: versions ?? this.versions,
      currentVersion: currentVersion ?? this.currentVersion,
      applicableProductIds: applicableProductIds ?? this.applicableProductIds,
      applicableProcessIds: applicableProcessIds ?? this.applicableProcessIds,
      regulatoryReferences: regulatoryReferences ?? this.regulatoryReferences,
      relatedDocuments: relatedDocuments ?? this.relatedDocuments,
      auditHistory: auditHistory ?? this.auditHistory,
      confidential: confidential ?? this.confidential,
      accessLevel: accessLevel ?? this.accessLevel,
      storageLocation: storageLocation ?? this.storageLocation,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      reviewCycleMonths: reviewCycleMonths ?? this.reviewCycleMonths,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      reviewReminder: reviewReminder ?? this.reviewReminder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplianceDocumentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          documentCode == other.documentCode;

  @override
  int get hashCode => id.hashCode ^ documentCode.hashCode;
}

/// Extension methods for compliance document functionality
extension ComplianceDocumentExtension on ComplianceDocumentModel {
  /// Check if document is expired
  bool isExpired() {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    return expiryDate!.isBefore(now);
  }

  /// Check if document needs review
  bool needsReview() {
    if (nextReviewDate == null) return false;
    final now = DateTime.now();
    return nextReviewDate!.isBefore(now);
  }

  /// Get latest version
  DocumentVersion getLatestVersion() {
    if (versions.isEmpty) {
      throw Exception('Document has no versions');
    }

    return versions.reduce((current, next) {
      // Compare version numbers (assuming format like 1.0, 1.1, 2.0)
      final currentVersion = double.tryParse(current.versionNumber) ?? 0.0;
      final nextVersion = double.tryParse(next.versionNumber) ?? 0.0;
      return nextVersion > currentVersion ? next : current;
    });
  }

  /// Check if document is approved
  bool isApproved() {
    return approvalStatus == ApprovalStatus.approved;
  }

  /// Get all audits that found non-compliance
  List<AuditRecord> getNonCompliantAudits() {
    if (auditHistory == null || auditHistory!.isEmpty) return [];
    return auditHistory!.where((audit) => !audit.compliant).toList();
  }

  /// Check if document applies to a specific product
  bool appliesTo(String productId) {
    if (applicableProductIds == null) return false;
    return applicableProductIds!.contains(productId);
  }

  /// Calculate time until next review in days
  int daysUntilNextReview() {
    if (nextReviewDate == null) return -1;
    final now = DateTime.now();
    return nextReviewDate!.difference(now).inDays;
  }
}

/// Documentation for integration with inventory and production systems:
/// 
/// # Integration with Inventory and Production Systems
/// 
/// The ComplianceDocumentModel is designed to integrate with the inventory and production 
/// systems to provide compliance management across the dairy factory operations.
/// 
/// ## Inventory System Integration
/// 
/// - Specifications and certificates link to materials and finished products
/// - applicableProductIds allows filtering documents by product
/// - Certificates can be linked to specific lots via the LotTraceabilityModel
/// 
/// ## Production System Integration
/// 
/// - SOPs and procedures are linked to production processes
/// - applicableProcessIds allows filtering documents by process
/// - HACCP plans can be linked to production steps and critical control points
/// 
/// ## Quality System Integration
/// 
/// - Test methods and specifications support the QualityTestResultModel
/// - Calibration records support equipment management and testing
/// - Audit records track compliance status for regulatory requirements
/// 
/// ## Document Management Best Practices
/// 
/// 1. Maintain unique document codes with a consistent formatting
/// 2. Implement a systematic review cycle, typically:
///    - SOPs: Annual review
///    - HACCP Plans: Annual review or after process change
///    - Quality Manual: Every 2 years
///    - Certificates: Before expiry
/// 3. Ensure all documents have proper approvals before release
/// 4. Track document history through the versions collection
/// 5. Link documents to regulatory requirements via regulatoryReferences
/// 
/// ## Regulatory Compliance
/// 
/// - Manage FDA, USDA, and other regulatory requirements through documents
/// - Support third-party certifications (organic, kosher, etc.)
/// - Prepare for audits by maintaining current documentation
/// - Track corrective actions from regulatory findings
/// 
/// ## Usage Example
/// 
/// 1. Create standard operating procedures for each production step
/// 2. Link procedures to applicable products and processes
/// 3. Define review cycles and responsible personnel
/// 4. Record audit findings and track corrective actions
/// 5. Ensure all production activities follow current document versions
/// 6. Review documents before expiry to maintain compliance 