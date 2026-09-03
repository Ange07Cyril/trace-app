import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/dimension.dart';
import '../state/dimension_state.dart';

class DimensionPainter extends CustomPainter {
  final DimensionState state;
  final Offset? cursorPos;

  const DimensionPainter({required this.state, this.cursorPos});

  @override
  void paint(Canvas canvas, Size size) {
    if (state.showRuler) _drawRuler(canvas, size);
    if (state.showGuides) {
      for (final g in state.guides) _drawGuide(canvas, size, g);
    }
    if (state.showDimensions) {
      for (final d in state.dimensions) {
        _drawDimension(canvas, d, isSelected: d.id == state.selectedId);
      }
    }
    if (state.awaitingSecondPoint && state.firstPoint != null) {
      _drawFirstPointMarker(canvas, state.firstPoint!);
      if (cursorPos != null) {
        _drawDimensionPreview(canvas, state.firstPoint!, cursorPos!);
      }
    }
  }

  void _drawRuler(Canvas canvas, Size size) {
    const rulerW = 24.0;
    final bg = Paint()..color = const Color(0xFF1A1A1A);
    final tick = Paint()
      ..color = const Color(0xFF555555)
      ..strokeWidth = 0.8;
    final textStyle = TextStyle(
      color: const Color(0xFF666666),
      fontSize: 8,
    );

    canvas.drawRect(
        Rect.fromLTWH(rulerW, 0, size.width - rulerW, rulerW), bg);
    canvas.drawRect(
        Rect.fromLTWH(0, rulerW, rulerW, size.height - rulerW), bg);
    canvas.drawRect(Rect.fromLTWH(0, 0, rulerW, rulerW), bg);

    final ppu = state.scale.pixelsPerUnit;
    double spacing = ppu;
    int step = 1;
    while (spacing < 30) { spacing *= 5; step *= 5; }

    double x = rulerW;
    while (x < size.width) {
      final label = ((x - rulerW) / ppu).round();
      canvas.drawLine(Offset(x, rulerW - 6), Offset(x, rulerW), tick);
      _drawText(canvas, '$label', Offset(x + 2, 2), textStyle);
      x += spacing;
    }

    double y = rulerW;
    while (y < size.height) {
      final label = ((y - rulerW) / ppu).round();
      canvas.drawLine(Offset(rulerW - 6, y), Offset(rulerW, y), tick);
      canvas.save();
      canvas.translate(2, y - 2);
      canvas.rotate(-math.pi / 2);
      _drawText(canvas, '$label', Offset.zero, textStyle);
      canvas.restore();
      y += spacing;
    }

    final border = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 0.5;
    canvas.drawLine(
        Offset(rulerW, rulerW), Offset(size.width, rulerW), border);
    canvas.drawLine(
        Offset(rulerW, rulerW), Offset(rulerW, size.height), border);

    _drawText(
      canvas,
      state.scale.unit,
      const Offset(3, 8),
      textStyle.copyWith(
          color: const Color(0xFF4A9EFF), fontSize: 7),
    );
  }

  void _drawGuide(Canvas canvas, Size size, GuideRule guide) {
    final paint = Paint()
      ..color = guide.color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    _drawDashed(
      canvas,
      guide.isHorizontal
          ? Offset(0, guide.position)
          : Offset(guide.position, 0),
      guide.isHorizontal
          ? Offset(size.width, guide.position)
          : Offset(guide.position, size.height),
      paint,
    );
  }

  void _drawDimension(Canvas canvas, DimensionLine dim,
      {bool isSelected = false}) {
    final color =
        isSelected ? const Color(0xFF4A9EFF) : dim.color;
    final paint = Paint()
      ..color = color
      ..strokeWidth = dim.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (dim.type == DimensionType.leader) {
      _drawLeader(canvas, dim, paint, color, isSelected);
    } else {
      _drawLinearDim(canvas, dim, paint, color, isSelected);
    }
  }

