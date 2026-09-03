import 'package:flutter/material.dart';

class ColorPickerSheet extends StatefulWidget {
  final Color currentColor;
  final Function(Color) onColorSelected;

  const ColorPickerSheet({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  late Color _selected;

  static const _palette = [
    Color(0xFF000000), Color(0xFF1A1A1A), Color(0xFF333333),
    Color(0xFF555555), Color(0xFF888888), Color(0xFFAAAAAA),
    Color(0xFFCCCCCC), Color(0xFFE5E5E5), Color(0xFFFFFFFF),
    Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF4A9EFF),
    Color(0xFF90CAF9), Color(0xFF1B5E20), Color(0xFF388E3C),
    Color(0xFF50E3A4), Color(0xFFB71C1C), Color(0xFFE53935),
    Color(0xFFFF6B35), Color(0xFFFFAB91), Color(0xFFF57F17),
    Color(0xFFFFD93D), Color(0xFF4A148C), Color(0xFF9C27B0),
    Color(0xFFCE93D8), Color(0xFFFF6B9D), Color(0xFF8D6E63),
    Color(0xFFBCAAA4), Color(0xFF546E7A), Color(0xFFB0BEC5),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            const Text('Couleur', style: TextStyle(
                color: Colors.white, fontSize: 16,
                fontWeight: FontWeight.w600)),
            const Spacer(),
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _selected,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 9,
              mainAxisSpacing: 6, crossAxisSpacing: 6,
            ),
            itemCount: _palette.length,
            itemBuilder: (ctx, i) {
              final color = _palette[i];
              final isSelected = _selected.value == color.value;
              return GestureDetector(
                onTap: () => setState(() => _selected = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white12,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onColorSelected(_selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A9EFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Appliquer',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}