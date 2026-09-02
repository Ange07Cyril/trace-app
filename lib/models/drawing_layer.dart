import 'package:flutter/material.dart';
import 'drawing_stroke.dart';

class DrawingLayer {
  final String id;
  String name;
  List<DrawingStroke> strokes;
  bool isVisible;
  bool isLocked;
  double opacity;
  Color color;

  DrawingLayer({
    required this.id,
    required this.name,
    List<DrawingStroke>? strokes,
    this.isVisible = true,
    this.isLocked = false,
    this.opacity = 1.0,
    Color? color,
  })  : strokes = strokes ?? [],
        color = color ?? Colors.blue;

  DrawingLayer copyWith({
    String? name,
    List<DrawingStroke>? strokes,
    bool? isVisible,
    bool? isLocked,
    double? opacity,
    Color? color,
  }) {
    return DrawingLayer(
      id: id,
      name: name ?? this.name,
      strokes: strokes ?? List.from(this.strokes),
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      opacity: opacity ?? this.opacity,
      color: color ?? this.color,
    );
  }
}