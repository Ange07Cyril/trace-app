import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

class ExportService {
  static Future<Uint8List?> captureAsPng(GlobalKey repaintKey) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture PNG error: $e');
      return null;
    }
  }

  static Future<Uint8List?> exportAsPdf(
    Uint8List? pngBytes, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    if (pngBytes == null) return null;
    try {
      final pdf = pw.Document();
      final image = pw.MemoryImage(pngBytes);
      pdf.addPage(pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.zero,
        build: (context) =>
            pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
      ));
      return await pdf.save();
    } catch (e) {
      debugPrint('Export PDF error: $e');
      return null;
    }
  }

  static Future<void> shareFile(
      Uint8List bytes, String filename, String mimeType) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
          [XFile(file.path, mimeType: mimeType)],
          subject: filename);
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  static String timestampedName(String prefix, String extension) {
    final now = DateTime.now();
    return '${prefix}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.$extension';
  }
}