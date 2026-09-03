import 'package:flutter/material.dart';
import '../models/arch_symbol.dart';
import '../state/symbol_state.dart';

class SymbolPropertiesBar extends StatelessWidget {
  final PlacedSymbol symbol;
  final SymbolState state;
  const SymbolPropertiesBar({super.key, required this.symbol, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(top: BorderSide(color: Color(0xFF333333))),
      ),
      child: Row(children: [
        const SizedBox(width: 12),
        Text(symbol.symbol.name, style: const TextStyle(
            color: Color(0xFF888888), fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        _Sep(),
        _Btn(Icons.rotate_left, 'Rotation -15°',
            () => state.rotateSymbol(symbol.id, -0.2618)),
        _Btn(Icons.rotate_right, 'Rotation +15°',
            () => state.rotateSymbol(symbol.id, 0.2618)),
        _Sep(),
        _Btn(Icons.remove, 'Réduire',
            () => state.scaleSymbol(symbol.id, symbol.scale - 0.1)),
        Text('${(symbol.scale * 100).round()}%',
            style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12)),
        _Btn(Icons.add, 'Agrandir',
            () => state.scaleSymbol(symbol.id, symbol.scale + 0.1)),
        _Sep(),
        _ColorDot(symbol: symbol, state: state),
        const Spacer(),
        _Btn(Icons.delete_outline, 'Supprimer',
            () => state.deleteSymbol(symbol.id),
            color: const Color(0xFFFF4444)),
        _Btn(Icons.close, 'Désélectionner', state.deselectAll),
        const SizedBox(width: 8),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;
  const _Btn(this.icon, this.tooltip, this.onTap, {this.color});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(icon, size: 18,
            color: color ?? const Color(0xFF888888)),
      ),
    ),
  );
}

class _Sep extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 24, color: const Color(0xFF333333),
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

class _ColorDot extends StatelessWidget {
  final PlacedSymbol symbol;
  final SymbolState state;
  const _ColorDot({required this.symbol, required this.state});

  static const _colors = [
    Colors.black, Color(0xFF333333), Color(0xFF888888),
    Color(0xFF1565C0), Color(0xFF2E7D32), Color(0xFFC62828),
    Color(0xFFF57F17), Color(0xFF6A1B9A),
  ];

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Couleur du symbole', style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Wrap(spacing: 10, runSpacing: 10, children: _colors.map((c) {
            final isActive = symbol.color.value == c.value;
            return GestureDetector(
              onTap: () { state.setSymbolColor(symbol.id, c); Navigator.pop(ctx); },
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: c, shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? const Color(0xFF4A9EFF) : Colors.white24,
                    width: isActive ? 2.5 : 1.5,
                  ),
                ),
              ),
            );
          }).toList()),
          const SizedBox(height: 8),
        ]),
      ),
    ),
    child: Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        color: symbol.color, shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
    ),
  );
}