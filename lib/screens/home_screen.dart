import 'package:flutter/material.dart';
import '../models/project.dart';
import '../data/plan_templates.dart';
import '../services/project_service.dart';
import 'canvas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<ProjectMeta> _projects = [];
  bool _loading = true;
  String _templateFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadProjects();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    final list = await ProjectService.loadIndex();
    if (mounted) setState(() { _projects = list; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Column(children: [
        _buildHeader(),
        _buildTabBar(),
        Expanded(child: TabBarView(
          controller: _tab,
          children: [
            _buildProjectsTab(),
            _buildTemplatesTab(),
          ],
        )),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF151515),
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A9EFF), Color(0xFF0044CC)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.architecture, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TRACE', style: TextStyle(
            color: Colors.white, fontSize: 20,
            fontWeight: FontWeight.w900, letterSpacing: 4,
          )),
          Text('Architecture Drawing', style: TextStyle(
            color: Color(0xFF555555), fontSize: 11, letterSpacing: 1,
          )),
        ]),
        const Spacer(),
        GestureDetector(
          onTap: _newBlankProject,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A9EFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(children: [
              Icon(Icons.add, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text('Nouveau', style: TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600,
              )),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF151515),
      child: TabBar(
        controller: _tab,
        labelColor: const Color(0xFF4A9EFF),
        unselectedLabelColor: const Color(0xFF555555),
        indicatorColor: const Color(0xFF4A9EFF),
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(text: 'Mes projets'),
          Tab(text: 'Templates'),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    if (_loading) return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4A9EFF)));
    if (_projects.isEmpty) return _buildEmptyProjects();
    return RefreshIndicator(
      onRefresh: _loadProjects,
      color: const Color(0xFF4A9EFF),
      backgroundColor: const Color(0xFF1E1E1E),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _projects.length,
        itemBuilder: (ctx, i) => _ProjectCard(
          project: _projects[i],
          onTap: () => _openProject(_projects[i]),
          onDelete: () => _deleteProject(_projects[i]),
        ),
      ),
    );
  }

  Widget _buildEmptyProjects() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.folder_open_outlined,
          size: 64, color: Color(0xFF333333)),
      const SizedBox(height: 16),
      const Text('Aucun projet',
          style: TextStyle(color: Color(0xFF555555), fontSize: 16)),
      const SizedBox(height: 8),
      const Text('Créez votre premier plan',
          style: TextStyle(color: Color(0xFF444444), fontSize: 13)),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: () => _tab.animateTo(1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A5A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: const Color(0xFF4A9EFF).withOpacity(0.5)),
          ),
          child: const Text('Choisir un template',
              style: TextStyle(color: Color(0xFF4A9EFF),
                  fontWeight: FontWeight.w600)),
        ),
      ),
    ]));
  }

  Widget _buildTemplatesTab() {
    final cats = PlanTemplates.categories;
    final filtered = _templateFilter == 'all'
        ? PlanTemplates.all
        : PlanTemplates.byCategory(_templateFilter);

    return Column(children: [
      SizedBox(
        height: 52,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: cats.map((c) {
            final isActive = _templateFilter == c.$1;
            return GestureDetector(
              onTap: () => setState(() => _templateFilter = c.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF1E3A5A)
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF4A9EFF)
                        : const Color(0xFF2A2A2A),
                  ),
                ),
                child: Row(children: [
                  Icon(c.$3, size: 14,
                      color: isActive
                          ? const Color(0xFF4A9EFF)
                          : const Color(0xFF666666)),
                  const SizedBox(width: 6),
                  Text(c.$2, style: TextStyle(
                    color: isActive
                        ? const Color(0xFF4A9EFF)
                        : const Color(0xFF666666),
                    fontSize: 12,
                    fontWeight: isActive
                        ? FontWeight.w600 : FontWeight.normal,
                  )),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
      Expanded(child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12,
          crossAxisSpacing: 12, childAspectRatio: 0.85,
        ),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => _TemplateCard(
          template: filtered[i],
          onTap: () => _openFromTemplate(filtered[i]),
        ),
      )),
    ]);
  }

  void _newBlankProject() => _openFromTemplate(
      PlanTemplates.all.firstWhere((t) => t.id == 'blank'));

  void _openFromTemplate(PlanTemplate template) {
    final ctrl = TextEditingController(
        text: template.id == 'blank' ? '' : template.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Nouveau projet',
            style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (template.id != 'blank') ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: template.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: template.color.withOpacity(0.3)),
              ),
              child: Row(children: [
                Icon(template.icon, color: template.color, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(template.description,
                    style: const TextStyle(
                        color: Color(0xFFAAAAAA), fontSize: 12))),
              ]),
            ),
            const SizedBox(height: 14),
            Text('${template.layers.length} calques pré-configurés',
                style: const TextStyle(
                    color: Color(0xFF666666), fontSize: 11)),
            const SizedBox(height: 14),
          ],
          const Text('Nom du projet',
              style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl, autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Mon plan…',
              hintStyle: TextStyle(color: Color(0xFF444444)),
              filled: true, fillColor: Color(0xFF2A2A2A),
              border: OutlineInputBorder(borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler',
                  style: TextStyle(color: Color(0xFF666666)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CanvasScreen(
                  template: template,
                  projectTitle: ctrl.text.isNotEmpty
                      ? ctrl.text : template.name,
                ),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A9EFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _openProject(ProjectMeta project) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CanvasScreen(projectId: project.id),
    ));
  }

  Future<void> _deleteProject(ProjectMeta project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Supprimer',
            style: TextStyle(color: Colors.white)),
        content: Text('Supprimer « ${project.title} » ?',
            style: const TextStyle(color: Color(0xFFAAAAAA))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler',
                  style: TextStyle(color: Color(0xFF666666)))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer',
                  style: TextStyle(color: Color(0xFFFF4444)))),
        ],
      ),
    );
    if (confirm == true) {
      await ProjectService.deleteProject(project.id);
      await _loadProjects();
    }
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectMeta project;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _ProjectCard({required this.project,
      required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined,
                color: Color(0xFF4A9EFF), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.title, style: const TextStyle(
                color: Colors.white, fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 3),
              Text(_relativeDate(project.updatedAt),
                  style: const TextStyle(
                      color: Color(0xFF555555), fontSize: 12)),
            ],
          )),
          GestureDetector(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.delete_outline,
                  color: Color(0xFF444444), size: 18),
            ),
          ),
        ]),
      ),
    );
  }

  String _relativeDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _TemplateCard extends StatelessWidget {
  final PlanTemplate template;
  final VoidCallback onTap;
  const _TemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(children: [
          Expanded(child: Container(
            decoration: BoxDecoration(
              color: template.color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(13)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(template.icon, color: template.color, size: 40),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: template.layers.take(6).map((l) =>
                    Container(
                      width: 8, height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                          color: l.color, shape: BoxShape.circle),
                    ),
                  ).toList(),
                ),
              ],
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.name, style: const TextStyle(
                  color: Colors.white, fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 3),
                Text('${template.layers.length} calques',
                    style: const TextStyle(
                        color: Color(0xFF555555), fontSize: 11)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}