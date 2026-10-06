/// Represents a trusted person or support contact that the user can reach out to
/// during moments of acute loneliness, isolation, or distress.
class ReachOutContact {
  const ReachOutContact({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.relationship = '',
    this.isSafetyPlanContact = false,
    this.displayOrder = 0,
    required this.createdAtUnix,
  });

  final String id;
  final String name;
  final String? phoneNumber;
  final String relationship;
  final bool isSafetyPlanContact;
  final int displayOrder;
  final int createdAtUnix;

  /// Display string with name and relationship qualifier.
  String get displaySubtitle {
    if (relationship.trim().isEmpty) {
      return isSafetyPlanContact ? 'Safety Plan contact' : 'Trusted person';
    }
    return isSafetyPlanContact ? '$relationship • Safety Plan' : relationship;
  }

  /// Whether this contact has a valid phone number for SMS/calls.
  bool get hasPhoneNumber => phoneNumber != null && phoneNumber!.trim().isNotEmpty;

  /// Adapter factory creating a [ReachOutContact] from a safety plan contact or dynamic object.
  factory ReachOutContact.fromSafetyPlanContact(dynamic contact) {
    return ReachOutContact(
      id: 'sp_${contact.id}',
      name: contact.name as String,
      phoneNumber: contact.phoneNumber as String?,
      relationship: (contact.relationship as String?) ?? '',
      isSafetyPlanContact: true,
      displayOrder: (contact.displayOrder as int?) ?? 0,
      createdAtUnix: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  ReachOutContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    bool? isSafetyPlanContact,
    int? displayOrder,
    int? createdAtUnix,
  }) {
    return ReachOutContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      isSafetyPlanContact: isSafetyPlanContact ?? this.isSafetyPlanContact,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAtUnix: createdAtUnix ?? this.createdAtUnix,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'isSafetyPlanContact': isSafetyPlanContact,
      'displayOrder': displayOrder,
      'createdAtUnix': createdAtUnix,
    };
  }

  factory ReachOutContact.fromJson(Map<String, dynamic> json) {
    return ReachOutContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      relationship: json['relationship'] as String? ?? '',
      isSafetyPlanContact: json['isSafetyPlanContact'] as bool? ?? false,
      displayOrder: json['displayOrder'] as int? ?? 0,
      createdAtUnix: json['createdAtUnix'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReachOutContact &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phoneNumber == other.phoneNumber &&
          relationship == other.relationship &&
          isSafetyPlanContact == other.isSafetyPlanContact &&
          displayOrder == other.displayOrder &&
          createdAtUnix == other.createdAtUnix;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      phoneNumber.hashCode ^
      relationship.hashCode ^
      isSafetyPlanContact.hashCode ^
      displayOrder.hashCode ^
      createdAtUnix.hashCode;
}
