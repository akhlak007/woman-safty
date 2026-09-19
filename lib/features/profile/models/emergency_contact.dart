/// SafeLife Verified Emergency Contact
class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relation;
  final int priority; // 1 = Primary, 2 = Secondary, etc.
  final bool verified; // Consent granted to receive live tracking
  final String? verificationCode;
  final DateTime createdAt;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
    this.priority = 1,
    this.verified = false,
    this.verificationCode,
    required this.createdAt,
  });

  static const List<String> commonRelations = [
    'Family',
    'Parent',
    'Spouse',
    'Sibling',
    'Child',
    'Friend',
    'Colleague',
    'Neighbor',
    'Doctor / Healthcare',
    'Other',
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relation': relation,
      'priority': priority,
      'verified': verified,
      'verificationCode': verificationCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map, String id) {
    return EmergencyContact(
      id: id,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      relation: map['relation'] as String? ?? 'Family',
      priority: (map['priority'] as num?)?.toInt() ?? 1,
      verified: map['verified'] as bool? ?? false,
      verificationCode: map['verificationCode'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  EmergencyContact copyWith({
    String? name,
    String? phone,
    String? relation,
    int? priority,
    bool? verified,
    String? verificationCode,
  }) {
    return EmergencyContact(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relation: relation ?? this.relation,
      priority: priority ?? this.priority,
      verified: verified ?? this.verified,
      verificationCode: verificationCode ?? this.verificationCode,
      createdAt: createdAt,
    );
  }
}
