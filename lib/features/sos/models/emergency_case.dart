import '../../../core/constants/alert_constants.dart';

enum EmergencyStatus {
  active('active', 'Active'),
  resolved('resolved', 'Resolved'),
  cancelled('cancelled', 'Cancelled'),
  falseAlarm('false_alarm', 'False Alarm');

  final String code;
  final String label;
  const EmergencyStatus(this.code, this.label);

  static EmergencyStatus fromCode(String code) {
    return EmergencyStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => EmergencyStatus.active,
    );
  }
}

class EmergencyLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final String? address;

  const EmergencyLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.address,
  });

  String get googleMapsUrl =>
      'https://maps.google.com/?q=$latitude,$longitude';

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
      'googleMapsUrl': googleMapsUrl,
    };
  }

  factory EmergencyLocation.fromMap(Map<String, dynamic> map) {
    return EmergencyLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      address: map['address'] as String?,
    );
  }
}

class ContactAlertRecord {
  final String contactId;
  final String contactName;
  final String contactPhone;
  final String channel; // 'fcm' or 'sms'
  final String status; // 'sent', 'delivered', 'acked', 'failed'
  final DateTime timestamp;

  const ContactAlertRecord({
    required this.contactId,
    required this.contactName,
    required this.contactPhone,
    required this.channel,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'contactId': contactId,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'channel': channel,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ContactAlertRecord.fromMap(Map<String, dynamic> map) {
    return ContactAlertRecord(
      contactId: map['contactId'] as String? ?? '',
      contactName: map['contactName'] as String? ?? '',
      contactPhone: map['contactPhone'] as String? ?? '',
      channel: map['channel'] as String? ?? 'sms',
      status: map['status'] as String? ?? 'sent',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class EmergencyCase {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final EmergencyType type;
  final RiskLevel riskLevel;
  final AlertLevel alertLevel;
  final EmergencyStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final EmergencyLocation? lastKnownLocation;
  final String triggerSource;
  final Map<String, dynamic> triageAnswers;
  final List<ContactAlertRecord> contactAlerts;

  const EmergencyCase({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.type,
    required this.riskLevel,
    required this.alertLevel,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.lastKnownLocation,
    this.triggerSource = 'sos_button',
    this.triageAnswers = const {},
    this.contactAlerts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'type': type.code,
      'riskLevel': riskLevel.name,
      'alertLevel': alertLevel.value,
      'status': status.code,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'lastKnownLocation': lastKnownLocation?.toMap(),
      'triggerSource': triggerSource,
      'triageAnswers': triageAnswers,
      'contactAlerts': contactAlerts.map((a) => a.toMap()).toList(),
    };
  }

  factory EmergencyCase.fromMap(Map<String, dynamic> map, String id) {
    return EmergencyCase(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userPhone: map['userPhone'] as String? ?? '',
      type: EmergencyType.values.firstWhere(
        (t) => t.code == map['type'],
        orElse: () => EmergencyType.safety,
      ),
      riskLevel: RiskLevel.values.firstWhere(
        (r) => r.name == map['riskLevel'],
        orElse: () => RiskLevel.high,
      ),
      alertLevel: AlertLevel.values.firstWhere(
        (a) => a.value == map['alertLevel'],
        orElse: () => AlertLevel.emergencyContactAlert,
      ),
      status: EmergencyStatus.fromCode(map['status'] as String? ?? 'active'),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.tryParse(map['resolvedAt'] as String)
          : null,
      lastKnownLocation: map['lastKnownLocation'] != null
          ? EmergencyLocation.fromMap(
              Map<String, dynamic>.from(map['lastKnownLocation'] as Map),
            )
          : null,
      triggerSource: map['triggerSource'] as String? ?? 'sos_button',
      triageAnswers: Map<String, dynamic>.from(map['triageAnswers'] as Map? ?? {}),
      contactAlerts: (map['contactAlerts'] as List? ?? [])
          .map((item) => ContactAlertRecord.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  EmergencyCase copyWith({
    EmergencyStatus? status,
    DateTime? resolvedAt,
    EmergencyLocation? lastKnownLocation,
    List<ContactAlertRecord>? contactAlerts,
  }) {
    return EmergencyCase(
      id: id,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      type: type,
      riskLevel: riskLevel,
      alertLevel: alertLevel,
      status: status ?? this.status,
      createdAt: createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
      triggerSource: triggerSource,
      triageAnswers: triageAnswers,
      contactAlerts: contactAlerts ?? this.contactAlerts,
    );
  }
}
