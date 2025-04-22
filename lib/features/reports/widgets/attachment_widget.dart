import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/file_service.dart';

class AttachmentWidget extends StatelessWidget {
  final List<Map<String, dynamic>> attachments;
  final bool editable;
  final Future<void> Function(Map<String, dynamic> attachment)? onDelete;
  final Future<void> Function(Map<String, dynamic> newAttachment)? onAdd;
  final Future<void> Function(Map<String, dynamic> attachment)? onDownload;

  const AttachmentWidget({
    super.key,
    required this.attachments,
    this.editable = false,
    this.onDelete,
    this.onAdd,
    this.onDownload,
  });

  void _showPreview(BuildContext context, Map<String, dynamic> attachment) {
    final url = attachment['url'] ?? '';
    final fileType = FileService.getFileType(url);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 400,
          height: 600,
          child: FileService.previewFile(url, fileType: fileType),
        ),
      ),
    );
  }

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
                const Text('Attachments',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                if (editable && onAdd != null)
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    onPressed: () async {
                      final file = await FileService.pickFile();
                      if (file != null) {
                        final url = await FileService.uploadFile(file);
                        final newAttachment = {
                          'id':
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          'name': file.name,
                          'url': url,
                          'uploadedAt': DateTime.now().toIso8601String(),
                        };
                        await onAdd!(newAttachment);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (attachments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No attachments'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: attachments.length,
                itemBuilder: (context, index) {
                  final attachment = attachments[index];
                  final url = attachment['url'] ?? '';
                  final fileType = FileService.getFileType(url);
                  final isPreviewable = fileType.startsWith('image/') ||
                      fileType == 'application/pdf';
                  return ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(attachment['name'] ?? 'Document'),
                    subtitle:
                        Text('Uploaded: ${attachment['uploadedAt'] ?? ''}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPreviewable)
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () => _showPreview(context, attachment),
                            tooltip: 'Preview',
                          ),
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            if (onDownload != null) {
                              await onDownload!(attachment);
                            } else {
                              await FileService.downloadOrOpenFile(url);
                            }
                          },
                          tooltip: 'Download/View',
                        ),
                        if (editable && onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await FileService.deleteFile(url);
                              await onDelete!(attachment);
                            },
                            tooltip: 'Delete',
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
