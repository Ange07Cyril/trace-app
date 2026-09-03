import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import '../models/canvas_background.dart';

class ImportService {
  static Future<List<CanvasBackground>> importPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return [];
    final file = result.files.first;
    if (file.bytes == null) return [];

    final document = await PdfDocument.openData(file.bytes!);
    final List<CanvasBackground> backgrounds = [];

    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.png,
        backgroundColor: '#FFFFFF',
      );
      await page.close();
      if (pageImage?.bytes != null) {
        backgrounds.add(CanvasBackground(
          id: 'bg_${DateTime.now().millisecondsSinceEpoch}_$i',
          imageData: pageImage!.bytes,
          type: BackgroundType.pdf,
          fileName: file.name,
          pageIndex: i - 1,
          totalPages: document.pagesCount,
        ));
      }
    }
    await document.close();
    return backgrounds;
  }

  static Future<CanvasBackground?> importImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    if (file.bytes == null) return null;
    return CanvasBackground(
      id: 'bg_${DateTime.now().millisecondsSinceEpoch}',
      imageData: file.bytes!,
      type: BackgroundType.image,
      fileName: file.name,
    );
  }
}