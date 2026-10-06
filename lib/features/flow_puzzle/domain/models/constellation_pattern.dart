/// A normalized coordinate node representing a star in a constellation pattern.
class ConstellationNode {
  const ConstellationNode({
    required this.id,
    required this.x,
    required this.y,
    required this.label,
  });

  /// 1-based sequential order of this node.
  final int id;

  /// Normalized x-coordinate between 0.0 and 1.0.
  final double x;

  /// Normalized y-coordinate between 0.0 and 1.0.
  final double y;

  /// Human-friendly display label (e.g. '1', '2', or a star name).
  final String label;

  Map<String, dynamic> toJson() => {
        'id': id,
        'x': x,
        'y': y,
        'label': label,
      };

  factory ConstellationNode.fromJson(Map<String, dynamic> json) =>
      ConstellationNode(
        id: json['id'] as int,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        label: json['label'] as String,
      );
}

/// A curated celestial or natural path pattern for gentle connect-the-dots flow.
class ConstellationPattern {
  const ConstellationPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.story,
    required this.nodes,
  });

  final String id;
  final String name;
  final String description;
  final String story;
  final List<ConstellationNode> nodes;

  int get nodeCount => nodes.length;

  static ConstellationPattern fromString(String id) {
    return kCuratedConstellations.firstWhere(
      (c) => c.id.toLowerCase() == id.toLowerCase(),
      orElse: () => kCuratedConstellations.first,
    );
  }
}

/// Curated soothing constellation patterns designed for non-clinical attention absorption.
const List<ConstellationPattern> kCuratedConstellations = [
  ConstellationPattern(
    id: 'cassiopeia',
    name: 'Cassiopeia',
    description: 'The ancient five-star crown resting in the north.',
    story: 'Five brilliant stars forming a gentle zig-zag that glides through the night sky.',
    nodes: [
      ConstellationNode(id: 1, x: 0.20, y: 0.65, label: '1'),
      ConstellationNode(id: 2, x: 0.35, y: 0.35, label: '2'),
      ConstellationNode(id: 3, x: 0.52, y: 0.55, label: '3'),
      ConstellationNode(id: 4, x: 0.68, y: 0.30, label: '4'),
      ConstellationNode(id: 5, x: 0.82, y: 0.50, label: '5'),
    ],
  ),
  ConstellationPattern(
    id: 'northern_crown',
    name: 'Corona Borealis',
    description: 'A tranquil semi-circle of celestial pearls.',
    story: 'Seven stars curved into a gentle arc, creating a quiet celestial wreath.',
    nodes: [
      ConstellationNode(id: 1, x: 0.18, y: 0.60, label: '1'),
      ConstellationNode(id: 2, x: 0.26, y: 0.44, label: '2'),
      ConstellationNode(id: 3, x: 0.38, y: 0.34, label: '3'),
      ConstellationNode(id: 4, x: 0.50, y: 0.30, label: '4'),
      ConstellationNode(id: 5, x: 0.62, y: 0.34, label: '5'),
      ConstellationNode(id: 6, x: 0.74, y: 0.44, label: '6'),
      ConstellationNode(id: 7, x: 0.82, y: 0.60, label: '7'),
    ],
  ),
  ConstellationPattern(
    id: 'cygnus_swan',
    name: 'Cygnus the Swan',
    description: 'The tranquil glider spanning the starry river.',
    story: 'A serene cross formation representing a swan gliding peacefully across the Milky Way.',
    nodes: [
      ConstellationNode(id: 1, x: 0.50, y: 0.20, label: '1'), // Tail (Deneb)
      ConstellationNode(id: 2, x: 0.50, y: 0.45, label: '2'), // Center (Sadr)
      ConstellationNode(id: 3, x: 0.22, y: 0.42, label: '3'), // West wing
      ConstellationNode(id: 4, x: 0.78, y: 0.42, label: '4'), // East wing
      ConstellationNode(id: 5, x: 0.50, y: 0.68, label: '5'), // Body
      ConstellationNode(id: 6, x: 0.50, y: 0.82, label: '6'), // Head (Albireo)
    ],
  ),
  ConstellationPattern(
    id: 'pleiades',
    name: 'The Pleiades Cluster',
    description: 'The seven quiet sisters wrapped in gentle blue dust.',
    story: 'A luminous cluster of close stars that guides wanderers through quiet winter nights.',
    nodes: [
      ConstellationNode(id: 1, x: 0.30, y: 0.55, label: '1'),
      ConstellationNode(id: 2, x: 0.40, y: 0.45, label: '2'),
      ConstellationNode(id: 3, x: 0.52, y: 0.40, label: '3'),
      ConstellationNode(id: 4, x: 0.65, y: 0.42, label: '4'),
      ConstellationNode(id: 5, x: 0.72, y: 0.52, label: '5'),
      ConstellationNode(id: 6, x: 0.60, y: 0.62, label: '6'),
      ConstellationNode(id: 7, x: 0.44, y: 0.60, label: '7'),
    ],
  ),
  ConstellationPattern(
    id: 'lotus_blossom',
    name: 'Lotus Blossom',
    description: 'A harmonious natural geometry opening petal by petal.',
    story: 'A meditative water bloom rising above still waters in gentle symmetry.',
    nodes: [
      ConstellationNode(id: 1, x: 0.50, y: 0.78, label: '1'), // Base stem
      ConstellationNode(id: 2, x: 0.30, y: 0.65, label: '2'), // Left base
      ConstellationNode(id: 3, x: 0.22, y: 0.45, label: '3'), // Outer left
      ConstellationNode(id: 4, x: 0.38, y: 0.32, label: '4'), // Inner left
      ConstellationNode(id: 5, x: 0.50, y: 0.22, label: '5'), // Center crest
      ConstellationNode(id: 6, x: 0.62, y: 0.32, label: '6'), // Inner right
      ConstellationNode(id: 7, x: 0.78, y: 0.45, label: '7'), // Outer right
      ConstellationNode(id: 8, x: 0.70, y: 0.65, label: '8'), // Right base
    ],
  ),
  ConstellationPattern(
    id: 'river_stone',
    name: 'River Pebble',
    description: 'The smooth, softened outline of a stone rounded by clear waters.',
    story: 'Countless seasons of gentle water flowing past stone, leaving only peace and smoothness.',
    nodes: [
      ConstellationNode(id: 1, x: 0.32, y: 0.35, label: '1'),
      ConstellationNode(id: 2, x: 0.68, y: 0.32, label: '2'),
      ConstellationNode(id: 3, x: 0.82, y: 0.52, label: '3'),
      ConstellationNode(id: 4, x: 0.70, y: 0.72, label: '4'),
      ConstellationNode(id: 5, x: 0.30, y: 0.70, label: '5'),
      ConstellationNode(id: 6, x: 0.18, y: 0.50, label: '6'),
    ],
  ),
];
