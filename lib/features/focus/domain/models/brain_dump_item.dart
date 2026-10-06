/// Immutable domain model for unstructured thought offloading.
/// Allows rapid externalization of tasks, anxieties, or ideas before categorizing or parking them.
class BrainDumpItem {
  final String id;
  final String rawText;
  final bool isParked;
  final DateTime createdAt;

  const BrainDumpItem({
    required this.id,
    required this.rawText,
    this.isParked = false,
    required this.createdAt,
  });

  factory BrainDumpItem.create({
    required String rawText,
  }) {
    return BrainDumpItem(
      id: 'braindump_${DateTime.now().millisecondsSinceEpoch}_${rawText.hashCode.abs() % 1000}',
      rawText: rawText.trim(),
      isParked: false,
      createdAt: DateTime.now(),
    );
  }

  BrainDumpItem copyWith({
    String? id,
    String? rawText,
    bool? isParked,
    DateTime? createdAt,
  }) {
    return BrainDumpItem(
      id: id ?? this.id,
      rawText: rawText ?? this.rawText,
      isParked: isParked ?? this.isParked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rawText': rawText,
      'isParked': isParked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BrainDumpItem.fromJson(Map<String, dynamic> json) {
    return BrainDumpItem(
      id: json['id'] as String,
      rawText: json['rawText'] as String,
      isParked: json['isParked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrainDumpItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          rawText == other.rawText &&
          isParked == other.isParked;

  @override
  int get hashCode => id.hashCode ^ rawText.hashCode ^ isParked.hashCode;
}
