/// SafeLife User & Medical Profile
class UserProfile {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String? bloodGroup;
  final List<String> conditions;
  final List<String> medications;
  final List<String> allergies;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    this.bloodGroup,
    this.conditions = const [],
    this.medications = const [],
    this.allergies = const [],
    this.language = 'bn',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Common blood groups
  static const List<String> availableBloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  /// Standard chronic medical risk factors for emergency triage
  static const List<String> commonConditions = [
    'Hypertension (High BP)',
    'Diabetes Mellitus',
    'Coronary Artery Disease',
    'Prior Heart Attack',
    'Prior Stroke / TIA',
    'Asthma / COPD',
    'Kidney Disease',
    'Smoking History',
  ];

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'bloodGroup': bloodGroup,
      'conditions': conditions,
      'medications': medications,
      'allergies': allergies,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      bloodGroup: map['bloodGroup'] as String?,
      conditions: List<String>.from(map['conditions'] as List? ?? []),
      medications: List<String>.from(map['medications'] as List? ?? []),
      allergies: List<String>.from(map['allergies'] as List? ?? []),
      language: map['language'] as String? ?? 'bn',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    String? bloodGroup,
    List<String>? conditions,
    List<String>? medications,
    List<String>? allergies,
    String? language,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      conditions: conditions ?? this.conditions,
      medications: medications ?? this.medications,
      allergies: allergies ?? this.allergies,
      language: language ?? this.language,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
