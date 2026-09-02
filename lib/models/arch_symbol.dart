import 'package:flutter/material.dart';

enum SymbolCategory {
  furniture,
  doors,
  windows,
  sanitary,
  vegetation,
  stairs,
  structural,
  annotation,
}

extension SymbolCategoryExt on SymbolCategory {
  String get label {
    switch (this) {
      case SymbolCategory.furniture:   return 'Mobilier';
      case SymbolCategory.doors:       return 'Portes';
      case SymbolCategory.windows:     return 'Fenêtres';
      case SymbolCategory.sanitary:    return 'Sanitaires';
      case SymbolCategory.vegetation:  return 'Végétation';
      case SymbolCategory.stairs:      return 'Escaliers';
      case SymbolCategory.structural:  return 'Structure';
      case SymbolCategory.annotation:  return 'Annotation';
    }
  }

  IconData get icon {
    switch (this) {
      case SymbolCategory.furniture:   return Icons.chair_outlined;
      case SymbolCategory.doors:       return Icons.door_front_door_outlined;
      case SymbolCategory.windows:     return Icons.window_outlined;
      case SymbolCategory.sanitary:    return Icons.bathtub_outlined;
      case SymbolCategory.vegetation:  return Icons.park_outlined;
      case SymbolCategory.stairs:      return Icons.stairs_outlined;
      case SymbolCategory.structural:  return Icons.architecture;
      case SymbolCategory.annotation:  return Icons.text_fields;
    }
  }
}

class ArchSymbol {
  final String id;
  final String name;
  final SymbolCategory category;
  final List<SymbolPath> paths;
  final Size baseSize;

  const ArchSymbol({
    required this.id,
    required this.name,
    required this.category,
    required this.paths,
    required this.baseSize,
  });
}

class SymbolPath {
  final String svgD;
  final bool filled;
  final double strokeWidth;

  const SymbolPath({
    required this.svgD,
    this.filled = false,
    this.strokeWidth = 1.5,
  });
}

class PlacedSymbol {
  final String id;
  final ArchSymbol symbol;
  Offset position;
  double rotation;
  double scale;
  Color color;

  PlacedSymbol({
    required this.id,
    required this.symbol,
    required this.position,
    this.rotation = 0.0,
    this.scale = 1.0,
    this.color = Colors.black,
  });

  PlacedSymbol copyWith({
    Offset? position,
    double? rotation,
    double? scale,
    Color? color,
  }) {
    return PlacedSymbol(
      id: id,
      symbol: symbol,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      color: color ?? this.color,
    );
  }
}