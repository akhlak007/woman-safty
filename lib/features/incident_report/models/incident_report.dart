import '../../sos/models/emergency_case.dart';

/// Confidential harassment and safety incident report
class IncidentReport {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String category; // 'harassment', 'stalking', 'threat', 'suspicious'
  final String description;
  final EmergencyLocation? location;
  final DateTime createdAt;

  const IncidentReport({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.category,
    required this.description,
    this.location,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'category': category,
      'description': description,
      'location': location?.toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory IncidentReport.fromMap(Map<String, dynamic> map, String id) {
    return IncidentReport(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userPhone: map['userPhone'] as String? ?? '',
      category: map['category'] as String? ?? 'harassment',
      description: map['description'] as String? ?? '',
      location: map['location'] != null
          ? EmergencyLocation.fromMap(Map<String, dynamic>.from(map['location'] as Map))
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
