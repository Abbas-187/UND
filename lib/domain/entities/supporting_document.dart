import 'package:meta/meta.dart';

/// Types of supporting documents.
enum DocumentType {
  quotation,
  specification,
  invoice,
  receipt,
  contract,
  other
}

/// Converts [DocumentType] enum to string
String documentTypeToString(DocumentType type) {
  return type.toString().split('.').last;
}

/// Converts string to [DocumentType] enum
DocumentType documentTypeFromString(String type) {
  return DocumentType.values.firstWhere(
    (e) => e.toString().split('.').last == type,
    orElse: () => DocumentType.other,
  );
}

/// Represents a supporting document.
@immutable
class SupportingDocument {
  final String id;
  final String name;
  final String url;
  final DocumentType type;
  final DateTime uploadDate;
  final String uploadedBy;
  final String? description;

  const SupportingDocument({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.uploadDate,
    required this.uploadedBy,
    this.description,
  });

  SupportingDocument copyWith({
    String? id,
    String? name,
    String? url,
    DocumentType? type,
    DateTime? uploadDate,
    String? uploadedBy,
    String? description,
  }) {
    return SupportingDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      type: type ?? this.type,
      uploadDate: uploadDate ?? this.uploadDate,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportingDocument &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          url == other.url &&
          type == other.type &&
          uploadDate == other.uploadDate &&
          uploadedBy == other.uploadedBy &&
          description == other.description;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      url.hashCode ^
      type.hashCode ^
      uploadDate.hashCode ^
      uploadedBy.hashCode ^
      (description?.hashCode ?? 0);
}
