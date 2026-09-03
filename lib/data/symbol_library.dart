import '../models/arch_symbol.dart';

class SymbolLibrary {
  static const List<ArchSymbol> all = [
    // ── MOBILIER ──
    ArchSymbol(
      id: 'sofa_2p', name: 'Canapé 2 places',
      category: SymbolCategory.furniture, baseSize: Size(100, 60),
      paths: [
        SymbolPath(svgD: 'M5,20 L5,55 L95,55 L95,20 Z', filled: true),
        SymbolPath(svgD: 'M5,20 L5,55 L18,55 L18,20 Z', filled: true),
        SymbolPath(svgD: 'M82,20 L82,55 L95,55 L95,20 Z', filled: true),
        SymbolPath(svgD: 'M5,20 L95,20 L95,10 L5,10 Z', filled: true),
        SymbolPath(svgD: 'M50,20 L50,55', strokeWidth: 1.0),
      ],
    ),
    ArchSymbol(
      id: 'sofa_3p', name: 'Canapé 3 places',
      category: SymbolCategory.furniture, baseSize: Size(140, 60),
      paths: [
        SymbolPath(svgD: 'M5,20 L5,55 L135,55 L135,20 Z', filled: true),
        SymbolPath(svgD: 'M5,20 L5,55 L18,55 L18,20 Z', filled: true),
        SymbolPath(svgD: 'M122,20 L122,55 L135,55 L135,20 Z', filled: true),
        SymbolPath(svgD: 'M5,20 L135,20 L135,10 L5,10 Z', filled: true),
        SymbolPath(svgD: 'M51.67,20 L51.67,55', strokeWidth: 1.0),
        SymbolPath(svgD: 'M88.33,20 L88.33,55', strokeWidth: 1.0),
      ],
    ),
    ArchSymbol(
      id: 'armchair', name: 'Fauteuil',
      category: SymbolCategory.furniture, baseSize: Size(70, 70),
      paths: [
        SymbolPath(svgD: 'M10,25 L10,60 L60,60 L60,25 Z', filled: true),
        SymbolPath(svgD: 'M10,25 L10,60 L22,60 L22,25 Z', filled: true),
        SymbolPath(svgD: 'M48,25 L48,60 L60,60 L60,25 Z', filled: true),
        SymbolPath(svgD: 'M10,25 L60,25 L60,15 L10,15 Z', filled: true),
      ],
    ),
    ArchSymbol(
      id: 'bed_single', name: 'Lit simple',
      category: SymbolCategory.furniture, baseSize: Size(90, 200),
      paths: [
        SymbolPath(svgD: 'M5,5 L85,5 L85,195 L5,195 Z', strokeWidth: 2.0),
        SymbolPath(svgD: 'M5,5 L85,5 L85,35 L5,35 Z', filled: true),
        SymbolPath(svgD: 'M15,45 L75,45 L75,75 L15,75 Z', strokeWidth: 1.2),
        SymbolPath(svgD: 'M5,75 L85,75 L85,195 L5,195 Z', filled: true, strokeWidth: 1.0),
      ],
    ),
    ArchSymbol(
      id: 'bed_double', name: 'Lit double',
      category: SymbolCategory.furniture, baseSize: Size(160, 200),
      paths: [
        SymbolPath(svgD: 'M5,5 L155,5 L155,195 L5,195 Z', strokeWidth: 2.0),
        SymbolPath(svgD: 'M5,5 L155,5 L155,35 L5,35 Z', filled: true),
        SymbolPath(svgD: 'M15,45 L73,45 L73,75 L15,75 Z', strokeWidth: 1.2),
        SymbolPath(svgD: 'M87,45 L145,45 L145,75 L87,75 Z', strokeWidth: 1.2),
        SymbolPath(svgD: 'M5,75 L155,75 L155,195 L5,195 Z', filled: true, strokeWidth: 1.0),
        SymbolPath(svgD: 'M80,35 L80,195', strokeWidth: 0.8),
      ],
    ),
    ArchSymbol(
      id: 'table_rect', name: 'Table rectangulaire',
      category: SymbolCategory.furniture, baseSize: Size(120, 80),
      paths: [
        SymbolPath(svgD: 'M10,10 L110,10 L110,70 L10,70 Z', strokeWidth: 2.0),
        SymbolPath(svgD: 'M20,2 L40,2 L40,10 L20,10 Z', filled: true, strokeWidth: 1.0),
        SymbolPath(svgD: 'M60,2 L80,2 L80,10 L60,10 Z', filled: true, strokeWidth: 1.0),
        SymbolPath(svgD: 'M20,70 L40,70 L40,78 L20,78 Z', filled: true, strokeWidth: 1.0),
        SymbolPath(svgD: 'M60,70 L80,70 L80,78 L60,78 Z', filled: true, strokeWidth: 1.0),
        SymbolPath(svgD: 'M2,15 L10,15 L10,35 L2,35 Z', filled: true, strokeWidth: 1.0),
        SymbolPath(svgD: 'M110,15 L118,15 L118,35 L110,35 Z', filled: true, strokeWidth: 1.0),
      ],
    ),
    ArchSymbol(
      id: 'table_round', name: 'Table ronde',
      category: SymbolCategory.furniture, baseSize: Size(100, 100),
      paths: [
        SymbolPath(svgD: 'M50,5 A45,45 0 1,1 49.9,5 Z', strokeWidth: 2.0),
        SymbolPath(svgD: 'M50,15 A35,35 0 1,1 49.9,15 Z', strokeWidth: 0.8),
      ],
    ),
    ArchSymbol(
      id: 'desk', name: 'Bureau',
      category: SymbolCategory.furniture, baseSize: Size(140, 70),
      paths: [
        SymbolPath(svgD: 'M5,5 L135,5 L135,65 L5,65 Z', strokeWidth: 2.0),
        SymbolPath(svgD: 'M5,5 L45,5 L45,65', strokeWidth: 1.5),
        SymbolPath(svgD: 'M55,30 L125,30', strokeWidth: 1.0),
        SymbolPath(svgD: 'M55,40 L125,40', strokeWidth: 1.0),
      ],
    ),
    ArchSymbol(
      id: 'wardrobe', name: 'Armoire',
      category: SymbolCategory.furniture, baseSize: Size(120, 60),
      paths: [
        SymbolPath(svgD: 'M5,5 L115,5 L115,55 L5,55 Z', strokeWidth: 2.0),
        SymbolPath(svgD: 'M60,5 L60,55', strokeWidth: 1.5),
        SymbolPath(svgD: 'M52,28 L52,32', strokeWidth: 2.0),
        SymbolPath(svgD: 'M68,28 L68,32', strokeWidth: 2.0),
        SymbolPath(svgD: 'M5,5 L60,55', strokeWidth: 0.5),
        SymbolPath(svgD: 'M60,5 L115,55', strokeWidth: 0.5),
      ],
    ),
    // ── PORTES ──
    ArchSymbol(
      id: 'door_single', name: 'Porte simple',
      category: SymbolCategory.doors, baseSize: Size(90, 90),
      paths: [
        SymbolPath(svgD: 'M0,0 L15,0 L15,90 L0,90 Z', filled: true),
        SymbolPath(svgD: 'M15,0 L15,80', strokeWidth: 2.0),
        SymbolPath(svgD: 'M15,80 A80,80 0 0,0 95,0', strokeWidth: 1.5),
        SymbolPath(svgD: 'M15,0 L95,0', strokeWidth: 0.5),
      ],
    ),
    ArchSymbol(
      id: 'door_double', name: 'Porte double',
      category: SymbolCategory.doors, baseSize: Size(160, 90),
      paths: [
        SymbolPath(svgD: 'M0,0 L15,0 L15,90 L0,90 Z', filled: true),
        SymbolPath(svgD: 'M145,0 L160,0 L160,90 L145,90 Z', filled: true),
        SymbolPath(svgD: 'M15,0 L15,80', strokeWidth: 2.0),
        SymbolPath(svgD: 'M145,0 L145,80', strokeWidth: 2.0),
        SymbolPath(svgD: 'M15,80 A80,80 0 0,0 95,0', strokeWidth: 1.5),
        SymbolPath(svgD: 'M145,80 A80,80 0 0,1 65,0', strokeWidth: 1.5),
      ],
    ),
    ArchSymbol(
      id: 'door_sliding', name: 'Porte coulissante',
      category: SymbolCategory.doors, baseSize: Size(100, 25),
      paths: [
        SymbolPath(svgD: 'M0,0 L100,0 L100,8 L0,8 Z', filled: true),
        SymbolPath(svgD: 'M2,8 L60,8 L60,25 L2,25 Z', strokeWidth: 2.0),
        SymbolPath(svgD: 'M62,16 L95,16 M88,10 L95,16 L88,22', strokeWidth: 1.5),
      ],
    ),
    // ── FENÊTRES ──
    ArchSymbol(
      id: 'window_single', name: 'Fenêtre simple',
      category: SymbolCategory.windows, baseSize: Size(100, 20),
      paths: [
        SymbolPath(svgD: 'M0,0 L100,0 L100,20 L0,20 Z', filled: true),
        SymbolPath(svgD: 'M0,5 L100,5', strokeWidth: 1.5),
        SymbolPath(svgD: 'M0,15 L100,15', strokeWidth: 1.5),
        SymbolPath(svgD: 'M0,5 L100,15', strokeWidth: 0.8),
        SymbolPath(svgD: 'M0,15 L100,5', strokeWidth: 0.8),
      ],
    ),
    ArchSymbol(
      id: 'window_double', name: 'Fenêtre double',
      category: SymbolCategory.windows, baseSize: Size(140, 20),
      paths: [
        SymbolPath(svgD: 'M0,0 L140,0 L140,20 L0,20 Z', filled: true),
        SymbolPath(svgD: 'M0,5 L140,5', strokeWidth: 1.5),
        SymbolPath(svgD: 'M0,15 L140,15', strokeWidth: 1.5),
        SymbolPath(svgD: 'M70,0 L70,20', strokeWidth: 1.5),
        SymbolPath(svgD: 'M0,5 L70,15', strokeWidth: 0.8),
        SymbolPath(svgD: 'M70,5 L140,15', strokeWidth: 0.8),
      ],
    ),
    ArchSymbol(
      id: 'window_bay', name: 'Baie vitrée',
      category: SymbolCategory.windows, baseSize: Size(200, 20),
      paths: [
        SymbolPath(svgD: 'M0,0 L200,0 L200,20 L0,20 Z', filled: true),
        SymbolPath(svgD: 'M0,5 L200,5', strokeWidth: 2.0),
        SymbolPath(svgD: 'M0,15 L200,15', strokeWidth: 2.0),
        SymbolPath(svgD: 'M66,0 L66,20', strokeWidth: 1.0),
        SymbolPath(svgD: 'M133,0 L133,20', strokeWidth: 1.0),
      ],
    ),
    // ── SANITAIRES ──
    ArchSymbol(
      id: 'toilet', name: 'WC',
      category: SymbolCategory.sanitary, baseSize: Size(60, 80),
      paths: [
        SymbolPath(svgD: 'M5,5 L55,5 L55,30 L5,30 Z', strokeWidth: 2.0),
        SymbolPath(svgD: 'M8,30 Q5,75 30,78 Q55,75 52,30 Z', strokeWidth: 2.0),
        SymbolPath(svgD: 'M12,32 Q10,70 30,73 Q50,70 48,32 Z', strokeWidth: 1.2),
      ],
    ),
    ArchSymbol(
      id: 'sink_round', name: 'Lavabo rond',
      category: SymbolCategory.sanitary, baseSize: Size(60, 60),
      paths: [
        SymbolPath(svgD: 'M5,5 L55,5 L55,55 L5,55 Z', strokeWidth: 1.5),
        SymbolPath(svgD: 'M30,30 m-20,0 a20,20 0 1,1 40,0 a20,20 0 1,1 -40,0', strokeWidth: 2.0),
        SymbolPath(svgD: 'M27,12 L33,12 L33,18 L27,18 Z', filled: true),
        SymbolPath(svgD: 'M30,18 L30,22', strokeWidth: 1.5),
      ],
    ),
    ArchSymbol(
      id: 'bathtub', name: 'Baignoire',
      category: SymbolCategory.sanitary, baseSize: Size(170, 80),
      paths: [
        SymbolPath(svgD: 'M5,5 L165,5 L165,75 L5,75 Z', strokeWidth: 2.0),
        SymbolPath(svgD: 'M12,12 L158,12 L158,68 L12,68 Z', strokeWidth: 1.5),
        SymbolPath(svgD: 'M145,40 m-8,0 a8,8 0 1,1 16,0 a8,8 0 1,1 -16,0', strokeWidth: 1.2),
        SymbolPath(svgD: 'M22,40 m-6,0 a6,6 0 1,1 12,0 a6,6 0 1,1 -12,0', strokeWidth: 1.5),
      ],
    ),
    ArchSymbol(
      id: 'shower', name: 'Douche',
      category: SymbolCategory.sanitary, baseSize: Size(90, 90),
      paths: [
        SymbolPath(svgD: 'M5,5 L85,5 L85,85 L5,85 Z', strokeWidth: 2.0),
        SymbolPath(svgD: 'M45,45 m-6,0 a6,6 0 1,1 12,0 a6,6 0 1,1 -12,0', strokeWidth: 1.2),
        SymbolPath(svgD: 'M18,18 m-8,0 a8,8 0 1,1 16,0 a8,8 0 1,1 -16,0', strokeWidth: 1.5),
        SymbolPath(svgD: 'M18,26 L18,85', strokeWidth: 1.0),
      ],
    ),
    // ── VÉGÉTATION ──
    ArchSymbol(
      id: 'tree_plan', name: 'Arbre (plan)',
      category: SymbolCategory.vegetation, baseSize: Size(80, 80),
      paths: [
        SymbolPath(svgD: 'M40,5 A35,35 0 1,1 39.9,5 Z', strokeWidth: 1.5),
        SymbolPath(svgD: 'M40,40 L40,10', strokeWidth: 0.8),
        SymbolPath(svgD: 'M40,40 L15,25', strokeWidth: 0.8),
        SymbolPath(svgD: 'M40,40 L65,25', strokeWidth: 0.8),
        SymbolPath(svgD: 'M40,40 L20,60', strokeWidth: 0.8),
        SymbolPath(svgD: 'M40,40 L60,60', strokeWidth: 0.8),
        SymbolPath(svgD: 'M40,40 m-3,0 a3,3 0 1,1 6,0 a3,3 0 1,1 -6,0', filled: true),
      ],
    ),
    ArchSymbol(
      id: 'palm', name: 'Palmier (plan)',
      category: SymbolCategory.vegetation, baseSize: Size(80, 80),
      paths: [
        SymbolPath(svgD: 'M40,40 m-4,0 a4,4 0 1,1 8,0 a4,4 0 1,1 -8,0', filled: true),
        SymbolPath(svgD: 'M40,40 Q30,20 25,8', strokeWidth: 1.5),
        SymbolPath(svgD: 'M40,40 Q55,22 65,10', strokeWidth: 1.5),
        SymbolPath(svgD: 'M40,40 Q62,35 75,32', strokeWidth: 1.5),
        SymbolPath(svgD: 'M40,40 Q60,55 70,68', strokeWidth: 1.5),
        SymbolPath(svgD: 'M40,40 Q45,62 45,75', strokeWidth: 1.5),
        SymbolPath(svgD: 'M40,40 Q25,58 15,70', strokeWidth: 1.5),
        SymbolPath(svgD: 'M40,40 Q18,45 5,48', strokeWidth: 1.5),
        SymbolPath(svgD: 'M40,40 Q20,25 10,14', strokeWidth: 1.5),
      ],
    ),
    ArchSymbol(
      id: 'shrub', name: 'Arbuste',
      category: SymbolCategory.vegetation, baseSize: Size(50, 50),
      paths: [
        SymbolPath(svgD: 'M25,5 A20,20 0 1,1 24.9,5 Z', strokeWidth: 1.2),
        SymbolPath(svgD: 'M12,15 A10,10 0 1,1 11.9,15 Z', strokeWidth: 1.0),
        SymbolPath(svgD: 'M38,15 A10,10 0 1,1 37.9,15 Z', strokeWidth: 1.0),
        SymbolPath(svgD: 'M25,38 A10,10 0 1,1 24.9,38 Z', strokeWidth: 1.0),
      ],
    ),
    // ── ESCALIERS ──
    ArchSymbol(
      id: 'stairs_straight', name: 'Escalier droit',
      category: SymbolCategory.stairs, baseSize: Size(80, 200),
      paths: [
        SymbolPath(svgD: 'M5,5 L75,5 L75,195 L5,195 Z', strokeWidth: 2.0),
        SymbolPath(svgD: 'M5,24 L75,24', strokeWidth: 1.2),
        SymbolPath(svgD: 'M5,43 L75,43', strokeWidth: 1.2),
        SymbolPath(svgD: 'M5,62 L75,62', strokeWidth: 1.2),
        SymbolPath(svgD: 'M5,81 L75,81', strokeWidth: 1.2),
        SymbolPath(svgD: 'M5,100 L75,100', strokeWidth: 1.2),
        SymbolPath(svgD: 'M5,119 L75,119', strokeWidth: 1.2),
        SymbolPath(svgD: 'M5,138 L75,138', strokeWidth: 1.2),
        SymbolPath(svgD: 'M5,157 L75,157', strokeWidth: 1.2),
        SymbolPath(svgD: 'M5,176 L75,176', strokeWidth: 1.2),
        SymbolPath(svgD: 'M40,180 L40,15 M33,22 L40,15 L47,22', strokeWidth: 1.5),
      ],
    ),
    // ── STRUCTURE ──
    ArchSymbol(
      id: 'column_round', name: 'Poteau rond',
      category: SymbolCategory.structural, baseSize: Size(40, 40),
      paths: [
        SymbolPath(svgD: 'M20,20 m-18,0 a18,18 0 1,1 36,0 a18,18 0 1,1 -36,0', filled: true, strokeWidth: 2.0),
        SymbolPath(svgD: 'M20,20 m-12,0 a12,12 0 1,1 24,0 a12,12 0 1,1 -24,0', strokeWidth: 1.0),
      ],
    ),
    ArchSymbol(
      id: 'column_rect', name: 'Poteau carré',
      category: SymbolCategory.structural, baseSize: Size(40, 40),
      paths: [
        SymbolPath(svgD: 'M2,2 L38,2 L38,38 L2,38 Z', filled: true, strokeWidth: 2.0),
        SymbolPath(svgD: 'M2,2 L38,38 M38,2 L2,38', strokeWidth: 1.0),
      ],
    ),
    // ── ANNOTATION ──
    ArchSymbol(
      id: 'north_arrow', name: 'Nord',
      category: SymbolCategory.annotation, baseSize: Size(50, 70),
      paths: [
        SymbolPath(svgD: 'M25,5 L35,45 L25,38 L15,45 Z', filled: true, strokeWidth: 1.5),
        SymbolPath(svgD: 'M25,38 L25,65', strokeWidth: 1.5),
        SymbolPath(svgD: 'M25,35 m-20,0 a20,20 0 1,1 40,0 a20,20 0 1,1 -40,0', strokeWidth: 1.5),
      ],
    ),
    ArchSymbol(
      id: 'dimension_line', name: 'Ligne de cote',
      category: SymbolCategory.annotation, baseSize: Size(120, 30),
      paths: [
        SymbolPath(svgD: 'M10,15 L110,15', strokeWidth: 1.5),
        SymbolPath(svgD: 'M10,5 L10,25', strokeWidth: 1.5),
        SymbolPath(svgD: 'M110,5 L110,25', strokeWidth: 1.5),
        SymbolPath(svgD: 'M10,15 L20,10 M10,15 L20,20', strokeWidth: 1.2),
        SymbolPath(svgD: 'M110,15 L100,10 M110,15 L100,20', strokeWidth: 1.2),
      ],
    ),
    ArchSymbol(
      id: 'section_mark', name: 'Repère de coupe',
      category: SymbolCategory.annotation, baseSize: Size(100, 30),
      paths: [
        SymbolPath(svgD: 'M15,15 L85,15', strokeWidth: 1.5),
        SymbolPath(svgD: 'M15,15 m-12,0 a12,12 0 1,1 24,0 a12,12 0 1,1 -24,0', strokeWidth: 1.5),
        SymbolPath(svgD: 'M85,15 m-12,0 a12,12 0 1,1 24,0 a12,12 0 1,1 -24,0', strokeWidth: 1.5),
      ],
    ),
  ];

  static List<ArchSymbol> byCategory(SymbolCategory cat) =>
      all.where((s) => s.category == cat).toList();

  static List<ArchSymbol> search(String query) {
    final q = query.toLowerCase();
    return all.where((s) => s.name.toLowerCase().contains(q)).toList();
  }
}