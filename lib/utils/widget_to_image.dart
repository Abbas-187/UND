import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<Uint8List?> widgetToImageBytes({
  required Widget widget,
  double width = 600,
  double height = 400,
  double pixelRatio = 3.0,
}) async {
  final repaintBoundary = GlobalKey();
  final completer = Completer<Uint8List?>();

  final widgetApp = MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: RepaintBoundary(
          key: repaintBoundary,
          child: SizedBox(width: width, height: height, child: widget),
        ),
      ),
    ),
  );

  final overlay = OverlayEntry(builder: (_) => widgetApp);
  final context = WidgetsBinding.instance.rootElement;
  if (context == null) {
    completer.complete(null);
    return completer.future;
  }
  Overlay.of(context, rootOverlay: true).insert(overlay);

  await Future.delayed(const Duration(milliseconds: 100));

  try {
    final boundary = repaintBoundary.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary != null) {
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      overlay.remove();
      completer.complete(byteData?.buffer.asUint8List());
    } else {
      overlay.remove();
      completer.complete(null);
    }
  } catch (e) {
    overlay.remove();
    completer.complete(null);
  }

  return completer.future;
}
