import 'dart:math' as math;

/// Specialized clinical capabilities and contact model for emergency hospitals
class Hospital {
  final String id;
  final String name;
  final String banglaName;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final bool is24x7;
  final bool hasCathLab; // Primary PCI / Cardiac catheterization lab
  final bool hasStrokeThrombolysis; // Acute stroke center / tPA administration
  final bool hasICU;
  final String type; // 'government' or 'private'
  final String area;
  final String district;

  const Hospital({
    required this.id,
    required this.name,
    required this.banglaName,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    this.is24x7 = true,
    this.hasCathLab = false,
    this.hasStrokeThrombolysis = false,
    this.hasICU = true,
    this.type = 'government',
    this.area = 'Dhaka',
    this.district = 'Dhaka',
  });

  /// Calculates geodesic distance in kilometers using the Haversine formula
  double distanceTo(double userLat, double userLng) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(latitude - userLat);
    final dLon = _degreesToRadians(longitude - userLng);

    final lat1 = _degreesToRadians(userLat);
    final lat2 = _degreesToRadians(latitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Calculates estimated driving time in minutes for emergency response (avg ~25 km/h)
  int estimatedDrivingMinutes(double distanceKm) {
    if (distanceKm <= 0.2) return 2;
    final mins = (distanceKm * 2.4 + 2).round();
    return mins.clamp(2, 180);
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'banglaName': banglaName,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'is24x7': is24x7,
      'hasCathLab': hasCathLab,
      'hasStrokeThrombolysis': hasStrokeThrombolysis,
      'hasICU': hasICU,
      'type': type,
      'area': area,
      'district': district,
    };
  }

  factory Hospital.fromMap(Map<String, dynamic> map, String id) {
    return Hospital(
      id: id,
      name: map['name'] as String? ?? '',
      banglaName: map['banglaName'] as String? ?? '',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      is24x7: map['is24x7'] as bool? ?? true,
      hasCathLab: map['hasCathLab'] as bool? ?? false,
      hasStrokeThrombolysis: map['hasStrokeThrombolysis'] as bool? ?? false,
      hasICU: map['hasICU'] as bool? ?? true,
      type: map['type'] as String? ?? 'government',
      area: map['area'] as String? ?? 'Dhaka',
      district: map['district'] as String? ?? 'Dhaka',
    );
  }
}
