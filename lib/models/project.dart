import 'package:flutter/material.dart';

class ProjectMeta {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? thumbnailPath;
  final String templateType;

  ProjectMeta({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.thumbnailPath,
    this.templateType = 'blank',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'thumbnailPath': thumbnailPath,
    'templateType': templateType,
  };

  factory ProjectMeta.fromJson(Map<String, dynamic> j) => ProjectMeta(
    id: j['id'],
    title: j['title'],
    description: j['description'],
    createdAt: DateTime.parse(j['createdAt']),
    updatedAt: DateTime.parse(j['updatedAt']),
    thumbnailPath: j['thumbnailPath'],
    templateType: j['templateType'] ?? 'blank',
  );
}

class PlanTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final IconData icon;
  final Color color;
  final List<TemplateLayer> layers;

  const PlanTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.layers,
  });
}

class TemplateLayer {
  final String name;
  final Color color;
  final List<TemplateShape> shapes;

  const TemplateLayer({
    required this.name,
    required this.color,
    this.shapes = const [],
  });
}

class TemplateShape {
  final String type;
  final Offset position;
  final Size? size;
  final double? strokeWidth;

  const TemplateShape({
    required this.type,
    required this.position,
    this.size,
    this.strokeWidth = 2.0,
  });
}