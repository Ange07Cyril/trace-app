import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/drawing_layer.dart';
import '../models/arch_symbol.dart';
import '../models/dimension.dart';

class DxfExportService {
  static Uint8List export({
    required List<DrawingLayer> layers,
    required List<PlacedSymbol> symbols,
    required List<DimensionLine> dimensions,
    required ScaleConfig scale,
    String title = 'Trace Export',
  }) {
    final buf = StringBuffer();
    _writeHeader(buf);
    _writeTables(buf, layers);
    _writeBlocks(buf);
    _writeEntities(buf, layers, symbols, dimensions, scale);
    _writeEnd(buf);
    return Uint8List.fromList(buf.toString().codeUnits);
  }

  static void _writeHeader(StringBuffer b) {
    b.writeln('  0\nSECTION');
    b.writeln('  2\nHEADER');
    b.writeln('  9\n\$ACADVER');
    b.writeln('  1\nAC1009');
    b.writeln('  9\n\$INSUNITS');
    b.writeln(' 70\n     4');
    b.writeln('  0\nENDSEC');
  }

  static void _writeTables(StringBuffer b, List<DrawingLayer> layers) {
    b.writeln('  0\nSECTION');
    b.writeln('  2\nTABLES');
    b.writeln('  0\nTABLE');
    b.writeln('  2\nLAYER');
    b.writeln(' 70\n${layers.length + 2}');
    _writeLayerDef(b, '0', 7);
    _writeLayerDef(b, 'DIMENSIONS', 1);
    _writeLayerDef(b, 'SYMBOLS', 3);
    for (final layer in layers) {
      _writeLayerDef(b, _sanitize(layer.name), _colorIndex(layer.color));
    }
    b.writeln('  0\nENDTAB');
    b.writeln('  0\nENDSEC');
  }

  static void _writeLayerDef(StringBuffer b, String name, int color) {
    b.writeln('  0\nLAYER');
    b.writeln('  2\n$name');
    b.writeln(' 70\n     0');
    b.writeln(' 62\n     $color');
    b.writeln('  6\nCONTINUOUS');
  }

  static void _writeBlocks(StringBuffer b) {
    b.writeln('  0\nSECTION');
    b.writeln('  2\nBLOCKS');
    b.writeln('  0\nENDSEC');
  }

  static void _writeEntities(StringBuffer b, List<DrawingLayer> layers,
      List<PlacedSymbol> symbols, List<DimensionLine> dimensions,
      ScaleConfig scale) {
    b.writeln('  0\nSECTION');
    b.writeln('  2\nENTITIES');
    for (final layer in layers) {
      if (!layer.isVisible) continue;
      final ln = _sanitize(layer.name);
      for (final stroke in layer.strokes) {
        if (stroke.points.length < 2) continue;
        b.writeln('  0\nPOLYLINE');
        b.writeln('  8\n$ln');
        b.writeln(' 66\n     1');
        b.writeln(' 10\n0.0\n 20\n0.0\n 30\n0.0');
        b.writeln(' 70\n     0');
        for (final pt in stroke.points) {
          b.writeln('  0\nVERTEX');
          b.writeln('  8\n$ln');
          b.writeln(' 10\n${_px(pt.dx, scale)}');
          b.writeln(' 20\n${_px(pt.dy, scale)}');
          b.writeln(' 30\n0.0');
        }
        b.writeln('  0\nSEQEND');
      }
    }
    for (final sym in symbols) {
      _writeText(b, sym.symbol.name, sym.position, 'SYMBOLS', scale);
    }
    for (final dim in dimensions) {
      _writeLine(b, dim.startPoint, dim.endPoint, 'DIMENSIONS', scale);
      _writeText(b, dim.displayValue, dim.midPoint, 'DIMENSIONS', scale);
    }
    b.writeln('  0\nENDSEC');
  }

  static void _writeLine(StringBuffer b, Offset a, Offset b2,
      String layer, ScaleConfig sc) {
    b.writeln('  0\nLINE');
    b.writeln('  8\n$layer');
    b.writeln(' 10\n${_px(a.dx, sc)}\n 20\n${_px(a.dy, sc)}\n 30\n0.0');
    b.writeln(' 11\n${_px(b2.dx, sc)}\n 21\n${_px(b2.dy, sc)}\n 31\n0.0');
  }

  static void _writeText(StringBuffer b, String text, Offset pos,
      String layer, ScaleConfig sc) {
    b.writeln('  0\nTEXT');
    b.writeln('  8\n$layer');
    b.writeln(' 10\n${_px(pos.dx, sc)}\n 20\n${_px(pos.dy, sc)}\n 30\n0.0');
    b.writeln(' 40\n2.5');
    b.writeln('  1\n$text');
  }

  static void _writeEnd(StringBuffer b) => b.writeln('  0\nEOF');

  static String _px(double px, ScaleConfig sc) =>
      (px / sc.pixelsPerUnit * 10).toStringAsFixed(4);

  static String _sanitize(String name) =>
      name.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_').toUpperCase();

  static int _colorIndex(Color c) {
    if (c.red > 200 && c.green < 50 && c.blue < 50) return 1;
    if (c.red < 50 && c.green < 50 && c.blue > 200) return 5;
    if (c.red < 50 && c.green > 150 && c.blue < 50) return 3;
    return 7;
  }
}