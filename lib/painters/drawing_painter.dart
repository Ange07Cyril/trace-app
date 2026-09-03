import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/drawing_layer.dart';
import '../models/drawing_stroke.dart';
import '../models/canvas_background.dart';

class DrawingPainter extends CustomPainter {
  final List<DrawingLayer> layers;
  final DrawingStroke? activeStroke;
  final CanvasBackground? background;
  final ui.Image? backgroundImage;
  final bool showGrid;

  DrawingPainter({
    required this.layers,
    this.activeStroke,
    this.background,
    this.backgroundImage,
    this.showGrid = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) _drawGrid(canvas, size);

    if (backgroundImage != null && background != null) {
      _drawBackground(canvas, size);
    }

    for (final layer in layers) {
      if (!layer.isVisible) continue;
      canvas.saveLayer(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white.withOpacity(layer.opacity),
      );
      for (final stroke in layer.strokes) {
        _drawStroke(canvas, stroke);
      }
      canvas.restore();
    }

    if (activeStroke != null) _drawStroke(canvas, activeStroke!);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final img = backgroundImage!;
    final bg = background!;

    final imgAspect = img.width / img.height;
    final canvasAspect = size.width / size.height;

    double dstW, dstH;
    if (imgAspect > canvasAspect) {
      dstW = size.width * bg.scale;
      dstH = dstW / imgAspect;
    } else {
      dstH = size.height * bg.scale;
      dstW = dstH * imgAspect;
    }

    final dstRect = Rect.fromLTWH(
      (size.width - dstW) / 2 + bg.offset.dx,
      (size.height - dstH) / 2 + bg.offset.dy,
      dstW,
      dstH,
    );

    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      dstRect,
      Paint()
        ..filterQuality = FilterQuality.high
        ..color = Colors.white.withOpacity(bg.opacity),
    );
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;
    if (stroke.points.length == 1) {
      canvas.drawCircle(
        stroke.points.first,
        stroke.strokeWidth / 2,
        stroke.paint,
      );
      return;
    }

    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

    if (stroke.points.length == 2) {
      path.lineTo(stroke.points[1].dx, stroke.points[1].dy);
    } else {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p0 = stroke.points[i];
        final p1 = stroke.points[i + 1];
        path.quadraticBezierTo(
          p0.dx, p0.dy,
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
      }
      path.lineTo(stroke.points.last.dx, stroke.points.last.dy);
    }

    canvas.drawPath(path, stroke.paint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x15FFFFFF)
      ..strokeWidth = 0.5;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter old) => true;
}