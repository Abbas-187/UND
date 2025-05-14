import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/entities/supporting_document.dart';

/// Widget for selecting and managing document attachments.
class DocumentAttachmentPicker extends StatefulWidget {

  const DocumentAttachmentPicker({
    super.key,
    required this.documents,
    required this.onDocumentsChanged,
  });
  final List<SupportingDocument> documents;
  final Function(List<SupportingDocument>) onDocumentsChanged;

  @override
  State<DocumentAttachmentPicker> createState() =>
      _DocumentAttachmentPickerState();
}

class _DocumentAttachmentPickerState extends State<DocumentAttachmentPicker> {
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Document list
        if (widget.documents.isNotEmpty) ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.documents.length,
            itemBuilder: (context, index) {
              final document = widget.documents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  leading: _getDocumentIcon(document.type),
                  title: Text(document.name),
                  subtitle: Text(document.description ?? 'No description'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _removeDocument(index);
                    },
                  ),
                  onTap: () {
                    // Preview document if possible
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // Add document button
        ElevatedButton.icon(
          icon: const Icon(Icons.attach_file),
          label: const Text('Attach Supporting Document'),
          onPressed: _pickDocument,
        ),
      ],
    );
  }

  Widget _getDocumentIcon(DocumentType type) {
    IconData iconData;

    switch (type) {
      case DocumentType.quotation:
        iconData = Icons.request_quote;
        break;
      case DocumentType.specification:
        iconData = Icons.description;
        break;
      case DocumentType.invoice:
        iconData = Icons.receipt;
        break;
      case DocumentType.receipt:
        iconData = Icons.receipt_long;
        break;
      case DocumentType.contract:
        iconData = Icons.gavel;
        break;
      case DocumentType.other:
      default:
        iconData = Icons.insert_drive_file;
        break;
    }

    return Icon(iconData);
  }

  void _pickDocument() async {
    // In a real app, this would upload to storage
    // For now, we'll just simulate it

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'jpg', 'png'],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;

    // Show a dialog to get additional info
    await _showDocumentInfoDialog(file.name);
  }

  Future<void> _showDocumentInfoDialog(String fileName) async {
    DocumentType selectedType = DocumentType.other;
    final descriptionController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Document Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('File: $fileName'),
                const SizedBox(height: 16),
                DropdownButtonFormField<DocumentType>(
                  decoration: const InputDecoration(
                    labelText: 'Document Type',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedType,
                  items: DocumentType.values.map((type) {
                    return DropdownMenuItem<DocumentType>(
                      value: type,
                      child: Text(documentTypeToString(type).toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedType = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // In a real app, we would upload the file
                // For now, just create the document
                _addDocument(
                  fileName,
                  'https://example.com/files/$fileName', // Placeholder URL
                  selectedType,
                  descriptionController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addDocument(
      String name, String url, DocumentType type, String description) {
    final document = SupportingDocument(
      id: _uuid.v4(),
      name: name,
      url: url,
      type: type,
      uploadDate: DateTime.now(),
      uploadedBy: 'Current User', // In a real app, get from auth provider
      description: description.isNotEmpty ? description : null,
    );

    final updatedDocs = [...widget.documents, document];
    widget.onDocumentsChanged(updatedDocs);
  }

  void _removeDocument(int index) {
    final updatedDocs = [...widget.documents];
    updatedDocs.removeAt(index);
    widget.onDocumentsChanged(updatedDocs);
  }
}
