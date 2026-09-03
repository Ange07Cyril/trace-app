import 'package:flutter/material.dart';
import '../models/arch_symbol.dart';

class SymbolState extends ChangeNotifier {
  final List<PlacedSymbol> _symbols = [];
  String? _selectedSymbolId;

  List<PlacedSymbol> get symbols => List.unmodifiable(_symbols);
  String? get selectedSymbolId => _selectedSymbolId;

  PlacedSymbol? get selectedSymbol => _selectedSymbolId == null
      ? null
      : _symbols.where((s) => s.id == _selectedSymbolId).firstOrNull;

  void placeSymbol(ArchSymbol symbol, Offset position) {
    final placed = PlacedSymbol(
      id: 'sym_${DateTime.now().millisecondsSinceEpoch}',
      symbol: symbol,
      position: position,
    );
    _symbols.add(placed);
    _selectedSymbolId = placed.id;
    notifyListeners();
  }

  void selectSymbol(String? id) {
    _selectedSymbolId = id;
    notifyListeners();
  }

  void deselectAll() {
    _selectedSymbolId = null;
    notifyListeners();
  }

  void moveSymbol(String id, Offset delta) {
    final idx = _symbols.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    _symbols[idx] = _symbols[idx].copyWith(
      position: _symbols[idx].position + delta,
    );
    notifyListeners();
  }

  void rotateSymbol(String id, double deltaAngle) {
    final idx = _symbols.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    _symbols[idx] = _symbols[idx].copyWith(
      rotation: _symbols[idx].rotation + deltaAngle,
    );
    notifyListeners();
  }

  void scaleSymbol(String id, double scale) {
    final idx = _symbols.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    _symbols[idx] = _symbols[idx].copyWith(
      scale: scale.clamp(0.2, 5.0),
    );
    notifyListeners();
  }

  void deleteSymbol(String id) {
    _symbols.removeWhere((s) => s.id == id);
    if (_selectedSymbolId == id) _selectedSymbolId = null;
    notifyListeners();
  }

  void setSymbolColor(String id, Color color) {
    final idx = _symbols.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    _symbols[idx] = _symbols[idx].copyWith(color: color);
    notifyListeners();
  }

  PlacedSymbol? hitTest(Offset pos) {
    for (final sym in _symbols.reversed) {
      final size = Size(
        sym.symbol.baseSize.width * sym.scale,
        sym.symbol.baseSize.height * sym.scale,
      );
      final rect = Rect.fromCenter(
        center: sym.position,
        width: size.width + 12,
        height: size.height + 12,
      );
      if (rect.contains(pos)) return sym;
    }
    return null;
  }
}