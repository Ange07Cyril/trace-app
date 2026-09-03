import 'package:flutter/material.dart';
import '../state/dimension_state.dart';
import '../models/dimension.dart';

class DimensionToolbar extends StatelessWidget {
  final DimensionState state;
  const DimensionToolbar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFF181818),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Row(children: [
        const SizedBox(width: 12),
        const Text('COTES', style: TextStyle(
          color: Color(0xFF555555), fontSize: 10,
          fontWeight: FontWeight.w700, letterSpacing: 1.2,
        )),
        const SizedBox(width: 16),
        _Sep(),
        _Btn(Icons.straighten, 'Cote',
            state.activeTool == DimensionTool.linearDim,
            () => state.setTool(DimensionTool.linearDim)),
        _Btn(Icons.call_made, 'Repère',
            state.activeTool == DimensionTool.leaderLine,
            () => state.setTool(DimensionTool.leaderLine)),
        _Sep(),
        _Btn(Icons.horizontal_rule, 'Guide H',
            state.activeTool == DimensionTool.guideH,
            () => state.setTool(DimensionTool.guideH)),
        _Btn(Icons.vertical_distribute, 'Guide V',
            state.activeTool == DimensionTool.guideV,
            () => state.setTool(DimensionTool.guideV)),
        _Sep(),
        _Toggle(Icons.rule, 'Règle', state.showRuler, state.toggleRuler),
        _Toggle(Icons.grid_4x4, 'Guides', state.showGuides, state.toggleGuides),
        _Toggle(Icons.straighten_outlined, 'Cotes',
            state.showDimensions, state.toggleDimensions),
        _Sep(),
        _ScaleBtn(state: state),
        const Spacer(),
        if (state.selectedId != null)
          _Btn(Icons.delete_outline, 'Supprimer', false,
              state.deleteSelected, color: const Color(0xFFFF4444)),
        _Btn(Icons.clear_all, 'Effacer guides', false,
            state.clearAllGuides, color: const Color(0xFF888888)),
        const SizedBox(width: 8),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? color;
  const _Btn(this.icon, this.label, this.isActive, this.onTap, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isActive ? const Color(0xFF4A9EFF) : const Color(0xFF888888));
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E3A5A) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: c, fontSize: 8)),
        ]),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOn;
  final VoidCallback onTap;
  const _Toggle(this.icon, this.label, this.isOn, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15,
            color: isOn ? const Color(0xFF50E3A4) : const Color(0xFF444444)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(
            color: isOn ? const Color(0xFF50E3A4) : const Color(0xFF444444),
            fontSize: 8)),
      ]),
    ),
  );
}

class _ScaleBtn extends StatelessWidget {
  final DimensionState state;
  const _ScaleBtn({required this.state});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Échelle du dessin', style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          ...ScaleConfig.presets.map((cfg) {
            final isActive = state.scale.drawingScale == cfg.drawingScale;
            return GestureDetector(
              onTap: () { state.setScale(cfg); Navigator.pop(ctx); },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF1E3A5A) : const Color(0xFF242424),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive ? const Color(0xFF4A9EFF) : const Color(0xFF333333),
                  ),
                ),
                child: Row(children: [
                  Text(cfg.drawingScale, style: TextStyle(
                    color: isActive ? const Color(0xFF4A9EFF) : Colors.white,
                    fontSize: 16, fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(width: 16),
                  Text('1 px = ${cfg.format(1)}',
                      style: const TextStyle(
                          color: Color(0xFF888888), fontSize: 12)),
                  const Spacer(),
                  if (isActive) const Icon(Icons.check_circle,
                      color: Color(0xFF4A9EFF), size: 18),
                ]),
              ),
            );
          }),
        ]),
      ),
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.zoom_in_map, size: 13, color: Color(0xFFFFD93D)),
        const SizedBox(width: 5),
        Text(state.scale.drawingScale, style: const TextStyle(
          color: Color(0xFFFFD93D), fontSize: 12, fontWeight: FontWeight.w700,
        )),
        const SizedBox(width: 4),
        const Icon(Icons.expand_more, size: 13, color: Color(0xFF888888)),
      ]),
    ),
  );
}

class _Sep extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 28, color: const Color(0xFF2A2A2A),
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}