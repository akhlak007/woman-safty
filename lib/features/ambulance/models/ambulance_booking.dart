import '../../sos/models/emergency_case.dart';

enum AmbulanceType {
  bls('bls', 'Basic Life Support (BLS)'),
  als('als', 'Advanced Cardiac Life Support (ALS)');

  final String code;
  final String label;
  const AmbulanceType(this.code, this.label);

  static AmbulanceType fromCode(String code) {
    return AmbulanceType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AmbulanceType.bls,
    );
  }
}

enum AmbulanceStatus {
  requested('requested', 'Requested'),
  dispatched('dispatched', 'Dispatched'),
  enRoute('enRoute', 'On The Way'),
  arrived('arrived', 'Arrived On Scene'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  final String code;
  final String label;
  const AmbulanceStatus(this.code, this.label);

  static AmbulanceStatus fromCode(String code) {
    return AmbulanceStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AmbulanceStatus.requested,
    );
  }
}

class AmbulanceBooking {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String pickupAddress;
  final EmergencyLocation? pickupLocation;
  final String destinationHospital;
  final AmbulanceType ambulanceType;
  final AmbulanceStatus status;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleNumber;
  final int estimatedMinutes;
  final DateTime createdAt;

  const AmbulanceBooking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.pickupAddress,
    this.pickupLocation,
    required this.destinationHospital,
    required this.ambulanceType,
    required this.status,
    this.driverName,
    this.driverPhone,
    this.vehicleNumber,
    this.estimatedMinutes = 15,
    required this.createdAt,
  });

  AmbulanceBooking copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? pickupAddress,
    EmergencyLocation? pickupLocation,
    String? destinationHospital,
    AmbulanceType? ambulanceType,
    AmbulanceStatus? status,
    String? driverName,
    String? driverPhone,
    String? vehicleNumber,
    int? estimatedMinutes,
    DateTime? createdAt,
  }) {
    return AmbulanceBooking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationHospital: destinationHospital ?? this.destinationHospital,
      ambulanceType: ambulanceType ?? this.ambulanceType,
      status: status ?? this.status,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'pickupAddress': pickupAddress,
      'pickupLocation': pickupLocation?.toMap(),
      'destinationHospital': destinationHospital,
      'ambulanceType': ambulanceType.code,
      'status': status.code,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleNumber': vehicleNumber,
      'estimatedMinutes': estimatedMinutes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AmbulanceBooking.fromMap(Map<String, dynamic> map, String id) {
    return AmbulanceBooking(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userPhone: map['userPhone'] as String? ?? '',
      pickupAddress: map['pickupAddress'] as String? ?? '',
      pickupLocation: map['pickupLocation'] != null
          ? EmergencyLocation.fromMap(Map<String, dynamic>.from(map['pickupLocation'] as Map))
          : null,
      destinationHospital: map['destinationHospital'] as String? ?? '',
      ambulanceType: AmbulanceType.fromCode(map['ambulanceType'] as String? ?? 'bls'),
      status: AmbulanceStatus.fromCode(map['status'] as String? ?? 'requested'),
      driverName: map['driverName'] as String?,
      driverPhone: map['driverPhone'] as String?,
      vehicleNumber: map['vehicleNumber'] as String?,
      estimatedMinutes: map['estimatedMinutes'] as int? ?? 15,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
