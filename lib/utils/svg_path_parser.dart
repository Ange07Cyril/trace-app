import 'dart:math' as math;
import 'package:flutter/material.dart';

class SvgPathParser {
  static Path parse(String svgD) {
    final path = Path();
    final commands = _tokenize(svgD);
    double cx = 0, cy = 0;
    int i = 0;
    while (i < commands.length) {
      final cmd = commands[i++];
      switch (cmd) {
        case 'M':
          cx = _d(commands, i); cy = _d(commands, i + 1); i += 2;
          path.moveTo(cx, cy);
          while (i < commands.length && _isNum(commands[i])) {
            cx = _d(commands, i); cy = _d(commands, i + 1); i += 2;
            path.lineTo(cx, cy);
          }
          break;
        case 'm':
          cx += _d(commands, i); cy += _d(commands, i + 1); i += 2;
          path.moveTo(cx, cy);
          break;
        case 'L':
          while (i < commands.length && _isNum(commands[i])) {
            cx = _d(commands, i); cy = _d(commands, i + 1); i += 2;
            path.lineTo(cx, cy);
          }
          break;
        case 'l':
          while (i < commands.length && _isNum(commands[i])) {
            cx += _d(commands, i); cy += _d(commands, i + 1); i += 2;
            path.lineTo(cx, cy);
          }
          break;
        case 'Q':
          while (i + 3 < commands.length && _isNum(commands[i])) {
            final x1 = _d(commands, i), y1 = _d(commands, i + 1);
            cx = _d(commands, i + 2); cy = _d(commands, i + 3); i += 4;
            path.quadraticBezierTo(x1, y1, cx, cy);
          }
          break;
        case 'Z':
        case 'z':
          path.close();
          break;
        case 'A':
          while (i + 6 < commands.length && _isNum(commands[i])) {
            final rx = _d(commands, i);
            final ry = _d(commands, i + 1);
            final x = _d(commands, i + 5);
            final y = _d(commands, i + 6);
            i += 7;
            _addArc(path, cx, cy, x, y, rx, ry);
            cx = x; cy = y;
          }
          break;
        case 'a':
          if (i + 6 < commands.length) {
            final rx = _d(commands, i);
            final ry = _d(commands, i + 1);
            final x = cx + _d(commands, i + 5);
            final y = cy + _d(commands, i + 6);
            i += 7;
            _addArc(path, cx, cy, x, y, rx, ry);
            cx = x; cy = y;
          }
          break;
        default:
          break;
      }
    }
    return path;
  }

  static void _addArc(Path path, double x1, double y1,
      double x2, double y2, double rx, double ry) {
    path.arcToPoint(
      Offset(x2, y2),
      radius: Radius.elliptical(rx, ry),
      largeArc: false,
      clockwise: true,
    );
  }

  static List<String> _tokenize(String d) {
    final result = <String>[];
    final regex = RegExp(
        r'([MmLlQqAaZzHhVvCcSsTt])|(-?[0-9]*\.?[0-9]+(?:e[-+]?[0-9]+)?)');
    for (final match in regex.allMatches(d)) {
      result.add(match.group(0)!);
    }
    return result;
  }

  static bool _isNum(String s) => RegExp(r'^-?[0-9]').hasMatch(s);
  static double _d(List<String> t, int i) =>
      i < t.length ? double.tryParse(t[i]) ?? 0.0 : 0.0;

  static Path scaled(String svgD, Size baseSize, Size targetSize) {
    final raw = parse(svgD);
    final sx = targetSize.width / baseSize.width;
    final sy = targetSize.height / baseSize.height;
    final m = Matrix4.identity()..scale(sx, sy);
    return raw.transform(m.storage);
  }
}