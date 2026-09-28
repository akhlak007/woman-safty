import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../errors/app_exceptions.dart';
import '../../features/sos/models/emergency_case.dart';

class LocationService {
  const LocationService();

  Future<bool> checkAndRequestPermission() async {
    try {
      if (!kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw const LocationException(
            'Location services are disabled on your device. Please enable GPS.',
          );
        }
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const LocationException(
            'Location permission was denied. Cannot determine emergency coordinates.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(
          'Location permissions are permanently denied. Please enable them in app settings.',
        );
      }

      return true;
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException('Failed to check location permissions.', e.toString());
    }
  }

  /// Attempts to get real-time location via GPS, with automatic real-time Network IP fallback
  Future<EmergencyLocation?> getCurrentLocation() async {
    // 1. Try high-precision device GPS / HTML5 browser geolocation
    try {
      await checkAndRequestPermission();

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 6),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        String? address;
        try {
          address = await reverseGeocode(position.latitude, position.longitude);
        } catch (_) {}

        return EmergencyLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          timestamp: position.timestamp,
          address: address,
        );
      }
    } catch (_) {
      // Hardware GPS unavailable, denied, or timed out - continue to network fallback
    }

    // 2. Real-time Network IP Geolocation (instant real-time coordinates on web & desktop)
    final netLoc = await getNetworkIpLocation();
    if (netLoc != null) {
      return netLoc;
    }

    return null;
  }

  /// Real-time IP-based geolocation fallback
  Future<EmergencyLocation?> getNetworkIpLocation() async {
    try {
      final response = await http
          .get(Uri.parse('http://ip-api.com/json'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'success') {
          final lat = (data['lat'] as num).toDouble();
          final lon = (data['lon'] as num).toDouble();
          final city = data['city'] as String? ?? 'Local City';
          final region = data['regionName'] as String? ?? '';
          final country = data['country'] as String? ?? 'Bangladesh';
          final address = [city, region, country].where((s) => s.isNotEmpty).join(', ');

          return EmergencyLocation(
            latitude: lat,
            longitude: lon,
            accuracy: 1000.0,
            timestamp: DateTime.now(),
            address: address,
          );
        }
      }
    } catch (_) {}

    // Secondary IP fallback
    try {
      final response = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final lat = (data['latitude'] as num?)?.toDouble();
        final lon = (data['longitude'] as num?)?.toDouble();
        if (lat != null && lon != null) {
          final city = data['city'] as String? ?? 'Local Area';
          final region = data['region'] as String? ?? '';
          final country = data['country_name'] as String? ?? 'Bangladesh';
          final address = [city, region, country].where((s) => s.isNotEmpty).join(', ');

          return EmergencyLocation(
            latitude: lat,
            longitude: lon,
            accuracy: 1000.0,
            timestamp: DateTime.now(),
            address: address,
          );
        }
      }
    } catch (_) {}

    return null;
  }

  /// Reverse geocode coordinates to human-readable street/area name using OpenStreetMap Nominatim
  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng',
      );
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'SafeLifeEmergencyApp/1.0',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final area = address['suburb'] ??
              address['neighbourhood'] ??
              address['village'] ??
              address['road'] ??
              address['county'] ??
              address['city'];
          final district = address['state_district'] ?? address['city'] ?? address['state'];
          if (area != null && district != null) {
            return '$area, $district';
          }
        }
        return data['display_name'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Stream<EmergencyLocation> getPositionStream({int intervalSeconds = 10}) {
    try {
      final settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        timeLimit: Duration(seconds: intervalSeconds),
      );

      return Geolocator.getPositionStream(locationSettings: settings)
          .map((position) => EmergencyLocation(
                latitude: position.latitude,
                longitude: position.longitude,
                accuracy: position.accuracy,
                timestamp: position.timestamp,
              ));
    } catch (e) {
      throw LocationException('Failed to start location stream.', e.toString());
    }
  }
}
