import 'package:flutter/material.dart';
import '../state/canvas_state.dart';
import '../models/drawing_layer.dart';

class LayersPanel extends StatelessWidget {
  final CanvasState state;
  const LayersPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(left: BorderSide(color: Color(0xFF333333))),
      ),
      child: Column(children: [
        _buildHeader(),
        Expanded(child: _buildList()),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF242424),
        border: Border(bottom: BorderSide(color: Color(0xFF333333))),
      ),
      child: Row(children: [
        const Text('CALQUES', style: TextStyle(
          color: Color(0xFF888888), fontSize: 11,
          fontWeight: FontWeight.w600, letterSpacing: 1.2,
        )),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.add, color: Color(0xFF4A9EFF), size: 20),
          onPressed: state.addLayer,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ]),
    );
  }

  Widget _buildList() {
    final reversed = state.layers.reversed.toList();
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: reversed.length,
      onReorder: (oldIndex, newIndex) {
        final actualOld = state.layers.length - 1 - oldIndex;
        final actualNew = state.layers.length - 1 - newIndex;
        state.reorderLayers(actualOld, actualNew);
      },
      itemBuilder: (context, ri) {
        final ai = state.layers.length - 1 - ri;
        final layer = reversed[ri];
        final isActive = ai == state.activeLayerIndex;
        return _LayerTile(
          key: ValueKey(layer.id),
          layer: layer,
          isActive: isActive,
          onTap: () => state.setActiveLayer(ai),
          onToggleVisibility: () => state.toggleLayerVisibility(ai),
          onToggleLock: () => state.toggleLayerLock(ai),
          onDelete: state.layers.length > 1
              ? () => state.deleteLayer(ai) : null,
          onRename: (n) => state.renameLayer(ai, n),
          onOpacityChange: (v) => state.setLayerOpacity(ai, v),
        );
      },
    );
  }
}

class _LayerTile extends StatefulWidget {
  final DrawingLayer layer;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onToggleVisibility;
  final VoidCallback onToggleLock;
  final VoidCallback? onDelete;
  final Function(String) onRename;
  final Function(double) onOpacityChange;

  const _LayerTile({
    super.key, required this.layer, required this.isActive,
    required this.onTap, required this.onToggleVisibility,
    required this.onToggleLock, this.onDelete,
    required this.onRename, required this.onOpacityChange,
  });

  @override
  State<_LayerTile> createState() => _LayerTileState();
}

class _LayerTileState extends State<_LayerTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: widget.isActive ? const Color(0xFF2A2A2A) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: widget.isActive
            ? Border.all(color: widget.layer.color.withOpacity(0.4))
            : null,
      ),
      child: Column(children: [
        InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(children: [
              const Icon(Icons.drag_indicator,
                  color: Color(0xFF444444), size: 16),
              const SizedBox(width: 6),
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                    color: widget.layer.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.layer.name, style: TextStyle(
                color: widget.isActive ? Colors.white : const Color(0xFFAAAAAA),
                fontSize: 13,
                fontWeight: widget.isActive ? FontWeight.w500 : FontWeight.normal,
              ), overflow: TextOverflow.ellipsis)),
              Text('${widget.layer.strokes.length}',
                  style: const TextStyle(color: Color(0xFF555555), fontSize: 11)),
              const SizedBox(width: 4),
              _Ico(widget.layer.isVisible ? Icons.visibility : Icons.visibility_off,
                  widget.layer.isVisible
                      ? const Color(0xFF888888) : const Color(0xFF444444),
                  widget.onToggleVisibility),
              _Ico(widget.layer.isLocked ? Icons.lock : Icons.lock_open,
                  widget.layer.isLocked
                      ? const Color(0xFFFF6B35) : const Color(0xFF888888),
                  widget.onToggleLock),
              _Ico(_expanded ? Icons.expand_less : Icons.expand_more,
                  const Color(0xFF666666),
                  () => setState(() => _expanded = !_expanded)),
            ]),
          ),
        ),
        if (_expanded) _buildExpanded(context),
      ]),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(color: Color(0xFF333333), height: 1),
        const SizedBox(height: 8),
        Row(children: [
          const Text('Opacité',
              style: TextStyle(color: Color(0xFF888888), fontSize: 11)),
          const SizedBox(width: 8),
          Expanded(child: Slider(
            value: widget.layer.opacity, min: 0.1, max: 1.0,
            activeColor: widget.layer.color,
            onChanged: widget.onOpacityChange,
          )),
          Text('${(widget.layer.opacity * 100).round()}%',
              style: const TextStyle(color: Color(0xFF888888), fontSize: 11)),
        ]),
        Row(children: [
          _ActionBtn('Renommer', Icons.edit,
              () => _showRename(context)),
          const SizedBox(width: 6),
          if (widget.onDelete != null)
            _ActionBtn('Supprimer', Icons.delete_outline,
                widget.onDelete!, color: const Color(0xFFFF4444)),
        ]),
      ]),
    );
  }

  void _showRename(BuildContext context) {
    final ctrl = TextEditingController(text: widget.layer.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Renommer', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl, autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4A9EFF))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4A9EFF))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler',
                  style: TextStyle(color: Color(0xFF888888)))),
          TextButton(
            onPressed: () { widget.onRename(ctrl.text); Navigator.pop(ctx); },
            child: const Text('OK',
                style: TextStyle(color: Color(0xFF4A9EFF))),
          ),
        ],
      ),
    );
  }
}

class _Ico extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Ico(this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Icon(icon, color: color, size: 16),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _ActionBtn(this.label, this.icon, this.onTap, {this.color});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color ?? const Color(0xFF888888)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(
            fontSize: 11, color: color ?? const Color(0xFF888888))),
      ]),
    ),
  );
}