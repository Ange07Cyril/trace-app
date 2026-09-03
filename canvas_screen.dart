import 'package:flutter/material.dart';
import '../state/canvas_state.dart';
import '../state/symbol_state.dart';
import '../state/dimension_state.dart';
import '../painters/drawing_painter.dart';
import '../painters/symbol_painter.dart';
import '../painters/dimension_painter.dart';
import '../widgets/drawing_toolbar.dart';
import '../widgets/layers_panel.dart';
import '../widgets/background_panel.dart';
import '../widgets/symbol_library_panel.dart';
import '../widgets/symbol_properties_bar.dart';
import '../widgets/dimension_toolbar.dart';
import '../widgets/dimension_hint.dart';
import '../models/arch_symbol.dart';
import '../models/project.dart';
import '../data/plan_templates.dart';
import '../services/import_service.dart';
import '../services/export_service.dart';
import '../services/dxf_export_service.dart';
import '../services/project_service.dart';

enum CanvasMode { draw, symbol, dimension }

class CanvasScreen extends StatefulWidget {
  final PlanTemplate? template;
  final String? projectTitle;
  final String? projectId;

  const CanvasScreen({
    super.key,
    this.template,
    this.projectTitle,
    this.projectId,
  });

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  late final CanvasState _state;
  late final SymbolState _symbolState;
  late final DimensionState _dimState;

  CanvasMode _mode = CanvasMode.draw;
  bool _showLayers = true;
  bool _showGrid = true;
  bool _isImporting = false;
  bool _isExporting = false;
  bool _isSaving = false;
  String _projectTitle = 'Sans titre';

