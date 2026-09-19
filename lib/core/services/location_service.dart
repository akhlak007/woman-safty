import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../errors/app_exceptions.dart';
import '../../features/sos/models/emergency_case.dart';

class LocationService {
  const LocationService();

  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationException(
          'Location services are disabled on your device. Please enable GPS.',
        );
      }

      permission = await Geolocator.checkPermission();
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

  Future<EmergencyLocation?> getCurrentLocation() async {
    try {
      await checkAndRequestPermission();

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) return null;

      return EmergencyLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException('Could not retrieve current GPS position.', e.toString());
    }
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
