import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/project.dart';
import '../models/drawing_layer.dart';
import '../models/drawing_stroke.dart';
import '../state/canvas_state.dart';

class ProjectService {
  static const _projectsFile = 'trace_projects.json';

  static Future<List<ProjectMeta>> loadIndex() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_projectsFile');
      if (!await file.exists()) return [];
      final data = jsonDecode(await file.readAsString()) as List;
      return data.map((j) => ProjectMeta.fromJson(j)).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (_) { return []; }
  }

  static Future<void> _saveIndex(List<ProjectMeta> projects) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_projectsFile');
    await file.writeAsString(
        jsonEncode(projects.map((p) => p.toJson()).toList()));
  }

  static Future<ProjectMeta> saveProject({
    required CanvasState state,
    String? existingId,
    required String title,
    String? description,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final id = existingId ?? 'proj_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final layersData = state.layers.map((l) => {
      'id': l.id,
      'name': l.name,
      'isVisible': l.isVisible,
      'isLocked': l.isLocked,
      'opacity': l.opacity,
      'color': l.color.value,
      'strokes': l.strokes.map((s) => {
        'brushType': s.brushType.index,
        'color': s.color.value,
        'strokeWidth': s.strokeWidth,
        'opacity': s.opacity,
        'points': s.points.map((p) => [p.dx, p.dy]).toList(),
      }).toList(),
    }).toList();

    final file = File('${dir.path}/$id.trace');
    await file.writeAsString(jsonEncode({
      'id': id, 'title': title,
      'layers': layersData,
      'savedAt': now.toIso8601String(),
    }));

    final meta = ProjectMeta(
      id: id, title: title, description: description,
      createdAt: now, updatedAt: now,
    );
    final index = await loadIndex();
    index.removeWhere((p) => p.id == id);
    index.insert(0, meta);
    await _saveIndex(index);
    return meta;
  }

  static Future<void> deleteProject(String id) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$id.trace');
    if (await file.exists()) await file.delete();
    final index = await loadIndex();
    index.removeWhere((p) => p.id == id);
    await _saveIndex(index);
  }

  static List<DrawingLayer> layersFromTemplate(PlanTemplate template) {
    return template.layers.asMap().entries.map((e) {
      return DrawingLayer(
        id: 'layer_${DateTime.now().millisecondsSinceEpoch}_${e.key}',
        name: e.value.name,
        color: e.value.color,
      );
    }).toList();
  }
}