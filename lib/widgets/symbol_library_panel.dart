import 'package:flutter/material.dart';
import '../models/arch_symbol.dart';
import '../data/symbol_library.dart';
import '../painters/symbol_painter.dart';

class SymbolLibraryPanel extends StatefulWidget {
  final Function(ArchSymbol) onSymbolSelected;
  const SymbolLibraryPanel({super.key, required this.onSymbolSelected});

  @override
  State<SymbolLibraryPanel> createState() => _SymbolLibraryPanelState();
}

class _SymbolLibraryPanelState extends State<SymbolLibraryPanel> {
  SymbolCategory? _activeCategory;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  List<ArchSymbol> get _filtered {
    if (_searchQuery.isNotEmpty) return SymbolLibrary.search(_searchQuery);
    if (_activeCategory != null) return SymbolLibrary.byCategory(_activeCategory!);
    return SymbolLibrary.all;
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(right: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Column(children: [
        _buildHeader(),
        _buildSearch(),
        if (_searchQuery.isEmpty) _buildCategoryBar(),
        Expanded(child: _buildGrid()),
      ]),
    );
  }

  Widget _buildHeader() => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: const BoxDecoration(
      color: Color(0xFF222222),
      border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
    ),
    child: Row(children: [
      const Text('SYMBOLES', style: TextStyle(
        color: Color(0xFF888888), fontSize: 11,
        fontWeight: FontWeight.w700, letterSpacing: 1.2,
      )),
      const Spacer(),
      Text('${_filtered.length}',
          style: const TextStyle(color: Color(0xFF444444), fontSize: 11)),
    ]),
  );

  Widget _buildSearch() => Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
    child: TextField(
      controller: _searchCtrl,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Chercher…',
        hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 13),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF555555), size: 18),
        suffixIcon: _searchQuery.isNotEmpty
            ? GestureDetector(
                onTap: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); },
                child: const Icon(Icons.close, color: Color(0xFF555555), size: 16))
            : null,
        filled: true, fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      onChanged: (v) => setState(() => _searchQuery = v),
    ),
  );

  Widget _buildCategoryBar() => SizedBox(
    height: 70,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      children: [
        _CatChip('Tous', Icons.apps, _activeCategory == null,
            () => setState(() => _activeCategory = null)),
        ...SymbolCategory.values.map((cat) => _CatChip(
          cat.label, cat.icon, _activeCategory == cat,
          () => setState(() =>
              _activeCategory = _activeCategory == cat ? null : cat),
        )),
      ],
    ),
  );

  Widget _buildGrid() {
    final symbols = _filtered;
    if (symbols.isEmpty) return const Center(
      child: Text('Aucun symbole',
          style: TextStyle(color: Color(0xFF444444))),
    );
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6,
      ),
      itemCount: symbols.length,
      itemBuilder: (ctx, i) => _SymCard(
        symbol: symbols[i],
        onTap: () => widget.onSymbolSelected(symbols[i]),
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const _CatChip(this.label, this.icon, this.isActive, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E3A5A) : const Color(0xFF252525),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isActive ? const Color(0xFF4A9EFF) : const Color(0xFF333333)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16,
            color: isActive ? const Color(0xFF4A9EFF) : const Color(0xFF888888)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(
          color: isActive ? const Color(0xFF4A9EFF) : const Color(0xFF888888),
          fontSize: 9,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        )),
      ]),
    ),
  );
}

class _SymCard extends StatefulWidget {
  final ArchSymbol symbol;
  final VoidCallback onTap;
  const _SymCard({required this.symbol, required this.onTap});
  @override
  State<_SymCard> createState() => _SymCardState();
}

class _SymCardState extends State<_SymCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    onTapDown: (_) => setState(() => _pressed = true),
    onTapUp: (_) => setState(() => _pressed = false),
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        color: _pressed ? const Color(0xFF1E3A5A) : const Color(0xFF242424),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: _pressed ? const Color(0xFF4A9EFF) : const Color(0xFF333333)),
      ),
      child: Column(children: [
        Expanded(child: Padding(
          padding: const EdgeInsets.all(4),
          child: CustomPaint(
            painter: SymbolPreviewPainter(
              symbol: widget.symbol,
              color: _pressed ? const Color(0xFF4A9EFF) : const Color(0xFFCCCCCC),
            ),
            size: Size.infinite,
          ),
        )),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: Text(widget.symbol.name,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 9),
            textAlign: TextAlign.center, maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    ),
  );
}