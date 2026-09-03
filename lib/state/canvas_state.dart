import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/drawing_layer.dart';
import '../models/drawing_stroke.dart';
import '../models/canvas_background.dart';

class CanvasState extends ChangeNotifier {
  List<DrawingLayer> _layers = [];
  int _activeLayerIndex = 0;

  BrushType _currentBrush = BrushType.pen;
  Color _currentColor = Colors.black;
  double _strokeWidth = 3.0;
  double _opacity = 1.0;

  final List<List<DrawingLayer>> _history = [];
  final List<List<DrawingLayer>> _redoStack = [];
  static const int _maxHistory = 50;

  DrawingStroke? _activeStroke;

  List<CanvasBackground> _pdfPages = [];
  int _activePdfPage = 0;
  CanvasBackground? _background;
  ui.Image? _backgroundImage;

  CanvasState() { _initLayers(); }

  void _initLayers() {
    _layers = [
      DrawingLayer(
        id: 'layer_1',
        name: 'Calque 1',
        color: const Color(0xFF4A9EFF),
      ),
    ];
    notifyListeners();
  }

  List<DrawingLayer> get layers => _layers;
  int get activeLayerIndex => _activeLayerIndex;
  DrawingLayer get activeLayer => _layers[_activeLayerIndex];
  BrushType get currentBrush => _currentBrush;
  Color get currentColor => _currentColor;
  double get strokeWidth => _strokeWidth;
  double get opacity => _opacity;
  DrawingStroke? get activeStroke => _activeStroke;
  bool get canUndo => _history.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  CanvasBackground? get background => _background;
  ui.Image? get backgroundImage => _backgroundImage;
  List<CanvasBackground> get pdfPages => _pdfPages;
  int get activePdfPage => _activePdfPage;

  void setBrush(BrushType brush) { _currentBrush = brush; notifyListeners(); }
  void setColor(Color color) { _currentColor = color; notifyListeners(); }
  void setStrokeWidth(double width) { _strokeWidth = width; notifyListeners(); }
  void setOpacity(double op) { _opacity = op; notifyListeners(); }

  void setActiveLayer(int index) {
    if (index >= 0 && index < _layers.length) {
      _activeLayerIndex = index;
      notifyListeners();
    }
  }

  Future<void> setBackground(CanvasBackground? bg) async {
    _background = bg;
    _backgroundImage = null;
    if (bg != null) {
      _backgroundImage = await _decodeImage(bg.imageData);
    }
    notifyListeners();
  }

  Future<void> setPdfPages(List<CanvasBackground> pages) async {
    _pdfPages = pages;
    _activePdfPage = 0;
    if (pages.isNotEmpty) await setBackground(pages.first);
    notifyListeners();
  }

  Future<void> goToPdfPage(int index) async {
    if (index < 0 || index >= _pdfPages.length) return;
    _activePdfPage = index;
    await setBackground(_pdfPages[index]);
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void startStroke(Offset point) {
    if (activeLayer.isLocked) return;
    _activeStroke = DrawingStroke(
      points: [point],
      color: _currentBrush == BrushType.eraser
          ? Colors.white
          : _currentColor,
      strokeWidth: _strokeWidth,
      brushType: _currentBrush,
      opacity: _opacity,
    );
    notifyListeners();
  }

  void addPoint(Offset point) {
    if (_activeStroke == null) return;
    _activeStroke = _activeStroke!.copyWith(
      points: [..._activeStroke!.points, point],
    );
    notifyListeners();
  }

  void endStroke() {
    if (_activeStroke == null) return;
    _saveHistory();
    _layers[_activeLayerIndex].strokes.add(_activeStroke!);
    _activeStroke = null;
    _redoStack.clear();
    notifyListeners();
  }

  void _saveHistory() {
    _history.add(_layers.map((l) => l.copyWith()).toList());
    if (_history.length > _maxHistory) _history.removeAt(0);
  }

  void undo() {
    if (!canUndo) return;
    _redoStack.add(_layers.map((l) => l.copyWith()).toList());
    _layers = _history.removeLast();
    if (_activeLayerIndex >= _layers.length) {
      _activeLayerIndex = _layers.length - 1;
    }
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _saveHistory();
    _layers = _redoStack.removeLast();
    notifyListeners();
  }

  void addLayer() {
    _saveHistory();
    final colors = [
      const Color(0xFF4A9EFF), const Color(0xFFFF6B35),
      const Color(0xFF50E3A4), const Color(0xFFFFD93D),
      const Color(0xFFFF6B9D),
    ];
    _layers.add(DrawingLayer(
      id: 'layer_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Calque ${_layers.length + 1}',
      color: colors[_layers.length % colors.length],
    ));
    _activeLayerIndex = _layers.length - 1;
    notifyListeners();
  }

  void deleteLayer(int index) {
    if (_layers.length <= 1) return;
    _saveHistory();
    _layers.removeAt(index);
    if (_activeLayerIndex >= _layers.length) {
      _activeLayerIndex = _layers.length - 1;
    }
    notifyListeners();
  }

  void toggleLayerVisibility(int index) {
    _layers[index].isVisible = !_layers[index].isVisible;
    notifyListeners();
  }

  void toggleLayerLock(int index) {
    _layers[index].isLocked = !_layers[index].isLocked;
    notifyListeners();
  }

  void setLayerOpacity(int index, double opacity) {
    _layers[index].opacity = opacity;
    notifyListeners();
  }

  void reorderLayers(int oldIndex, int newIndex) {
    _saveHistory();
    if (newIndex > oldIndex) newIndex--;
    final layer = _layers.removeAt(oldIndex);
    _layers.insert(newIndex, layer);
    _activeLayerIndex = newIndex;
    notifyListeners();
  }

  void clearActiveLayer() {
    _saveHistory();
    _layers[_activeLayerIndex].strokes.clear();
    notifyListeners();
  }

  void renameLayer(int index, String name) {
    _layers[index].name = name;
    notifyListeners();
  }

  void applyLayers(List<DrawingLayer> layers) {
    _layers = layers;
    _activeLayerIndex = 0;
    notifyListeners();
  }
}