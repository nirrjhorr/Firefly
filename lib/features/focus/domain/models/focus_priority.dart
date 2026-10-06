/// Immutable domain model representing one of up to three active micro-intentions.
/// Enforces cognitive load throttling to prevent executive paralysis.
class FocusPriority {
  final String id;
  final String title;
  final bool isCompleted;
  final int orderIndex; // 0, 1, or 2
  final DateTime createdAt;
  final DateTime? completedAt;

  const FocusPriority({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.orderIndex,
    required this.createdAt,
    this.completedAt,
  });

  factory FocusPriority.create({
    required String title,
    required int orderIndex,
  }) {
    return FocusPriority(
      id: 'priority_${DateTime.now().millisecondsSinceEpoch}_$orderIndex',
      title: title.trim(),
      isCompleted: false,
      orderIndex: orderIndex.clamp(0, 2),
      createdAt: DateTime.now(),
    );
  }

  FocusPriority copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return FocusPriority(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'orderIndex': orderIndex,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory FocusPriority.fromJson(Map<String, dynamic> json) {
    return FocusPriority(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      orderIndex: json['orderIndex'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusPriority &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          isCompleted == other.isCompleted &&
          orderIndex == other.orderIndex;

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ isCompleted.hashCode ^ orderIndex.hashCode;
}
