import 'package:flutter/material.dart';

/// Shows an error dialog with the given title and message.
Future<void> showErrorDialog({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
