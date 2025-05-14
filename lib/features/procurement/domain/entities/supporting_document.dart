class SupportingDocument {

  const SupportingDocument({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.filePath,
    required this.uploadDate,
    required this.uploadedBy,
  });
  final String id;
  final String fileName;
  final String fileType;
  final String filePath;
  final DateTime uploadDate;
  final String uploadedBy;

  SupportingDocument copyWith({
    String? id,
    String? fileName,
    String? fileType,
    String? filePath,
    DateTime? uploadDate,
    String? uploadedBy,
  }) {
    return SupportingDocument(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      filePath: filePath ?? this.filePath,
      uploadDate: uploadDate ?? this.uploadDate,
      uploadedBy: uploadedBy ?? this.uploadedBy,
    );
  }
}
