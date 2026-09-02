import 'package:flutter/material.dart';

enum DimensionType {
  linear,
  angle,
  radius,
  leader,
}

class DimensionLine {
  final String id;
  final DimensionType type;
  final Offset startPoint;
  final Offset endPoint;
  final Offset? textOffset;
  final double? overrideValue;
  final String unit;
  final double scale;
  final Color color;
  final double strokeWidth;
  final String? label;

  DimensionLine({
    required this.id,
    required this.type,
    required this.startPoint,
    required this.endPoint,
    this.textOffset,
    this.overrideValue,
    this.unit = 'cm',
    this.scale = 1.0,
    this.color = Colors.black,
    this.strokeWidth = 1.2,
    this.label,
  });

  double get pixelLength {
    final dx = endPoint.dx - startPoint.dx;
    final dy = endPoint.dy - startPoint.dy;
    return _sqrt(dx * dx + dy * dy);
  }

  static double _sqrt(double v) {
    double x = v;
    for (int i = 0; i < 20; i++) x = (x + v / x) / 2;
    return x;
  }

  String get displayValue {
    final raw = overrideValue ?? pixelLength * scale;
    if (raw < 10) return '${raw.toStringAsFixed(1)} $unit';
    return '${raw.round()} $unit';
  }

  Offset get midPoint => Offset(
    (startPoint.dx + endPoint.dx) / 2,
    (startPoint.dy + endPoint.dy) / 2,
  );

  DimensionLine copyWith({
    Offset? startPoint,
    Offset? endPoint,
    Offset? textOffset,
    double? overrideValue,
    String? unit,
    double? scale,
    Color? color,
    String? label,
  }) {
    return DimensionLine(
      id: id,
      type: type,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      textOffset: textOffset ?? this.textOffset,
      overrideValue: overrideValue ?? this.overrideValue,
      unit: unit ?? this.unit,
      scale: scale ?? this.scale,
      color: color ?? this.color,
      strokeWidth: strokeWidth,
      label: label ?? this.label,
    );
  }
}

class GuideRule {
  final String id;
  final bool isHorizontal;
  double position;
  Color color;

  GuideRule({
    required this.id,
    required this.isHorizontal,
    required this.position,
    this.color = const Color(0x884A9EFF),
  });
}

class ScaleConfig {
  final double pixelsPerUnit;
  final String unit;
  final String drawingScale;

  const ScaleConfig({
    this.pixelsPerUnit = 10.0,
    this.unit = 'cm',
    this.drawingScale = '1:50',
  });

  static const List<ScaleConfig> presets = [
    ScaleConfig(pixelsPerUnit: 1.0,   unit: 'm',  drawingScale: '1:100'),
    ScaleConfig(pixelsPerUnit: 2.0,   unit: 'm',  drawingScale: '1:50'),
    ScaleConfig(pixelsPerUnit: 5.0,   unit: 'm',  drawingScale: '1:20'),
    ScaleConfig(pixelsPerUnit: 10.0,  unit: 'cm', drawingScale: '1:10'),
    ScaleConfig(pixelsPerUnit: 20.0,  unit: 'cm', drawingScale: '1:5'),
    ScaleConfig(pixelsPerUnit: 50.0,  unit: 'cm', drawingScale: '1:2'),
    ScaleConfig(pixelsPerUnit: 100.0, unit: 'cm', drawingScale: '1:1'),
  ];

  String format(double pixels) {
    final value = pixels / pixelsPerUnit;
    if (value < 10) return '${value.toStringAsFixed(1)} $unit';
    return '${value.round()} $unit';
  }

  double toReal(double pixels) => pixels / pixelsPerUnit;
}