  double _scale = 1.0, _prevScale = 1.0;
  Offset _offset = Offset.zero, _prevOffset = Offset.zero;
  bool _isPanning = false;
  String? _draggingSymbolId;
  Offset _dragStart = Offset.zero;
  Offset? _cursorPos;

  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _state = CanvasState();
    _symbolState = SymbolState();
    _dimState = DimensionState();
    _projectTitle = widget.projectTitle ?? 'Sans titre';
    _applyTemplate();
  }

  void _applyTemplate() {
    final tpl = widget.template;
    if (tpl == null) return;
    final layers = ProjectService.layersFromTemplate(tpl);
    if (layers.isNotEmpty) _state.applyLayers(layers);
  }

  @override
  void dispose() {
    _state.dispose();
    _symbolState.dispose();
    _dimState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: AnimatedBuilder(
        animation: Listenable.merge([_state, _symbolState, _dimState]),
        builder: (context, _) {
          final selectedSym = _symbolState.selectedSymbol;
          return Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Row(
                  children: [
                    if (_mode == CanvasMode.draw)
                      DrawingToolbar(state: _state)
                    else if (_mode == CanvasMode.symbol)
                      SymbolLibraryPanel(onSymbolSelected: _onSymbolSelected)
                    else
                      _buildDimSidePanel(),

                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: _buildCanvas()),
                          if (_mode == CanvasMode.symbol && selectedSym != null)
                            SymbolPropertiesBar(
                                symbol: selectedSym, state: _symbolState),
                          if (_mode == CanvasMode.dimension)
                            DimensionToolbar(state: _dimState),
                          BackgroundPanel(
                            background: _state.background,
                            pdfPages: _state.pdfPages,
                            activePage: _state.activePdfPage,
                            onBackgroundChanged: _state.setBackground,
                            onPageChanged: _state.goToPdfPage,
                            onImportPdf: _importPdf,
                            onImportImage: _importImage,
                          ),
                        ],
                      ),
                    ),
                    if (_showLayers) LayersPanel(state: _state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 鈹€鈹€ Top bar 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

  Widget _buildTopBar() {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFF151515),
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back_ios,
                color: Color(0xFF666666), size: 18),
          ),
          const SizedBox(width: 8),

          // Title (editable)
          GestureDetector(
            onTap: _editTitle,
            child: Text(_projectTitle, style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600,
            )),
          ),

          const SizedBox(width: 20),
          _ModeToggle(mode: _mode, onChanged: _switchMode),
          const Spacer(),

          // Scale badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(_dimState.scale.drawingScale, style: const TextStyle(
              color: Color(0xFFFFD93D), fontSize: 11, fontWeight: FontWeight.w700,
            )),
          ),

          const SizedBox(width: 8),
          Text('${(_scale * 100).round()}%',
              style: const TextStyle(color: Color(0xFF444444), fontSize: 11)),
          const Spacer(),

          if (_isImporting || _isExporting || _isSaving)
            const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFF4A9EFF)))
          else ...[
            _TopBarButton(icon: Icons.zoom_out_map,
                tooltip: 'R茅initialiser', onTap: _resetView),
            _TopBarButton(icon: Icons.grid_on, isActive: _showGrid,
                tooltip: 'Grille',
                onTap: () => setState(() => _showGrid = !_showGrid)),
            _TopBarButton(icon: Icons.layers, isActive: _showLayers,
                tooltip: 'Calques',
                onTap: () => setState(() => _showLayers = !_showLayers)),

            // Save
            _TopBarButton(icon: Icons.save_outlined,
                tooltip: 'Sauvegarder', onTap: _saveProject),

            const SizedBox(width: 4),
            _ExportMenu(
              onPng: _exportPng,
              onPdf: _exportPdf,
              onDxf: _exportDxf,
            ),
          ],
        ],
      ),
    );
  }

  // 鈹€鈹€ Dimension side panel 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

  Widget _buildDimSidePanel() {
    return Container(
      width: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(right: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _SideIcon(icon: Icons.straighten, label: 'Cote',
              isActive: _dimState.activeTool == DimensionTool.linearDim,
              onTap: () => _dimState.setTool(DimensionTool.linearDim)),
          _SideIcon(icon: Icons.call_made, label: 'Rep猫re',
              isActive: _dimState.activeTool == DimensionTool.leaderLine,
              onTap: () => _dimState.setTool(DimensionTool.leaderLine)),
          const Divider(color: Color(0xFF2A2A2A), height: 20),
          _SideIcon(icon: Icons.horizontal_rule, label: 'Guide H',
              isActive: _dimState.activeTool == DimensionTool.guideH,
              onTap: () => _dimState.setTool(DimensionTool.guideH)),
          _SideIcon(icon: Icons.vertical_distribute, label: 'Guide V',
              isActive: _dimState.activeTool == DimensionTool.guideV,
              onTap: () => _dimState.setTool(DimensionTool.guideV)),
        ],
      ),
    );
  }

  // 鈹€鈹€ Canvas 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

  Widget _buildCanvas() {
    return ClipRect(
      child: MouseRegion(
        onHover: (e) {
          if (_mode == CanvasMode.dimension && _dimState.awaitingSecondPoint) {
            setState(() => _cursorPos = _toCanvas(e.localPosition));
          }
        },
        child: GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          onTapDown: _onTapDown,
          child: Transform(
            transform: Matrix4.identity()
              ..translate(_offset.dx, _offset.dy)
              ..scale(_scale),
            child: RepaintBoundary(
              key: _repaintKey,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: DrawingPainter(
                      layers: _state.layers,
                      activeStroke: _state.activeStroke,
                      background: _state.background,
                      backgroundImage: _state.backgroundImage,
                      showGrid: _showGrid,
                    ),
                    child: Container(color: const Color(0xFF252525)),
                  ),
                  CustomPaint(painter: SymbolPainter(
                    symbols: _symbolState.symbols,
                    selectedId: _symbolState.selectedSymbolId,
                  )),
                  CustomPaint(painter: DimensionPainter(
                    state: _dimState,
                    cursorPos: _cursorPos,
                  )),
                  DimensionHint(state: _dimState),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 鈹€鈹€ Gestures 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

  void _onScaleStart(ScaleStartDetails d) {
    _prevScale = _scale; _prevOffset = _offset;
    if (d.pointerCount >= 2) { _isPanning = true; _state.endStroke(); return; }
    _isPanning = false;
    final pos = _toCanvas(d.localFocalPoint);
    if (_mode == CanvasMode.draw) {
      _state.startStroke(pos);
    } else if (_mode == CanvasMode.symbol) {
      final hit = _symbolState.hitTest(pos);
      if (hit != null) {
        _symbolState.selectSymbol(hit.id);
        _draggingSymbolId = hit.id; _dragStart = pos;
      } else {
        _symbolState.deselectAll(); _draggingSymbolId = null;
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (_isPanning || d.pointerCount >= 2) {
      setState(() {
        _scale = (_prevScale * d.scale).clamp(0.15, 8.0);
        _offset = _prevOffset + d.focalPointDelta;
      });
      return;
    }
    final pos = _toCanvas(d.localFocalPoint);
    if (_mode == CanvasMode.draw) {
      _state.addPoint(pos);
    } else if (_mode == CanvasMode.symbol && _draggingSymbolId != null) {
      _symbolState.moveSymbol(_draggingSymbolId!, pos - _dragStart);
      _dragStart = pos;
    } else if (_mode == CanvasMode.dimension) {
      setState(() => _cursorPos = pos);
    }
  }

  void _onScaleEnd(ScaleEndDetails _) {
    if (_isPanning) { _isPanning = false; return; }
    if (_mode == CanvasMode.draw) _state.endStroke();
    _draggingSymbolId = null;
  }

  void _onTapDown(TapDownDetails d) {
    if (_mode == CanvasMode.dimension) {
      _dimState.onCanvasTap(_toCanvas(d.localPosition));
      setState(() => _cursorPos = null);
    }
  }

  // 鈹€鈹€ Helpers 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

  Offset _toCanvas(Offset p) => (p - _offset) / _scale;
  void _resetView() => setState(() { _scale = 1.0; _offset = Offset.zero; });

  void _switchMode(CanvasMode m) {
    setState(() => _mode = m);
    if (m != CanvasMode.symbol) _symbolState.deselectAll();
    if (m != CanvasMode.dimension) _dimState.cancelTool();
  }

  void _onSymbolSelected(ArchSymbol sym) {
    final s = MediaQuery.of(context).size;
    _symbolState.placeSymbol(sym, Offset(
      (s.width / 2 - _offset.dx) / _scale,
      (s.height / 2 - _offset.dy) / _scale,
    ));
  }

  void _editTitle() {
    final ctrl = TextEditingController(text: _projectTitle);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Renommer', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl, autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            filled: true, fillColor: Color(0xFF333333),
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler',
                  style: TextStyle(color: Color(0xFF888888)))),
          TextButton(
            onPressed: () {
              setState(() => _projectTitle = ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF4A9EFF))),
          ),
        ],
      ),
    );
  }

  // 鈹€鈹€ Save 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

  Future<void> _saveProject() async {
    setState(() => _isSaving = true);
    try {
      await ProjectService.saveProject(
        state: _state,
        title: _projectTitle,
        existingId: widget.projectId,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projet sauvegard茅 鉁�'),
            backgroundColor: Color(0xFF2A3A2A)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // 鈹€鈹€ Import 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

  Future<void> _importPdf() async {
    setState(() => _isImporting = true);
    try {
      final pages = await ImportService.importPdf();
      if (pages.isNotEmpty) await _state.setPdfPages(pages);
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _importImage() async {
    setState(() => _isImporting = true);
    try {
      final bg = await ImportService.importImage();
      if (bg != null) await _state.setBackground(bg);
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  // 鈹€鈹€ Export 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

  Future<void> _exportPng() async {
    setState(() => _isExporting = true);
    try {
      final bytes = await ExportService.captureAsPng(_repaintKey);
      if (bytes != null) await ExportService.shareFile(
          bytes, ExportService.timestampedName('trace', 'png'), 'image/png');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      final png = await ExportService.captureAsPng(_repaintKey);
      final pdf = await ExportService.exportAsPdf(png);
      if (pdf != null) await ExportService.shareFile(
          pdf, ExportService.timestampedName('trace', 'pdf'), 'application/pdf');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportDxf() async {
    setState(() => _isExporting = true);
    try {
      final bytes = DxfExportService.export(
        layers: _state.layers,
        symbols: _symbolState.symbols,
        dimensions: _dimState.dimensions,
        scale: _dimState.scale,
        title: _projectTitle,
      );
      await ExportService.shareFile(
          bytes,
          ExportService.timestampedName(_projectTitle, 'dxf'),
          'application/dxf');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export DXF pr锚t 鈥� compatible AutoCAD / FreeCAD'),
            backgroundColor: Color(0xFF2A2A2A)),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

// 鈹€鈹€ Widgets helpers 鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€鈹€

class _ModeToggle extends StatelessWidget {
  final CanvasMode mode;
  final Function(CanvasMode) onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(children: [
        _ModeTab('Dessin', Icons.edit_outlined,
            mode == CanvasMode.draw, () => onChanged(CanvasMode.draw)),
        _ModeTab('Symboles', Icons.chair_outlined,
            mode == CanvasMode.symbol, () => onChanged(CanvasMode.symbol)),
        _ModeTab('Cotes', Icons.straighten,
            mode == CanvasMode.dimension, () => onChanged(CanvasMode.dimension)),
      ]),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const _ModeTab(this.label, this.icon, this.isActive, this.onTap);

  @override
  Widget build(BuildContext context) {
    final c = isActive ? const Color(0xFF4A9EFF) : const Color(0xFF555555);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E3A5A) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: c, fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    );
  }
}

class _SideIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _SideIcon({required this.icon, required this.label,
      required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 44, height: 44,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E3A5A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18,
              color: isActive ? const Color(0xFF4A9EFF) : const Color(0xFF666666)),
          Text(label, style: TextStyle(fontSize: 7,
              color: isActive ? const Color(0xFF4A9EFF) : const Color(0xFF555555))),
        ]),
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;
  const _TopBarButton({required this.icon, required this.tooltip,
      required this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2A3A4A) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 18,
              color: isActive ? const Color(0xFF4A9EFF) : const Color(0xFF888888)),
        ),
      ),
    );
  }
}

class _ExportMenu extends StatelessWidget {
  final VoidCallback onPng, onPdf, onDxf;
  const _ExportMenu({required this.onPng, required this.onPdf, required this.onDxf});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF333333))),
      onSelected: (v) {
        if (v == 'png') onPng();
        if (v == 'pdf') onPdf();
        if (v == 'dxf') onDxf();
      },
      itemBuilder: (_) => [
        _menuItem('png', Icons.image_outlined, 'PNG haute r茅solution',
            const Color(0xFF50E3A4)),
        _menuItem('pdf', Icons.picture_as_pdf_outlined, 'PDF imprimable',
            const Color(0xFFFF6B35)),
        _menuItem('dxf', Icons.architecture, 'DXF 鈥� AutoCAD / FreeCAD',
            const Color(0xFFFFD93D)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF4A9EFF).withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: const Color(0xFF4A9EFF).withOpacity(0.4)),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.ios_share, size: 14, color: Color(0xFF4A9EFF)),
          SizedBox(width: 5),
          Text('Exporter', style: TextStyle(
            color: Color(0xFF4A9EFF), fontSize: 12, fontWeight: FontWeight.w600,
          )),
          SizedBox(width: 3),
          Icon(Icons.expand_more, size: 13, color: Color(0xFF4A9EFF)),
        ]),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String val, IconData icon, String label, Color c) {
    return PopupMenuItem(
      value: val,
      child: Row(children: [
        Icon(icon, color: c, size: 18),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ]),
    );
  }
}