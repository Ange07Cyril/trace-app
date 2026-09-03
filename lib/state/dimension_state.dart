import 'package:flutter/material.dart';
import '../models/dimension.dart';

enum DimensionTool {
  none,
  linearDim,
  leaderLine,
  guideH,
  guideV,
}

class DimensionState extends ChangeNotifier {
  final List<DimensionLine> _dimensions = [];
  final List<GuideRule> _guides = [];
  ScaleConfig _scale = ScaleConfig.presets[1];

  DimensionTool _activeTool = DimensionTool.none;
  String? _selectedId;

  Offset? _firstPoint;
  bool _awaitingSecondPoint = false;

  bool _showGuides = true;
  bool _showDimensions = true;
  bool _showRuler = true;

  List<DimensionLine> get dimensions => List.unmodifiable(_dimensions);
  List<GuideRule> get guides => List.unmodifiable(_guides);
  ScaleConfig get scale => _scale;
  DimensionTool get activeTool => _activeTool;
  String? get selectedId => _selectedId;
  bool get awaitingSecondPoint => _awaitingSecondPoint;
  Offset? get firstPoint => _firstPoint;
  bool get showGuides => _showGuides;
  bool get showDimensions => _showDimensions;
  bool get showRuler => _showRuler;
  bool get isActive => _activeTool != DimensionTool.none;

  DimensionLine? get selected => _selectedId == null
      ? null
      : _dimensions.where((d) => d.id == _selectedId).firstOrNull;

  void setTool(DimensionTool tool) {
    _activeTool = _activeTool == tool ? DimensionTool.none : tool;
    _firstPoint = null;
    _awaitingSecondPoint = false;
    _selectedId = null;
    notifyListeners();
  }

  void setScale(ScaleConfig cfg) {
    _scale = cfg;
    notifyListeners();
  }

  void toggleGuides() { _showGuides = !_showGuides; notifyListeners(); }
  void toggleDimensions() { _showDimensions = !_showDimensions; notifyListeners(); }
  void toggleRuler() { _showRuler = !_showRuler; notifyListeners(); }

  void onCanvasTap(Offset pos) {
    switch (_activeTool) {
      case DimensionTool.linearDim:
      case DimensionTool.leaderLine:
        _handleTwoClickTool(pos);
        break;
      case DimensionTool.guideH:
        _addGuide(isHorizontal: true, position: pos.dy);
        break;
      case DimensionTool.guideV:
        _addGuide(isHorizontal: false, position: pos.dx);
        break;
      case DimensionTool.none:
        _trySelect(pos);
        break;
    }
  }

  void _handleTwoClickTool(Offset pos) {
    if (!_awaitingSecondPoint) {
      _firstPoint = pos;
      _awaitingSecondPoint = true;
      notifyListeners();
    } else {
      _commitDimension(_firstPoint!, pos);
      _firstPoint = null;
      _awaitingSecondPoint = false;
      notifyListeners();
    }
  }

  void _commitDimension(Offset a, Offset b) {
    final dim = DimensionLine(
      id: 'dim_${DateTime.now().millisecondsSinceEpoch}',
      type: _activeTool == DimensionTool.leaderLine
          ? DimensionType.leader
          : DimensionType.linear,
      startPoint: a,
      endPoint: b,
      unit: _scale.unit,
      scale: 1 / _scale.pixelsPerUnit,
    );
    _dimensions.add(dim);
    _selectedId = dim.id;
  }

  void _addGuide({required bool isHorizontal, required double position}) {
    _guides.add(GuideRule(
      id: 'guide_${DateTime.now().millisecondsSinceEpoch}',
      isHorizontal: isHorizontal,
      position: position,
    ));
    notifyListeners();
  }

  void _trySelect(Offset pos) {
    const hitRadius = 12.0;
    for (final dim in _dimensions.reversed) {
      if (_distToSegment(pos, dim.startPoint, dim.endPoint) < hitRadius) {
        _selectedId = dim.id;
        notifyListeners();
        return;
      }
    }
    _selectedId = null;
    notifyListeners();
  }

  double _distToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 == 0) return (p - a).distance;
    final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / len2).clamp(0.0, 1.0);
    final proj = a + ab * t;
    return (p - proj).distance;
  }

  void deleteSelected() {
    if (_selectedId == null) return;
    _dimensions.removeWhere((d) => d.id == _selectedId);
    _selectedId = null;
    notifyListeners();
  }

  void deleteGuide(String id) {
    _guides.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  void clearAllGuides() {
    _guides.clear();
    notifyListeners();
  }

  void updateSelectedLabel(String label) {
    final idx = _dimensions.indexWhere((d) => d.id == _selectedId);
    if (idx == -1) return;
    _dimensions[idx] = _dimensions[idx].copyWith(label: label);
    notifyListeners();
  }

  void setSelectedColor(Color color) {
    final idx = _dimensions.indexWhere((d) => d.id == _selectedId);
    if (idx == -1) return;
    _dimensions[idx] = _dimensions[idx].copyWith(color: color);
    notifyListeners();
  }

  void cancelTool() {
    _activeTool = DimensionTool.none;
    _firstPoint = null;
    _awaitingSecondPoint = false;
    notifyListeners();
  }
}