import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Single contact target for rapid 1-tap crisis dispatch.
@immutable
class CrisisContact {
  const CrisisContact({
    required this.name,
    required this.phone,
    this.defaultMessage,
  });

  final String name;
  final String phone;
  final String? defaultMessage;

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        if (defaultMessage != null) 'defaultMessage': defaultMessage,
      };

  factory CrisisContact.fromJson(Map<String, dynamic> json) {
    return CrisisContact(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      defaultMessage: json['defaultMessage'] as String?,
    );
  }

  CrisisContact copyWith({
    String? name,
    String? phone,
    String? defaultMessage,
  }) {
    return CrisisContact(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      defaultMessage: defaultMessage ?? this.defaultMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrisisContact &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          phone == other.phone &&
          defaultMessage == other.defaultMessage;

  @override
  int get hashCode => Object.hash(name, phone, defaultMessage);
}

/// Dynamic crisis support configuration storing dedicated call and text targets.
@immutable
class CrisisSupportConfig {
  const CrisisSupportConfig({
    this.primaryCallContact,
    this.primaryTextContact,
  });

  final CrisisContact? primaryCallContact;
  final CrisisContact? primaryTextContact;

  bool get isConfigured =>
      (primaryCallContact != null && primaryCallContact!.phone.trim().isNotEmpty) ||
      (primaryTextContact != null && primaryTextContact!.phone.trim().isNotEmpty);

  static const defaultHelplines = CrisisSupportConfig(
    primaryCallContact: CrisisContact(
      name: '988 Lifeline',
      phone: '988',
    ),
    primaryTextContact: CrisisContact(
      name: '741741 Text Line',
      phone: '741741',
      defaultMessage: 'HOME',
    ),
  );

  Map<String, dynamic> toJson() => {
        if (primaryCallContact != null)
          'primaryCallContact': primaryCallContact!.toJson(),
        if (primaryTextContact != null)
          'primaryTextContact': primaryTextContact!.toJson(),
      };

  factory CrisisSupportConfig.fromJson(Map<String, dynamic> json) {
    return CrisisSupportConfig(
      primaryCallContact: json['primaryCallContact'] != null
          ? CrisisContact.fromJson(
              json['primaryCallContact'] as Map<String, dynamic>,
            )
          : null,
      primaryTextContact: json['primaryTextContact'] != null
          ? CrisisContact.fromJson(
              json['primaryTextContact'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  String serialize() => jsonEncode(toJson());

  static CrisisSupportConfig? deserialize(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return CrisisSupportConfig.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  CrisisSupportConfig copyWith({
    CrisisContact? primaryCallContact,
    CrisisContact? primaryTextContact,
    bool clearCall = false,
    bool clearText = false,
  }) {
    return CrisisSupportConfig(
      primaryCallContact: clearCall ? null : (primaryCallContact ?? this.primaryCallContact),
      primaryTextContact: clearText ? null : (primaryTextContact ?? this.primaryTextContact),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrisisSupportConfig &&
          runtimeType == other.runtimeType &&
          primaryCallContact == other.primaryCallContact &&
          primaryTextContact == other.primaryTextContact;

  @override
  int get hashCode => Object.hash(primaryCallContact, primaryTextContact);
}
