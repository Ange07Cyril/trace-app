import 'package:flutter/material.dart';
import '../models/arch_symbol.dart';
import '../utils/svg_path_parser.dart';

class SymbolPainter extends CustomPainter {
  final List<PlacedSymbol> symbols;
  final String? selectedId;

  const SymbolPainter({
    required this.symbols,
    this.selectedId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final placed in symbols) {
      _drawSymbol(canvas, placed);
    }
  }

  void _drawSymbol(Canvas canvas, PlacedSymbol placed) {
    final sym = placed.symbol;
    final targetSize = Size(
      sym.baseSize.width * placed.scale,
      sym.baseSize.height * placed.scale,
    );

    canvas.save();
    canvas.translate(placed.position.dx, placed.position.dy);
    if (placed.rotation != 0) canvas.rotate(placed.rotation);
    canvas.translate(-targetSize.width / 2, -targetSize.height / 2);

    for (final sp in sym.paths) {
      final path = SvgPathParser.scaled(sp.svgD, sym.baseSize, targetSize);
      final paint = Paint()
        ..color = placed.color
        ..strokeWidth = sp.strokeWidth * placed.scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = sp.filled ? PaintingStyle.fill : PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }

    if (placed.id == selectedId) {
      _drawSelectionBox(canvas, targetSize);
    }

    canvas.restore();
  }

  void _drawSelectionBox(Canvas canvas, Size size) {
    const padding = 6.0;
    final rect = Rect.fromLTWH(
      -padding, -padding,
      size.width + padding * 2,
      size.height + padding * 2,
    );

    final paint = Paint()
      ..color = const Color(0xFF4A9EFF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);

    const hs = 6.0;
    final handleFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final handleStroke = Paint()
      ..color = const Color(0xFF4A9EFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final corner in [
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.left, rect.bottom),
      Offset(rect.right, rect.bottom),
    ]) {
      canvas.drawRect(
        Rect.fromCenter(center: corner, width: hs, height: hs),
        handleFill,
      );
      canvas.drawRect(
        Rect.fromCenter(center: corner, width: hs, height: hs),
        handleStroke,
      );
    }

    final rotHandle = Offset(rect.center.dx, rect.top - 16);
    canvas.drawLine(Offset(rect.center.dx, rect.top), rotHandle, paint);
    canvas.drawCircle(rotHandle, 5, handleFill);
    canvas.drawCircle(rotHandle, 5, handleStroke);
  }

  @override
  bool shouldRepaint(SymbolPainter old) =>
      old.symbols != symbols || old.selectedId != selectedId;
}

class SymbolPreviewPainter extends CustomPainter {
  final ArchSymbol symbol;
  final Color color;

  const SymbolPreviewPainter({
    required this.symbol,
    this.color = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 6.0;
    final targetSize = Size(
      size.width - padding * 2,
      size.height - padding * 2,
    );

    canvas.save();
    canvas.translate(padding, padding);

    final sx = targetSize.width / symbol.baseSize.width;
    final sy = targetSize.height / symbol.baseSize.height;
    final scale = sx < sy ? sx : sy;

    final scaledW = symbol.baseSize.width * scale;
    final scaledH = symbol.baseSize.height * scale;
    canvas.translate(
      (targetSize.width - scaledW) / 2,
      (targetSize.height - scaledH) / 2,
    );

    for (final sp in symbol.paths) {
      final path = SvgPathParser.scaled(
        sp.svgD,
        symbol.baseSize,
        Size(scaledW, scaledH),
      );
      final paint = Paint()
        ..color = color
        ..strokeWidth = sp.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = sp.filled ? PaintingStyle.fill : PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(SymbolPreviewPainter old) =>
      old.symbol != symbol || old.color != color;
}