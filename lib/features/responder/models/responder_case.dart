import '../../sos/models/emergency_case.dart';

enum ResponderStatus {
  pending,
  accepted,
  dispatched,
  onScene,
  resolved;

  String get label {
    switch (this) {
      case ResponderStatus.pending:
        return 'Pending Dispatch';
      case ResponderStatus.accepted:
        return 'Accepted';
      case ResponderStatus.dispatched:
        return 'Dispatched';
      case ResponderStatus.onScene:
        return 'On Scene';
      case ResponderStatus.resolved:
        return 'Resolved';
    }
  }

  String get banglaLabel {
    switch (this) {
      case ResponderStatus.pending:
        return 'অপেক্ষমাণ ডিসপ্যাচ';
      case ResponderStatus.accepted:
        return 'গৃহীত';
      case ResponderStatus.dispatched:
        return 'রওনা হয়েছে';
      case ResponderStatus.onScene:
        return 'ঘটনাস্থলে উপস্থিত';
      case ResponderStatus.resolved:
        return 'নিষ্পন্ন';
    }
  }
}

/// Operational responder tracking model linked to an active EmergencyCase
class ResponderCase {
  final String caseId;
  final EmergencyCase emergencyCase;
  final ResponderStatus status;
  final String? assignedUnit;
  final List<String> notes;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? resolvedAt;

  const ResponderCase({
    required this.caseId,
    required this.emergencyCase,
    this.status = ResponderStatus.pending,
    this.assignedUnit,
    this.notes = const [],
    this.acceptedAt,
    this.arrivedAt,
    this.resolvedAt,
  });

  ResponderCase copyWith({
    ResponderStatus? status,
    String? assignedUnit,
    List<String>? notes,
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? resolvedAt,
  }) {
    return ResponderCase(
      caseId: caseId,
      emergencyCase: emergencyCase,
      status: status ?? this.status,
      assignedUnit: assignedUnit ?? this.assignedUnit,
      notes: notes ?? this.notes,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'caseId': caseId,
      'emergencyCase': emergencyCase.toMap(),
      'status': status.name,
      'assignedUnit': assignedUnit,
      'notes': notes,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'arrivedAt': arrivedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory ResponderCase.fromEmergency(EmergencyCase eCase, {
    ResponderStatus status = ResponderStatus.pending,
    String? assignedUnit,
    List<String> notes = const [],
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? resolvedAt,
  }) {
    return ResponderCase(
      caseId: eCase.id,
      emergencyCase: eCase,
      status: status,
      assignedUnit: assignedUnit,
      notes: notes,
      acceptedAt: acceptedAt,
      arrivedAt: arrivedAt,
      resolvedAt: resolvedAt,
    );
  }
}
