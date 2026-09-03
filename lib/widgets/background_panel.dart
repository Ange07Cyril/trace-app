import 'package:flutter/material.dart';
import '../models/canvas_background.dart';

class BackgroundPanel extends StatelessWidget {
  final CanvasBackground? background;
  final List<CanvasBackground> pdfPages;
  final int activePage;
  final Function(CanvasBackground?) onBackgroundChanged;
  final Function(int) onPageChanged;
  final VoidCallback onImportPdf;
  final VoidCallback onImportImage;

  const BackgroundPanel({
    super.key, required this.background, required this.pdfPages,
    required this.activePage, required this.onBackgroundChanged,
    required this.onPageChanged, required this.onImportPdf,
    required this.onImportImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(top: BorderSide(color: Color(0xFF333333))),
      ),
      child: Column(children: [
        _buildHeader(),
        if (background == null)
          _buildImportButtons()
        else
          _buildControls(context),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF242424),
        border: Border(bottom: BorderSide(color: Color(0xFF333333))),
      ),
      child: Row(children: [
        const Text('FOND', style: TextStyle(
          color: Color(0xFF888888), fontSize: 11,
          fontWeight: FontWeight.w600, letterSpacing: 1.2,
        )),
        if (background != null) ...[
          const SizedBox(width: 8),
          Expanded(child: Text(background!.fileName,
              style: const TextStyle(color: Color(0xFF555555), fontSize: 10),
              overflow: TextOverflow.ellipsis)),
          GestureDetector(
            onTap: () => onBackgroundChanged(null),
            child: const Icon(Icons.close, color: Color(0xFF666666), size: 16),
          ),
        ],
      ]),
    );
  }

  Widget _buildImportButtons() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(children: [
        Expanded(child: _ImportBtn(
          icon: Icons.picture_as_pdf_outlined, label: 'PDF',
          color: const Color(0xFFFF6B35), onTap: onImportPdf,
        )),
        const SizedBox(width: 8),
        Expanded(child: _ImportBtn(
          icon: Icons.image_outlined, label: 'Image',
          color: const Color(0xFF50E3A4), onTap: onImportImage,
        )),
      ]),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        if (pdfPages.length > 1) ...[
          Text('Page ${activePage + 1} / ${pdfPages.length}',
              style: const TextStyle(color: Color(0xFF888888), fontSize: 11)),
          const SizedBox(height: 6),
        ],
        Row(children: [
          const Text('Opacité',
              style: TextStyle(color: Color(0xFF888888), fontSize: 11)),
          const SizedBox(width: 6),
          Expanded(child: Slider(
            value: background!.opacity, min: 0.1, max: 1.0,
            activeColor: const Color(0xFFFF6B35),
            onChanged: (v) => onBackgroundChanged(background!.copyWith(opacity: v)),
          )),
          Text('${(background!.opacity * 100).round()}%',
              style: const TextStyle(color: Color(0xFF888888), fontSize: 10)),
        ]),
        Row(children: [
          const Text('Échelle',
              style: TextStyle(color: Color(0xFF888888), fontSize: 11)),
          const SizedBox(width: 6),
          Expanded(child: Slider(
            value: background!.scale, min: 0.3, max: 3.0,
            activeColor: const Color(0xFF4A9EFF),
            onChanged: (v) => onBackgroundChanged(background!.copyWith(scale: v)),
          )),
          Text('${(background!.scale * 100).round()}%',
              style: const TextStyle(color: Color(0xFF888888), fontSize: 10)),
        ]),
      ]),
    );
  }
}

class _ImportBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ImportBtn({required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11,
            fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}