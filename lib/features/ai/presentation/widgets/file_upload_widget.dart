import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FileUploadWidget extends StatefulWidget {
  final Function(String)
      onFileUploaded; // Returns the path of the uploaded file

  const FileUploadWidget({Key? key, required this.onFileUploaded})
      : super(key: key);

  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'pdf',
          'doc',
          'png',
          'txt',
          'csv'
        ], // Example extensions
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        // You might want to do something with the file here, like uploading to a server
        // For now, just pass the path back
        widget.onFileUploaded(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File selected: ${result.files.single.name}')),
        );
      } else {
        // User canceled the picker
      }
    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.attach_file),
      onPressed: _pickFile,
      tooltip: 'Attach File',
    );
  }
}