  void _drawLinearDim(Canvas canvas, DimensionLine dim,
      Paint paint, Color color, bool isSelected) {
    final a = dim.startPoint;
    final b = dim.endPoint;
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;

    final nx = -dy / len;
    final ny = dx / len;
    const offset = 20.0;

    final aOff = Offset(a.dx + nx * offset, a.dy + ny * offset);
    final bOff = Offset(b.dx + nx * offset, b.dy + ny * offset);

    canvas.drawLine(a, aOff, paint);
    canvas.drawLine(b, bOff, paint);
    canvas.drawLine(aOff, bOff, paint);

    _drawArrow(canvas, aOff, bOff, paint);
    _drawArrow(canvas, bOff, aOff, paint);

    final mid = Offset(
        (aOff.dx + bOff.dx) / 2, (aOff.dy + bOff.dy) / 2);
    _drawDimText(canvas, dim.displayValue, mid, color,
        angle: math.atan2(dy, dx));

    if (isSelected) _drawEndpointHandles(canvas, a, b);
  }

  void _drawLeader(Canvas canvas, DimensionLine dim,
      Paint paint, Color color, bool isSelected) {
    final a = dim.startPoint;
    final b = dim.endPoint;
    canvas.drawLine(a, b, paint);
    _drawArrow(canvas, b, a, paint);
    final shelfEnd = Offset(b.dx + 25, b.dy);
    canvas.drawLine(b, shelfEnd, paint);
    final label = dim.label ?? dim.displayValue;
    _drawDimText(canvas, label, Offset(b.dx + 4, b.dy - 10), color);
    if (isSelected) _drawEndpointHandles(canvas, a, b);
  }

  void _drawDimensionPreview(Canvas canvas, Offset a, Offset b) {
    final paint = Paint()
      ..color = const Color(0x804A9EFF)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    _drawDashed(canvas, a, b, paint);
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final pxLen = math.sqrt(dx * dx + dy * dy);
    final value = state.scale.format(pxLen);
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    _drawDimText(canvas, value, mid,
        const Color(0xFF4A9EFF),
        angle: math.atan2(dy, dx), isPreview: true);
  }

  void _drawFirstPointMarker(Canvas canvas, Offset pt) {
    canvas.drawCircle(pt, 5,
        Paint()..color = const Color(0xFF4A9EFF)..style = PaintingStyle.fill);
    canvas.drawCircle(pt, 5,
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  void _drawArrow(Canvas canvas, Offset tip, Offset other, Paint paint) {
    final dx = tip.dx - other.dx;
    final dy = tip.dy - other.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final ux = dx / len, uy = dy / len;
    const as_ = 8.0, aw = 3.5;
    final left = Offset(tip.dx - ux * as_ + uy * aw,
        tip.dy - uy * as_ - ux * aw);
    final right = Offset(tip.dx - ux * as_ - uy * aw,
        tip.dy - uy * as_ + ux * aw);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(path,
        Paint()..color = paint.color..style = PaintingStyle.fill);
  }

  void _drawEndpointHandles(Canvas canvas, Offset a, Offset b) {
    final hp = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final hs = Paint()
      ..color = const Color(0xFF4A9EFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final pt in [a, b]) {
      canvas.drawCircle(pt, 5, hp);
      canvas.drawCircle(pt, 5, hs);
    }
  }

  void _drawDimText(Canvas canvas, String text, Offset pos, Color color,
      {double angle = 0, bool isPreview = false}) {
    final span = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: isPreview ? 11 : 10,
        fontWeight: FontWeight.w600,
        background: Paint()..color = const Color(0xCC1A1A1A),
      ),
    );
    final tp = TextPainter(
        text: span, textDirection: TextDirection.ltr)..layout();
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    if (angle > math.pi / 2 || angle < -math.pi / 2) {
      canvas.rotate(angle + math.pi);
      canvas.translate(-tp.width, -tp.height);
    } else {
      canvas.rotate(angle);
    }
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height - 2));
    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, pos);
  }

  void _drawDashed(Canvas canvas, Offset a, Offset b, Paint paint,
      {double dashLen = 6, double gapLen = 4}) {
    final dx = b.dx - a.dx, dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final ux = dx / len, uy = dy / len;
    double d = 0;
    bool drawing = true;
    while (d < len) {
      final segLen = drawing ? dashLen : gapLen;
      final end = math.min(d + segLen, len);
      if (drawing) {
        canvas.drawLine(
          Offset(a.dx + ux * d, a.dy + uy * d),
          Offset(a.dx + ux * end, a.dy + uy * end),
          paint,
        );
      }
      d = end;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(DimensionPainter old) => true;
}