import 'dart:typed_data';
import 'package:flutter/material.dart';

enum BackgroundType { pdf, image }

class CanvasBackground {
  final String id;
  final Uint8List imageData;
  final BackgroundType type;
  final String fileName;
  final int pageIndex;
  final int totalPages;
  double opacity;
  Offset offset;
  double scale;

  CanvasBackground({
    required this.id,
    required this.imageData,
    required this.type,
    required this.fileName,
    this.pageIndex = 0,
    this.totalPages = 1,
    this.opacity = 1.0,
    this.offset = Offset.zero,
    this.scale = 1.0,
  });

  CanvasBackground copyWith({
    Uint8List? imageData,
    double? opacity,
    Offset? offset,
    double? scale,
  }) {
    return CanvasBackground(
      id: id,
      imageData: imageData ?? this.imageData,
      type: type,
      fileName: fileName,
      pageIndex: pageIndex,
      totalPages: totalPages,
      opacity: opacity ?? this.opacity,
      offset: offset ?? this.offset,
      scale: scale ?? this.scale,
    );
  }
}