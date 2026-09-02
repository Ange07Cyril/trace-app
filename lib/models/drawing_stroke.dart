import 'package:flutter/material.dart';

enum BrushType {
  pen,
  pencil,
  marker,
  eraser,
  fineliner,
}

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final BrushType brushType;
  final double opacity;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.brushType,
    this.opacity = 1.0,
  });

  DrawingStroke copyWith({
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
    BrushType? brushType,
    double? opacity,
  }) {
    return DrawingStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      brushType: brushType ?? this.brushType,
      opacity: opacity ?? this.opacity,
    );
  }

  Paint get paint {
    final p = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    switch (brushType) {
      case BrushType.pen:
        p.strokeCap = StrokeCap.round;
        break;
      case BrushType.pencil:
        p.maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
        p.strokeWidth = strokeWidth * 1.2;
        break;
      case BrushType.marker:
        p.color = color.withOpacity(opacity * 0.6);
        p.strokeWidth = strokeWidth * 2.5;
        p.strokeCap = StrokeCap.square;
        break;
      case BrushType.fineliner:
        p.strokeWidth = strokeWidth * 0.5;
        p.strokeCap = StrokeCap.butt;
        break;
      case BrushType.eraser:
        p.blendMode = BlendMode.clear;
        p.strokeWidth = strokeWidth * 2;
        break;
    }
    return p;
  }
}