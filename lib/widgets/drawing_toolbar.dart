import 'package:flutter/material.dart';
import '../state/canvas_state.dart';
import '../models/drawing_stroke.dart';
import 'color_picker.dart';

class DrawingToolbar extends StatelessWidget {
  final CanvasState state;
  const DrawingToolbar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(right: BorderSide(color: Color(0xFF333333))),
      ),
      child: Column(children: [
        const SizedBox(height: 8),
        _ToolBtn(icon: Icons.undo, tooltip: 'Annuler',
            enabled: state.canUndo, onTap: state.undo),
        _ToolBtn(icon: Icons.redo, tooltip: 'Rétablir',
            enabled: state.canRedo, onTap: state.redo),
        _Div(),
        _brushBtn(context, BrushType.pen, Icons.edit, 'Stylo'),
        _brushBtn(context, BrushType.pencil, Icons.create, 'Crayon'),
        _brushBtn(context, BrushType.marker, Icons.brush, 'Marqueur'),
        _brushBtn(context, BrushType.fineliner,
            Icons.horizontal_rule, 'Fineliner'),
        _brushBtn(context, BrushType.eraser,
            Icons.auto_fix_normal, 'Gomme'),
        _Div(),
        _ColorBtn(state: state),
        _Div(),
        _StrokeBtn(state: state),
        const Spacer(),
        _ToolBtn(
          icon: Icons.delete_sweep_outlined,
          tooltip: 'Effacer le calque',
          color: const Color(0xFFFF4444),
          onTap: () => _confirmClear(context),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _brushBtn(BuildContext ctx, BrushType type,
      IconData icon, String label) {
    return _ToolBtn(
      icon: icon, tooltip: label,
      isActive: state.currentBrush == type,
      onTap: () => state.setBrush(type),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Effacer le calque',
            style: TextStyle(color: Colors.white)),
        content: const Text('Tous les traits seront supprimés.',
            style: TextStyle(color: Color(0xFFAAAAAA))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler',
                  style: TextStyle(color: Color(0xFF888888)))),
          TextButton(
            onPressed: () {
              state.clearActiveLayer();
              Navigator.pop(ctx);
            },
            child: const Text('Effacer',
                style: TextStyle(color: Color(0xFFFF4444))),
          ),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final bool enabled;
  final Color? color;
  final VoidCallback onTap;

  const _ToolBtn({
    required this.icon, required this.tooltip, required this.onTap,
    this.isActive = false, this.enabled = true, this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = !enabled
        ? const Color(0xFF333333)
        : isActive ? const Color(0xFF4A9EFF)
        : color ?? const Color(0xFF888888);
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44, height: 44,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2A3A4A) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: c, size: 22),
        ),
      ),
    );
  }
}

class _ColorBtn extends StatelessWidget {
  final CanvasState state;
  const _ColorBtn({required this.state});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E1E1E),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => ColorPickerSheet(
          currentColor: state.currentColor,
          onColorSelected: (c) { state.setColor(c); Navigator.pop(ctx); },
        ),
      ),
      child: Container(
        width: 34, height: 34,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: state.currentColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30, width: 2),
        ),
      ),
    );
  }
}

class _StrokeBtn extends StatelessWidget {
  final CanvasState state;
  const _StrokeBtn({required this.state});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E1E1E),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => _StrokeSheet(state: state),
      ),
      child: SizedBox(
        width: 44, height: 44,
        child: Center(
          child: Container(
            width: state.strokeWidth * 2.5,
            height: state.strokeWidth * 2.5,
            decoration: BoxDecoration(
                color: state.currentColor, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _StrokeSheet extends StatefulWidget {
  final CanvasState state;
  const _StrokeSheet({required this.state});
  @override
  State<_StrokeSheet> createState() => _StrokeSheetState();
}

class _StrokeSheetState extends State<_StrokeSheet> {
  late double _width;
  @override
  void initState() { super.initState(); _width = widget.state.strokeWidth; }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Épaisseur', style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Slider(
          value: _width, min: 1.0, max: 30.0,
          activeColor: const Color(0xFF4A9EFF),
          onChanged: (v) {
            setState(() => _width = v);
            widget.state.setStrokeWidth(v);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [1.0, 3.0, 6.0, 12.0, 20.0].map((w) =>
            GestureDetector(
              onTap: () { setState(() => _width = w); widget.state.setStrokeWidth(w); },
              child: Container(
                width: w * 2 + 10, height: w * 2 + 10,
                decoration: BoxDecoration(
                  color: _width == w
                      ? const Color(0xFF4A9EFF)
                      : widget.state.currentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ).toList(),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _Div extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 30, height: 1,
    margin: const EdgeInsets.symmetric(vertical: 6),
    color: const Color(0xFF333333),
  );
}