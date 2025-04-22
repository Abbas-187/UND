import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:firebase_storage/firebase_storage.dart';

// NOTE: Add to pubspec.yaml:
//   photo_view: ^0.14.0
//   syncfusion_flutter_pdfviewer: ^20.4.0
//   firebase_core: ^2.24.2
//   firebase_storage: ^11.6.6

class FileService {
  /// Pick a file using file_picker
  static Future<PlatformFile?> pickFile(
      {List<String>? allowedExtensions}) async {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
    );
    if (result != null && result.files.isNotEmpty) {
      return result.files.first;
    }
    return null;
  }

  /// Upload a file to Firebase Storage and return the download URL
  static Future<String> uploadFile(PlatformFile file, {String? folder}) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = file.name;
      final filePath = folder != null ? '$folder/$fileName' : fileName;
      final uploadTask = storageRef.child(filePath).putFile(File(file.path!));
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('File upload error: $e');
      rethrow;
    }
  }

  /// Delete a file from Firebase Storage by its download URL
  static Future<void> deleteFile(String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('File delete error: $e');
      rethrow;
    }
  }

  /// Download or open a file by URL
  static Future<void> downloadOrOpenFile(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  /// Preview a file (now with real PDF/image preview)
  static Widget previewFile(String url, {String? fileType}) {
    if (fileType != null && fileType.toLowerCase().contains('pdf')) {
      return SfPdfViewer.network(url);
    }
    if (fileType != null && fileType.startsWith('image/')) {
      return PhotoView(
        imageProvider: NetworkImage(url),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      );
    }
    // Default: show download button
    return Center(
      child: ElevatedButton(
        onPressed: () => downloadOrOpenFile(url),
        child: const Text('Download/View'),
      ),
    );
  }

  /// Get file type from file name or URL
  static String getFileType(String fileNameOrUrl) {
    final ext = fileNameOrUrl.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return 'image/$ext';
    }
    if (ext == 'pdf') return 'application/pdf';
    if (['doc', 'docx'].contains(ext)) return 'application/msword';
    if (['xls', 'xlsx'].contains(ext)) return 'application/vnd.ms-excel';
    return 'application/octet-stream';
  }
}
