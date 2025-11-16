import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Returns the device location. Falls back to Dhaka, Bangladesh if permission denied.
  static Future<Position> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Try to open location settings so the user can enable the device location service.
      // Some devices require the user to enable the physical location/GPS setting in system settings
      // even after app permissions are granted.
      try {
        await Geolocator.openLocationSettings();
      } catch (_) {}

      // Give user a moment to enable service, then re-check.
      await Future.delayed(const Duration(seconds: 2));
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // fallback to Dhaka coordinates if still disabled
        return Position(
          latitude: 23.8103,
          longitude: 90.4125,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // fallback to Dhaka coordinates
      return Position(
        latitude: 23.8103,
        longitude: 90.4125,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      // If fetching current position fails for any reason, fallback to Dhaka.
      return Position(
        latitude: 23.8103,
        longitude: 90.4125,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }

  /// Location result with position and a human readable label (city, region, country).
  /// Uses reverse-geocoding to produce the label; label may be empty if reverse
  /// geocoding fails.
  static Future<LocationResult> getLocationWithLabel() async {
    final pos = await getLocation();
    String label = '';
    try {
      final places = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (places.isNotEmpty) {
        final p = places.first;
        final parts = <String>[];
        if (p.locality != null && p.locality!.isNotEmpty)
          parts.add(p.locality!);
        if (p.administrativeArea != null &&
            p.administrativeArea!.isNotEmpty &&
            (p.locality == null || p.administrativeArea != p.locality))
          parts.add(p.administrativeArea!);
        if (p.country != null && p.country!.isNotEmpty) parts.add(p.country!);
        label = parts.join(', ');
      }
    } catch (_) {
      label = '';
    }

    return LocationResult(position: pos, label: label);
  }
}

class LocationResult {
  final Position position;
  final String label;

  LocationResult({required this.position, required this.label});
}
